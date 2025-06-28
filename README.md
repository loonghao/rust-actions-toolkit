# 🦀 Rust Actions Toolkit

[![CI](https://github.com/loonghao/rust-actions-toolkit/workflows/CI/badge.svg)](https://github.com/loonghao/rust-actions-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/loonghao/rust-actions-toolkit.svg)](https://github.com/loonghao/rust-actions-toolkit/releases)
[![Marketplace](https://img.shields.io/badge/GitHub-Marketplace-blue.svg)](https://github.com/marketplace/actions/rust-actions-toolkit)

> 🚀 Universal GitHub Actions toolkit for Rust projects - CI/CD, cross-platform builds, releases, and Python wheels

[English](README.md) | [中文文档](README_zh.md)

## ✨ Features

- **🔍 Code Quality**: Automated formatting, linting, and documentation checks
- **🧪 Testing**: Cross-platform testing on Linux, macOS, and Windows
- **🔒 Security**: Automated vulnerability scanning with cargo-audit
- **📊 Coverage**: Code coverage reporting with Codecov integration
- **🚀 Releases**: Cross-platform binary releases and automatic uploads
- **🐍 Python**: Python wheel building and distribution
- **📦 Publishing**: Automated crates.io publishing with release-plz

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

### Cross-Platform Release

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

## 📋 Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `command` | Command to run: `ci`, `release`, or `setup` | No | `ci` |
| `rust-toolchain` | Rust toolchain version | No | `stable` |
| `check-format` | Run cargo fmt --check (ci command) | No | `true` |
| `check-clippy` | Run cargo clippy (ci command) | No | `true` |
| `check-docs` | Run cargo doc (ci command) | No | `true` |
| `target` | Target platform for release | No | Auto-detected |
| `binary-name` | Binary name to release | No | Auto-detected |
| `github-token` | GitHub token for uploads | No | `${{ github.token }}` |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `rust-version` | Installed Rust version |
| `binary-path` | Built binary path (release command) |
| `wheel-path` | Built Python wheel path (release command) |

## 🎯 Supported Project Types

- **Pure Rust Crate**: Library projects published to crates.io
- **Binary Crate**: CLI tools with cross-platform releases
- **Python Wheels**: Rust + Python binding projects using maturin

## � Configuration

### CI Workflow (`ci.yml`)

The CI workflow includes:

- **Code Formatting** - `cargo fmt --check`
- **Linting** - `cargo clippy`
- **Documentation** - `cargo doc`
- **Testing** - Cross-platform testing
- **Security Audit** - `cargo audit`
- **Code Coverage** - `cargo llvm-cov` (PR only)
- **Python Wheels** - Conditional testing

### Release Workflow (`release.yml`)

The release workflow supports:

- **Binary Releases** - Cross-platform compilation
- **Python Wheels** - Multi-platform wheel building
- **Asset Upload** - Automatic GitHub release assets

### Release-plz (`release-plz.yml`)

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

## 📚 Examples

See the `examples/` directory for complete project setups:

- `pure-crate/` - Pure crate example
- `binary-crate/` - CLI tool example
- `python-wheel/` - Python binding example
- `enhanced-ci/` - Enhanced CI configuration examples

## ⚙️ Project Setup

### Required Files

To use this toolkit in your Rust project, you need:

1. **Cargo.toml** - Standard Rust project file
2. **release-plz.toml** - Automated release configuration (optional)

### Required Secrets

Add these secrets to your GitHub repository:

- `CARGO_REGISTRY_TOKEN` - Your crates.io API token (for Rust crate publishing)
- `CODECOV_TOKEN` - Your Codecov token (optional, for coverage reporting)
- `RELEASE_PLZ_TOKEN` - GitHub PAT for release automation (optional, enhanced features)

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

### Workflow

1. **Push to main** → `release-plz.yml` creates release PR
2. **Merge release PR** → `release-plz.yml` creates tag and GitHub release
3. **Tag created** → `release.yml` builds cross-platform binaries
4. **Upload binaries** → Users can download from GitHub releases page

## 📚 Documentation

- **[Best Practices Guide](docs/BEST_PRACTICES.md)** - How to choose and use the toolkit effectively
- [Usage Guide](USAGE.md) - Detailed usage instructions
- [Examples](examples/) - Complete project setups

### 🔧 Troubleshooting Guides
- [Cross-Compilation Issues](docs/CROSS_COMPILATION_ISSUES.md) - Comprehensive analysis and solutions
- [Memory Allocator Issues](docs/MIMALLOC_TROUBLESHOOTING.md) - Fix mimalloc and other allocator problems
- [OpenSSL Troubleshooting](docs/OPENSSL_TROUBLESHOOTING.md) - Resolve compilation issues
- [Workflow Robustness Fixes](docs/WORKFLOW_ROBUSTNESS_FIXES.md) - Fix cross-platform workflow issues
- [GitHub Token Issues](docs/GITHUB_TOKEN_ISSUE.md) - Fix workflow permission problems
- [GitHub Actions Linting](docs/GITHUB_ACTIONS_LINTING.md) - Validate workflow configurations

### 🤝 Community
- [Contributing](CONTRIBUTING.md) - How to contribute

## 🤝 Contributing

Contributions welcome! See our [Contributing Guide](CONTRIBUTING.md).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [release-plz Documentation](https://release-plz.ieni.dev/)
- [Maturin Documentation](https://www.maturin.rs/)
- [Cross-compilation Guide](https://rust-lang.github.io/rustup/cross-compilation.html)

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件。

---

**注意**: 这些改进需要在 `rust-actions-toolkit` 仓库中实施，然后项目可以升级到新版本以获得一致性保证。