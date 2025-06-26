# Base Rust toolkit image with common dependencies
# This serves as the foundation for all specialized images
# Updated: 2025-06-26 - Fixed branch configuration for Docker builds
# Trigger build: 2025-06-26 15:35

FROM ubuntu:24.04

LABEL org.opencontainers.image.title="Rust Actions Toolkit - Base"
LABEL org.opencontainers.image.description="Base image with Rust toolchain and common build dependencies"
LABEL org.opencontainers.image.vendor="loonghao"
LABEL org.opencontainers.image.source="https://github.com/loonghao/rust-actions-toolkit"

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    pkg-config \
    curl \
    git \
    ca-certificates \
    # OpenSSL development libraries
    libssl-dev \
    # Cross-compilation tools
    musl-tools \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu \
    # Additional utilities
    jq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.83.0

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION && \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME

# Install common Rust components
RUN rustup component add rustfmt clippy && \
    rustup target add \
        x86_64-unknown-linux-musl \
        aarch64-unknown-linux-gnu \
        aarch64-unknown-linux-musl \
        armv7-unknown-linux-gnueabihf \
        riscv64gc-unknown-linux-gnu

# Install essential Rust tools
# Only install cross for now to minimize base image build time
# Other tools are installed in specialized images for better caching
RUN cargo install cross@0.2.5

# Configure OpenSSL for cross-compilation
ENV OPENSSL_STATIC=1 \
    OPENSSL_LIB_DIR=/usr/lib/x86_64-linux-gnu \
    OPENSSL_INCLUDE_DIR=/usr/include/openssl \
    PKG_CONFIG_ALLOW_CROSS=1

# Configure cross-compilation linkers
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc \
    CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc \
    CARGO_TARGET_RISCV64GC_UNKNOWN_LINUX_GNU_LINKER=riscv64-linux-gnu-gcc

# Set up working directory
WORKDIR /workspace

# Create non-root user for security
RUN if ! getent group rust > /dev/null 2>&1; then groupadd --gid 1001 rust; fi && \
    if ! getent passwd rust > /dev/null 2>&1; then useradd --uid 1001 --gid 1001 --shell /bin/bash --create-home rust; fi && \
    chown -R rust:rust /workspace && \
    chown -R rust:rust $RUSTUP_HOME $CARGO_HOME

USER rust

# Verify installation
RUN rustc --version && \
    cargo --version && \
    rustfmt --version && \
    cargo clippy --version

CMD ["/bin/bash"]
