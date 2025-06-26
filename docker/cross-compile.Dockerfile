# Cross-compilation optimized image
# Specialized for building Rust binaries for multiple targets

FROM ghcr.io/loonghao/rust-toolkit:base

LABEL org.opencontainers.image.title="Rust Actions Toolkit - Cross Compile"
LABEL org.opencontainers.image.description="Optimized image for cross-compilation with pre-configured toolchains"

USER root

# Install additional cross-compilation dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Windows cross-compilation
    gcc-mingw-w64-x86-64 \
    gcc-mingw-w64-i686 \
    mingw-w64-tools \
    # Wine for testing Windows binaries
    wine \
    wine64 \
    # Additional ARM variants
    gcc-arm-linux-gnueabi \
    # MIPS support
    gcc-mips-linux-gnu \
    gcc-mipsel-linux-gnu \
    gcc-mips64-linux-gnuabi64 \
    gcc-mips64el-linux-gnuabi64 \
    # PowerPC support
    gcc-powerpc-linux-gnu \
    gcc-powerpc64-linux-gnu \
    gcc-powerpc64le-linux-gnu \
    # S390x support
    gcc-s390x-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

USER root

# Fix cargo permissions for rust user
RUN chown -R rust:rust /usr/local/cargo && \
    chmod -R 755 /usr/local/cargo

USER rust

# Install additional Rust targets for comprehensive cross-compilation
RUN rustup target add \
    # Windows targets
    x86_64-pc-windows-gnu \
    i686-pc-windows-gnu \
    # Additional Linux targets
    i686-unknown-linux-gnu \
    i686-unknown-linux-musl \
    armv5te-unknown-linux-gnueabi \
    armv7-unknown-linux-musleabihf \
    aarch64-unknown-linux-musl \
    # MIPS targets
    mips-unknown-linux-gnu \
    mipsel-unknown-linux-gnu \
    mips64-unknown-linux-gnuabi64 \
    mips64el-unknown-linux-gnuabi64 \
    # PowerPC targets
    powerpc-unknown-linux-gnu \
    powerpc64-unknown-linux-gnu \
    powerpc64le-unknown-linux-gnu \
    # S390x target
    s390x-unknown-linux-gnu \
    # RISC-V targets
    riscv64gc-unknown-linux-gnu

# Configure additional cross-compilation linkers
ENV CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc \
    CARGO_TARGET_I686_PC_WINDOWS_GNU_LINKER=i686-w64-mingw32-gcc \
    # Windows-specific environment
    WINEARCH=win64 \
    WINEPREFIX=/home/rust/.wine \
    CARGO_TARGET_I686_UNKNOWN_LINUX_GNU_LINKER=i686-linux-gnu-gcc \
    CARGO_TARGET_ARMV5TE_UNKNOWN_LINUX_GNUEABI_LINKER=arm-linux-gnueabi-gcc \
    CARGO_TARGET_MIPS_UNKNOWN_LINUX_GNU_LINKER=mips-linux-gnu-gcc \
    CARGO_TARGET_MIPSEL_UNKNOWN_LINUX_GNU_LINKER=mipsel-linux-gnu-gcc \
    CARGO_TARGET_MIPS64_UNKNOWN_LINUX_GNUABI64_LINKER=mips64-linux-gnuabi64-gcc \
    CARGO_TARGET_MIPS64EL_UNKNOWN_LINUX_GNUABI64_LINKER=mips64el-linux-gnuabi64-gcc \
    CARGO_TARGET_POWERPC_UNKNOWN_LINUX_GNU_LINKER=powerpc-linux-gnu-gcc \
    CARGO_TARGET_POWERPC64_UNKNOWN_LINUX_GNU_LINKER=powerpc64-linux-gnu-gcc \
    CARGO_TARGET_POWERPC64LE_UNKNOWN_LINUX_GNU_LINKER=powerpc64le-linux-gnu-gcc \
    CARGO_TARGET_S390X_UNKNOWN_LINUX_GNU_LINKER=s390x-linux-gnu-gcc \
    CARGO_TARGET_RISCV64GC_UNKNOWN_LINUX_GNU_LINKER=riscv64-linux-gnu-gcc

# Install cross for additional target support
RUN cargo install cross --locked

# Create a script for easy cross-compilation
COPY docker/build-scripts/cross-build.sh /usr/local/bin/cross-build
USER root
RUN chmod +x /usr/local/bin/cross-build
USER rust

# Zero-dependency build configuration for all targets
ENV RUSTFLAGS_BASE="-C target-feature=+crt-static" \
    # Windows static linking
    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS="-C target-feature=+crt-static -C link-args=-static" \
    CARGO_TARGET_I686_PC_WINDOWS_GNU_RUSTFLAGS="-C target-feature=+crt-static -C link-args=-static" \
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
