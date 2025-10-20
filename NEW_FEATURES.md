# New Features in Apple Reminders CLI v3.0.0

This document describes all the new features added to support comprehensive Reminders app functionality.

## 📋 List Management

### Create a New List

```bash
apple-reminders-cli create-list "Work Projects"
apple-reminders-cli create-list "Shopping" --color "#FF5733"
```

### Delete a List

```bash
# With confirmation prompt
apple-reminders-cli delete-list "Old List"

# Skip confirmation
apple-reminders-cli delete-list "Old List" --force
```

### Rename a List

```bash
apple-reminders-cli rename-list "Old Name" "New Name"
```

## 🔁 Recurring Reminders

### Add Recurrence to a Reminder

```bash
# Daily recurrence
apple-reminders-cli add-recurrence "Daily standup" --frequency daily

# Weekly recurrence
apple-reminders-cli add-recurrence "Team meeting" --frequency weekly

# Every other week
apple-reminders-cli add-recurrence "Biweekly review" --frequency weekly --interval 2

# Monthly recurrence until a specific date
apple-reminders-cli add-recurrence "Pay rent" --frequency monthly --until "2026-12-31"

# Yearly recurrence
apple-reminders-cli add-recurrence "Birthday reminder" --frequency yearly
```

**Frequency Options:**

- `daily` / `day`
- `weekly` / `week`
- `monthly` / `month`
- `yearly` / `year`

### Remove Recurrence

```bash
apple-reminders-cli remove-recurrence "Daily standup"
```

## 📍 Location-Based Reminders

### Add Location Alert

```bash
# Trigger when arriving at a location
apple-reminders-cli add-location "Buy milk" \
  --location "Whole Foods" \
  --latitude 37.7749 \
  --longitude -122.4194 \
  --radius 100 \
  --trigger arriving

# Trigger when leaving a location
apple-reminders-cli add-location "Call mom" \
  --location "Office" \
  --latitude 37.7749 \
  --longitude -122.4194 \
  --trigger leaving

# Simple location without coordinates (address only)
apple-reminders-cli add-location "Pick up package" --location "Post Office"
```

**Parameters:**

- `--location` - Location name/address (required)
- `--latitude` - GPS latitude (optional)
- `--longitude` - GPS longitude (optional)
- `--radius` - Geofence radius in meters (default: 100)
- `--trigger` - `arriving` or `leaving` (default: arriving)

### Remove Location Alarms

```bash
apple-reminders-cli remove-location "Buy milk"
```

## 📝 Subtasks (via Notes)

**Note:** EventKit doesn't expose native subtasks API. This feature stores subtasks in the notes field with special formatting.

### Add a Subtask

```bash
apple-reminders-cli add-subtask "Plan vacation" "Book flights"
apple-reminders-cli add-subtask "Plan vacation" "Reserve hotel"
apple-reminders-cli add-subtask "Plan vacation" "Rent car"
```

### List Subtasks

```bash
apple-reminders-cli list-subtasks "Plan vacation"
```

**Output:**

```
=== Subtasks for: Plan vacation ===
  ☐ Book flights
  ☐ Reserve hotel
  ☐ Rent car
```

## 🏷️ Tags (via Hashtags)

**Note:** EventKit doesn't expose native tags API. This feature uses hashtags in notes for tagging.

### Add Tags to a Reminder

```bash
apple-reminders-cli add-tag "Design homepage" "work"
apple-reminders-cli add-tag "Design homepage" "urgent"
apple-reminders-cli add-tag "Design homepage" "frontend"
```

Tags can be added with or without the `#` symbol - it will be added automatically.

### List All Tags

```bash
# All tags across all lists
apple-reminders-cli list-tags

# Tags in a specific list
apple-reminders-cli list-tags --list-name "Work"
```

**Output:**

```
=== Tags ===
  #work (15 reminders)
  #urgent (8 reminders)
  #frontend (5 reminders)
```

### Search by Tag

```bash
# Find all reminders with #work tag
apple-reminders-cli search --tag "#work"

# Or without the # symbol
apple-reminders-cli search --tag "work"
```

## 📊 Enhanced Show Command

The `show` command now displays recurrence and location information:

```bash
apple-reminders-cli show "Team meeting"
```

**Output:**

```
=== Reminder Details ===
Title: Team meeting
List: Work
Status: Incomplete ☐
Priority: High !!!
Due Date: December 25, 2025
Recurrence: 🔁
  1. Weekly
Alarms: 2 🔔
  1. Location: arriving at Office 📍
      Radius: 100m
  2. 15 minutes before
Created: December 20, 2025, 10:30 AM
```

## 🔍 Enhanced Search Command

The search command now supports filtering by tags:

```bash
# Search with multiple filters
apple-reminders-cli search "meeting" \
  --tag "#work" \
  --priority high \
  --uncompleted \
  --has-alarms

# Search overdue tasks with specific tag
apple-reminders-cli search --overdue --tag "#urgent"
```

## 📈 All Available Commands

### List Commands

- `list` - List reminders
- `lists` - Show all reminder lists
- `create-list` - Create a new list
- `delete-list` - Delete a list
- `rename-list` - Rename a list

### Reminder Commands

- `create` - Create a new reminder
- `update` - Update an existing reminder
- `show` - Show detailed information
- `complete` - Mark as completed
- `delete` - Delete a reminder
- `search` - Search for reminders
- `stats` - Show statistics

### Alarm Commands

- `add-alarm` - Add a time-based alarm
- `remove-alarm` - Remove all alarms
- `add-location` - Add location-based alarm
- `remove-location` - Remove location alarms

### Recurrence Commands

- `add-recurrence` - Add recurrence rule
- `remove-recurrence` - Remove recurrence rules

### Subtask Commands

- `add-subtask` - Add a subtask
- `list-subtasks` - List all subtasks

### Tag Commands

- `add-tag` - Add a tag
- `list-tags` - List all tags

## 🎯 Complete Examples

### Create a Complex Reminder

```bash
# Create a recurring reminder with location and tags
apple-reminders-cli create "Weekly team standup" \
  --list-name "Work" \
  --due-date "2025-12-23" \
  --priority high \
  --notes "Discuss sprint progress"

# Add recurrence
apple-reminders-cli add-recurrence "Weekly team standup" \
  --frequency weekly

# Add location alert
apple-reminders-cli add-location "Weekly team standup" \
  --location "Conference Room A" \
  --latitude 37.7749 \
  --longitude -122.4194 \
  --trigger arriving

# Add tags
apple-reminders-cli add-tag "Weekly team standup" "work"
apple-reminders-cli add-tag "Weekly team standup" "meeting"

# Add subtasks
apple-reminders-cli add-subtask "Weekly team standup" "Prepare agenda"
apple-reminders-cli add-subtask "Weekly team standup" "Update task board"
```

### Project Planning with Subtasks

```bash
# Create project reminder
apple-reminders-cli create "Launch new website" --list-name "Projects"

# Add subtasks
apple-reminders-cli add-subtask "Launch new website" "Design mockups"
apple-reminders-cli add-subtask "Launch new website" "Frontend development"
apple-reminders-cli add-subtask "Launch new website" "Backend API"
apple-reminders-cli add-subtask "Launch new website" "Testing"
apple-reminders-cli add-subtask "Launch new website" "Deployment"

# Add tags
apple-reminders-cli add-tag "Launch new website" "project"
apple-reminders-cli add-tag "Launch new website" "Q1-2026"

# View all subtasks
apple-reminders-cli list-subtasks "Launch new website"
```

### Shopping List with Location

```bash
# Create shopping list
apple-reminders-cli create-list "Grocery Shopping"

# Add items
apple-reminders-cli create "Buy milk" --list-name "Grocery Shopping"
apple-reminders-cli create "Buy bread" --list-name "Grocery Shopping"
apple-reminders-cli create "Buy eggs" --list-name "Grocery Shopping"

# Add location reminder for all
apple-reminders-cli add-location "Buy milk" \
  --location "Whole Foods Market" \
  --latitude 37.7749 \
  --longitude -122.4194 \
  --trigger arriving
```

## ⚠️ Important Notes

### EventKit Limitations

The public EventKit framework doesn't expose:

- **Native Tags API**: We use hashtags in notes as a workaround
- **Native Subtasks API**: We use structured formatting in notes

These workarounds provide similar functionality while being fully compatible with the Reminders app.

### Permissions

The CLI requires calendar/reminders access permissions. You'll be prompted on first run.

### Syncing

All changes sync automatically with iCloud if you have Reminders syncing enabled.

## 🚀 Version History

- **v3.0.0** - Added list management, recurrence, location alerts, subtasks, and tags
- **v2.0.0** - Added alarms, priority, URLs, search, and stats
- **v1.0.0** - Initial release with basic CRUD operations

## 📚 Additional Resources

For more examples, see:

- [EXAMPLES.md](EXAMPLES.md)
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- [README.md](README.md)
