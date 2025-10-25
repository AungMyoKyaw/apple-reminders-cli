#!/bin/bash

# Build Script for Apple Reminders CLI
# This script builds the universal binary and creates a zip archive for distribution

set -e  # Exit on any error

echo "🔨 Building Apple Reminders CLI..."

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Get version from git tag or use default
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "latest")
echo "📦 Building version: $VERSION"

# Clean any existing binary
rm -f reminder reminder-*.zip

# Build the universal binary for both architectures
echo "🏗️  Building universal binary (arm64 + x86_64)..."
xcodebuild -project apple-reminders-cli.xcodeproj \
           -scheme apple-reminders-cli \
           -configuration Release \
           -arch arm64 \
           -arch x86_64 \
           ONLY_ACTIVE_ARCH=NO \
           -quiet

# Find the built binary in DerivedData (prioritize the main executable over dSYM)
BINARY_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "reminder" -path "*/Build/Products/Release/*" -type f ! -path "*/Contents/Resources/DWARF/*" ! -path "*/.dSYM/*" 2>/dev/null | head -1)

if [ -z "$BINARY_PATH" ]; then
    echo "❌ Error: Built binary not found in DerivedData"
    exit 1
fi

echo "✅ Found binary at: $BINARY_PATH"

# Verify it's a universal binary
echo "🔍 Verifying binary architecture..."
file "$BINARY_PATH"
if ! file "$BINARY_PATH" | grep -q "universal binary"; then
    echo "❌ Error: Binary is not universal"
    exit 1
fi

# Copy binary to current directory
cp "$BINARY_PATH" ./reminder
echo "📋 Binary copied to current directory"

# Generate man page
echo "📚 Generating man page..."
if [ -f "./generate-man.sh" ]; then
    chmod +x ./generate-man.sh
    ./generate-man.sh
    echo "✅ Man page generated: reminder.1"
else
    echo "⚠️  Warning: generate-man.sh not found, skipping man page generation"
fi

# Test the binary works
echo "🧪 Testing binary..."
if ./reminder --version > /dev/null 2>&1; then
    echo "✅ Binary test passed"
else
    echo "❌ Binary test failed"
    exit 1
fi

# Create zip archive
ARCHIVE_NAME="reminder-$VERSION.zip"
echo "📦 Creating zip archive: $ARCHIVE_NAME"

# Add files to the archive
zip -j "$ARCHIVE_NAME" reminder

# Include man page if it exists
if [ -f "reminder.1" ]; then
    zip -j "$ARCHIVE_NAME" reminder.1
    echo "📚 Man page included in archive"
else
    echo "⚠️  Warning: reminder.1 not found, man page not included"
fi

# Clean up the binary and man page from current directory (keep the zip)
rm -f reminder reminder.1

echo ""
echo "✅ Build complete!"
echo "📁 Archive created: $ARCHIVE_NAME"
echo "💡 Ready for GitHub release upload"
echo ""
echo "Next steps:"
echo "1. Upload $ARCHIVE_NAME to GitHub release"
echo "2. Update Homebrew formula if needed"