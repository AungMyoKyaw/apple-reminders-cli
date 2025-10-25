#!/bin/bash

# Man Page Generation Script for Apple Reminders CLI
# This script generates the man page from the ArgumentParser configuration
# using Swift Package Manager's built-in plugin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📖 Apple Reminders CLI - Man Page Generator"
echo "==========================================="
echo ""

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift is not installed"
    echo "Please install Xcode or Swift toolchain"
    exit 1
fi

# Check if we have Package.swift
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Package.swift not found in project directory"
    exit 1
fi

echo "🔨 Generating man page using Swift Package Manager plugin..."
swift package plugin generate-manual

# Find and copy the generated man page
MAN_SOURCE=".build/plugins/GenerateManual/outputs/reminder/reminder.1"
if [ -f "$MAN_SOURCE" ]; then
    cp "$MAN_SOURCE" "reminder.1"
    echo "✅ Man page generated successfully!"
    echo ""
    echo "Generated: reminder.1"
    echo "Location:  $(pwd)/reminder.1"
    echo ""
    echo "To install the man page, run:"
    echo "  sudo mkdir -p /usr/local/share/man/man1"
    echo "  sudo cp reminder.1 /usr/local/share/man/man1/"
    echo "  man reminder"
    echo ""
else
    echo "❌ Error: Man page was not generated"
    echo "Check if the Swift Package is valid and ArgumentParser is configured correctly"
    exit 1
fi
