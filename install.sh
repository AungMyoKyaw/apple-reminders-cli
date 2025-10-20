#!/bin/bash

# Installation script for Apple Reminders CLI
# This script builds and installs the CLI tool to /usr/local/bin

set -e

echo "🍎 Apple Reminders CLI - Installation Script"
echo "=============================================="
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or xcodebuild is not in PATH"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "apple-reminders-cli.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the project directory"
    echo "Usage: cd apple-reminders-cli && ./install.sh"
    exit 1
fi

echo "📦 Building project..."
xcodebuild -project apple-reminders-cli.xcodeproj \
    -scheme apple-reminders-cli \
    -configuration Release \
    clean build \
    > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Running with output:"
    xcodebuild -project apple-reminders-cli.xcodeproj \
        -scheme apple-reminders-cli \
        -configuration Release \
        build
    exit 1
fi

echo "✅ Build successful!"

# Find the built executable
EXECUTABLE=$(find ~/Library/Developer/Xcode/DerivedData/apple-reminders-cli-* \
    -name "apple-reminders-cli" -type f -perm +111 2>/dev/null | grep Release | head -n1)

if [ -z "$EXECUTABLE" ]; then
    echo "❌ Error: Could not find built executable"
    exit 1
fi

echo "📍 Found executable: $EXECUTABLE"

# Install to /usr/local/bin
INSTALL_DIR="/usr/local/bin"
INSTALL_NAME="reminder"

echo "📥 Installing to $INSTALL_DIR/$INSTALL_NAME..."

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating $INSTALL_DIR directory..."
    sudo mkdir -p "$INSTALL_DIR"
fi

sudo cp "$EXECUTABLE" "$INSTALL_DIR/$INSTALL_NAME"
sudo chmod +x "$INSTALL_DIR/$INSTALL_NAME"

echo "✅ Installation complete!"
echo ""
echo "🎉 You can now use the CLI with the 'reminder' command"
echo ""
echo "Examples:"
echo "  reminder list"
echo "  reminder create \"Buy groceries\" --due-date tomorrow"
echo "  reminder stats"
echo ""
echo "📚 For full documentation, see README.md"
echo ""
echo "⚠️  Note: On first run, you'll need to grant Calendar/Reminders permissions"
echo "    Go to: System Settings → Privacy & Security → Calendars"
echo ""
