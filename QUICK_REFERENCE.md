# Quick Reference Guide

## Command Summary

| Command        | Description      | Example                                         |
| -------------- | ---------------- | ----------------------------------------------- |
| `list`         | Show reminders   | `reminder list --list-name Work`                |
| `lists`        | Show all lists   | `reminder lists`                                |
| `create`       | Create reminder  | `reminder create "Task" --priority high`        |
| `update`       | Modify reminder  | `reminder update "Task" --new-priority low`     |
| `show`         | Show details     | `reminder show "Task"`                          |
| `complete`     | Mark done        | `reminder complete "Task"`                      |
| `delete`       | Remove reminder  | `reminder delete "Task"`                        |
| `search`       | Find reminders   | `reminder search --overdue`                     |
| `stats`        | Show statistics  | `reminder stats --list-name Work`               |
| `add-alarm`    | Add notification | `reminder add-alarm "Task" --minutes-before 30` |
| `remove-alarm` | Remove alarms    | `reminder remove-alarm "Task"`                  |

## List Command Options

```bash
--list-name, -l         # Specific list
--uncompleted-only      # Hide completed
--show-dates            # Display due dates
--show-priority         # Display priority symbols
--show-url              # Display URLs
--priority              # Filter by priority
--has-url               # Only with URLs
--has-alarms            # Only with alarms
```

## Create Command Options

```bash
--list-name, -l         # Target list
--due-date, -d          # Due date
--start-date            # Start date
--notes, -n             # Description
--priority, -p          # Priority level
--url, -u               # URL attachment
--alarm                 # Minutes before due
```

## Search Command Options

```bash
[query]                 # Text search
--list-name, -l         # In specific list
--priority              # By priority
--has-url               # With URLs
--has-notes             # With notes
--has-alarms            # With alarms
--due-before            # Before date
--due-after             # After date
--overdue               # Overdue only
--completed             # Completed only
--uncompleted           # Uncompleted only
```

## Priority Quick Reference

| Input                     | Result               |
| ------------------------- | -------------------- |
| `high`, `h`, `1`          | High priority (!!!)  |
| `medium`, `med`, `m`, `5` | Medium priority (!!) |
| `low`, `l`, `9`           | Low priority (!)     |
| `none`, `n`, `0`          | No priority          |

## Date Input Examples

```bash
today                   # Today's date
tomorrow                # Tomorrow
yesterday               # Yesterday
2025-12-31             # Specific date
12/31/2025             # US format
31/12/2025             # European format
"in 3 days"            # 3 days from now
"in 2 weeks"           # 2 weeks from now
"in 1 month"           # 1 month from now
"2025-12-31 14:30"     # With time
```

## Common Workflows

### Morning Routine

```bash
# Check today's tasks
reminder search --due-before tomorrow --uncompleted

# Check overdue
reminder search --overdue

# High priority items
reminder list --priority high --uncompleted-only
```

### Weekly Review

```bash
# Overall stats
reminder stats

# Overdue items
reminder search --overdue

# This week's tasks
reminder search --due-before "in 7 days" --uncompleted
```

### Quick Add

```bash
# Simple task
reminder create "Buy milk"

# With details
reminder create "Team meeting" -d tomorrow -p high -n "Prepare slides"

# With alarm
reminder create "Call client" -d "in 2 days" --alarm 60
```

### Find & Update

```bash
# Find task
reminder search "project"

# Update priority
reminder update "project" --new-priority high

# Add details
reminder update "project" --new-url "https://example.com"
```

## Keyboard-Friendly Tips

1. **Tab completion**: Use shell completion for commands (if installed)
2. **Aliases**: Create shell aliases for frequent commands:
   ```bash
   alias rt='reminder list --uncompleted-only'
   alias rc='reminder create'
   alias rs='reminder search'
   alias rstat='reminder stats'
   ```
3. **History search**: Use `Ctrl+R` to search command history
4. **Partial matches**: No need to type full names - partial matching works

## Output Symbols

| Symbol | Meaning         |
| ------ | --------------- |
| ☐      | Incomplete      |
| ☑      | Completed       |
| !!!    | High priority   |
| !!     | Medium priority |
| !      | Low priority    |
| 🔗     | Has URL         |
| 🔔     | Has alarm       |
| 📝     | Has notes       |
| ⚠️     | Overdue         |

## Error Messages

| Message                  | Solution                               |
| ------------------------ | -------------------------------------- |
| "No access to Reminders" | Grant permissions in System Settings   |
| "Reminder not found"     | Check spelling, use partial match      |
| "List not found"         | Verify list name with `reminder lists` |
| "Invalid date format"    | Use supported date formats             |
| "Invalid priority"       | Use high/medium/low/none or 0-9        |

## Performance Tips

1. **List-specific searches**: Use `--list-name` to narrow search scope
2. **Partial names**: Use unique partial names to avoid ambiguity
3. **Filter combinations**: Combine filters to get precise results
4. **Stats for overview**: Use `stats` before detailed searches

## Integration Examples

### Shell Scripts

```bash
#!/bin/bash
# Add daily standup reminder
reminder create "Daily Standup" \
  --list-name Work \
  --due-date tomorrow \
  --alarm 15 \
  --priority high
```

### Cron Jobs

```bash
# Check overdue tasks every morning at 9 AM
0 9 * * * /usr/local/bin/reminder search --overdue | mail -s "Overdue Tasks" user@example.com
```

### Git Hooks

```bash
#!/bin/bash
# pre-commit hook to check for TODO reminders
if reminder search "TODO" --list-name Dev | grep -q "TODO"; then
    echo "Warning: You have TODO reminders in Dev list"
fi
```

## Troubleshooting

### Permission Issues

```bash
# Check if running in sandboxed environment
# Grant full disk access to Terminal.app
# System Settings → Privacy & Security → Full Disk Access
```

### Build Issues

```bash
# Clean build
swift package clean
swift build -c release

# Check dependencies
swift package resolve
```

### Debug Mode

```bash
# Add debug output (modify source if needed)
# Or use verbose logging in EventKit operations
```

## Advanced Usage

### JSON Output (Future Feature)

```bash
# Conceptual - not yet implemented
reminder list --format json | jq '.[] | select(.priority == "high")'
```

### Scripting

```bash
# Get count of overdue tasks
OVERDUE_COUNT=$(reminder search --overdue | grep -c "☐")
echo "You have $OVERDUE_COUNT overdue tasks"
```

### Batch Creation

```bash
# From file
while IFS= read -r task; do
    reminder create "$task" --list-name Inbox
done < tasks.txt
```

## Best Practices

1. **Consistent naming**: Use clear, searchable names
2. **Use lists**: Organize by context (Work, Personal, Shopping)
3. **Set priorities**: Not everything is high priority
4. **Add details**: Use notes and URLs for context
5. **Set alarms**: For time-sensitive tasks
6. **Review regularly**: Use stats and search to stay on top
7. **Archive completed**: Keep lists clean and focused

## Version History

- **2.0.0** - Full EventKit integration, advanced features

  - Priority management
  - URL attachments
  - Alarm support
  - Advanced search
  - Statistics
  - Update command
  - Show command

- **1.0.0** - Initial release
  - Basic CRUD operations
  - List management
