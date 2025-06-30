#!/bin/bash
set -euo pipefail

# Script to create platform-specific archives
# Usage: ./create-archive.sh <binary-name> <target> <archive-name>

BINARY_NAME="${1:?Binary name is required}"
TARGET="${2:?Target is required}"
ARCHIVE_NAME="${3:?Archive name is required}"

echo "📦 Creating archive for $BINARY_NAME ($TARGET)"

# Determine binary path and archive format based on target
if [[ "$TARGET" == *"windows"* ]]; then
    BINARY_PATH="target/$TARGET/release/${BINARY_NAME}.exe"
    ARCHIVE_FILE="${ARCHIVE_NAME}.zip"
    ARCHIVE_FORMAT="zip"
else
    BINARY_PATH="target/$TARGET/release/${BINARY_NAME}"
    ARCHIVE_FILE="${ARCHIVE_NAME}.tar.gz"
    ARCHIVE_FORMAT="tar.gz"
fi

# Verify binary exists
if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ Error: Binary not found at $BINARY_PATH"
    exit 1
fi

echo "📍 Binary path: $BINARY_PATH"
echo "📦 Archive file: $ARCHIVE_FILE"
echo "🗜️ Archive format: $ARCHIVE_FORMAT"

# Create archive based on format
if [ "$ARCHIVE_FORMAT" = "zip" ]; then
    echo "🗜️ Creating ZIP archive..."
    if command -v 7z >/dev/null 2>&1; then
        7z a "$ARCHIVE_FILE" "$BINARY_PATH"
    elif command -v zip >/dev/null 2>&1; then
        zip "$ARCHIVE_FILE" "$BINARY_PATH"
    else
        echo "❌ Error: Neither 7z nor zip command found"
        exit 1
    fi
else
    echo "🗜️ Creating TAR.GZ archive..."
    tar -czf "$ARCHIVE_FILE" -C "target/$TARGET/release" "$BINARY_NAME"
fi

# Verify archive was created
if [ ! -f "$ARCHIVE_FILE" ]; then
    echo "❌ Error: Archive not created: $ARCHIVE_FILE"
    exit 1
fi

# Get archive size for reporting
ARCHIVE_SIZE=$(du -h "$ARCHIVE_FILE" | cut -f1)

echo "✅ Archive created successfully"
echo "📦 Archive: $ARCHIVE_FILE"
echo "📏 Size: $ARCHIVE_SIZE"

# Output for GitHub Actions
echo "archive-file=$ARCHIVE_FILE" >> "$GITHUB_OUTPUT"
echo "archive-size=$ARCHIVE_SIZE" >> "$GITHUB_OUTPUT"
