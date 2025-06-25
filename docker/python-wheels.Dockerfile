# Python wheels building optimized image
# Specialized for building Python extensions with Rust (PyO3/maturin)

FROM ghcr.io/loonghao/rust-toolkit:base

LABEL org.opencontainers.image.title="Rust Actions Toolkit - Python Wheels"
LABEL org.opencontainers.image.description="Optimized image for building Python wheels with Rust extensions"

USER root

# Install Python development dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Python development
    python3-dev \
    python3-pip \
    python3-venv \
    # Additional Python versions (using deadsnakes PPA)
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.8 \
        python3.8-dev \
        python3.8-venv \
        python3.9 \
        python3.9-dev \
        python3.9-venv \
        python3.10 \
        python3.10-dev \
        python3.10-venv \
        python3.11 \
        python3.11-dev \
        python3.11-venv \
        python3.12 \
        python3.12-dev \
        python3.12-venv \
    # Wheel building dependencies
    && python3 -m pip install --upgrade pip setuptools wheel \
    && rm -rf /var/lib/apt/lists/*

# Install maturin and related tools
RUN python3 -m pip install \
    maturin[patchelf] \
    cibuildwheel \
    auditwheel \
    twine \
    build

USER rust

# Install PyO3 and related Rust crates (pre-compile for faster builds)
RUN cargo install maturin --locked

# Create Python virtual environments for different versions
RUN python3.8 -m venv /home/rust/.venv/py38 && \
    python3.9 -m venv /home/rust/.venv/py39 && \
    python3.10 -m venv /home/rust/.venv/py310 && \
    python3.11 -m venv /home/rust/.venv/py311 && \
    python3.12 -m venv /home/rust/.venv/py312

# Install maturin in each virtual environment
RUN for py_ver in py38 py39 py310 py311 py312; do \
        /home/rust/.venv/$py_ver/bin/pip install maturin[patchelf]; \
    done

# Configure environment for wheel building
ENV MATURIN_PEP517_ARGS="--compatibility linux"

# Create helper scripts
COPY docker/build-scripts/build-wheels.sh /usr/local/bin/build-wheels
COPY docker/build-scripts/test-wheels.sh /usr/local/bin/test-wheels

USER root
RUN chmod +x /usr/local/bin/build-wheels /usr/local/bin/test-wheels
USER rust

# Verify Python and maturin installation
RUN echo "Python versions:" && \
    python3.8 --version && \
    python3.9 --version && \
    python3.10 --version && \
    python3.11 --version && \
    python3.12 --version && \
    echo "Maturin version:" && \
    maturin --version

CMD ["/bin/bash"]
