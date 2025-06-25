#!/bin/bash
# Windows executable building script
# Usage: build-windows.sh [target] [binary-name] [additional-args]

set -euo pipefail

TARGET="${1:-x86_64-pc-windows-gnu}"
BINARY_NAME="${2:-$(basename $(pwd))}"
shift 2 || true
ADDITIONAL_ARGS="$*"

echo "🪟 Building Windows executable"
echo "🎯 Target: $TARGET"
echo "📦 Binary name: $BINARY_NAME"
echo "⚙️  Additional args: $ADDITIONAL_ARGS"

# Validate Windows target
case "$TARGET" in
    x86_64-pc-windows-gnu|i686-pc-windows-gnu|x86_64-pc-windows-msvc|i686-pc-windows-msvc)
        echo "✅ Valid Windows target: $TARGET"
        ;;
    *)
        echo "❌ Invalid Windows target: $TARGET"
        echo "Supported targets: x86_64-pc-windows-gnu, i686-pc-windows-gnu, x86_64-pc-windows-msvc, i686-pc-windows-msvc"
        exit 1
        ;;
esac

# Check if target is installed
if ! rustup target list --installed | grep -q "^$TARGET$"; then
    echo "📥 Installing target: $TARGET"
    rustup target add "$TARGET"
fi

# Configure target-specific environment for ZERO-DEPENDENCY builds
case "$TARGET" in
    *-windows-gnu)
        echo "🔧 Configuring GNU Windows toolchain for ZERO-DEPENDENCY build"
        # Force static linking of everything
        export RUSTFLAGS="${RUSTFLAGS:-} -C target-feature=+crt-static -C link-args=-static"
        export OPENSSL_STATIC=1
        export OPENSSL_NO_VENDOR=1

        if [[ "$TARGET" == "x86_64-pc-windows-gnu" ]]; then
            export CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
            export CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++
            export AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar
        elif [[ "$TARGET" == "i686-pc-windows-gnu" ]]; then
            export CC_i686_pc_windows_gnu=i686-w64-mingw32-gcc
            export CXX_i686_pc_windows_gnu=i686-w64-mingw32-g++
            export AR_i686_pc_windows_gnu=i686-w64-mingw32-ar
        fi
        ;;
    *-windows-msvc)
        echo "🔧 Configuring MSVC Windows toolchain for ZERO-DEPENDENCY build"
        echo "⚠️  MSVC targets require Windows runner or cross-compilation setup"
        # Force static CRT linking
        export RUSTFLAGS="${RUSTFLAGS:-} -C target-feature=+crt-static"
        export OPENSSL_STATIC=1
        ;;
esac

# Build the executable
echo "🔨 Building Windows executable..."
if command -v cross >/dev/null 2>&1 && [[ "$TARGET" == *-windows-gnu ]]; then
    echo "📦 Using cross for Windows GNU compilation"
    cross build --target "$TARGET" --release --bin "$BINARY_NAME" $ADDITIONAL_ARGS
else
    echo "📦 Using cargo for Windows compilation"
    cargo build --target "$TARGET" --release --bin "$BINARY_NAME" $ADDITIONAL_ARGS
fi

# Verify build
RELEASE_DIR="target/$TARGET/release"
EXE_FILE="$RELEASE_DIR/$BINARY_NAME.exe"

if [[ -f "$EXE_FILE" ]]; then
    echo "✅ Windows executable built successfully!"
    echo "📁 Location: $EXE_FILE"
    echo "📊 File info:"
    ls -la "$EXE_FILE"
    file "$EXE_FILE" || true
    
    # Get file size in human readable format
    SIZE=$(du -h "$EXE_FILE" | cut -f1)
    echo "📏 Size: $SIZE"
    
    # Verify zero-dependency build
    echo "🔍 Verifying zero-dependency build..."
    if command -v verify-static >/dev/null 2>&1; then
        verify-static "$EXE_FILE" "$TARGET"
    else
        echo "⚠️  verify-static script not available, performing basic checks..."

        # Basic Windows PE dependency check
        if command -v objdump >/dev/null 2>&1; then
            echo "📋 Checking DLL dependencies:"
            if objdump -p "$EXE_FILE" | grep "DLL Name:" | grep -v -E "(KERNEL32.dll|msvcrt.dll|USER32.dll|ADVAPI32.dll)"; then
                echo "⚠️  Found unexpected DLL dependencies"
            else
                echo "✅ Only expected system DLLs found (or none)"
            fi
        fi
    fi

    # Try to get version info if possible
    if command -v wine >/dev/null 2>&1; then
        echo "🍷 Testing with Wine..."
        timeout 10s wine "$EXE_FILE" --version 2>/dev/null || echo "Wine test completed (may have timed out)"
    fi
    
    # Check for debug symbols
    PDB_FILE="$RELEASE_DIR/$BINARY_NAME.pdb"
    if [[ -f "$PDB_FILE" ]]; then
        echo "🔍 Debug symbols found: $PDB_FILE"
        ls -la "$PDB_FILE"
    fi
    
else
    echo "❌ Failed to build Windows executable"
    echo "Expected location: $EXE_FILE"
    echo "Available files in release directory:"
    ls -la "$RELEASE_DIR" || echo "Release directory not found"
    exit 1
fi

# Create Windows-specific package
echo "📦 Creating Windows package..."
PACKAGE_DIR="windows-package"
mkdir -p "$PACKAGE_DIR"

# Copy executable
cp "$EXE_FILE" "$PACKAGE_DIR/"

# Copy debug symbols if available
if [[ -f "$PDB_FILE" ]]; then
    cp "$PDB_FILE" "$PACKAGE_DIR/"
fi

# Create README for Windows users
cat > "$PACKAGE_DIR/README.txt" << EOF
$BINARY_NAME - Windows Executable
================================

This package contains the Windows executable for $BINARY_NAME.

Files included:
- $BINARY_NAME.exe - Main executable
$(if [[ -f "$PDB_FILE" ]]; then echo "- $BINARY_NAME.pdb - Debug symbols"; fi)

System Requirements:
- Windows 7 or later (64-bit recommended)
- No additional dependencies required (statically linked)

Usage:
1. Extract this package to a folder
2. Run $BINARY_NAME.exe from Command Prompt or PowerShell
3. For help, run: $BINARY_NAME.exe --help

Built with:
- Target: $TARGET
- Rust toolchain: $(rustc --version)
- Build date: $(date)

For more information, visit: https://github.com/your-repo
EOF

# Create ZIP package
if command -v zip >/dev/null 2>&1; then
    ZIP_NAME="${BINARY_NAME}-${TARGET}.zip"
    cd "$PACKAGE_DIR"
    zip -r "../$ZIP_NAME" .
    cd ..
    echo "📦 Windows package created: $ZIP_NAME"
    ls -la "$ZIP_NAME"
else
    echo "⚠️  zip command not available, package directory created: $PACKAGE_DIR"
fi

echo "🎉 Windows build completed successfully!"
echo "📁 Executable: $EXE_FILE"
echo "📦 Package: $PACKAGE_DIR"
