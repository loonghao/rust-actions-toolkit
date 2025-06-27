# 🦀 Rust Actions Toolkit

[![CI](https://github.com/loonghao/rust-actions-toolkit/workflows/CI/badge.svg)](https://github.com/loonghao/rust-actions-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/loonghao/rust-actions-toolkit.svg)](https://github.com/loonghao/rust-actions-toolkit/releases)
[![Marketplace](https://img.shields.io/badge/GitHub-Marketplace-blue.svg)](https://github.com/marketplace/actions/rust-actions-toolkit)

> 🚀 Universal GitHub Actions toolkit for Rust projects with support for CI/CD, cross-platform builds, releases, and Python wheels

[中文文档](README_zh.md) | [English](README.md)

## ✨ Features

- **🔍 Code Quality**: Automated formatting, linting, and documentation checks
- **🧪 Testing**: Cross-platform testing on Linux, macOS, and Windows
- **🔒 Security**: Automated vulnerability scanning with cargo-audit
- **📊 Coverage**: Code coverage reporting with Codecov integration
- **🚀 Releases**: Cross-platform binary releases with automated uploads
- **📦 Zero-Dependency**: Build portable executables that run anywhere
- **🐍 Python**: Python wheel building and distribution
- **📦 Publishing**: Automated crates.io publishing with release-plz
- **🐳 Docker**: Pre-configured containers for consistent builds

## 🚀 Quick Start

### Simple CI Setup

```yaml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: ci
```

### Automated Publishing with release-plz

```yaml
name: Release-plz
on:
  push:
    branches: [main]
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: release-plz
          cargo-registry-token: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

### Zero-Dependency Windows EXE

```yaml
name: Build Windows EXE
on:
  push:
    tags: ["v*"]
jobs:
  windows:
    runs-on: ubuntu-latest
    container: ghcr.io/loonghao/rust-toolkit:cross-compile
    steps:
      - uses: actions/checkout@v4
      - name: Build portable Windows EXE
        run: build-windows x86_64-pc-windows-gnu my-app
      - name: Verify zero dependencies
        run: verify-static target/x86_64-pc-windows-gnu/release/my-app.exe
```

### 🚀 Zero-Config Release (Recommended)

```yaml
name: Smart Release

on:
  push:
    tags: ['v*']

jobs:
  release:
    strategy:
      matrix:
        include:
          - { os: ubuntu-latest, target: x86_64-unknown-linux-gnu }
          - { os: ubuntu-latest, target: x86_64-pc-windows-gnu }
          - { os: macos-latest, target: x86_64-apple-darwin }

    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4

      # That's it! Everything else is automatic �?
      - uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          target: ${{ matrix.target }}
```

### Cross-Platform Releases

```yaml
name: Release
on:
  push:
    tags: ["v*"]
jobs:
  release:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: macos-latest
            target: x86_64-apple-darwin
          - os: windows-latest
            target: x86_64-pc-windows-msvc
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: release
          target: ${{ matrix.target }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

## 📋 Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `command` | Command to run: `ci`, `release`, or `setup` | Yes | `ci` |
| `rust-toolchain` | Rust toolchain version | No | `stable` |
| `check-format` | Run cargo fmt --check (ci command) | No | `true` |
| `check-clippy` | Run cargo clippy (ci command) | No | `true` |
| `check-docs` | Run cargo doc (ci command) | No | `true` |
| `target` | Target platform for release | No | Auto-detect |
| `binary-name` | Binary name to release | No | Auto-detect |
| `github-token` | GitHub token for uploads | No | `${{ github.token }}` |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `rust-version` | Installed Rust version |
| `binary-path` | Path to built binary (release command) |
| `wheel-path` | Path to built Python wheel (release command) |

## 🎯 Supported Project Types

- **Pure Rust Crates**: Library projects published to crates.io
- **Binary Crates**: CLI tools with cross-platform releases
- **Python Wheels**: Rust projects with Python bindings using maturin

## 🔧 Advanced Usage

### Custom Clippy Configuration

```yaml
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
    clippy-args: '--all-targets --all-features -- -D warnings -D clippy::pedantic'
```

### Python Wheel Projects

For projects with `pyproject.toml`, Python wheels are automatically built:

```yaml
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: release
    target: x86_64-unknown-linux-gnu
    enable-python-wheels: true
```

## 🏷�?Versioning

Use specific versions for stability:

```yaml
- uses: loonghao/rust-actions-toolkit@v2.0.0  # Specific version
- uses: loonghao/rust-actions-toolkit@v2      # Major version
- uses: loonghao/rust-actions-toolkit@main    # Latest (not recommended for production)
```

## 🔄 Alternative Usage Methods

### Reusable Workflows

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

### Composite Actions

```yaml
- uses: loonghao/rust-actions-toolkit/actions/setup-rust-ci@v2
  with:
    toolchain: stable
    check-format: true
```

### Copy Files (Full Control)

```bash
curl -o .github/workflows/ci.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/ci.yml
```

## ⚙️ Setup for Your Project

### Required Files

To use this toolkit in your Rust project, you need:

1. **Cargo.toml** - Standard Rust project file
2. **release-plz.toml** - For automated releases (optional)

### Required Secrets

Add these secrets to your GitHub repository:

- `CARGO_REGISTRY_TOKEN` - Your crates.io API token (for Rust crate publishing)
- `CODECOV_TOKEN` - Your Codecov token (optional, for coverage reporting)
- `RELEASE_PLZ_TOKEN` - GitHub PAT for release automation (optional, for enhanced features)

### Automated Release Setup

This toolkit uses **release-plz** for automated version management. Create a `release-plz.toml` file:

```toml
[workspace]
changelog_update = true
git_release_enable = false
git_tag_enable = true
release = true

[[package]]
name = "your-package-name"  # Change to your package name
changelog_update = true
git_release_enable = true
release = true
git_tag_name = "v{{version}}"
git_release_draft = false
```

### How It All Works Together

1. **Push to main** �?`release-plz.yml` creates release PR
2. **Merge release PR** �?`release-plz.yml` creates tag and GitHub release
3. **Tag created** �?`release.yml` builds cross-platform binaries
4. **Binaries uploaded** �?Users can download from GitHub releases

## 💡 Complete Examples

### Pure Rust Library

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: ci
          rust-toolchain: stable
```

### CLI Tool with Releases

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ["v*"]
jobs:
  release:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: macos-latest
            target: x86_64-apple-darwin
          - os: windows-latest
            target: x86_64-pc-windows-msvc
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: release
          target: ${{ matrix.target }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Python Wheel Project

Just add a `pyproject.toml` file and wheels will be built automatically:

```toml
[build-system]
requires = ["maturin>=1.0,<2.0"]
build-backend = "maturin"

[project]
name = "your-python-package"
requires-python = ">=3.8"
```

## 🎯 Real-World Projects

This toolkit is used by projects like:

- **vx shimexe** - Binary tools
- **py2pyd** - Python wheel projects
- **rez-tools** - CLI utilities
- **rez-core** - Core libraries

## 🎯 Best Practices

### **New Project? �?Use GitHub Actions**
```yaml
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
```

### **Need Flexibility? �?Use GitHub Actions**
```yaml
# Mix with existing steps
- name: Custom setup
  run: ./setup.sh
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
- name: Custom cleanup
  run: ./cleanup.sh
```

### **Enterprise Standardization? �?Use Reusable Workflows**
```yaml
# Enforced standards across all projects
uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2
```

**📖 [Complete Best Practices Guide](docs/BEST_PRACTICES.md)**

## 📚 Documentation

- **[Best Practices Guide](docs/BEST_PRACTICES.md)** - How to choose and use the toolkit effectively
- [Usage Guide](USAGE.md) - Detailed usage instructions
- [Examples](examples/) - Complete project setups
- [OpenSSL Troubleshooting](docs/OPENSSL_TROUBLESHOOTING.md) - Resolve compilation issues
- [GitHub Token Issues](docs/GITHUB_TOKEN_ISSUE.md) - Fix workflow permission problems
- [Contributing](CONTRIBUTING.md) - How to contribute

## 🤝 Contributing

Contributions welcome! See our [Contributing Guide](CONTRIBUTING.md).

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.
