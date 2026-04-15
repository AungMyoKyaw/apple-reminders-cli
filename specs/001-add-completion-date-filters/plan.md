# Implementation Plan: Add Completion Date Filters

**Feature Branch**: `001-add-completion-date-filters`  
**Created**: 2026-04-15  
**Tech Stack**: Swift 5.5, EventKit, ArgumentParser

## Overview

Add `--completed-after` and `--completed-before` date filter options to the `search` command, and add `completionDate` field to JSON output across `list`, `show`, and `search` commands.

## Changes Required

### File: `apple-reminders-cli/main.swift`

#### Change 1: Add `completionDate` to `ReminderEntry` struct (line ~18)
- Add `let completionDate: String?` field after `lastModifiedDate`
- This is the Codable struct used for all JSON output

#### Change 2: Update `List` command JSON mapping (line ~178)
- Add `completionDate: r.completionDate.flatMap { isoFormatter.string(from: $0) }` to the ReminderEntry constructor

#### Change 3: Update `Show` command JSON mapping (line ~440)
- Same pattern as Change 2

#### Change 4: Add `--completed-after` and `--completed-before` options to `Search` command (line ~573)
- Add two `@Option(name: .long)` properties: `completedAfter: String?` and `completedBefore: String?`
- Place after existing `dueAfter` option for consistency

#### Change 5: Add completion date filtering logic in `Search.run()` (after line ~661)
- Filter using `$0.completionDate` property from EKReminder
- Use `.distantPast` default for `--completed-after` (excludes nil completionDates)
- Use `.distantFuture` default for `--completed-before` (excludes nil completionDates)
- Use existing `DateParser.parse()` for date string conversion

#### Change 6: Update `Search` command JSON mapping (line ~676)
- Same pattern as Change 2

### File: `README.md`

#### Change 7: Add usage examples (line ~210)
- Add two example lines showing `--completed-after` and `--completed-before` usage

## Architecture Notes

- Follows exact same pattern as existing `--due-before`/`--due-after` flags
- Uses same `DateParser` for consistency
- `completionDate` on EKReminder is a native Foundation `Date?` property
- Nil handling mirrors due date nil handling (`.distantPast`/`.distantFuture`)

## Build & Verify

```bash
swift build -c release
reminder search --help  # verify new flags appear
```

## Risk Assessment

- **Low risk**: Additive changes only, no existing behavior modified
- **No breaking changes**: JSON output gains a field, never loses one
- **Tested pattern**: Mirrors existing due-date filter implementation exactly
