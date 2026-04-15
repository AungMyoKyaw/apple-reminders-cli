# Feature Specification: Configure Gitignore for Speckit Artifacts

**Feature Branch**: `003-gitignore-speckit`  
**Created**: 2026-04-15  
**Status**: Draft

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Commit design artifacts, ignore tooling (Priority: P1)

As a project maintainer, I want `specs/` (design decisions) and `.specify/memory/constitution.md` (project principles) tracked in git, while `.specify/` tooling scaffolding is ignored.

**Why this priority**: Preserves design rationale and governance without polluting the repo with bulky tooling files.

**Independent Test**: After commit, `git status` shows no `.specify/` tooling files as untracked. `specs/` and constitution are tracked.

**Acceptance Scenarios**:

1. **Given** `.gitignore` is updated, **When** `git status` is run, **Then** `.specify/` tooling is ignored
2. **Given** negation rules exist, **When** checking tracked files, **Then** `.specify/memory/constitution.md` is trackable
3. **Given** `specs/` exists, **When** checking tracked files, **Then** all spec artifacts are tracked

### Edge Cases

- `.specify/memory/constitution.md` needs negation rules to unignore nested path inside ignored `.specify/`
- `specs/` is top-level, separate from `.specify/` — must not be accidentally ignored

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `.gitignore` MUST ignore `.specify/` directory
- **FR-002**: `.gitignore` MUST whitelist `.specify/memory/` and `.specify/memory/constitution.md` via negation
- **FR-003**: `specs/` directory MUST remain tracked (not ignored)
- **FR-004**: Existing `.gitignore` entries MUST be preserved

## Success Criteria *(mandatory)*

- **SC-001**: `.specify/` tooling does not appear in `git status`
- **SC-002**: `specs/` files show as trackable in `git status`
- **SC-003**: `.specify/memory/constitution.md` shows as trackable in `git status`
