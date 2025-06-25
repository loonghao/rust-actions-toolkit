# Base Rust toolkit image with common dependencies
# This serves as the foundation for all specialized images

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
    RUST_VERSION=1.75.0

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

# Install common Rust tools
RUN cargo install --locked \
    cargo-audit \
    cargo-deny \
    cargo-outdated \
    cross

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
RUN groupadd --gid 1000 rust && \
    useradd --uid 1000 --gid rust --shell /bin/bash --create-home rust && \
    chown -R rust:rust /workspace

USER rust

# Verify installation
RUN rustc --version && \
    cargo --version && \
    rustfmt --version && \
    cargo clippy --version

CMD ["/bin/bash"]
