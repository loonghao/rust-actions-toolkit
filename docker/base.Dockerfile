# Base Rust toolkit image with common dependencies
# This serves as the foundation for all specialized images
# Updated: 2025-06-26 - Fixed branch configuration for Docker builds
# Trigger build: 2025-06-26 15:35

# Accept Rust version as build argument
ARG RUST_VERSION=stable

FROM ubuntu:24.04

LABEL org.opencontainers.image.title="Rust Actions Toolkit - Base"
LABEL org.opencontainers.image.description="Base image with Rust toolchain and common build dependencies"
LABEL org.opencontainers.image.vendor="loonghao"
LABEL org.opencontainers.image.source="https://github.com/loonghao/rust-actions-toolkit"

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies in layers for better caching
# Layer 1: Essential build tools (changes rarely)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Development libraries and git (changes occasionally)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libssl-dev \
    jq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Layer 2.5: Install GitHub CLI (needed for release-plz and other GitHub operations)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Layer 3: Cross-compilation tools (changes rarely, but large)
RUN apt-get update && apt-get install -y --no-install-recommends \
    musl-tools \
    musl-dev \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu \
    libc6-dev-arm64-cross \
    libc6-dev-armhf-cross \
    && rm -rf /var/lib/apt/lists/*

# Re-declare ARG after FROM (ARG before FROM is not available after FROM)
ARG RUST_VERSION=stable

# Install Rust toolchain
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=${RUST_VERSION}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --profile minimal --default-toolchain stable && \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME

# Install common Rust components
RUN rustup component add rustfmt clippy && \
    rustup target add \
        # Zero-dependency Windows builds
        x86_64-pc-windows-gnu \
        i686-pc-windows-gnu \
        # Static Linux builds
        x86_64-unknown-linux-musl \
        aarch64-unknown-linux-musl \
        # Standard builds
        x86_64-unknown-linux-gnu \
        aarch64-unknown-linux-gnu \
        x86_64-apple-darwin \
        aarch64-apple-darwin

# Install essential Rust tools with caching optimization
# Use --locked for reproducible builds and better caching
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo install --locked cross@0.2.5

# Configure OpenSSL for cross-compilation
ENV OPENSSL_STATIC=1 \
    OPENSSL_LIB_DIR=/usr/lib/x86_64-linux-gnu \
    OPENSSL_INCLUDE_DIR=/usr/include/openssl \
    PKG_CONFIG_ALLOW_CROSS=1

# Configure cross-compilation linkers for GNU targets
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc \
    CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc \
    CARGO_TARGET_RISCV64GC_UNKNOWN_LINUX_GNU_LINKER=riscv64-linux-gnu-gcc

# Configure musl targets - use GNU gcc with musl flags
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-linux-gnu-gcc \
    CC_aarch64_unknown_linux_musl=aarch64-linux-gnu-gcc \
    CXX_aarch64_unknown_linux_musl=aarch64-linux-gnu-g++ \
    AR_aarch64_unknown_linux_musl=aarch64-linux-gnu-ar \
    CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=+crt-static"

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
