# Apple Reminders CLI

A powerful, feature-rich command-line interface for Apple Reminders built with Swift and EventKit.

## Features

### Core Commands

- **list** - List reminders with advanced filtering
- **lists** - Show all reminder lists with statistics
- **create** - Create new reminders with full metadata support
- **update** - Modify existing reminders
- **show** - Display detailed information about a specific reminder
- **complete** - Mark reminders as completed
- **delete** - Remove reminders
- **search** - Advanced search with multiple filters
- **stats** - Show productivity statistics and metrics
- **add-alarm** - Add notifications to reminders
- **remove-alarm** - Remove alarms from reminders

### EventKit Features

✅ **Priority Management** - Set and filter by priority levels (High/Medium/Low)  
✅ **URL Attachments** - Attach links to reminders  
✅ **Start & Due Dates** - Full date support with flexible parsing  
✅ **Alarms/Notifications** - Set time-based reminders  
✅ **Notes** - Add detailed descriptions  
✅ **Advanced Filtering** - Filter by priority, dates, URLs, alarms  
✅ **Statistics** - Track completion rates and productivity metrics  
✅ **Overdue Detection** - Identify overdue tasks  
✅ **Flexible Date Parsing** - Natural language date input

## Installation

### Build from Source

```bash
cd apple-reminders-cli
swift build -c release
cp .build/release/apple-reminders-cli /usr/local/bin/reminder
```

### Xcode

1. Open `apple-reminders-cli.xcodeproj`
2. Build the project (Cmd+B)
3. The executable will be in the Products folder

## Usage

### List Reminders

```bash
# List all reminders
reminder list

# List reminders from a specific list
reminder list --list-name Work

# Show only uncompleted reminders
reminder list --uncompleted-only

# Show reminders with priority and URLs
reminder list --show-priority --show-url --show-dates

# Filter by priority
reminder list --priority high
reminder list --priority medium

# Show only reminders with URLs
reminder list --has-url

# Show only reminders with alarms
reminder list --has-alarms
```

### Create Reminders

```bash
# Basic reminder
reminder create "Buy groceries"

# With priority
reminder create "Urgent task" --priority high

# With due date
reminder create "Meeting" --due-date today
reminder create "Deadline" --due-date tomorrow
reminder create "Project" --due-date 2025-12-31
reminder create "Follow up" --due-date "in 3 days"

# With all metadata
reminder create "Important meeting" \
  --list-name Work \
  --due-date tomorrow \
  --priority high \
  --notes "Bring presentation slides" \
  --url "https://zoom.us/meeting" \
  --alarm 30

# With start and due dates
reminder create "Project phase" \
  --start-date today \
  --due-date "in 2 weeks"
```

### Update Reminders

```bash
# Change title
reminder update "old name" --new-title "new name"

# Update priority
reminder update "task" --new-priority high

# Update due date
reminder update "task" --new-due-date tomorrow

# Update notes
reminder update "task" --new-notes "Updated description"

# Add or update URL
reminder update "task" --new-url "https://example.com"

# Move to different list
reminder update "task" --move-to-list Personal

# Multiple updates at once
reminder update "task" \
  --new-title "Updated task" \
  --new-priority medium \
  --new-due-date "in 5 days"
```

### Show Reminder Details

```bash
# Show complete information about a reminder
reminder show "task name"

# Show from specific list
reminder show "task name" --list-name Work
```

Output includes:

- Title, List, Status
- Priority level
- Start and due dates
- Completion date
- URL (if attached)
- Notes
- Alarms (with timing details)
- Creation and modification dates
- Overdue warning

### Complete Reminders

```bash
# Mark as completed
reminder complete "task name"

# Complete from specific list
reminder complete "task name" --list-name Work
```

### Delete Reminders

```bash
# Delete a reminder
reminder delete "task name"

# Delete from specific list
reminder delete "task name" --list-name Work
```

### Search Reminders

```bash
# Search by text (searches title and notes)
reminder search "meeting"

# Search in specific list
reminder search "project" --list-name Work

# Filter by priority
reminder search --priority high

# Show only reminders with URLs
reminder search --has-url

# Show only reminders with notes
reminder search --has-notes

# Show only reminders with alarms
reminder search --has-alarms

# Filter by date range
reminder search --due-before tomorrow
reminder search --due-after today

# Show overdue reminders
reminder search --overdue

# Show only completed
reminder search --completed

# Show only uncompleted
reminder search --uncompleted

# Combine filters
reminder search "important" \
  --priority high \
  --has-url \
  --overdue \
  --list-name Work
```

### Statistics

```bash
# Overall statistics
reminder stats

# Statistics for specific list
reminder stats --list-name Work
```

Shows:

- Total, completed, and incomplete counts
- Completion rate percentage
- Overdue count
- Priority distribution
- Feature usage (URLs, notes, alarms)
- Upcoming reminders (today, tomorrow, this week)

### Alarm Management

```bash
# Add alarm 15 minutes before due date
reminder add-alarm "task" --minutes-before 15

# Add alarm 1 hour before
reminder add-alarm "task" --minutes-before 60

# Add alarm 1 day before
reminder add-alarm "task" --minutes-before 1440

# Add alarm at specific date/time
reminder add-alarm "task" --absolute-date "2025-12-31 09:00"

# Remove all alarms
reminder remove-alarm "task"
```

### List Management

```bash
# Show all lists with completion stats
reminder lists
```

## Priority Levels

| Priority | Symbol | Values |
| -------- | ------ | ------ |
| High     | !!!    | 1-4    |
| Medium   | !!     | 5      |
| Low      | !      | 6-9    |
| None     |        | 0      |

You can specify priority as:

- Names: `high`, `medium`, `low`, `none`
- Short: `h`, `m`, `l`, `n`
- Numbers: `0-9`

## Date Formats

Supported date input formats:

- **Natural language**: `today`, `tomorrow`, `yesterday`
- **Relative**: `in 3 days`, `in 2 weeks`, `in 1 month`
- **ISO format**: `2025-12-31`
- **US format**: `12/31/2025`
- **European format**: `31/12/2025`
- **With time**: `2025-12-31 14:30`

## Symbols

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

On first run, you'll be prompted to grant Calendar/Reminders access to the app. Go to:

**System Settings → Privacy & Security → Calendars** (or **Reminders**)

Enable access for your terminal app or the CLI executable.

## Tips

1. **Fuzzy matching**: You don't need to type the complete reminder name. The CLI searches for partial matches (case-insensitive).

2. **List shortcuts**: Same applies to list names - partial matches work.

3. **Quick priorities**: Use shortcuts like `h`, `m`, `l` instead of typing full priority names.

4. **Date shortcuts**: Use `today`, `tomorrow` instead of typing full dates.

5. **Combine filters**: Most commands support multiple filters for powerful queries.

6. **Statistics workflow**: Run `reminder stats` regularly to track your productivity.

7. **Search for planning**: Use `reminder search --overdue` to find tasks that need attention.

## Examples

### Daily Workflow

```bash
# Morning: Check what's due today
reminder search --due-before tomorrow --uncompleted

# See overdue items
reminder search --overdue

# Check high priority tasks
reminder list --priority high --uncompleted-only

# Evening: Review stats
reminder stats
```

### Project Management

```bash
# Create project with phases
reminder create "Project Planning" \
  --list-name Work \
  --priority high \
  --due-date "in 1 week" \
  --url "https://project.example.com"

# Add team meeting
reminder create "Team sync" \
  --due-date tomorrow \
  --alarm 30 \
  --notes "Discuss project timeline"

# Track progress
reminder stats --list-name Work
```

### Personal Tasks

```bash
# Shopping list with reminder
reminder create "Buy birthday gift" \
  --list-name Personal \
  --due-date "in 3 days" \
  --alarm 1440 \
  --notes "Check Amazon wishlist"

# Health reminder
reminder create "Doctor appointment" \
  --due-date "2025-11-15 14:00" \
  --priority high \
  --alarm 120
```

## Technical Details

### Built With

- **Swift** - Native macOS development
- **EventKit** - Apple's Calendar and Reminders framework
- **ArgumentParser** - Swift command-line argument parsing

### EventKit Features Used

- `EKEventStore` - Access to Reminders data
- `EKReminder` - Reminder objects with full metadata
- `EKCalendar` - Reminder lists
- `EKAlarm` - Notifications and time-based reminders
- Priority levels (0-9)
- Date components (start, due, completion)
- URLs and notes
- Completion tracking

### Architecture

- **ReminderStore** - Centralized EventKit access and permission handling
- **DateParser** - Flexible date parsing with natural language support
- **Extensions** - Priority formatting and display utilities
- **Modular commands** - Each subcommand is independently implemented
- **Synchronous operations** - Uses semaphores for reliable EventKit operations

## Limitations

- EventKit doesn't support:
  - Subtasks (Apple Reminders subtasks are not exposed in EventKit)
  - Tags/categories (not available in EventKit API)
  - Location-based reminders (requires additional setup)
  - Recurrence rules (possible to implement - future feature)

## Future Enhancements

Potential features for future versions:

- [ ] Recurrence rules (daily, weekly, monthly reminders)
- [ ] Location-based reminders
- [ ] Export/Import (JSON, CSV formats)
- [ ] Bulk operations (complete/delete multiple)
- [ ] Interactive mode with prompts
- [ ] Color output support
- [ ] Shell completion (bash, zsh, fish)
- [ ] Watch mode (monitor changes)
- [ ] Integration with other tools (via JSON output)

## Contributing

Contributions welcome! Areas for improvement:

- Additional date parsing formats
- Better error messages
- Performance optimizations
- Unit tests
- CI/CD setup

## License

See LICENSE file for details.

## Author

Aung Myo Kyaw

## Version

2.0.0 - Complete EventKit integration with advanced features
