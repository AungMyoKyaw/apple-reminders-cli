# Feature Specification: Add Completion Date Filters

**Feature Branch**: `001-add-completion-date-filters`  
**Created**: 2026-04-15  
**Status**: Draft  
**Input**: PR #2 — add --completed-after and --completed-before search filters

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Filter completed reminders by date range (Priority: P1)

As a user, I want to search for reminders completed after a specific date so I can review what I finished recently (e.g., "what did I finish this week?").

**Why this priority**: Core motivation for the feature. Currently impossible to filter by completion date — users must pull all completed reminders and filter externally.

**Independent Test**: Run `reminder search --completed --completed-after 2026-04-01` and verify only reminders completed after that date appear.

**Acceptance Scenarios**:

1. **Given** completed reminders exist, **When** user runs `reminder search --completed --completed-after <date>`, **Then** only reminders with completionDate after that date are returned
2. **Given** completed reminders exist, **When** user runs `reminder search --completed --completed-before <date>`, **Then** only reminders with completionDate before that date are returned
3. **Given** completed reminders exist, **When** user combines both flags `--completed-after X --completed-before Y`, **Then** only reminders completed within that date range are returned

---

### User Story 2 - Completion date in JSON output (Priority: P2)

As a user, I want the `completionDate` field included in JSON output across `list`, `show`, and `search` commands so I can use it in scripts and automation.

**Why this priority**: Enables programmatic access to completion date data. Without this, even knowing a reminder is completed doesn't tell you when.

**Independent Test**: Run `reminder list --json` and verify the `completionDate` field is present in each entry.

**Acceptance Scenarios**:

1. **Given** a completed reminder exists, **When** user runs `reminder list --json`, **Then** output includes `completionDate` in ISO8601 format
2. **Given** a completed reminder exists, **When** user runs `reminder show "task" --json`, **Then** output includes `completionDate`
3. **Given** a completed reminder exists, **When** user runs `reminder search --completed --json`, **Then** output includes `completionDate`
4. **Given** an uncompleted reminder, **When** user runs any command with `--json`, **Then** `completionDate` is `null`

---

### Edge Cases

- What happens when `--completed-after` or `--completed-before` is used without `--completed`? (Should still filter, but results depend on whether uncompleted reminders have nil completionDate)
- How does system handle reminders with nil completionDate during filtering? (nil completionDate → `.distantPast` for after, `.distantFuture` for before — effectively excludes them)
- What happens with invalid date strings? (Handled by existing DateParser — flag is ignored if date can't be parsed)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST accept `--completed-after <date>` option on the `search` command
- **FR-002**: System MUST accept `--completed-before <date>` option on the `search` command
- **FR-003**: Completion date filters MUST use the same DateParser as existing date flags (--due-before, --due-after)
- **FR-004**: `ReminderEntry` struct MUST include `completionDate` as an optional ISO8601 string field
- **FR-005**: JSON output for `list`, `show`, and `search` commands MUST include the `completionDate` field
- **FR-006**: Nil completion dates MUST be treated as `.distantPast` for --completed-after and `.distantFuture` for --completed-before (excluding uncompleted reminders by default)

### Key Entities

- **ReminderEntry**: Codable struct for JSON output — gains new optional `completionDate: String?` field
- **Search command**: Gains two new `@Option` flags for completion date filtering

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `swift build -c release` compiles without errors
- **SC-002**: `reminder search --help` shows both new options
- **SC-003**: `reminder search --completed --completed-after <date> --json` returns only matching reminders
- **SC-004**: JSON output from list/show/search includes `completionDate` field
- **SC-005**: Existing commands and flags continue to work unchanged

## Assumptions

- Users have Apple Reminders with completed reminders that have system-tracked completionDate
- EventKit's EKReminder exposes `completionDate` property (confirmed — it does)
- The existing DateParser handles all date formats needed for the new flags
- README update with usage examples is sufficient documentation
