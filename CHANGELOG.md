# Changelog

All notable changes to Apple Reminders CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-10-21

### Added

#### Core Features

- **Priority Management**: Full support for reminder priorities (0-9, high/medium/low/none)
- **URL Attachments**: Attach URLs to reminders for quick reference
- **Alarm Support**: Add time-based notifications to reminders
- **Advanced Search**: Search with multiple filters (text, priority, dates, features)
- **Statistics Command**: Comprehensive productivity metrics and analytics
- **Update Command**: Modify existing reminders without recreation
- **Show Command**: Display detailed information about specific reminders

#### Commands

- `list` - Enhanced with priority, URL, and alarm filtering
- `lists` - Show all reminder lists with completion stats
- `create` - Enhanced with priority, URL, start-date, and alarm options
- `update` - New command for modifying existing reminders
- `show` - New command for detailed reminder view
- `complete` - Mark reminders as completed
- `delete` - Remove reminders
- `search` - New advanced search command with 10+ filters
- `stats` - New statistics command with productivity metrics
- `add-alarm` - New command for adding notifications
- `remove-alarm` - New command for removing alarms

#### Utilities

- `ReminderStore` class for centralized EventKit access
- Priority formatting with symbols (!!!, !!, !)
- Flexible date parser supporting multiple formats
- Natural language date input (today, tomorrow, in X days)
- Partial name matching for commands
- Smart sorting (completion → priority → due date → name)

#### User Experience

- Status indicators (☐ ☑)
- Priority symbols in output
- Feature icons (🔗 🔔 📝 ⚠️)
- Overdue detection and warnings
- Formatted date display
- Comprehensive error messages
- Permission handling guidance

#### Documentation

- Complete README with all features
- Quick Reference guide
- Examples and use cases
- Implementation summary
- Installation script
- Inline help for all commands
- API documentation in code

#### EventKit Integration

- Full EKReminder property support
- Multiple alarm management
- Start and due dates
- Completion tracking
- Calendar (list) management
- Creation and modification dates
- Notes and URL support

### Changed

- Upgraded from basic CRUD to full-featured CLI
- Improved error handling and user feedback
- Enhanced command-line argument parsing
- Better organization with shared utilities
- Cleaner code structure with modular design

### Technical

- Added ArgumentParser dependency (1.5.0+)
- Swift 5.0 compatibility
- macOS 11.5+ target
- Xcode project structure
- Release build optimization

## [1.0.0] - 2025-10-20 (Draft)

### Added

- Basic `list` command
- Basic `create` command
- Basic `complete` command
- Basic `delete` command
- `lists` command
- Simple filtering options
- EventKit integration foundation

### Features

- List reminders from all or specific lists
- Create new reminders with optional due dates
- Mark reminders as complete
- Delete reminders
- Show all reminder lists
- Filter by completion status
- Show due dates

## Roadmap

### [2.1.0] - Planned

- Recurrence rules support (repeating reminders)
- Bulk operations (complete/delete multiple)
- JSON output format for integrations
- Shell completion scripts (bash, zsh, fish)
- Improved performance for large datasets

### [2.2.0] - Planned

- Export/Import functionality (JSON, CSV, iCal)
- Color output options
- Location-based reminders
- Interactive mode
- Configuration file support

### [3.0.0] - Future

- Subtask support (if EventKit improves)
- Watch mode (live updates)
- Advanced reporting
- Integration APIs
- Plugin system

## Notes

### Breaking Changes

- v2.0.0: Complete rewrite - not compatible with v1.0.0 draft

### Deprecations

- None yet

### Security

- No security issues reported
- Permission model follows macOS standards
- No network access required
- No data collection

### Known Issues

- EventKit doesn't expose subtask relationships
- Tags/categories not available in EventKit API
- Location-based reminders need additional setup
- Recurrence rules not yet implemented

## Contributing

Contributions are welcome! See CONTRIBUTING.md for guidelines.

## Support

For issues and questions:

- GitHub Issues: [repository URL]
- Documentation: README.md, QUICK_REFERENCE.md, EXAMPLES.md

---

**Legend**:

- `Added` for new features
- `Changed` for changes in existing functionality
- `Deprecated` for soon-to-be removed features
- `Removed` for now removed features
- `Fixed` for any bug fixes
- `Security` in case of vulnerabilities
