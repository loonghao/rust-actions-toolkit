# 🦀 Rust Actions Toolkit

[![CI](https://github.com/loonghao/rust-actions-toolkit/workflows/CI/badge.svg)](https://github.com/loonghao/rust-actions-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/loonghao/rust-actions-toolkit.svg)](https://github.com/loonghao/rust-actions-toolkit/releases)
[![Marketplace](https://img.shields.io/badge/GitHub-Marketplace-blue.svg)](https://github.com/marketplace/actions/rust-actions-toolkit)

> 🚀 Simple and universal GitHub Actions toolkit for Rust projects - CI/CD, native builds, and releases

[English](README.md) | [中文文档](README_zh.md)

## ✨ Features

- **🔍 Code Quality**: Automated formatting, linting, and documentation checks
- **🧪 Testing**: Native testing on Linux, macOS, and Windows
- **🚀 Releases**: Native binary releases and automatic uploads
- **🐍 Python**: Optional Python wheel building and distribution
- **📦 Publishing**: Automated crates.io publishing with release-plz
- **⚡ Simple**: Zero-configuration setup with sensible defaults

## 🚀 Quick Start

### 🌟 Recommended: Reusable Workflows

**Simple setup for modern Rust projects**

Create `.github/workflows/ci.yml`:
```yaml
name: CI
on: [push, pull_request]

permissions:
  contents: read

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      rust-toolchain: stable
```

Create `.github/workflows/release.yml`:
```yaml
name: Release
on:
  push:
    tags: ['v*']

permissions:
  contents: write

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@main
    with:
      rust-toolchain: stable
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**✨ What You Get:**
- ✅ **Native Compilation** - No complex cross-compilation setup needed
- ✅ **Multi-Platform Support** - Automatic builds for Linux, macOS, and Windows
- ✅ **Zero Configuration** - Works out of the box with sensible defaults
- ✅ **Simple and Reliable** - Focus on your code, not CI complexity

### 🔧 Alternative: Single Action

**For custom workflows or specific needs**

```yaml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@main
        with:
          command: ci
```

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
        os: [ubuntu-latest, macos-latest, windows-latest]
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@main
        with:
          command: release
          github-token: ${{ secrets.GITHUB_TOKEN }}

## 📋 Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `command` | Command to run: `ci`, `release`, or `release-plz` | No | `ci` |
| `rust-toolchain` | Rust toolchain version | No | `stable` |
| `check-format` | Run cargo fmt --check (ci command) | No | `true` |
| `check-clippy` | Run cargo clippy (ci command) | No | `true` |
| `check-docs` | Run cargo doc (ci command) | No | `true` |
| `binary-name` | Binary name to release | No | Auto-detected |
| `enable-python-wheels` | Enable Python wheel building | No | `false` |
| `github-token` | GitHub token for uploads | No | `${{ github.token }}` |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `rust-version` | Installed Rust version |
| `binary-path` | Built binary path (release command) |
| `wheel-path` | Built Python wheel path (release command) |

## 🎯 Supported Project Types

- **Pure Rust Crate**: Library projects published to crates.io
- **Binary Crate**: CLI tools with native platform releases
- **Python Wheels**: Rust + Python binding projects using maturin (optional)

## ⚙️ Configuration

### CI Workflow

The CI workflow includes:

- **Code Formatting** - `cargo fmt --check`
- **Linting** - `cargo clippy`
- **Documentation** - `cargo doc`
- **Testing** - Native testing on each platform
- **Optional Coverage** - Code coverage reporting
- **Optional Python Wheels** - Python wheel testing

### Release Workflow

The release workflow supports:

- **Binary Releases** - Native compilation for each platform
- **Python Wheels** - Optional multi-platform wheel building
- **Asset Upload** - Automatic GitHub release assets

### Release-plz

Automated version management:

- **Version Bumping** - Semantic versioning
- **Changelog Generation** - Automatic changelog
- **Crates.io Publishing** - Automated publishing
- **GitHub Releases** - Release creation

## 🎯 Supported Projects

This toolkit is designed for projects like:

- **vx shimexe** - Binary tools
- **py2pyd** - Python wheel projects
- **rez-tools** - CLI utilities
- **rez-core** - Core libraries

## ⚙️ Configuration Options

### Optional Features

Enable optional features by adding them to your workflow:

```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      rust-toolchain: stable
      enable-coverage: true        # Enable code coverage
      enable-python-wheel: true    # Enable Python wheel testing
```

### Python Wheel Projects

For projects with Python bindings:

```yaml
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@main
    with:
      rust-toolchain: stable
      enable-python-wheels: true   # Build Python wheels
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 📚 Examples

See the `examples/` directory for complete project setups:

- `pure-crate/` - Library crate example
- `binary-crate/` - CLI tool example
- `python-wheel/` - Python binding example
- `reusable-workflows/` - Workflow examples

## ⚙️ Project Setup

### Required Files

To use this toolkit in your Rust project, you need:

1. **Cargo.toml** - Standard Rust project file
2. **release-plz.toml** - Automated release configuration (optional)

### Optional Secrets

Add these secrets to your GitHub repository if needed:

- `CARGO_REGISTRY_TOKEN` - Your crates.io API token (for publishing)
- `CODECOV_TOKEN` - Your Codecov token (for coverage reporting)

### Automated Release Setup

For automated releases, create a `release-plz.toml` file:

```toml
[[package]]
name = "your-package-name"  # Change to your package name
changelog_update = true
git_release_enable = true
release = true
git_tag_name = "v{{version}}"
```

### Workflow

1. **Push to main** → Development and testing
2. **Create tag** → `release.yml` builds native binaries for all platforms
3. **Upload binaries** → Users can download from GitHub releases page

## 📚 Documentation

- [Usage Guide](USAGE.md) - Detailed usage instructions
- [Examples](examples/) - Complete project setups
- [Best Practices Guide](docs/BEST_PRACTICES.md) - How to use the toolkit effectively

## 🤝 Contributing

Contributions welcome! See our [Contributing Guide](CONTRIBUTING.md).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [release-plz Documentation](https://release-plz.ieni.dev/)
- [Maturin Documentation](https://www.maturin.rs/)