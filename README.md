# Apple Reminders CLI

A powerful command-line interface for Apple Reminders built with Swift and EventKit.

## Features

- **Complete Reminder Management** - Create, update, complete, delete reminders
- **List Management** - Create, rename, delete reminder lists
- **Advanced Search** - Filter by priority, dates, tags, URLs, alarms
- **JSON Output** - Machine-readable output for automation and scripting
- **Enhanced Features** - Tags, subtasks, recurring reminders, location alerts
- **Statistics** - Track productivity metrics and completion rates
- **Priority Management** - High/Medium/Low priority levels
- **Date Support** - Flexible date parsing (natural language, ISO, relative)
- **Attachments** - URLs, notes, alarms, and notifications

## Installation

### Homebrew (Recommended)

```bash
# Add the tap
brew tap AungMyoKyaw/homebrew-tap

# Install the CLI
brew install AungMyoKyaw/homebrew-tap/reminder
```

### Build from Source

```bash
cd apple-reminders-cli
./install.sh          # Builds and installs both CLI and man page
```

By default, this installs to `~/.local/bin` (no sudo required). To install system-wide:

```bash
./install.sh --system  # Installs to /usr/local/bin (requires sudo)
```

You can also specify a custom prefix:

```bash
./install.sh --prefix /custom/path
```

Or manually:

```bash
cd apple-reminders-cli
xcodebuild -scheme apple-reminders-cli -configuration Release
# Copy binary to /usr/local/bin/reminder
# Copy reminder.1 to /usr/local/share/man/man1/reminder.1
```

### Updating the Man Page

The man page is automatically generated from your ArgumentParser configuration using Swift Package Manager. To regenerate the man page after updating command definitions:

```bash
cd apple-reminders-cli
./generate-man.sh        # Generates and updates reminder.1
```

Or run the Swift Package Manager plugin directly:

```bash
swift package plugin generate-manual
```

**Why this approach?**
- ✅ **Always in sync** - Man page automatically reflects your command definitions
- ✅ **Zero maintenance** - No need to manually edit `.1` files
- ✅ **Built-in support** - Uses ArgumentParser's native documentation plugin
- ✅ **Professional format** - Generates mdoc-formatted UNIX man pages
- ✅ **Version controlled** - Keep `reminder.1` in git for distribution

## Documentation

The CLI includes comprehensive documentation accessible in multiple ways:

### Man Page

```bash
# View the full man page
man reminder

# Search within man page (press '/' then type query)
# Quit with 'q'
```

The man page covers:
- All commands with detailed options
- Tag system and usage
- Date formats and priority levels
- Examples and common workflows
- Permissions and system requirements

### CLI Help

```bash
# Show main help
reminder --help

# Show command-specific help
reminder create --help
reminder search --help
reminder add-tag --help
reminder list-tags --help

# Get help for any command
reminder help <command>
```

### This README

Quick start guide, common commands, and feature overview.

## Quick Start

```bash
# List all reminders
reminder list

# Create a new reminder
reminder create "Buy groceries" --priority high --due-date tomorrow

# Complete multiple reminders
reminder complete "Buy groceries" "Call Mom"

# Delete multiple reminders
reminder delete "Spam" "Old Task"

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
reminder create "Buy groceries #shopping #urgent" --due-date tomorrow
reminder create "Review doc" #work #review
```

### Tags

Tags help organize reminders and make them searchable. Tags are stored in the task title (prefixed with #) for proper Apple Reminders app support.

**Creating reminders with inline tags:**
```bash
# Single tag
reminder create "Buy milk #shopping" --due-date tomorrow

# Multiple tags
reminder create "Fix bug #work #urgent #backend" --due-date today

# Tags with priority and dates
reminder create "Deploy release #production #important" --priority high --due-date tomorrow
```

**Managing tags:**
```bash
# Add a tag to an existing reminder
reminder add-tag "Buy milk #shopping" review

# Search reminders by tag
reminder search --tag work
reminder search --tag shopping --list-name Work

# List all tags in use
reminder list-tags
reminder list-tags --list-name Work
```

**Tag Format:**
- Tags must start with `#` followed by alphanumeric characters
- Multiple tags are space-separated: `#tag1 #tag2 #tag3`
- Tags are case-sensitive: `#work`, `#Work`, and `#WORK` are different tags
- Punctuation after tags is automatically stripped: `#urgent, #pending!` becomes `#urgent #pending`
- Tags are appended to the end of task titles for maximum compatibility with Apple Reminders

### Update Reminders
```bash
reminder update "task" --new-priority medium
reminder update "task" --new-due-date tomorrow
reminder update "task" --new-due-date remove   # Remove due date
```

### JSON Output
All listing and search commands support JSON output for integration with other tools like `jq`.
```bash
reminder list --json
reminder search "meeting" --json | jq '.[0].title'
reminder show "task" --json
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

## Tag Behavior & Compatibility

**Tag Storage:**
- Tags are now stored in the task title (after the task name) for full compatibility with Apple Reminders
- This allows tags to sync across all Apple devices and apps
- Tags are automatically extracted and cleaned during reminder creation

**Backward Compatibility:**
- Tags previously stored in notes are still recognized and searchable
- Search function works for tags in both title and notes
- Existing reminders with tags in notes continue to work

**Examples:**
```bash
# Create task with tags - tags are extracted and appended to title
reminder create "Buy groceries #shopping #urgent"
# Result: Title becomes "Buy groceries #shopping #urgent"

# Tags are visible in Apple Reminders and other Apple apps
reminder list
# Output: ☐ Buy groceries #shopping #urgent

# Search works across all tag locations
reminder search --tag shopping
# Finds reminders with #shopping in title or notes
```

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

**3.0.2** - Full feature parity with Reminders app
