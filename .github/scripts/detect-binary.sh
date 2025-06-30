#!/bin/bash
set -euo pipefail

# Script to detect binary name from Cargo.toml or use provided name
# Usage: ./detect-binary.sh [binary-name]

BINARY_NAME="${1:-}"

if [ -n "$BINARY_NAME" ]; then
    echo "📦 Using specified binary name: $BINARY_NAME"
    echo "binary-name=$BINARY_NAME" >> "$GITHUB_OUTPUT"
else
    echo "🔍 Auto-detecting binary name from Cargo.toml..."
    
    if [ ! -f "Cargo.toml" ]; then
        echo "❌ Error: Cargo.toml not found"
        exit 1
    fi
    
    # Extract binary name from Cargo.toml
    DETECTED_NAME=$(grep '^name = ' Cargo.toml | head -1 | sed 's/name = "\(.*\)"/\1/')
    
    if [ -z "$DETECTED_NAME" ]; then
        echo "❌ Error: Could not detect binary name from Cargo.toml"
        exit 1
    fi
    
    echo "📦 Auto-detected binary name: $DETECTED_NAME"
    echo "binary-name=$DETECTED_NAME" >> "$GITHUB_OUTPUT"
fi
