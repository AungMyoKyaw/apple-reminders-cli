# Feature Specification: Fix README Inaccuracies

**Feature Branch**: `docs/fix-readme-inaccuracies`  
**Created**: 2026-04-15  
**Status**: Draft  
**Input**: PR #1 — fix README commands to match actual CLI usage

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Accurate CLI documentation (Priority: P1)

As a user reading the README, I expect the documented commands and flags to actually work when I type them into the terminal.

**Why this priority**: Inaccurate docs lead to user frustration and support issues. Every example must be runnable.

**Independent Test**: Run each README command example against `reminder --help` / `reminder <cmd> --help` and verify they match.

**Acceptance Scenarios**:

1. **Given** `reminder list --help`, **When** comparing to README examples, **Then** all documented flags and positional args match
2. **Given** `reminder --help`, **When** checking for subcommands referenced in README, **Then** no nonexistent subcommands are documented
3. **Given** the Features list in README, **When** comparing to actual capabilities, **Then** descriptions accurately reflect what the CLI does

### Edge Cases

- PR #2 added `--completed-after`/`--completed-before` examples to README — merge must preserve those

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: README MUST NOT reference `--show-priority` or `--show-dates` flags (don't exist on `list`)
- **FR-002**: README MUST show `list-name` as a positional arg, not `--list-name` flag
- **FR-003**: README MUST NOT reference `lists` or `create-list` subcommands (don't exist)
- **FR-004**: README MUST NOT reference `add-tag` or `list-tags` subcommands (don't exist)
- **FR-005**: Feature descriptions MUST match actual CLI capabilities

## Success Criteria *(mandatory)*

- **SC-001**: Every command example in README is valid per `--help` output
- **SC-002**: No references to nonexistent subcommands or flags
- **SC-003**: Merge does not conflict with PR #2 changes

## Assumptions

- The CLI interface is stable and these subcommands/flags were never implemented (not removed)
- README is the primary user-facing documentation
