# 🦀 Rust Actions Toolkit

[![CI](https://github.com/loonghao/rust-actions-toolkit/workflows/CI/badge.svg)](https://github.com/loonghao/rust-actions-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/loonghao/rust-actions-toolkit.svg)](https://github.com/loonghao/rust-actions-toolkit/releases)

> 🚀 Universal GitHub Actions toolkit for Rust projects - CI/CD, cross-platform builds, releases, and Python wheels

[中文文档](README_zh.md) | [English](README.md)

## ✨ Features

- ✅ **Pure Rust crates** - Complete CI/CD for library crates
- ✅ **Binary releases** - Cross-platform compilation and distribution
- ✅ **Python wheels** - Rust + Python integration with maturin
- ✅ **Comprehensive CI** - Code quality, testing, security, coverage
- ✅ **Automated releases** - Version management with release-plz
- ✅ **Cross-platform** - Linux, macOS, Windows (x86_64 + ARM64)
- ✅ **Security auditing** - Automated vulnerability scanning
- ✅ **Code coverage** - Codecov integration

## 🚀 Quick Start

Choose one of three ways to use this toolkit:

### Method 1: Reusable Workflows (Recommended) 🌟

Create simple workflow files that call our reusable workflows:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

```yaml
# .github/workflows/release-plz.yml
name: Release-plz
on:
  push:
    branches: [main]
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release-plz.yml@main
    secrets:
      CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ["v*"]
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@main
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Method 2: Composite Actions

Use our actions in your existing workflows:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit/actions/setup-rust-ci@main
        with:
          toolchain: stable
          check-format: true
          check-clippy: true
```

### Method 3: Copy Files (Full Control)

Copy and customize the workflow files:

```bash
# Create .github/workflows directory
mkdir -p .github/workflows

# Copy workflow files
curl -o .github/workflows/ci.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/ci.yml
curl -o .github/workflows/release-plz.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release-plz.yml
curl -o .github/workflows/release.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release.yml
curl -o release-plz.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/release-plz.toml
```

## ⚙️ Configuration

### Required Secrets

Add these secrets to your GitHub repository:

- `CARGO_REGISTRY_TOKEN` - Your crates.io API token
- `CODECOV_TOKEN` - Your Codecov token (optional)
- `RELEASE_PLZ_TOKEN` - GitHub PAT for release automation (optional)

## 📋 Project Types

### Pure Rust Crate

For library crates without binaries:

1. Use the default configuration
2. Remove binary-specific sections from `release.yml` if needed
3. Focus on `cargo test` and documentation

### Binary Crate

For projects with executable binaries:

1. Ensure your `Cargo.toml` has a `[[bin]]` section
2. The `upload-rust-binary-action` will auto-detect binary names
3. Cross-platform binaries will be built automatically

### Python Wheel Project

For Rust projects with Python bindings:

1. Add `pyproject.toml` to your project
2. Use maturin for Python integration
3. Python wheels will be built automatically when `pyproject.toml` exists

Example `pyproject.toml`:

```toml
[build-system]
requires = ["maturin>=1.0,<2.0"]
build-backend = "maturin"

[project]
name = "your-python-package"
requires-python = ">=3.8"
```

## 🔧 Configuration

### CI Workflow (`ci.yml`)

The CI workflow includes:

- **Code formatting** - `cargo fmt --check`
- **Linting** - `cargo clippy`
- **Documentation** - `cargo doc`
- **Testing** - Cross-platform testing
- **Security audit** - `cargo audit`
- **Code coverage** - `cargo llvm-cov` (PR only)
- **Python wheels** - Conditional testing

### Release Workflow (`release.yml`)

The release workflow supports:

- **Binary releases** - Cross-platform compilation
- **Python wheels** - Multi-platform wheel building
- **Asset uploads** - Automatic GitHub release assets

### Release-plz (`release-plz.yml`)

Automated version management:

- **Version bumping** - Semantic versioning
- **Changelog generation** - Automatic changelog
- **Crates.io publishing** - Automated publishing
- **GitHub releases** - Release creation

## 🎯 Supported Projects

This toolkit is designed for projects like:

- **vx shimexe** - Binary tools
- **py2pyd** - Python wheel projects
- **rez-tools** - CLI utilities
- **rez-core** - Core libraries

## 📚 Examples

See the `examples/` directory for complete project setups:

- `pure-crate/` - Library crate example
- `binary-crate/` - CLI tool example
- `python-wheel/` - Python binding example

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [release-plz Documentation](https://release-plz.ieni.dev/)
- [Maturin Documentation](https://www.maturin.rs/)
- [Cross Compilation Guide](https://rust-lang.github.io/rustup/cross-compilation.html)
