# Examples & Use Cases

This file contains practical examples and use cases for the Apple Reminders CLI.

## Table of Contents

- [Quick Start](#quick-start)
- [Daily Workflows](#daily-workflows)
- [Project Management](#project-management)
- [Personal Productivity](#personal-productivity)
- [Team Coordination](#team-coordination)
- [Advanced Usage](#advanced-usage)

## Quick Start

### Your First Reminder

```bash
# Create a simple reminder
reminder create "Call dentist"

# Create with due date
reminder create "Submit report" --due-date friday

# Create with priority
reminder create "Urgent meeting" --priority high --due-date today
```

### View Your Reminders

```bash
# See all reminders
reminder list

# See only incomplete tasks
reminder list --uncompleted-only

# See tasks with priorities
reminder list --show-priority --show-dates
```

## Daily Workflows

### Morning Routine

Start your day by checking what's on your plate:

```bash
#!/bin/bash
# save as ~/bin/morning-check.sh

echo "🌅 Good Morning! Here's your day:"
echo ""

echo "📅 Today's Tasks:"
reminder search --due-before tomorrow --uncompleted
echo ""

echo "⚠️  Overdue:"
reminder search --overdue
echo ""

echo "🔥 High Priority:"
reminder list --priority high --uncompleted-only
echo ""

echo "📊 Overall Stats:"
reminder stats
```

### Evening Review

Review and plan before ending your day:

```bash
#!/bin/bash
# save as ~/bin/evening-review.sh

echo "🌙 Evening Review:"
echo ""

echo "✅ Today's Completions:"
reminder search --completed --due-before tomorrow
echo ""

echo "📋 Tomorrow's Plan:"
reminder search --due-before tomorrow --uncompleted
echo ""

echo "📈 Weekly Progress:"
reminder stats
```

## Project Management

### Starting a New Project

```bash
# Create project list (do this in Reminders app first)
# Then add project tasks:

reminder create "Project kickoff meeting" \
  --list-name Work \
  --due-date "2025-11-01" \
  --priority high \
  --notes "Prepare agenda, invite stakeholders" \
  --url "https://meet.google.com/abc-defg-hij"

reminder create "Define project scope" \
  --list-name Work \
  --due-date "2025-11-03" \
  --priority high \
  --notes "Document requirements, timeline, resources"

reminder create "Set up project repository" \
  --list-name Work \
  --due-date "2025-11-05" \
  --priority medium \
  --url "https://github.com/company/project"

reminder create "Weekly progress update" \
  --list-name Work \
  --due-date "2025-11-08" \
  --priority medium \
  --alarm 1440
```

### Project Status Check

```bash
# Check project progress
reminder search "project" --list-name Work

# See what's overdue
reminder search "project" --overdue --list-name Work

# View detailed task info
reminder show "Project kickoff meeting"
```

## Personal Productivity

### Weekly Planning

```bash
#!/bin/bash
# Weekly planning script

echo "📅 Weekly Planning - $(date)"
echo ""

# Review last week
echo "=== Last Week's Completion ===" reminder stats --period week
echo ""

# High priority items
echo "=== This Week's Priorities ==="
reminder search --priority high --uncompleted

# Upcoming deadlines
echo ""
echo "=== Upcoming Deadlines ==="
reminder search --due-before "in 7 days" --uncompleted
```

### Habit Tracking

```bash
# Create daily habits
reminder create "Morning exercise" \
  --due-date today \
  --priority medium \
  --alarm 30

reminder create "Read 30 minutes" \
  --due-date today \
  --priority low \
  --notes "Currently reading: [Book Name]"

reminder create "Review daily goals" \
  --due-date today \
  --priority high \
  --alarm 60
```

### Shopping & Errands

```bash
# Quick shopping list
reminder create "Buy milk" --list-name Shopping
reminder create "Pick up prescription" --list-name Errands --alarm 120
reminder create "Return package" --list-name Errands --due-date tomorrow

# Check errands for today
reminder list --list-name Errands --uncompleted-only
```

## Team Coordination

### Meeting Preparation

```bash
# Create meeting reminder with all details
reminder create "Team standup" \
  --due-date tomorrow \
  --alarm 15 \
  --priority high \
  --url "https://zoom.us/j/123456789" \
  --notes "Agenda: Sprint review, blockers, next steps"

# Add action items from meeting
reminder create "Follow up with Sarah on API" \
  --due-date "in 2 days" \
  --priority high \
  --notes "Discuss authentication implementation"

reminder create "Update sprint board" \
  --due-date tomorrow \
  --priority medium \
  --url "https://jira.company.com/board/123"
```

### Deadline Management

```bash
# Add project deadline with milestone reminders
reminder create "Final delivery" \
  --due-date "2025-12-15" \
  --priority high \
  --alarm 10080  # 1 week before

reminder create "Code review deadline" \
  --due-date "2025-12-10" \
  --priority high \
  --alarm 1440  # 1 day before

reminder create "Testing phase complete" \
  --due-date "2025-12-08" \
  --priority medium

# Check all project deadlines
reminder search "deadline" --list-name Work
```

## Advanced Usage

### Batch Operations

```bash
# Create multiple reminders from a file
while IFS='|' read -r title duedate priority; do
  reminder create "$title" \
    --due-date "$duedate" \
    --priority "$priority" \
    --list-name Work
done < tasks.txt

# tasks.txt format:
# Complete documentation|2025-11-15|high
# Update dependencies|2025-11-20|medium
# Review code|2025-11-25|low
```

### Automated Reports

```bash
#!/bin/bash
# Daily email report

REPORT=$(cat <<EOF
Daily Reminder Report - $(date +%Y-%m-%d)

=== Overdue Tasks ===
$(reminder search --overdue)

=== Today's Tasks ===
$(reminder search --due-before tomorrow --uncompleted)

=== High Priority ===
$(reminder list --priority high --uncompleted-only)

=== Statistics ===
$(reminder stats)
EOF
)

echo "$REPORT" | mail -s "Daily Task Report" your@email.com
```

### Integration with Other Tools

#### Git Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for TODO reminders
TODO_COUNT=$(reminder search "TODO" --list-name Dev --uncompleted | wc -l)

if [ $TODO_COUNT -gt 10 ]; then
  echo "⚠️  Warning: You have $TODO_COUNT TODO reminders"
  echo "Consider addressing some before committing"
  reminder search "TODO" --list-name Dev --uncompleted

  read -p "Continue commit? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi
```

#### Slack Integration

```bash
#!/bin/bash
# Post daily summary to Slack

WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

SUMMARY=$(cat <<EOF
{
  "text": "*Daily Task Summary*",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "$(reminder search --due-before tomorrow --uncompleted)"
      }
    }
  ]
}
EOF
)

curl -X POST -H 'Content-type: application/json' \
  --data "$SUMMARY" \
  "$WEBHOOK_URL"
```

### Power User Scripts

#### Smart Task Creation

```bash
#!/bin/bash
# smart-task.sh - Create task with intelligent defaults

TASK="$1"
LIST="${2:-Inbox}"
PRIORITY="${3:-medium}"

# Auto-detect priority from keywords
if echo "$TASK" | grep -qi "urgent\|critical\|asap"; then
  PRIORITY="high"
elif echo "$TASK" | grep -qi "maybe\|someday\|low"; then
  PRIORITY="low"
fi

# Auto-detect due date
if echo "$TASK" | grep -qi "today"; then
  DUE="today"
elif echo "$TASK" | grep -qi "tomorrow"; then
  DUE="tomorrow"
elif echo "$TASK" | grep -qiE "[0-9]{4}-[0-9]{2}-[0-9]{2}"; then
  DUE=$(echo "$TASK" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")
else
  DUE=""
fi

# Extract URL if present
URL=$(echo "$TASK" | grep -oE "https?://[^ ]+")

# Create reminder
CMD="reminder create \"$TASK\" --list-name \"$LIST\" --priority \"$PRIORITY\""
[ -n "$DUE" ] && CMD="$CMD --due-date \"$DUE\""
[ -n "$URL" ] && CMD="$CMD --url \"$URL\""

eval $CMD
```

#### Weekly Cleanup

```bash
#!/bin/bash
# weekly-cleanup.sh - Archive old completed tasks

echo "🧹 Weekly Reminder Cleanup"
echo ""

# Show completed tasks from last week
echo "Completed last week:"
reminder search --completed | grep "$(date -v-7d +%Y-%m)"

echo ""
echo "Note: Manual archiving not yet implemented in CLI"
echo "Consider reviewing in Reminders app"
```

## Tips & Tricks

### Alias Shortcuts

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Quick aliases
alias rt='reminder list --uncompleted-only'
alias rc='reminder create'
alias rs='reminder search'
alias rstat='reminder stats'
alias rp='reminder list --priority high --uncompleted-only'

# Function for quick task with due date
rtask() {
    reminder create "$1" --due-date "$2" --priority "${3:-medium}"
}

# Usage: rtask "Buy milk" tomorrow high
```

### Keyboard Maestro Integration

Create a macro that triggers on hotkey:

1. Prompt for task name
2. Run: `reminder create "$TASK" --due-date today --priority high`
3. Display notification: "Task created"

### Alfred Workflow

Create custom commands like:

- `r Add groceries` → creates reminder
- `r list` → shows all tasks
- `r today` → shows today's tasks

## Troubleshooting Common Issues

### Permission Denied

```bash
# Reset permissions
tccutil reset Calendar com.apple.Terminal

# Re-run the tool
reminder list
# Grant permission when prompted
```

### Reminder Not Found

```bash
# Use partial matching
reminder show "meet"  # finds "Team meeting"

# Check which list it's in
reminder lists
reminder show "task" --list-name Work
```

### Date Parsing Issues

```bash
# Use explicit ISO format
reminder create "Task" --due-date "2025-11-30"

# Or natural language
reminder create "Task" --due-date tomorrow
reminder create "Task" --due-date "in 3 days"
```

## Contributing Your Examples

Have a great use case? Share it!

1. Add your example to this file
2. Submit a pull request
3. Help others be more productive!

---

**Pro Tip**: Combine these examples with your own workflows. The CLI is designed to be scriptable and integrates well with other Unix tools!
