//
//  main.swift
//  apple-reminders-cli
//
//  Created by Aung Myo Kyaw on 10/20/25.
//

import Foundation
import EventKit
import ArgumentParser

// MARK: - Shared Utilities

/// Shared EventKit store manager
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
                if let reminder = reminders?.first(where: { 
                    $0.title.localizedCaseInsensitiveContains(name) 
                }) {
                    foundReminder = reminder
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            if foundReminder != nil {
                break
            }
        }
        
        return foundReminder
    }
}

/// Priority formatting utilities
extension EKReminder {
    var prioritySymbol: String {
        switch priority {
        case 1...4: return "!!!"  // High priority
        case 5: return "!!"       // Medium priority
        case 6...9: return "!"    // Low priority
        default: return ""        // No priority
        }
    }
    
    var priorityDescription: String {
        switch priority {
        case 1...4: return "High"
        case 5: return "Medium"
        case 6...9: return "Low"
        default: return "None"
        }
    }
    
    static func parsePriority(_ input: String) -> Int? {
        let normalized = input.lowercased()
        switch normalized {
        case "high", "h", "1": return 1
        case "medium", "med", "m", "5": return 5
        case "low", "l", "9": return 9
        case "none", "n", "0": return 0
        default:
            if let number = Int(input), (0...9).contains(number) {
                return number
            }
            return nil
        }
    }
}

/// Date parsing utilities
struct DateParser {
    static func parse(_ input: String) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        let normalized = input.lowercased()
        
        switch normalized {
        case "today":
            return today
        case "tomorrow":
            return calendar.date(byAdding: .day, value: 1, to: today)
        case "yesterday":
            return calendar.date(byAdding: .day, value: -1, to: today)
        default:
            // Try parsing various date formats
            let formatters = [
                "yyyy-MM-dd",
                "MM/dd/yyyy",
                "dd/MM/yyyy",
                "yyyy-MM-dd HH:mm"
            ]
            
            for format in formatters {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                if let date = formatter.date(from: input) {
                    return date
                }
            }
            
            // Try relative dates like "in 3 days", "in 2 weeks"
            let components = input.split(separator: " ")
            if components.count >= 3 && components[0] == "in" {
                if let value = Int(components[1]) {
                    let unit = String(components[2]).lowercased()
                    if unit.hasPrefix("day") {
                        return calendar.date(byAdding: .day, value: value, to: today)
                    } else if unit.hasPrefix("week") {
                        return calendar.date(byAdding: .weekOfYear, value: value, to: today)
                    } else if unit.hasPrefix("month") {
                        return calendar.date(byAdding: .month, value: value, to: today)
                    }
                }
            }
            
            return nil
        }
    }
}

// MARK: - Main CLI

struct ReminderCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A powerful CLI for Apple Reminders using EventKit",
        version: "2.0.0",
        subcommands: [
            List.self, 
            Lists.self, 
            Create.self, 
            Update.self, 
            Show.self, 
            Complete.self, 
            Delete.self, 
            Search.self, 
            Stats.self,
            AddAlarm.self,
            RemoveAlarm.self
        ]
    )
    
    // MARK: - List Command
    
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "List reminders")

        @Option(name: .shortAndLong, help: "Specific list to show")
        var listName: String?

        @Flag(name: .long, help: "Show only uncompleted reminders")
        var uncompletedOnly = false

        @Flag(name: .long, help: "Show due dates")
        var showDates = false
        
        @Flag(name: .long, help: "Show priority levels")
        var showPriority = false
        
        @Flag(name: .long, help: "Show URLs")
        var showUrl = false
        
        @Option(name: .long, help: "Filter by priority (high/medium/low/none or 0-9)")
        var priority: String?
        
        @Flag(name: .long, help: "Show only reminders with URLs")
        var hasUrl = false
        
        @Flag(name: .long, help: "Show only reminders with alarms")
        var hasAlarms = false

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            let calendars = store.getCalendars()

            if let listName = listName {
                if let calendar = store.findCalendar(named: listName) {
                    printReminders(from: calendar, store: store)
                } else {
                    print("No list found with name: \(listName)")
                }
            } else {
                for calendar in calendars.sorted(by: { $0.title < $1.title }) {
                    printReminders(from: calendar, store: store)
                }
            }
        }

        private func printReminders(from calendar: EKCalendar, store: ReminderStore) {
            print("=== \(calendar.title) ===")

            let semaphore = DispatchSemaphore(value: 0)
            var reminders: [EKReminder] = []

            store.fetchReminders(in: [calendar]) { fetchedReminders in
                reminders = fetchedReminders
                semaphore.signal()
            }

            semaphore.wait()
            
            // Apply filters
            var filtered = reminders
            
            if uncompletedOnly {
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

            let sortedReminders = filtered.sorted { reminder1, reminder2 in
                // Sort by completion status first
                if reminder1.isCompleted != reminder2.isCompleted {
                    return !reminder1.isCompleted && reminder2.isCompleted
                }
                
                // Then by priority (higher priority first)
                if reminder1.priority != reminder2.priority {
                    return reminder1.priority < reminder2.priority && reminder1.priority != 0 ||
                           reminder2.priority == 0 && reminder1.priority != 0
                }

                // Then by due date
                if let date1 = reminder1.dueDateComponents?.date, let date2 = reminder2.dueDateComponents?.date {
                    return date1 < date2
                }

                if reminder1.dueDateComponents != nil && reminder2.dueDateComponents == nil {
                    return true
                }

                if reminder1.dueDateComponents == nil && reminder2.dueDateComponents != nil {
                    return false
                }

                return reminder1.title.localizedCaseInsensitiveCompare(reminder2.title) == .orderedAscending
            }

            var hasReminders = false

            for reminder in sortedReminders {
                hasReminders = true
                let status = reminder.isCompleted ? "☑" : "☐"
                var output = "  \(status)"
                
                if showPriority && !reminder.prioritySymbol.isEmpty {
                    output += " \(reminder.prioritySymbol)"
                }
                
                output += " \(reminder.title ?? "Untitled")"

                if showDates, let dueDate = reminder.dueDateComponents?.date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .none
                    output += " (Due: \(formatter.string(from: dueDate)))"
                }
                
                if showUrl, let url = reminder.url {
                    output += " 🔗 \(url.absoluteString)"
                }
                
                if reminder.hasAlarms {
                    output += " 🔔"
                }

                if let notes = reminder.notes, !notes.isEmpty {
                    output += "\n    📝 \(notes.replacingOccurrences(of: "\n", with: " "))"
                }

                print(output)
            }

            if !hasReminders {
                print("  (No reminders)")
            }

            print()
        }
    }
    
    // MARK: - Lists Command
    
    struct Lists: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Show all reminder lists")

        func run() throws {
            let store = ReminderStore()
            
            guard store.requestAccess() else {
                print("Error: No access to Reminders. Please grant permission in System Preferences.")
                return
            }

            let calendars = store.getCalendars()

            print("Your Reminder Lists:")
            for calendar in calendars.sorted(by: { $0.title < $1.title }) {
                let semaphore = DispatchSemaphore(value: 0)
                var reminderCount = 0
                var completedCount = 0

                store.fetchReminders(in: [calendar]) { reminders in
                    reminderCount = reminders.count
                    completedCount = reminders.filter { $0.isCompleted }.count
                    semaphore.signal()
                }

                semaphore.wait()

                print("  \(calendar.title) (\(completedCount)/\(reminderCount) completed)")
            }
        }
    }
    
    // MARK: - Create Command
    
    struct Create: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Create a new reminder")

        @Argument(help: "Reminder name")
        var name: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

        @Option(name: .shortAndLong, help: "Due date (YYYY-MM-DD, 'today', 'tomorrow', 'in 3 days')")
        var dueDate: String?

        @Option(name: .shortAndLong, help: "Reminder notes")
        var notes: String?
        
        @Option(name: .shortAndLong, help: "Priority (high/medium/low/none or 0-9)")
        var priority: String?
        
        @Option(name: .shortAndLong, help: "URL to attach")
        var url: String?
        
        @Option(name: .long, help: "Start date (YYYY-MM-DD, 'today', 'tomorrow')")
        var startDate: String?
        
        @Option(name: .long, help: "Add alarm (minutes before due date, e.g., 15, 60)")
        var alarm: Int?

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
            reminder.title = name
            reminder.calendar = targetCalendar

            // Set start date
            if let startDateString = startDate, let date = DateParser.parse(startDateString) {
                reminder.startDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            }

            // Set due date
            if let dueDateString = dueDate, let date = DateParser.parse(dueDateString) {
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            }

            // Set priority
            if let priorityStr = priority, let priorityValue = EKReminder.parsePriority(priorityStr) {
                reminder.priority = priorityValue
            }

            // Set notes
            if let notes = notes {
                reminder.notes = notes
            }
            
            // Set URL
            if let urlString = url, let reminderUrl = URL(string: urlString) {
                reminder.url = reminderUrl
            }
            
            // Add alarm
            if let alarmMinutes = alarm, let dueDate = reminder.dueDateComponents?.date {
                let alarm = EKAlarm(absoluteDate: dueDate.addingTimeInterval(-Double(alarmMinutes * 60)))
                reminder.addAlarm(alarm)
            }

            do {
                try store.eventStore.save(reminder, commit: true)
                var message = "✅ Created reminder '\(name)' in list '\(targetCalendar.title)'"
                if let priorityStr = priority {
                    message += " [Priority: \(priorityStr)]"
                }
                print(message)
            } catch {
                print("Error creating reminder: \(error)")
            }
        }
    }
    
    // MARK: - Update Command
    
    struct Update: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Update an existing reminder")

        @Argument(help: "Reminder name to update")
        var name: String

        @Option(name: .shortAndLong, help: "Current list name (to find the reminder)")
        var listName: String?
        
        @Option(name: .long, help: "New title")
        var newTitle: String?
        
        @Option(name: .long, help: "New priority (high/medium/low/none or 0-9)")
        var newPriority: String?
        
        @Option(name: .long, help: "New due date (YYYY-MM-DD, 'today', 'tomorrow')")
        var newDueDate: String?
        
        @Option(name: .long, help: "New notes")
        var newNotes: String?
        
        @Option(name: .long, help: "New URL")
        var newUrl: String?
        
        @Option(name: .long, help: "Move to this list")
        var moveToList: String?

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
            
            if let newTitle = newTitle {
                reminder.title = newTitle
                updated = true
            }
            
            if let newPriorityStr = newPriority, let priorityValue = EKReminder.parsePriority(newPriorityStr) {
                reminder.priority = priorityValue
                updated = true
            }
            
            if let newDueDateStr = newDueDate, let date = DateParser.parse(newDueDateStr) {
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
                updated = true
            }
            
            if let newNotes = newNotes {
                reminder.notes = newNotes
                updated = true
            }
            
            if let newUrlStr = newUrl {
                if newUrlStr.lowercased() == "remove" {
                    reminder.url = nil
                } else if let url = URL(string: newUrlStr) {
                    reminder.url = url
                }
                updated = true
            }
            
            if let moveToListName = moveToList, let targetCalendar = store.findCalendar(named: moveToListName) {
                reminder.calendar = targetCalendar
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
        static let configuration = CommandConfiguration(abstract: "Show detailed information about a reminder")

        @Argument(help: "Reminder name")
        var name: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

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
            
            print("=== Reminder Details ===")
            print("Title: \(reminder.title ?? "Untitled")")
            print("List: \(reminder.calendar.title)")
            print("Status: \(reminder.isCompleted ? "Completed ☑" : "Incomplete ☐")")
            print("Priority: \(reminder.priorityDescription) \(reminder.prioritySymbol)")
            
            if let startDate = reminder.startDateComponents?.date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                print("Start Date: \(formatter.string(from: startDate))")
            }
            
            if let dueDate = reminder.dueDateComponents?.date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                print("Due Date: \(formatter.string(from: dueDate))")
                
                if !reminder.isCompleted && dueDate < Date() {
                    print("⚠️  OVERDUE")
                }
            }
            
            if let completionDate = reminder.completionDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                print("Completed: \(formatter.string(from: completionDate))")
            }
            
            if let url = reminder.url {
                print("URL: \(url.absoluteString) 🔗")
            }
            
            if let notes = reminder.notes, !notes.isEmpty {
                print("Notes: \(notes)")
            }
            
            if reminder.hasAlarms {
                print("Alarms: \(reminder.alarms?.count ?? 0) 🔔")
                if let alarms = reminder.alarms {
                    for (index, alarm) in alarms.enumerated() {
                        if let absoluteDate = alarm.absoluteDate {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .short
                            formatter.timeStyle = .short
                            print("  \(index + 1). \(formatter.string(from: absoluteDate))")
                        } else {
                            let offset = alarm.relativeOffset
                            let minutes = Int(offset / -60)
                            print("  \(index + 1). \(minutes) minutes before")
                        }
                    }
                }
            }
            
            if let creationDate = reminder.creationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                print("Created: \(formatter.string(from: creationDate))")
            }
            
            if let modifiedDate = reminder.lastModifiedDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                print("Last Modified: \(formatter.string(from: modifiedDate))")
            }
        }
    }
    
    // MARK: - Complete Command
    
    struct Complete: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Mark a reminder as completed")

        @Argument(help: "Reminder name to complete")
        var name: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

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
            
            if reminder.isCompleted {
                print("ℹ️  Reminder already completed: \(reminder.title ?? "Untitled")")
                return
            }

            reminder.isCompleted = true
            reminder.completionDate = Date()

            do {
                try store.eventStore.save(reminder, commit: true)
                print("✅ Completed: \(reminder.title ?? "Untitled") (in list \(reminder.calendar.title))")
            } catch {
                print("Error completing reminder: \(error)")
            }
        }
    }
    
    // MARK: - Delete Command
    
    struct Delete: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Delete a reminder")

        @Argument(help: "Reminder name to delete")
        var name: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

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

            do {
                try store.eventStore.remove(reminder, commit: true)
                print("🗑️  Deleted: \(reminder.title ?? "Untitled") (from list \(reminder.calendar.title))")
            } catch {
                print("Error deleting reminder: \(error)")
            }
        }
    }
    
    // MARK: - Search Command
    
    struct Search: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Search for reminders with filters")

        @Argument(help: "Search query (searches in title and notes)")
        var query: String?
        
        @Option(name: .shortAndLong, help: "Filter by list name")
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
            
            for calendar in calendars {
                let semaphore = DispatchSemaphore(value: 0)
                store.fetchReminders(in: [calendar]) { reminders in
                    allReminders.append(contentsOf: reminders)
                    semaphore.signal()
                }
                semaphore.wait()
            }
            
            // Apply filters
            var filtered = allReminders
            
            if let query = query {
                let lowercasedQuery = query.lowercased()
                filtered = filtered.filter {
                    $0.title.lowercased().contains(lowercasedQuery) ||
                    ($0.notes?.lowercased().contains(lowercasedQuery) ?? false)
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
                filtered = filtered.filter {
                    !$0.isCompleted && $0.dueDateComponents?.date ?? .distantFuture < now
                }
            }
            
            if let dueBeforeStr = dueBefore, let date = DateParser.parse(dueBeforeStr) {
                filtered = filtered.filter {
                    guard let dueDate = $0.dueDateComponents?.date else { return false }
                    return dueDate < date
                }
            }
            
            if let dueAfterStr = dueAfter, let date = DateParser.parse(dueAfterStr) {
                filtered = filtered.filter {
                    guard let dueDate = $0.dueDateComponents?.date else { return false }
                    return dueDate > date
                }
            }
            
            // Sort results
            let sorted = filtered.sorted { r1, r2 in
                if r1.isCompleted != r2.isCompleted {
                    return !r1.isCompleted
                }
                if let d1 = r1.dueDateComponents?.date, let d2 = r2.dueDateComponents?.date {
                    return d1 < d2
                }
                return r1.title.localizedCaseInsensitiveCompare(r2.title) == .orderedAscending
            }
            
            // Display results
            if sorted.isEmpty {
                print("No reminders found matching your criteria.")
                return
            }
            
            print("=== Search Results (\(sorted.count) found) ===\n")
            
            for reminder in sorted {
                let status = reminder.isCompleted ? "☑" : "☐"
                var output = "\(status) \(reminder.prioritySymbol) \(reminder.title ?? "Untitled")"
                output += " [\(reminder.calendar.title)]"
                
                if let dueDate = reminder.dueDateComponents?.date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    output += " (Due: \(formatter.string(from: dueDate)))"
                    
                    if !reminder.isCompleted && dueDate < Date() {
                        output += " ⚠️"
                    }
                }
                
                if reminder.url != nil {
                    output += " 🔗"
                }
                
                if reminder.hasAlarms {
                    output += " 🔔"
                }
                
                print(output)
                
                if let notes = reminder.notes, !notes.isEmpty {
                    let truncated = notes.prefix(80)
                    print("  📝 \(truncated)\(notes.count > 80 ? "..." : "")")
                }
            }
        }
    }
    
    // MARK: - Stats Command
    
    struct Stats: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Show reminder statistics")

        @Option(name: .shortAndLong, help: "Filter by list name")
        var listName: String?

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
            
            for calendar in calendars {
                let semaphore = DispatchSemaphore(value: 0)
                store.fetchReminders(in: [calendar]) { reminders in
                    allReminders.append(contentsOf: reminders)
                    semaphore.signal()
                }
                semaphore.wait()
            }
            
            let total = allReminders.count
            let completed = allReminders.filter { $0.isCompleted }.count
            let incomplete = total - completed
            let completionRate = total > 0 ? Double(completed) / Double(total) * 100 : 0
            
            let now = Date()
            let overdue = allReminders.filter {
                !$0.isCompleted && ($0.dueDateComponents?.date ?? .distantFuture) < now
            }.count
            
            let highPriority = allReminders.filter { $0.priority >= 1 && $0.priority <= 4 && !$0.isCompleted }.count
            let mediumPriority = allReminders.filter { $0.priority == 5 && !$0.isCompleted }.count
            let lowPriority = allReminders.filter { $0.priority >= 6 && $0.priority <= 9 && !$0.isCompleted }.count
            
            let withUrl = allReminders.filter { $0.url != nil }.count
            let withNotes = allReminders.filter { $0.notes != nil && !$0.notes!.isEmpty }.count
            let withAlarms = allReminders.filter { $0.hasAlarms }.count
            
            print("=== Reminder Statistics ===\n")
            
            if let listName = listName {
                print("List: \(listName)\n")
            } else {
                print("All Lists (\(calendars.count) lists)\n")
            }
            
            print("Overall:")
            print("  Total: \(total)")
            print("  Completed: \(completed) (\(String(format: "%.1f", completionRate))%)")
            print("  Incomplete: \(incomplete)")
            print("  Overdue: \(overdue) ⚠️\n")
            
            print("Priority Distribution (incomplete):")
            print("  High (!!!): \(highPriority)")
            print("  Medium (!!): \(mediumPriority)")
            print("  Low (!): \(lowPriority)\n")
            
            print("Features:")
            print("  With URL: \(withUrl) 🔗")
            print("  With Notes: \(withNotes) 📝")
            print("  With Alarms: \(withAlarms) 🔔")
            
            // Due date distribution
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
            
            let dueToday = allReminders.filter {
                guard !$0.isCompleted, let dueDate = $0.dueDateComponents?.date else { return false }
                return calendar.isDate(dueDate, inSameDayAs: today)
            }.count
            
            let dueTomorrow = allReminders.filter {
                guard !$0.isCompleted, let dueDate = $0.dueDateComponents?.date else { return false }
                return calendar.isDate(dueDate, inSameDayAs: tomorrow)
            }.count
            
            let dueThisWeek = allReminders.filter {
                guard !$0.isCompleted, let dueDate = $0.dueDateComponents?.date else { return false }
                return dueDate >= today && dueDate < nextWeek
            }.count
            
            print("\nUpcoming (incomplete):")
            print("  Due Today: \(dueToday)")
            print("  Due Tomorrow: \(dueTomorrow)")
            print("  Due This Week: \(dueThisWeek)")
        }
    }
    
    // MARK: - AddAlarm Command
    
    struct AddAlarm: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Add an alarm to a reminder")

        @Argument(help: "Reminder name")
        var name: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?
        
        @Option(name: .long, help: "Minutes before due date (e.g., 15, 60, 1440 for 1 day)")
        var minutesBefore: Int?
        
        @Option(name: .long, help: "Absolute date and time (YYYY-MM-DD HH:mm)")
        var absoluteDate: String?

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
            
            let alarm: EKAlarm
            
            if let minutes = minutesBefore {
                guard let dueDate = reminder.dueDateComponents?.date else {
                    print("Error: Reminder must have a due date to use relative alarms.")
                    return
                }
                alarm = EKAlarm(absoluteDate: dueDate.addingTimeInterval(-Double(minutes * 60)))
            } else if let dateString = absoluteDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                guard let date = formatter.date(from: dateString) else {
                    print("Error: Invalid date format. Use YYYY-MM-DD HH:mm")
                    return
                }
                alarm = EKAlarm(absoluteDate: date)
            } else {
                print("Error: Must specify either --minutes-before or --absolute-date")
                return
            }
            
            reminder.addAlarm(alarm)
            
            do {
                try store.eventStore.save(reminder, commit: true)
                print("✅ Added alarm to: \(reminder.title ?? "Untitled")")
            } catch {
                print("Error adding alarm: \(error)")
            }
        }
    }
    
    // MARK: - RemoveAlarm Command
    
    struct RemoveAlarm: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Remove all alarms from a reminder")

        @Argument(help: "Reminder name")
        var name: String

        @Option(name: .shortAndLong, help: "List name")
        var listName: String?

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
            
            guard let alarms = reminder.alarms, !alarms.isEmpty else {
                print("ℹ️  Reminder has no alarms: \(reminder.title ?? "Untitled")")
                return
            }
            
            let count = alarms.count
            
            for alarm in alarms {
                reminder.removeAlarm(alarm)
            }
            
            do {
                try store.eventStore.save(reminder, commit: true)
                print("✅ Removed \(count) alarm(s) from: \(reminder.title ?? "Untitled")")
            } catch {
                print("Error removing alarms: \(error)")
            }
        }
    }
}

// Run the CLI
ReminderCLI.main()

