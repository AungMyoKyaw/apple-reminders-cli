# 🚀 Quick Start Guide

Get up and running with Apple Reminders CLI in 5 minutes!

## Installation

```bash
# Navigate to the project directory
cd apple-reminders-cli

# Run the installation script
./install.sh

# Verify installation
reminder --version
```

## First Time Setup

1. **Grant Permissions**: On first run, macOS will ask for Calendar/Reminders access
2. **Allow Access**: Click "OK" or go to System Settings → Privacy & Security → Calendars

## Your First Commands

### 1. See Your Lists

```bash
reminder lists
```

Output:

```
Your Reminder Lists:
  Personal (5/10 completed)
  Work (12/20 completed)
  Shopping (0/3 completed)
```

### 2. View Reminders

```bash
# See all reminders
reminder list

# See only uncompleted tasks
reminder list --uncompleted-only

# See Work list
reminder list --list-name Work
```

### 3. Create a Reminder

```bash
# Simple reminder
reminder create "Buy milk"

# With due date
reminder create "Meeting with Sarah" --due-date tomorrow

# With priority
reminder create "Urgent: Submit report" --priority high --due-date today

# Full featured
reminder create "Team presentation" \
  --list-name Work \
  --due-date "2025-11-15" \
  --priority high \
  --notes "Prepare slides and demo" \
  --url "https://zoom.us/j/123456" \
  --alarm 30
```

### 4. Complete a Task

```bash
reminder complete "Buy milk"
```

### 5. Check Your Progress

```bash
reminder stats
```

Output:

```
=== Reminder Statistics ===

All Lists (3 lists)

Overall:
  Total: 33
  Completed: 17 (51.5%)
  Incomplete: 16
  Overdue: 3 ⚠️

Priority Distribution (incomplete):
  High (!!!): 5
  Medium (!!): 8
  Low (!): 2

Features:
  With URL: 7 🔗
  With Notes: 12 📝
  With Alarms: 9 🔔

Upcoming (incomplete):
  Due Today: 4
  Due Tomorrow: 2
  Due This Week: 8
```

## Common Tasks

### Check Today's Tasks

```bash
reminder search --due-before tomorrow --uncompleted
```

### Find Overdue Items

```bash
reminder search --overdue
```

### High Priority Items

```bash
reminder list --priority high --uncompleted-only
```

### View Details

```bash
reminder show "Meeting with Sarah"
```

Output:

```
=== Reminder Details ===
Title: Meeting with Sarah
List: Work
Status: Incomplete ☐
Priority: High !!!
Due Date: November 15, 2025
URL: https://zoom.us/j/123456 🔗
Notes: Prepare slides and demo
Alarms: 1 🔔
  1. 30 minutes before
Created: October 21, 2025, 10:30 AM
Last Modified: October 21, 2025, 10:30 AM
```

### Update a Reminder

```bash
# Change priority
reminder update "Meeting with Sarah" --new-priority medium

# Change due date
reminder update "Meeting with Sarah" --new-due-date "2025-11-20"

# Add notes
reminder update "Meeting with Sarah" --new-notes "Bring laptop"
```

### Search

```bash
# Find all meetings
reminder search "meeting"

# Find high priority with URLs
reminder search --priority high --has-url

# Find tasks due this week
reminder search --due-before "in 7 days" --uncompleted
```

## Daily Workflow

### Morning Routine

```bash
# Check what's due today
reminder search --due-before tomorrow --uncompleted

# Check overdue tasks
reminder search --overdue

# Check high priority
reminder list --priority high --uncompleted-only
```

### Evening Review

```bash
# See overall progress
reminder stats

# Plan tomorrow
reminder search --due-before "in 2 days" --uncompleted
```

## Pro Tips

### 1. Use Aliases

Add to `~/.zshrc`:

```bash
alias rt='reminder list --uncompleted-only'
alias rc='reminder create'
alias rs='reminder search'
alias rp='reminder list --priority high --uncompleted-only'
```

### 2. Quick Task Creation

```bash
# Template: reminder create "task" --due-date X --priority Y
rc "Buy groceries" --due-date tomorrow --priority medium
```

### 3. Partial Matching

You don't need exact names:

```bash
# These all work if task is "Meeting with Sarah"
reminder complete "meeting"
reminder show "sarah"
reminder update "meet" --new-priority high
```

### 4. Flexible Dates

Multiple formats supported:

```bash
--due-date today
--due-date tomorrow
--due-date 2025-12-31
--due-date "in 3 days"
--due-date "in 2 weeks"
```

### 5. Priority Shortcuts

```bash
--priority h       # high
--priority m       # medium
--priority l       # low
--priority 1       # high (numeric)
--priority 5       # medium (numeric)
```

## Symbols Guide

| Symbol | Meaning         |
| ------ | --------------- |
| ☐      | Incomplete task |
| ☑      | Completed task  |
| !!!    | High priority   |
| !!     | Medium priority |
| !      | Low priority    |
| 🔗     | Has URL         |
| 🔔     | Has alarm       |
| 📝     | Has notes       |
| ⚠️     | Overdue         |

## Getting Help

### Command Help

```bash
# General help
reminder --help

# Command-specific help
reminder create --help
reminder search --help
```

### Documentation

- **README.md** - Complete guide
- **QUICK_REFERENCE.md** - Cheat sheet
- **EXAMPLES.md** - Use cases and scripts
- **IMPLEMENTATION.md** - Technical details

## Troubleshooting

### "No access to Reminders"

1. Go to System Settings
2. Privacy & Security → Calendars
3. Enable your Terminal app

### "Reminder not found"

- Use partial matching: `reminder show "meet"`
- Check the list: `reminder lists`
- Try with list name: `reminder show "task" --list-name Work`

### Build Errors

```bash
# Clean and rebuild
cd apple-reminders-cli
xcodebuild clean
./install.sh
```

## What's Next?

1. **Explore Commands**: Try all 11 commands
2. **Set Up Workflows**: Create daily/weekly routines
3. **Customize**: Add aliases and functions
4. **Automate**: Write scripts for recurring tasks
5. **Integrate**: Connect with other tools

## Full Documentation

For complete documentation, see:

- [README.md](README.md) - Full user guide
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Command reference
- [EXAMPLES.md](EXAMPLES.md) - Advanced examples

---

**Ready to boost your productivity?** Start with `reminder list` and explore from there!

**Questions?** Check the documentation or create an issue on GitHub.

**Pro users?** Jump to [EXAMPLES.md](EXAMPLES.md) for advanced workflows and integrations.
