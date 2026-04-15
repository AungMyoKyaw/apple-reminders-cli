# Apple Reminders CLI Constitution

## Core Principles

### I. CLI-First Design
Every feature must be accessible via command-line interface. Text in/out protocol: args/stdin → stdout, errors → stderr. Support both human-readable and JSON output formats.

### II. Apple Platform Native
Use EventKit as the sole data layer. Never bypass or duplicate Apple Reminders storage. Maintain full compatibility with Apple Reminders app across devices.

### III. Single Binary Simplicity
Ship as a single self-contained binary. Minimize dependencies — only swift-argument-parser for CLI parsing, EventKit for data. No external services or configuration files.

### IV. Backward Compatibility
New features must not break existing command syntax or output formats. JSON output additions are additive only — never remove or rename fields. CLI flags follow established naming conventions (--kebab-case).

### V. Test-First (NON-NEGOTIABLE)
TDD mandatory for logic changes: write test → test fails → implement → test passes → refactor. Red-Green-Refactor cycle strictly enforced.

## Development Constraints

- **Language**: Swift 5.5+, macOS 11+
- **Architecture**: ArgumentParser-based command structure in `main.swift`
- **Build**: `swift build -c release` must succeed cleanly
- **Distribution**: Homebrew tap, install.sh script, manual build

## Quality Gates

- `swift build -c release` compiles without warnings
- All existing CLI commands continue to work
- JSON output is valid and parseable
- Man page reflects current command set

## Governance

Constitution supersedes all other practices. Amendments require documentation and version bump.

**Version**: 1.0.0 | **Ratified**: 2026-04-15 | **Last Amended**: 2026-04-15
