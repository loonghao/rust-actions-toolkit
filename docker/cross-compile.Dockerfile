# Cross-compilation optimized image
# Specialized for building Rust binaries for multiple targets

FROM ghcr.io/loonghao/rust-toolkit:base

LABEL org.opencontainers.image.title="Rust Actions Toolkit - Cross Compile"
LABEL org.opencontainers.image.description="Optimized image for cross-compilation with pre-configured toolchains"

USER root

# Install essential cross-compilation dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Windows cross-compilation
    gcc-mingw-w64-x86-64 \
    gcc-mingw-w64-i686 \
    mingw-w64-tools \
    # Wine for testing Windows binaries
    wine \
    wine64 \
    # ARM support (already installed in base image: gcc-aarch64-linux-gnu, gcc-arm-linux-gnueabihf)
    gcc-arm-linux-gnueabi \
    && rm -rf /var/lib/apt/lists/*

USER root

# Fix cargo permissions for rust user
RUN chown -R rust:rust /usr/local/cargo && \
    chmod -R 755 /usr/local/cargo

USER rust

# Install essential Rust targets (optimized for 2025 mainstream platforms)
# Install targets in separate layers for better caching
# Core platforms (highest priority)
RUN rustup target add x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu
RUN rustup target add x86_64-apple-darwin aarch64-apple-darwin
RUN rustup target add x86_64-pc-windows-msvc
# Static linking platforms (important for zero-dependency builds)
RUN rustup target add x86_64-unknown-linux-musl aarch64-unknown-linux-musl
# GNU Windows (lower priority, but useful for specific use cases)
RUN rustup target add x86_64-pc-windows-gnu

# Configure cross-compilation linkers for essential targets
ENV CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc \
    CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc \
    # Windows-specific environment
    WINEARCH=win64 \
    WINEPREFIX=/home/rust/.wine \
    # Fix mimalloc cross-compilation issues for GNU targets
    CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc-posix \
    CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++-posix \
    AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar

# Install cross for additional target support
RUN cargo install cross --locked

# Create a script for easy cross-compilation
COPY docker/build-scripts/cross-build.sh /usr/local/bin/cross-build
USER root
RUN chmod +x /usr/local/bin/cross-build
USER rust

# Zero-dependency build configuration for all targets
ENV RUSTFLAGS_BASE="-C target-feature=+crt-static" \
    # Windows static linking (GNU targets)
    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS="-C target-feature=+crt-static -C link-args=-static" \
    # Windows MSVC static linking
    CARGO_TARGET_X86_64_PC_WINDOWS_MSVC_RUSTFLAGS="-C target-feature=+crt-static" \
    # Linux musl static linking (already static by default, but ensure it)
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=+crt-static" \
    CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=+crt-static" \
    # Ensure OpenSSL is statically linked
    OPENSSL_STATIC=1 \
    OPENSSL_NO_VENDOR=1

# Create a script to verify zero-dependency builds
COPY docker/build-scripts/verify-static.sh /usr/local/bin/verify-static
USER root
RUN chmod +x /usr/local/bin/verify-static
USER rust

# Verify cross-compilation setup
RUN echo "Available Rust targets:" && rustup target list --installed

CMD ["/bin/bash"]
