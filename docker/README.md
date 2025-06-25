# Docker Support for Rust Actions Toolkit 🐳

This directory contains Docker images and scripts for enhanced Rust development and deployment workflows.

## 🎯 Overview

Our Docker solution provides:
- **🚀 Zero-dependency builds** - Portable executables that run anywhere
- **⚡ Faster CI/CD** - Pre-installed tools and dependencies
- **🌍 Consistent environments** - Same results across all platforms
- **🔧 Specialized images** - Optimized for specific use cases

## 📦 Available Images

| Image | Purpose | Size | Use Case |
|-------|---------|------|----------|
| `ghcr.io/loonghao/rust-toolkit:base` | Basic Rust development | ~2GB | General CI/CD |
| `ghcr.io/loonghao/rust-toolkit:cross-compile` | Cross-compilation | ~3GB | Multi-platform builds |
| `ghcr.io/loonghao/rust-toolkit:python-wheels` | Python extensions | ~2.5GB | PyO3/maturin projects |
| `ghcr.io/loonghao/rust-toolkit:security-audit` | Security scanning | ~2.2GB | Security analysis |

## 🚀 Quick Start

### Using with GitHub Actions

```yaml
name: CI with Docker
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    container: ghcr.io/loonghao/rust-toolkit:base
    steps:
      - uses: actions/checkout@v4
      - run: cargo test
      - run: cargo clippy -- -D warnings
```

### Local Development

```bash
# Pull and run interactively
docker pull ghcr.io/loonghao/rust-toolkit:base
docker run -it --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/loonghao/rust-toolkit:base bash

# Build your project
cargo build --release
```

## 🎯 Zero-Dependency Builds

### Windows EXE (No DLL dependencies)

```bash
# Build portable Windows executable
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/loonghao/rust-toolkit:cross-compile \
  build-windows x86_64-pc-windows-gnu my-app

# Result: my-app.exe that runs on any Windows system
```

### Linux Static Binary

```bash
# Build fully static Linux binary
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/loonghao/rust-toolkit:cross-compile \
  cross-build x86_64-unknown-linux-musl my-app

# Result: Static binary that runs on any Linux distribution
```

### Verification

```bash
# Verify zero dependencies
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/loonghao/rust-toolkit:cross-compile \
  verify-static target/x86_64-pc-windows-gnu/release/my-app.exe
```

## 🛠️ Build Scripts

### Cross-Compilation

```bash
# Build for multiple targets
cross-build x86_64-unknown-linux-musl
cross-build aarch64-unknown-linux-gnu
cross-build x86_64-pc-windows-gnu
```

### Python Wheels

```bash
# Build wheels for multiple Python versions
build-wheels "3.8,3.9,3.10,3.11,3.12"
test-wheels wheels/
```

### Security Scanning

```bash
# Comprehensive security audit
security-scan all json
generate-sbom json
license-check text
```

### Windows Builds

```bash
# Build zero-dependency Windows EXE
build-windows x86_64-pc-windows-gnu my-app
```

## 📊 Performance Benefits

| Metric | GitHub Actions | Docker Images | Improvement |
|--------|---------------|---------------|-------------|
| **Cold Start** | 3-5 minutes | 30-60 seconds | 5-10x faster |
| **Warm Start** | 1-2 minutes | 10-20 seconds | 3-6x faster |
| **Dependencies** | Downloaded each time | Pre-installed | Consistent |
| **Environment** | Variable | Identical | Reliable |

## 🔧 Configuration

### Environment Variables

```bash
# Zero-dependency builds
RUSTFLAGS="-C target-feature=+crt-static"
OPENSSL_STATIC=1

# Cross-compilation
PKG_CONFIG_ALLOW_CROSS=1
CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc
```

### Custom Images

```dockerfile
# Extend our images for your needs
FROM ghcr.io/loonghao/rust-toolkit:base

# Add your custom tools
RUN cargo install your-tool

# Add your configuration
COPY config.toml /home/rust/.config/
```

## 📋 Supported Targets

### Windows
- `x86_64-pc-windows-gnu` - 64-bit Windows (zero dependencies)
- `i686-pc-windows-gnu` - 32-bit Windows (zero dependencies)
- `x86_64-pc-windows-msvc` - 64-bit Windows (MSVC)

### Linux
- `x86_64-unknown-linux-musl` - 64-bit Linux (static)
- `aarch64-unknown-linux-musl` - ARM64 Linux (static)
- `x86_64-unknown-linux-gnu` - 64-bit Linux (glibc)
- `aarch64-unknown-linux-gnu` - ARM64 Linux (glibc)

### macOS
- `x86_64-apple-darwin` - Intel macOS
- `aarch64-apple-darwin` - Apple Silicon macOS

### Others
- RISC-V, MIPS, PowerPC, s390x targets supported

## 🔄 CI/CD Integration

### Complete Workflow

```yaml
name: Multi-Platform Release
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
          - x86_64-pc-windows-gnu
          - x86_64-unknown-linux-musl
          - aarch64-unknown-linux-musl
          - x86_64-apple-darwin
    steps:
      - uses: actions/checkout@v4
      - name: Build for ${{ matrix.target }}
        run: |
          if [[ "${{ matrix.target }}" == *windows* ]]; then
            build-windows ${{ matrix.target }} my-app
          else
            cross-build ${{ matrix.target }} my-app
          fi
      - name: Verify build
        run: verify-static target/${{ matrix.target }}/release/my-app*
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.target }}
          path: target/${{ matrix.target }}/release/my-app*
```

## 🐛 Troubleshooting

### Common Issues

1. **Permission errors**
```bash
# Use correct user mapping
docker run --user $(id -u):$(id -g) ...
```

2. **Volume mounting**
```bash
# Use absolute paths
docker run -v "$(pwd)":/workspace ...
```

3. **Network issues**
```bash
# Use host network if needed
docker run --network host ...
```

### Debug Mode

```bash
# Run with debug output
docker run -e RUST_LOG=debug -e RUST_BACKTRACE=1 ...
```

## 📚 Examples

- [Zero-Dependency Builds](../examples/docker/zero-dependency-builds.md)
- [Windows EXE Building](../examples/docker/windows-build.yml)
- [Python Wheels](../examples/docker/python-wheels.yml)
- [Security Scanning](../examples/docker/security-audit.yml)

## 🔗 References

- [Docker Hub](https://github.com/loonghao/rust-actions-toolkit/pkgs/container/rust-toolkit)
- [Build Scripts](build-scripts/)
- [Dockerfiles](.)
- [GitHub Actions Integration](../.github/workflows/docker-build.yml)

## 🎉 Benefits Summary

✅ **Zero-dependency executables** - Run anywhere without installation  
✅ **Faster builds** - Pre-installed tools and dependencies  
✅ **Consistent results** - Same environment across all platforms  
✅ **Easy distribution** - Single file deployment  
✅ **Cross-platform** - Build for any target from Linux  
✅ **Security focused** - Regular updates and vulnerability scanning  

Our Docker solution makes Rust development faster, more reliable, and truly portable! 🚀
