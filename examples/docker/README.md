# Docker Usage Examples

This directory contains examples of using rust-actions-toolkit with Docker for enhanced performance and consistency.

## 🐳 Available Docker Images

| Image | Purpose | Size | Use Case |
|-------|---------|------|----------|
| `ghcr.io/loonghao/rust-toolkit:base` | Basic Rust development | ~2GB | General CI/CD |
| `ghcr.io/loonghao/rust-toolkit:cross-compile` | Cross-compilation | ~3GB | Multi-platform builds |
| `ghcr.io/loonghao/rust-toolkit:python-wheels` | Python extensions | ~2.5GB | PyO3/maturin projects |
| `ghcr.io/loonghao/rust-toolkit:security-audit` | Security scanning | ~2.2GB | Security analysis |

## 🚀 Quick Start

### Using with GitHub Actions

```yaml
# Basic CI with Docker
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    container: ghcr.io/loonghao/rust-toolkit:base
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: cargo test
      - name: Check formatting
        run: cargo fmt --check
      - name: Run clippy
        run: cargo clippy -- -D warnings
```

### Using with our Action (Experimental)

```yaml
# Using Docker through our action
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: ci
          use-docker: true
          docker-image: base
```

## 📋 Detailed Examples

### 1. Cross-Compilation

```yaml
name: Cross-Platform Build
on:
  push:
    tags: ["v*"]

jobs:
  build:
    runs-on: ubuntu-latest
    container: ghcr.io/loonghao/rust-toolkit:cross-compile
    strategy:
      matrix:
        target:
          - x86_64-unknown-linux-gnu
          - x86_64-unknown-linux-musl
          - aarch64-unknown-linux-gnu
          - aarch64-unknown-linux-musl
          - x86_64-pc-windows-gnu
    steps:
      - uses: actions/checkout@v4
      
      - name: Build for ${{ matrix.target }}
        run: cross-build ${{ matrix.target }}
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: binary-${{ matrix.target }}
          path: target/${{ matrix.target }}/release/
```

### 2. Python Wheels Building

```yaml
name: Build Python Wheels
on:
  push:
    tags: ["v*"]

jobs:
  wheels:
    runs-on: ubuntu-latest
    container: ghcr.io/loonghao/rust-toolkit:python-wheels
    steps:
      - uses: actions/checkout@v4
      
      - name: Build wheels for all Python versions
        run: build-wheels "3.8,3.9,3.10,3.11,3.12"
      
      - name: Test wheels
        run: test-wheels
      
      - name: Upload wheels
        uses: actions/upload-artifact@v4
        with:
          name: python-wheels
          path: wheels/
```

### 3. Security Audit

```yaml
name: Security Audit
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  security:
    runs-on: ubuntu-latest
    container: ghcr.io/loonghao/rust-toolkit:security-audit
    steps:
      - uses: actions/checkout@v4
      
      - name: Run comprehensive security scan
        run: security-scan all json
      
      - name: Upload security reports
        uses: actions/upload-artifact@v4
        with:
          name: security-reports
          path: security-reports/
      
      - name: Generate SBOM
        run: generate-sbom
      
      - name: Check licenses
        run: license-check
```

## 🛠️ Local Development

### Running Locally

```bash
# Pull the image
docker pull ghcr.io/loonghao/rust-toolkit:base

# Run interactively
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:base \
  bash

# Run specific commands
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:base \
  cargo test
```

### Cross-Compilation Example

```bash
# Build for multiple targets
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:cross-compile \
  cross-build x86_64-unknown-linux-musl

# Build for ARM64
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:cross-compile \
  cross-build aarch64-unknown-linux-gnu
```

### Python Wheels Example

```bash
# Build Python wheels
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:python-wheels \
  build-wheels "3.11,3.12"
```

### Security Scanning Example

```bash
# Run security audit
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:security-audit \
  security-scan all

# Generate SBOM
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:security-audit \
  generate-sbom
```

## 🎯 Performance Benefits

### Build Time Comparison

| Method | Cold Start | Warm Start | Dependencies |
|--------|------------|------------|--------------|
| **GitHub Actions** | ~3-5 min | ~1-2 min | Downloaded each time |
| **Docker Images** | ~30-60 sec | ~10-20 sec | Pre-installed |

### Cache Efficiency

```yaml
# Docker images provide better caching
- name: Build with Docker
  run: |
    # All dependencies are pre-installed
    # Rust toolchain is pre-configured
    # Cross-compilation tools are ready
    cargo build --release
```

## 🔧 Customization

### Custom Docker Images

You can extend our images for your specific needs:

```dockerfile
# Custom image based on our cross-compile image
FROM ghcr.io/loonghao/rust-toolkit:cross-compile

# Add your custom tools
RUN cargo install your-custom-tool

# Add your custom configuration
COPY your-config.toml /home/rust/.config/
```

### Environment Variables

```yaml
# Configure the Docker environment
- name: Build with custom config
  run: cargo build
  env:
    RUSTFLAGS: "-C target-cpu=native"
    CARGO_TERM_COLOR: always
```

## 🐛 Troubleshooting

### Common Issues

1. **Permission Issues**
```bash
# Fix file permissions
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  --user $(id -u):$(id -g) \
  ghcr.io/loonghao/rust-toolkit:base \
  cargo build
```

2. **Volume Mounting**
```bash
# Ensure correct volume mounting
docker run --rm \
  -v "$(pwd)":/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:base \
  cargo test
```

3. **Network Issues**
```bash
# Use host network if needed
docker run --rm \
  --network host \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:base \
  cargo test
```

## 📚 References

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions with Docker](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action)
- [Rust Cross-Compilation](https://rust-lang.github.io/rustup/cross-compilation.html)
