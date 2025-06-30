#!/bin/bash
set -euo pipefail

# Script to setup build environment and validate configuration
# Usage: ./setup-build-env.sh <target> <toolchain>

TARGET="${1:?Target is required}"
TOOLCHAIN="${2:-stable}"

echo "🔧 Setting up build environment"
echo "🎯 Target: $TARGET"
echo "🦀 Toolchain: $TOOLCHAIN"

# Validate target is supported
case "$TARGET" in
    x86_64-unknown-linux-gnu|aarch64-unknown-linux-gnu)
        echo "🐧 Linux target detected"
        ;;
    x86_64-apple-darwin|aarch64-apple-darwin)
        echo "🍎 macOS target detected"
        ;;
    x86_64-pc-windows-msvc|i686-pc-windows-msvc)
        echo "🪟 Windows target detected"
        ;;
    *)
        echo "⚠️ Warning: Uncommon target $TARGET - proceeding anyway"
        ;;
esac

# Check if we're cross-compiling
HOST_TARGET=$(rustc -vV | grep host | cut -d' ' -f2)
if [ "$HOST_TARGET" != "$TARGET" ]; then
    echo "🔄 Cross-compilation detected: $HOST_TARGET -> $TARGET"
    echo "⚠️ Note: This workflow is designed for native builds"
else
    echo "✅ Native compilation: $HOST_TARGET"
fi

# Validate Cargo.toml exists
if [ ! -f "Cargo.toml" ]; then
    echo "❌ Error: Cargo.toml not found"
    exit 1
fi

echo "📋 Cargo.toml found"

# Check for common issues
if grep -q "proc-macro = true" Cargo.toml; then
    echo "🔧 Proc-macro crate detected - native builds handle this correctly"
fi

if [ -f "Cargo.lock" ]; then
    echo "🔒 Cargo.lock found - using locked dependencies"
else
    echo "📦 No Cargo.lock - will use latest compatible versions"
fi

echo "✅ Build environment setup complete"
