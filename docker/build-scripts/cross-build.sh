#!/bin/bash
# Cross-compilation build script
# Usage: cross-build.sh <target> [additional-cargo-args]

set -euo pipefail

TARGET="${1:-x86_64-unknown-linux-musl}"
shift || true
CARGO_ARGS="$*"

echo "🎯 Cross-compiling for target: $TARGET"
echo "📦 Additional cargo args: $CARGO_ARGS"

# Check if target is installed
if ! rustup target list --installed | grep -q "^$TARGET$"; then
    echo "📥 Installing target: $TARGET"
    rustup target add "$TARGET"
fi

# Configure target-specific environment
case "$TARGET" in
    *-musl)
        echo "🔧 Configuring musl target environment"
        export OPENSSL_STATIC=1
        export PKG_CONFIG_ALLOW_CROSS=1
        ;;
    *-windows-*)
        echo "🔧 Configuring Windows target environment"
        export RUSTFLAGS="${RUSTFLAGS:-} -C target-feature=+crt-static"
        # Fix mimalloc cross-compilation issues
        export CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG=true
        if [[ "$TARGET" == "i686-pc-windows-gnu" ]]; then
            export CC_i686_pc_windows_gnu=i686-w64-mingw32-gcc-posix
            export CXX_i686_pc_windows_gnu=i686-w64-mingw32-g++-posix
            export AR_i686_pc_windows_gnu=i686-w64-mingw32-ar
        elif [[ "$TARGET" == "x86_64-pc-windows-gnu" ]]; then
            export CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc-posix
            export CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++-posix
            export AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar
        fi
        ;;
    aarch64-*)
        echo "🔧 Configuring ARM64 target environment"
        export CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc
        export CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++
        ;;
    armv7-*)
        echo "🔧 Configuring ARM target environment"
        export CC_armv7_unknown_linux_gnueabihf=arm-linux-gnueabihf-gcc
        export CXX_armv7_unknown_linux_gnueabihf=arm-linux-gnueabihf-g++
        ;;
esac

# Build the project
echo "🔨 Building project..."
if command -v cross >/dev/null 2>&1 && [[ "$TARGET" != "x86_64-unknown-linux-gnu" ]]; then
    echo "📦 Using cross for compilation"
    cross build --target "$TARGET" --release $CARGO_ARGS
else
    echo "📦 Using cargo for compilation"
    cargo build --target "$TARGET" --release $CARGO_ARGS
fi

echo "✅ Build completed successfully!"

# Show build artifacts
BINARY_PATH="target/$TARGET/release"
if [[ -d "$BINARY_PATH" ]]; then
    echo "📁 Build artifacts in $BINARY_PATH:"
    ls -la "$BINARY_PATH"
fi
