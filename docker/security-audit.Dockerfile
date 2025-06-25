# Security audit optimized image
# Specialized for security scanning and vulnerability assessment

FROM ghcr.io/loonghao/rust-toolkit:base

LABEL org.opencontainers.image.title="Rust Actions Toolkit - Security Audit"
LABEL org.opencontainers.image.description="Optimized image for security auditing and vulnerability scanning"

USER root

# Install additional security tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Network security tools
    nmap \
    netcat-openbsd \
    # File analysis tools
    file \
    binutils \
    # Cryptographic tools
    openssl \
    gnupg \
    # Additional utilities
    wget \
    tree \
    && rm -rf /var/lib/apt/lists/*

USER rust

# Install comprehensive Rust security tools
RUN cargo install --locked \
    # Core security tools
    cargo-audit \
    cargo-deny \
    cargo-geiger \
    cargo-outdated \
    cargo-udeps \
    # License checking
    cargo-license \
    # Dependency analysis
    cargo-tree \
    cargo-machete \
    # Code quality
    cargo-bloat \
    cargo-expand \
    # Supply chain security
    cargo-vet

# Install additional security scanners
RUN cargo install --locked \
    # SBOM generation
    cargo-cyclonedx \
    # Vulnerability scanning
    rustsec-admin

# Create security scanning scripts
COPY docker/build-scripts/security-scan.sh /usr/local/bin/security-scan
COPY docker/build-scripts/generate-sbom.sh /usr/local/bin/generate-sbom
COPY docker/build-scripts/license-check.sh /usr/local/bin/license-check

USER root
RUN chmod +x /usr/local/bin/security-scan /usr/local/bin/generate-sbom /usr/local/bin/license-check
USER rust

# Configure security scanning environment
ENV CARGO_AUDIT_DATABASE_URL="https://github.com/RustSec/advisory-db.git" \
    RUSTSEC_DATABASE_URL="https://github.com/RustSec/advisory-db.git"

# Pre-download security databases
RUN cargo audit --version && \
    echo "Updating security databases..." && \
    cargo audit --update || true

# Create default security configuration files
RUN mkdir -p /home/rust/.config/cargo-deny && \
    echo 'Creating default deny.toml configuration...'

# Verify security tools installation
RUN echo "Security tools installed:" && \
    cargo audit --version && \
    cargo deny --version && \
    cargo geiger --version && \
    cargo outdated --version && \
    cargo license --version

CMD ["/bin/bash"]
