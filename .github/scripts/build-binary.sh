#!/bin/bash
set -euo pipefail

# Script to build Rust binary for specific target
# Usage: ./build-binary.sh <binary-name> <target>

BINARY_NAME="${1:?Binary name is required}"
TARGET="${2:?Target is required}"

echo "🔨 Building $BINARY_NAME for $TARGET"

# Check if binary exists in Cargo.toml
if ! grep -q "name = \"$BINARY_NAME\"" Cargo.toml; then
    echo "❌ Error: Binary '$BINARY_NAME' not found in Cargo.toml"
    echo "Available binaries:"
    grep "name = " Cargo.toml || echo "  No binaries found"
    exit 1
fi

# Build the binary
echo "🚀 Starting build process..."
vx cargo build --release --target "$TARGET" --bin "$BINARY_NAME"

# Verify the binary was created
BINARY_PATH="target/$TARGET/release/$BINARY_NAME"
if [[ "$TARGET" == *"windows"* ]]; then
    BINARY_PATH="${BINARY_PATH}.exe"
fi

if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ Error: Binary not found at $BINARY_PATH"
    exit 1
fi

echo "✅ Build completed successfully"
echo "📍 Binary location: $BINARY_PATH"
echo "binary-path=$BINARY_PATH" >> "$GITHUB_OUTPUT"
