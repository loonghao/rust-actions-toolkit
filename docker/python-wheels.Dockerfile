# Python wheels building optimized image
# Specialized for building Python extensions with Rust (PyO3/maturin)

FROM ghcr.io/loonghao/rust-toolkit:base

LABEL org.opencontainers.image.title="Rust Actions Toolkit - Python Wheels"
LABEL org.opencontainers.image.description="Optimized image for building Python wheels with Rust extensions"

USER root

# Install Python development dependencies (simplified for Ubuntu 24.04)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Python development (use system default Python 3.12 in Ubuntu 24.04)
    python3-dev \
    python3-pip \
    python3-venv \
    python3-full \
    # Wheel building dependencies
    && python3 -m pip install --upgrade pip setuptools wheel --break-system-packages \
    && rm -rf /var/lib/apt/lists/*

# Install maturin and related tools
RUN python3 -m pip install --break-system-packages \
    maturin[patchelf] \
    cibuildwheel \
    auditwheel \
    twine \
    build

USER root

# Fix cargo permissions for rust user
RUN chown -R rust:rust /usr/local/cargo && \
    chmod -R 755 /usr/local/cargo

USER rust

# Install PyO3 and related Rust crates (pre-compile for faster builds)
RUN cargo install maturin --locked

# Create a single Python virtual environment
RUN python3 -m venv /home/rust/.venv/default && \
    /home/rust/.venv/default/bin/pip install --upgrade pip && \
    /home/rust/.venv/default/bin/pip install maturin[patchelf]

# Configure environment for wheel building
ENV MATURIN_PEP517_ARGS="--compatibility linux"

# Create helper scripts
COPY docker/build-scripts/build-wheels.sh /usr/local/bin/build-wheels
COPY docker/build-scripts/test-wheels.sh /usr/local/bin/test-wheels

USER root
RUN chmod +x /usr/local/bin/build-wheels /usr/local/bin/test-wheels
USER rust

# Verify Python and maturin installation
RUN echo "Python version:" && \
    python3 --version && \
    echo "Maturin version:" && \
    maturin --version

CMD ["/bin/bash"]
