# Implementation Plan: Fix README Inaccuracies

**Feature Branch**: `docs/fix-readme-inaccuracies`  
**Created**: 2026-04-15  
**Tech Stack**: Markdown only

## Overview

Docs-only change. Remove references to nonexistent CLI subcommands and flags from README. Fix positional arg syntax.

## Changes Required

### File: `README.md`

1. **Features list**: Change "Create, rename, delete reminder lists" → "Filter reminders by list"; Change "Tags, subtasks, recurring reminders, location alerts" → "Tags, notes, URLs, and notifications"
2. **CLI Help section**: Remove `add-tag --help` and `list-tags --help` examples
3. **List Reminders section**: Replace `--show-priority --show-dates` and `--list-name Work` with `reminder list` / `reminder list Work` / `--priority high --uncompleted-only`
4. **Tags section**: Remove `add-tag`, `list-tags` references; rename to "Searching by tag"
5. **List Management section**: Remove entirely (`lists` and `create-list` don't exist)

## Risk Assessment

- **Very low risk**: Docs-only, no code changes
- **Merge clean**: GitHub reports MERGEABLE with PR #2 already merged
