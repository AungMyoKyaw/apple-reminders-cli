import Foundation
import EventKit
import ArgumentParser

// MARK: - Models

/// Shared EventKit store manager
struct ReminderEntry: Codable {
    let id: String
    let title: String
    let notes: String?
    let dueDate: String?
    let priority: Int
    let isCompleted: Bool
    let list: String
    let url: String?
    let creationDate: String?
    let lastModifiedDate: String?
}

class ReminderStore {
    let eventStore = EKEventStore()
    
    func requestAccess() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var hasAccess = false
        
        eventStore.requestAccess(to: .reminder) { granted, error in
            hasAccess = granted
            semaphore.signal()
        }
        
        semaphore.wait()
        return hasAccess
    }
    
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .reminder)
    }
    
    func findCalendar(named name: String) -> EKCalendar? {
        return getCalendars().first { $0.title.localizedCaseInsensitiveContains(name) }
    }
    
    func fetchReminders(in calendars: [EKCalendar], completion: @escaping ([EKReminder]) -> Void) {
        let predicate = eventStore.predicateForReminders(in: calendars)
        eventStore.fetchReminders(matching: predicate) { reminders in
            completion(reminders ?? [])
        }
    }
    
    func findReminder(named name: String, in listName: String?) -> EKReminder? {
        let calendars = listName != nil ?
            getCalendars().filter { $0.title.localizedCaseInsensitiveContains(listName!) } :
            getCalendars()
        
        let semaphore = DispatchSemaphore(value: 0)
        var foundReminder: EKReminder?
        
        for calendar in calendars {
            let predicate = eventStore.predicateForReminders(in: [calendar])
            eventStore.fetchReminders(matching: predicate) { reminders in
                if let reminder = reminders?.first(where: { reminder in
                    // First try exact match in title
                    if reminder.title.localizedCaseInsensitiveContains(name) {
                        return true
                    }
                    return false
                }) {
                    foundReminder = reminder
                }
                semaphore.signal()
            }
            semaphore.wait()
            if foundReminder != nil { break }
        }
        
        return foundReminder
    }
}

// MARK: - CLI Tool

struct ReminderCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "reminder",
        abstract: "A CLI tool for interacting with Apple Reminders",
        version: "3.0.2",
        subcommands: [List.self, Create.self, Update.self, Show.self, Complete.self, Delete.self, Search.self, Stats.self]
    )

    // MARK: - List Command

    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "List reminders from a list")

        @Argument(help: "List name (optional, shows all if omitted)")
        var listName: String?

        @Flag(name: .shortAndLong, help: "Show completed reminders")
        var all = false

        @Flag(name: .shortAndLong, help: "Show only uncompleted reminders")
        var uncompletedOnly = false

        @Flag(name: .long, help: "Show only reminders with URLs")
        var hasUrl = false
        
        @Option(name: .shortAndLong, help: "Filter by priority (high/medium/low/none)")
        var priority: String?

        @Flag(name: .long, help: "Show only reminders with alarms")
        var hasAlarms = false

        @Flag(name: .shortAndLong, help: "Output in JSON format")
        var json = false

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            let calendars: [EKCalendar]
            if let listName = listName {
                if let calendar = store.findCalendar(named: listName) {
                    calendars = [calendar]
                } else {
                    print("Error: List '\(listName)' not found.")
                    return
                }
            } else {
                calendars = store.getCalendars()
            }

            store.fetchReminders(in: calendars) { reminders in
                self.printReminders(from: reminders, store: store)
                Darwin.exit(0)
            }
            
            RunLoop.main.run()
        }

        func printReminders(from reminders: [EKReminder], store: ReminderStore) {
            let isoFormatter = ISO8601DateFormatter()
            var filtered = reminders
            
            if uncompletedOnly {
                filtered = filtered.filter { !$0.isCompleted }
            } else if !all {
                filtered = filtered.filter { !$0.isCompleted }
            }
            
            if hasUrl {
                filtered = filtered.filter { $0.url != nil }
            }
            
            if hasAlarms {
                filtered = filtered.filter { $0.hasAlarms }
            }
            
            if let priorityStr = priority, let priorityValue = EKReminder.parsePriority(priorityStr) {
                filtered = filtered.filter { $0.priority == priorityValue }
            }

            if json {
                let entries = filtered.map { r in
                    ReminderEntry(
                        id: r.calendarItemExternalIdentifier ?? r.calendarItemIdentifier,
                        title: r.title,
                        notes: r.notes,
                        dueDate: r.dueDateComponents?.date.flatMap { isoFormatter.string(from: $0) },
                        priority: Int(r.priority),
                        isCompleted: r.isCompleted,
                        list: r.calendar?.title ?? "Unknown",
                        url: r.url?.absoluteString,
                        creationDate: r.creationDate.flatMap { isoFormatter.string(from: $0) },
                        lastModifiedDate: r.lastModifiedDate.flatMap { isoFormatter.string(from: $0) }
                    )
                }
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                if let data = try? encoder.encode(entries), let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                return
            }

            if filtered.isEmpty {
                print("No reminders found.")
                return
            }

            let sortedReminders = filtered.sorted { r1, r2 in
                if r1.isCompleted != r2.isCompleted {
                    return !r1.isCompleted
                }
                if let d1 = r1.dueDateComponents?.date, let d2 = r2.dueDateComponents?.date {
                    return d1 < d2
                }
                return r1.title.localizedCaseInsensitiveCompare(r2.title) == .orderedAscending
            }

            let grouped = Dictionary(grouping: sortedReminders) { $0.calendar.title }
            for (calendarName, calendarReminders) in grouped.sorted(by: { $0.key < $1.key }) {
                print("\n=== \(calendarName) (\(calendarReminders.count)) ===")
                for reminder in calendarReminders {
                    let status = reminder.isCompleted ? "☑" : "☐"
                    var output = "\(status) \(reminder.prioritySymbol) \(reminder.title ?? "Untitled")"
                    
                    if let dueDate = reminder.dueDateComponents?.date {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        output += " (Due: \(formatter.string(from: dueDate)))"
                    }
                    
                    if reminder.url != nil {
                        output += " 🔗"
                    }
                    
                    print(output)
                }
            }
        }
    }

    // MARK: - Create Command

    struct Create: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Create a new reminder")

        @Argument(help: "Reminder title")
        var title: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

        @Option(name: .long, help: "Start date (YYYY-MM-DD)")
        var startDate: String?

        @Option(name: .long, help: "Due date (YYYY-MM-DD)")
        var dueDate: String?

        @Option(name: .long, help: "Priority (high/medium/low/none)")
        var priority: String?

        @Option(name: .long, help: "Notes")
        var notes: String?

        @Option(name: .long, help: "URL")
        var url: String?

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            let calendars = store.getCalendars()
            let targetCalendar: EKCalendar

            if let listName = listName {
                if let calendar = store.findCalendar(named: listName) {
                    targetCalendar = calendar
                } else {
                    print("Error: List '\(listName)' not found.")
                    return
                }
            } else {
                guard let defaultCalendar = store.eventStore.defaultCalendarForNewReminders() ?? calendars.first else {
                    print("Error: No reminder lists available.")
                    return
                }
                targetCalendar = defaultCalendar
            }

            let reminder = EKReminder(eventStore: store.eventStore)
            reminder.title = title
            reminder.calendar = targetCalendar

            if let startDateStr = startDate, let date = DateParser.parse(startDateStr) {
                reminder.startDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            }

            if let dueDateStr = dueDate, let date = DateParser.parse(dueDateStr) {
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            }

            if let priorityStr = priority, let priorityValue = EKReminder.parsePriority(priorityStr) {
                reminder.priority = priorityValue
            }

            if let notesStr = notes {
                reminder.notes = notesStr
            }

            if let urlStr = url, let urlObj = URL(string: urlStr) {
                reminder.url = urlObj
            }

            do {
                try store.eventStore.save(reminder, commit: true)
                print("✅ Created reminder: \(title) in list \(targetCalendar.title)")
            } catch {
                print("Error saving reminder: \(error)")
            }
        }
    }

    // MARK: - Update Command

    struct Update: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Update an existing reminder")

        @Argument(help: "Reminder name to update")
        var name: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

        @Option(name: .long, help: "New title")
        var newTitle: String?

        @Option(name: .long, help: "New due date (YYYY-MM-DD, or 'remove')")
        var newDueDate: String?

        @Option(name: .long, help: "New notes")
        var newNotes: String?

        @Option(name: .long, help: "New priority (high/medium/low/none)")
        var newPriority: String?

        @Option(name: .long, help: "New URL (or 'remove')")
        var newUrl: String?

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            guard let reminder = store.findReminder(named: name, in: listName) else {
                print("❌ Reminder not found: \(name)")
                return
            }

            var updated = false

            if let title = newTitle {
                reminder.title = title
                updated = true
            }

            if let dueDateStr = newDueDate {
                if dueDateStr.lowercased() == "remove" || dueDateStr.lowercased() == "none" {
                    reminder.dueDateComponents = nil
                    updated = true
                } else if let date = DateParser.parse(dueDateStr) {
                    reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    updated = true
                }
            }

            if let notes = newNotes {
                reminder.notes = notes
                updated = true
            }

            if let priorityStr = newPriority, let priorityValue = EKReminder.parsePriority(priorityStr) {
                reminder.priority = priorityValue
                updated = true
            }

            if let urlStr = newUrl {
                if urlStr.lowercased() == "remove" {
                    reminder.url = nil
                } else {
                    reminder.url = URL(string: urlStr)
                }
                updated = true
            }

            if updated {
                do {
                    try store.eventStore.save(reminder, commit: true)
                    print("✅ Updated reminder: \(reminder.title ?? "Untitled")")
                } catch {
                    print("Error updating reminder: \(error)")
                }
            } else {
                print("No changes specified.")
            }
        }
    }

    // MARK: - Show Command

    struct Show: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Show details of a reminder")

        @Argument(help: "Reminder name")
        var name: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?
        
        @Flag(name: .shortAndLong, help: "Output in JSON format")
        var json = false

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            guard let reminder = store.findReminder(named: name, in: listName) else {
                print("❌ Reminder not found: \(name)")
                return
            }

            if json {
                let isoFormatter = ISO8601DateFormatter()
                let entry = ReminderEntry(
                    id: reminder.calendarItemExternalIdentifier ?? reminder.calendarItemIdentifier,
                    title: reminder.title,
                    notes: reminder.notes,
                    dueDate: reminder.dueDateComponents?.date.flatMap { isoFormatter.string(from: $0) },
                    priority: Int(reminder.priority),
                    isCompleted: reminder.isCompleted,
                    list: reminder.calendar?.title ?? "Unknown",
                    url: reminder.url?.absoluteString,
                    creationDate: reminder.creationDate.flatMap { isoFormatter.string(from: $0) },
                    lastModifiedDate: reminder.lastModifiedDate.flatMap { isoFormatter.string(from: $0) }
                )
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                if let data = try? encoder.encode(entry), let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                return
            }

            print("=== Reminder Details ===")
            print("Title: \(reminder.title ?? "Untitled")")
            print("List: \(reminder.calendar.title)")
            print("Status: \(reminder.isCompleted ? "Completed" : "Uncompleted")")
            if let dueDate = reminder.dueDateComponents?.date {
                print("Due Date: \(dueDate)")
            }
            if let notes = reminder.notes {
                print("Notes: \(notes)")
            }
            if let url = reminder.url {
                print("URL: \(url)")
            }
            print("Priority: \(reminder.prioritySymbol)")
        }
    }

    // MARK: - Complete Command

    struct Complete: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Mark reminders as completed")

        @Argument(help: "Reminder names to complete")
        var names: [String]

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            for name in names {
                guard let reminder = store.findReminder(named: name, in: listName) else {
                    print("❌ Reminder not found: \(name)")
                    continue
                }
                
                if reminder.isCompleted {
                    print("ℹ️  Already completed: \(reminder.title ?? name)")
                    continue
                }

                reminder.isCompleted = true
                reminder.completionDate = Date()

                do {
                    try store.eventStore.save(reminder, commit: true)
                    print("✅ Completed: \(reminder.title ?? name)")
                } catch {
                    print("Error completing '\(name)': \(error)")
                }
            }
        }
    }

    // MARK: - Delete Command

    struct Delete: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Delete reminders")

        @Argument(help: "Reminder names to delete")
        var names: [String]

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            for name in names {
                guard let reminder = store.findReminder(named: name, in: listName) else {
                    print("❌ Reminder not found: \(name)")
                    continue
                }

                do {
                    try store.eventStore.remove(reminder, commit: true)
                    print("🗑️  Deleted: \(reminder.title ?? name)")
                } catch {
                    print("Error deleting '\(name)': \(error)")
                }
            }
        }
    }

    // MARK: - Search Command

    struct Search: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Search for reminders")

        @Argument(help: "Search query")
        var query: String?

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

        @Option(name: .long, help: "Filter by priority (high/medium/low/none)")
        var priority: String?

        @Flag(name: .long, help: "Show only reminders with URLs")
        var hasUrl = false

        @Flag(name: .long, help: "Show only reminders with notes")
        var hasNotes = false

        @Flag(name: .long, help: "Show only reminders with alarms")
        var hasAlarms = false

        @Option(name: .long, help: "Due before this date")
        var dueBefore: String?

        @Option(name: .long, help: "Due after this date")
        var dueAfter: String?

        @Flag(name: .long, help: "Show only overdue reminders")
        var overdue = false

        @Flag(name: .long, help: "Show only completed reminders")
        var completed = false

        @Flag(name: .long, help: "Show only uncompleted reminders")
        var uncompleted = false

        @Option(name: .long, help: "Filter by tag")
        var tag: String?

        @Flag(name: .shortAndLong, help: "Output in JSON format")
        var json = false

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            let calendars = listName != nil ?
                store.getCalendars().filter { $0.title.localizedCaseInsensitiveContains(listName!) } :
                store.getCalendars()
            
            var allReminders: [EKReminder] = []
            let semaphore = DispatchSemaphore(value: 0)
            
            store.fetchReminders(in: calendars) { reminders in
                allReminders = reminders
                semaphore.signal()
            }
            semaphore.wait()

            var filtered = allReminders

            if let query = query {
                filtered = filtered.filter { 
                    $0.title.localizedCaseInsensitiveContains(query) || 
                    ($0.notes?.localizedCaseInsensitiveContains(query) ?? false)
                }
            }

            if let priorityStr = priority, let priorityValue = EKReminder.parsePriority(priorityStr) {
                filtered = filtered.filter { $0.priority == priorityValue }
            }

            if hasUrl {
                filtered = filtered.filter { $0.url != nil }
            }

            if hasNotes {
                filtered = filtered.filter { $0.notes != nil && !$0.notes!.isEmpty }
            }

            if hasAlarms {
                filtered = filtered.filter { $0.hasAlarms }
            }

            if completed {
                filtered = filtered.filter { $0.isCompleted }
            }

            if uncompleted {
                filtered = filtered.filter { !$0.isCompleted }
            }

            if overdue {
                let now = Date()
                filtered = filtered.filter { !$0.isCompleted && $0.dueDateComponents?.date ?? .distantFuture < now }
            }

            if let tagStr = tag {
                filtered = filtered.filter { 
                    $0.title.contains(tagStr) || ($0.notes?.contains(tagStr) ?? false)
                }
            }

            if let dueBeforeStr = dueBefore, let date = DateParser.parse(dueBeforeStr) {
                filtered = filtered.filter { $0.dueDateComponents?.date ?? .distantFuture < date }
            }

            if let dueAfterStr = dueAfter, let date = DateParser.parse(dueAfterStr) {
                filtered = filtered.filter { $0.dueDateComponents?.date ?? .distantPast > date }
            }

            if json {
                let isoFormatter = ISO8601DateFormatter()
                let entries = filtered.map { r in
                    ReminderEntry(
                        id: r.calendarItemExternalIdentifier ?? r.calendarItemIdentifier,
                        title: r.title,
                        notes: r.notes,
                        dueDate: r.dueDateComponents?.date.flatMap { isoFormatter.string(from: $0) },
                        priority: Int(r.priority),
                        isCompleted: r.isCompleted,
                        list: r.calendar?.title ?? "Unknown",
                        url: r.url?.absoluteString,
                        creationDate: r.creationDate.flatMap { isoFormatter.string(from: $0) },
                        lastModifiedDate: r.lastModifiedDate.flatMap { isoFormatter.string(from: $0) }
                    )
                }
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                if let data = try? encoder.encode(entries), let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                return
            }

            if filtered.isEmpty {
                print("No reminders found.")
                return
            }

            for reminder in filtered {
                print("\(reminder.isCompleted ? "☑" : "☐") \(reminder.title ?? "Untitled") [\(reminder.calendar.title)]")
            }
        }
    }

    // MARK: - Stats Command

    struct Stats: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Show statistics about reminders")

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            store.fetchReminders(in: store.getCalendars()) { reminders in
                let total = reminders.count
                let completed = reminders.filter { $0.isCompleted }.count
                let uncompleted = total - completed
                
                print("=== Reminders Stats ===")
                print("Total: \(total)")
                print("Completed: \(completed)")
                print("Uncompleted: \(uncompleted)")
                Darwin.exit(0)
            }
            
            RunLoop.main.run()
        }
    }
}

// MARK: - Helpers

struct DateParser {
    static func parse(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: string) {
            return date
        }
        
        let lowercased = string.lowercased()
        if lowercased == "today" {
            return Date()
        } else if lowercased == "tomorrow" {
            return Calendar.current.date(byAdding: .day, value: 1, to: Date())
        }
        
        return nil
    }
}

extension EKReminder {
    static func parsePriority(_ string: String) -> Int? {
        switch string.lowercased() {
        case "high": return Int(EKReminderPriority.high.rawValue)
        case "medium": return Int(EKReminderPriority.medium.rawValue)
        case "low": return Int(EKReminderPriority.low.rawValue)
        case "none": return Int(EKReminderPriority.none.rawValue)
        default: return nil
        }
    }
    
    var prioritySymbol: String {
        switch priority {
        case Int(EKReminderPriority.high.rawValue): return "!!!"
        case Int(EKReminderPriority.medium.rawValue): return "!!"
        case Int(EKReminderPriority.low.rawValue): return "!"
        default: return ""
        }
    }
}

ReminderCLI.main()
