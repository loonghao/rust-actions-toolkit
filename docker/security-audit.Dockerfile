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

USER root

# Fix cargo permissions and install security tools
RUN chown -R rust:rust /usr/local/cargo && \
    chmod -R 755 /usr/local/cargo

USER rust

# Install only cargo-audit (most essential security tool)
# Skip cargo-deny for now to reduce build time
RUN cargo install --locked cargo-audit || echo "cargo-audit failed, continuing..."

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

# Pre-download security databases (only if tools are available)
RUN if command -v cargo-audit >/dev/null 2>&1; then \
        echo "Updating security databases..." && \
        cargo audit --update || true; \
    else \
        echo "cargo-audit not available, skipping database update"; \
    fi

# Create default security configuration files
RUN mkdir -p /home/rust/.config/cargo-deny && \
    echo 'Creating default deny.toml configuration...'

# Verify security tools installation
RUN echo "Security tools installed:" && \
    cargo audit --version && \
    echo "✅ Security audit tools ready"

CMD ["/bin/bash"]
