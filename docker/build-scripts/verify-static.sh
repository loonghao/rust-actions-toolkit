#!/bin/bash
# Static linking verification script
# Usage: verify-static.sh <binary-path> [target]

set -euo pipefail

BINARY_PATH="${1:-}"
TARGET="${2:-$(rustc -vV | grep host | cut -d' ' -f2)}"

if [[ -z "$BINARY_PATH" ]]; then
    echo "Usage: verify-static.sh <binary-path> [target]"
    echo "Example: verify-static.sh target/x86_64-unknown-linux-musl/release/my-app x86_64-unknown-linux-musl"
    exit 1
fi

if [[ ! -f "$BINARY_PATH" ]]; then
    echo "❌ Binary not found: $BINARY_PATH"
    exit 1
fi

echo "🔍 Verifying static linking for: $BINARY_PATH"
echo "🎯 Target: $TARGET"
echo "📏 File size: $(du -h "$BINARY_PATH" | cut -f1)"

# Determine binary type and verification method
case "$TARGET" in
    *-windows-*)
        echo "🪟 Windows binary detected"
        verify_windows_binary "$BINARY_PATH"
        ;;
    *-linux-musl)
        echo "🐧 Linux musl binary detected"
        verify_linux_musl_binary "$BINARY_PATH"
        ;;
    *-linux-gnu)
        echo "🐧 Linux GNU binary detected"
        verify_linux_gnu_binary "$BINARY_PATH"
        ;;
    *-apple-darwin)
        echo "🍎 macOS binary detected"
        verify_macos_binary "$BINARY_PATH"
        ;;
    *)
        echo "❓ Unknown target, using generic verification"
        verify_generic_binary "$BINARY_PATH"
        ;;
esac

# Windows binary verification
verify_windows_binary() {
    local binary="$1"
    
    echo "🔍 Checking Windows PE dependencies..."
    
    # Use objdump if available
    if command -v x86_64-w64-mingw32-objdump >/dev/null 2>&1; then
        echo "📋 DLL dependencies:"
        x86_64-w64-mingw32-objdump -p "$binary" | grep "DLL Name:" || echo "✅ No external DLL dependencies found!"
    elif command -v objdump >/dev/null 2>&1; then
        echo "📋 DLL dependencies:"
        objdump -p "$binary" | grep "DLL Name:" || echo "✅ No external DLL dependencies found!"
    else
        echo "⚠️  objdump not available, cannot verify DLL dependencies"
    fi
    
    # Check file type
    if command -v file >/dev/null 2>&1; then
        echo "📄 File type:"
        file "$binary"
    fi
    
    # Test with Wine if available
    if command -v wine >/dev/null 2>&1; then
        echo "🍷 Testing with Wine..."
        timeout 5s wine "$binary" --version 2>/dev/null || echo "Wine test completed"
    fi
}

# Linux musl binary verification
verify_linux_musl_binary() {
    local binary="$1"
    
    echo "🔍 Checking Linux musl static linking..."
    
    # Check for dynamic dependencies
    if command -v ldd >/dev/null 2>&1; then
        echo "📋 Dynamic dependencies:"
        if ldd "$binary" 2>&1 | grep -q "not a dynamic executable"; then
            echo "✅ Statically linked - no dynamic dependencies!"
        else
            echo "⚠️  Dynamic dependencies found:"
            ldd "$binary"
        fi
    fi
    
    # Check with readelf
    if command -v readelf >/dev/null 2>&1; then
        echo "📋 ELF interpreter:"
        if readelf -l "$binary" | grep -q "INTERP"; then
            readelf -l "$binary" | grep -A1 "INTERP"
            echo "⚠️  Dynamic interpreter found - not fully static"
        else
            echo "✅ No dynamic interpreter - fully static!"
        fi
    fi
    
    # Check file type
    if command -v file >/dev/null 2>&1; then
        echo "📄 File type:"
        file "$binary"
    fi
}

# Linux GNU binary verification
verify_linux_gnu_binary() {
    local binary="$1"
    
    echo "🔍 Checking Linux GNU linking..."
    echo "⚠️  Note: GNU targets may have some dynamic dependencies"
    
    # Check for dynamic dependencies
    if command -v ldd >/dev/null 2>&1; then
        echo "📋 Dynamic dependencies:"
        ldd "$binary" || echo "Static binary or ldd failed"
    fi
    
    # Check with readelf
    if command -v readelf >/dev/null 2>&1; then
        echo "📋 Dynamic section:"
        readelf -d "$binary" | head -20 || echo "No dynamic section"
    fi
    
    # Check file type
    if command -v file >/dev/null 2>&1; then
        echo "📄 File type:"
        file "$binary"
    fi
}

# macOS binary verification
verify_macos_binary() {
    local binary="$1"
    
    echo "🔍 Checking macOS binary linking..."
    
    # Use otool if available (unlikely in Linux container)
    if command -v otool >/dev/null 2>&1; then
        echo "📋 Dynamic libraries:"
        otool -L "$binary"
    else
        echo "⚠️  otool not available (expected in cross-compilation environment)"
    fi
    
    # Check file type
    if command -v file >/dev/null 2>&1; then
        echo "📄 File type:"
        file "$binary"
    fi
}

# Generic binary verification
verify_generic_binary() {
    local binary="$1"
    
    echo "🔍 Generic binary verification..."
    
    # Check file type
    if command -v file >/dev/null 2>&1; then
        echo "📄 File type:"
        file "$binary"
    fi
    
    # Try strings to find clues about dependencies
    if command -v strings >/dev/null 2>&1; then
        echo "📋 Checking for common library references..."
        if strings "$binary" | grep -E "(\.so\.|\.dll|\.dylib)" | head -10; then
            echo "⚠️  Found potential library references"
        else
            echo "✅ No obvious library references found"
        fi
    fi
}

# Summary
echo ""
echo "📊 Verification Summary:"
echo "🎯 Target: $TARGET"
echo "📁 Binary: $BINARY_PATH"
echo "📏 Size: $(du -h "$BINARY_PATH" | cut -f1)"

# Provide recommendations
case "$TARGET" in
    *-windows-gnu)
        echo "💡 Windows GNU: Should be zero-dependency with static CRT"
        ;;
    *-linux-musl)
        echo "💡 Linux musl: Should be fully static and portable"
        ;;
    *-linux-gnu)
        echo "💡 Linux GNU: May depend on glibc, but other deps should be static"
        ;;
    *)
        echo "💡 Check target-specific documentation for dependency expectations"
        ;;
esac

echo "✅ Verification completed!"
