#!/bin/bash

# Installation script for Apple Reminders CLI
# This script builds and installs the CLI tool to /usr/local/bin

set -e

INSTALL_USER=true
PREFIX="$HOME/.local"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --user) INSTALL_USER=true; shift ;;
        --system) INSTALL_USER=false; PREFIX="/usr/local"; shift ;;
        --prefix) PREFIX="$2"; INSTALL_USER=false; shift 2 ;;
        -h|--help)
            echo "Usage: ./install.sh [options]"
            echo "Options:"
            echo "  --user          Install to ~/.local/bin and ~/.local/share/man (default)"
            echo "  --system        Install to /usr/local/bin and /usr/local/share/man (requires sudo)"
            echo "  --prefix <path> Install to <path>/bin and <path>/share/man"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

if [ "$INSTALL_USER" = true ]; then
    INSTALL_DIR="$HOME/.local/bin"
    MAN_DIR="$HOME/.local/share/man/man1"
else
    INSTALL_DIR="$PREFIX/bin"
    MAN_DIR="$PREFIX/share/man/man1"
fi

# Function to run command with sudo only if the current user lacks write permissions
run_cmd() {
    if [ -w "$(dirname "$1")" ] || [ -w "$1" ] || [ ! -e "$1" -a -w "$(dirname "$1")" ]; then
        "$@"
    else
        sudo "$@"
    fi
}

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

# Generate man page using Swift Package Manager
echo "📖 Generating man page from ArgumentParser..."
if command -v swift &> /dev/null; then
    swift package plugin generate-manual > /dev/null 2>&1
    if [ -f ".build/plugins/GenerateManual/outputs/reminder/reminder.1" ]; then
        cp ".build/plugins/GenerateManual/outputs/reminder/reminder.1" "reminder.1"
        echo "✅ Man page generated!"
    else
        echo "⚠️  Warning: Could not generate man page automatically"
    fi
else
    echo "⚠️  Warning: Swift not found, skipping automatic man page generation"
fi

echo "📦 Building project..."
swift build -c release --disable-sandbox > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Running with output:"
    swift build -c release --disable-sandbox
    exit 1
fi

echo "✅ Build successful!"

# Find the built executable 'reminder' in the .build directory
EXECUTABLE=$(find .build -name "reminder" -type f -perm +111 2>/dev/null | grep "/release/" | head -n1)

if [ -z "$EXECUTABLE" ] || [ ! -f "$EXECUTABLE" ]; then
    echo "❌ Error: Could not find built executable 'reminder' in .build directory"
    exit 1
fi

echo "📍 Found executable: $EXECUTABLE"

INSTALL_NAME="reminder"

echo "📥 Installing to $INSTALL_DIR/$INSTALL_NAME..."

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating $INSTALL_DIR directory..."
    run_cmd mkdir -p "$INSTALL_DIR"
fi

run_cmd cp "$EXECUTABLE" "$INSTALL_DIR/$INSTALL_NAME"
run_cmd chmod +x "$INSTALL_DIR/$INSTALL_NAME"

echo "✅ Installation complete!"
echo ""

# Install man page
echo "📖 Installing man page..."

if [ ! -d "$MAN_DIR" ]; then
    echo "Creating man page directory: $MAN_DIR"
    run_cmd mkdir -p "$MAN_DIR"
fi

if [ -f "reminder.1" ]; then
    run_cmd cp "reminder.1" "$MAN_DIR/reminder.1"
    run_cmd chmod 644 "$MAN_DIR/reminder.1"
    echo "✅ Man page installed!"
    echo "   Access with: man reminder"
else
    echo "⚠️  Warning: reminder.1 man page not found in project directory"
fi

echo ""
echo "🎉 You can now use the CLI with the 'reminder' command"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "⚠️  Note: $INSTALL_DIR is not in your PATH."
    echo "   You may need to add it to your shell profile (e.g., ~/.zshrc or ~/.bash_profile):"
    echo "   export PATH=\"\$PATH:$INSTALL_DIR\""
fi

echo ""
echo "Examples:"
echo "  reminder list"
echo "  reminder create \"Buy groceries\" --due-date tomorrow"
echo "  reminder stats"
echo ""
echo "📚 Documentation:"
echo "  man reminder              # Full man page"
echo "  reminder --help           # CLI help"
echo "  reminder help <command>   # Command-specific help"
echo "  README.md                 # Project documentation"
echo ""
echo "⚠️  Note: On first run, you'll need to grant Calendar/Reminders permissions"
echo "    Go to: System Settings → Privacy & Security → Calendars"
echo ""

