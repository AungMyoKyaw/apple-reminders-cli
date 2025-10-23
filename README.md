# Apple Reminders CLI

A powerful command-line interface for Apple Reminders built with Swift and EventKit.

## Features

- **Complete Reminder Management** - Create, update, complete, delete reminders
- **List Management** - Create, rename, delete reminder lists
- **Advanced Search** - Filter by priority, dates, tags, URLs, alarms
- **Enhanced Features** - Tags, subtasks, recurring reminders, location alerts
- **Statistics** - Track productivity metrics and completion rates
- **Priority Management** - High/Medium/Low priority levels
- **Date Support** - Flexible date parsing (natural language, ISO, relative)
- **Attachments** - URLs, notes, alarms, and notifications

## Installation

```bash
cd apple-reminders-cli
swift build -c release
cp .build/release/apple-reminders-cli /usr/local/bin/reminder
```

## Quick Start

```bash
# List all reminders
reminder list

# Create a new reminder
reminder create "Buy groceries" --priority high --due-date tomorrow

# Show help
reminder --help
```

## Common Commands

### List Reminders
```bash
reminder list --show-priority --show-dates
reminder list --priority high --uncompleted-only
reminder list --list-name Work
```

### Create Reminders
```bash
reminder create "Meeting" --due-date today --priority high
reminder create "Project" --due-date "2025-12-31" --notes "Important"
```

### Update Reminders
```bash
reminder update "task" --new-priority medium
reminder update "task" --new-due-date tomorrow
```

### Search & Stats
```bash
reminder search "meeting" --priority high
reminder stats
```

### List Management
```bash
reminder lists
reminder create-list "New Project"
```

## Reference

### Priority Levels
| Priority | Symbol | Values |
| -------- | ------ | ------ |
| High     | !!!    | 1-4    |
| Medium   | !!     | 5      |
| Low      | !      | 6-9    |
| None     |        | 0      |

### Date Formats
- Natural language: `today`, `tomorrow`, `yesterday`
- Relative: `in 3 days`, `in 2 weeks`, `in 1 month`
- ISO format: `2025-12-31`
- With time: `2025-12-31 14:30`

### Symbols
- ☐ - Uncompleted reminder
- ☑ - Completed reminder
- !!! - High priority
- !! - Medium priority
- ! - Low priority
- 🔗 - Has URL attachment
- 🔔 - Has alarm/notification
- 📝 - Has notes
- ⚠️ - Overdue

## Permissions

On first run, grant Calendar/Reminders access:

**System Settings → Privacy & Security → Calendars**

Enable access for your terminal app or the CLI executable.

## Tips

- **Fuzzy matching**: Use partial reminder/list names
- **Priority shortcuts**: `h`, `m`, `l`, `n` or numbers `0-9`
- **Date shortcuts**: `today`, `tomorrow`, `in 3 days`
- **Command help**: Use `reminder help <command>` for detailed options

## Built With

- **Swift** - Native macOS development
- **EventKit** - Apple's Calendar and Reminders framework
- **ArgumentParser** - Command-line argument parsing

## Version

**3.0.0** - Full feature parity with Reminders app
