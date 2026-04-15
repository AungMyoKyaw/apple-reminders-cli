# Tasks: Add Completion Date Filters

**Feature Branch**: `001-add-completion-date-filters`  
**Created**: 2026-04-15

## Phase 1: Setup

- [x] T001 [P] Checkout PR branch or create feature branch from master

## Phase 2: Model Update (US2 - JSON output)

- [x] T002 Add `completionDate: String?` field to `ReminderEntry` struct in `main.swift:8-19`
- [x] T003 [P] [US2] Update `List` command ReminderEntry construction to include `completionDate` (`main.swift:~170-180`)
- [x] T004 [P] [US2] Update `Show` command ReminderEntry construction to include `completionDate` (`main.swift:~431-440`)
- [x] T005 [P] [US2] Update `Search` command ReminderEntry construction to include `completionDate` (`main.swift:~666-677`)

## Phase 3: Search Filters (US1 - date filtering)

- [x] T006 [US1] Add `@Option` declarations for `--completed-after` and `--completed-before` to `Search` struct (`main.swift:~573`)
- [x] T007 [US1] Add filtering logic using `completionDate` in `Search.run()` (`main.swift:~661`)

## Phase 4: Documentation

- [x] T008 [US2] Add usage examples to README.md (`README.md:~210`)

## Phase 5: Verify

- [x] T009 Run `swift build -c release` — must compile cleanly
- [x] T010 Verify `reminder search --help` shows new options
