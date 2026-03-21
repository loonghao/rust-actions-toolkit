# 🦀 Rust Actions Toolkit

[![CI](https://github.com/loonghao/rust-actions-toolkit/workflows/CI/badge.svg)](https://github.com/loonghao/rust-actions-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/loonghao/rust-actions-toolkit.svg)](https://github.com/loonghao/rust-actions-toolkit/releases)
[![Marketplace](https://img.shields.io/badge/GitHub-Marketplace-blue.svg)](https://github.com/marketplace/actions/rust-actions-toolkit)

> 🚀 Simple and universal GitHub Actions toolkit for Rust projects - CI/CD, native builds, and releases

[English](README.md) | [中文文档](README_zh.md)

## ✨ Features

- **🔍 Code Quality**: Automated formatting, linting, and documentation checks
- **🧪 Testing**: Cross-platform testing on Linux, macOS, and Windows with optional `cargo-nextest`
- **🔒 Security**: Automated vulnerability scanning with `cargo-audit`
- **📊 Coverage**: Code coverage reporting with Codecov integration
- **🚀 Releases**: Multi-platform native binary releases with automatic uploads
- **🐍 Python**: Optional Python wheel building and distribution via maturin
- **📦 Publishing**: Automated crates.io publishing with release-plz (reusable workflow)
- **🏗️ Workspace**: Full support for Cargo workspace / monorepo projects
- **⚡ MSVC**: First-class MSVC developer environment support on Windows
- **🔧 sccache**: Optional sccache for faster compilation on large projects

## 🚀 Quick Start

### 🌟 Recommended: Reusable Workflows

**Simple zero-config setup for modern Rust projects**

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
```

**✨ What You Get:**
- ✅ **Multi-Platform Testing** - Automatic testing on Linux, macOS, and Windows
- ✅ **Native Compilation** - Platform-native builds (no complex cross-compilation)
- ✅ **Zero Configuration** - Works out of the box with sensible defaults
- ✅ **Security Audit** - Automated vulnerability scanning
- ✅ **Binary Releases** - Automatic multi-platform binary uploads to GitHub Releases

### 🔧 Alternative: Single Action

**For custom workflows or specific needs**

```yaml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: loonghao/rust-actions-toolkit@main
        with:
          command: ci
```

## 📋 Inputs

### Common Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `command` | Command to run: `ci`, `release`, or `release-plz` | No | `ci` |
| `rust-toolchain` | Rust toolchain version | No | `stable` |
| `working-directory` | Working directory for cargo commands (workspace support) | No | `.` |
| `cargo-features` | Cargo features to enable (`"all"` or comma-separated list) | No | `''` |
| `enable-cache` | Enable Rust compilation cache | No | `true` |
| `enable-sccache` | Enable sccache for faster compilation | No | `false` |
| `setup-msvc` | Setup MSVC developer environment on Windows | No | `false` |

### CI Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `check-format` | Run `cargo fmt --check` | No | `true` |
| `check-clippy` | Run `cargo clippy` | No | `true` |
| `check-docs` | Run `cargo doc` | No | `true` |
| `clippy-args` | Additional arguments for clippy | No | `--all-targets -- -D warnings` |
| `use-nextest` | Use `cargo-nextest` for faster parallel testing | No | `false` |
| `test-args` | Additional arguments for test runner | No | `''` |

### Release Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `binary-name` | Binary name(s) to release, comma-separated | No | Auto-detected |
| `enable-python-wheels` | Enable Python wheel building | No | `false` |
| `github-token` | GitHub token for release uploads | No | `''` |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `rust-version` | Installed Rust version |
| `binary-path` | Built binary path (release command) |
| `wheel-path` | Built Python wheel path (release command) |

## 🎯 Supported Project Types

| Project Type | Features | Example |
|-------------|----------|---------|
| **Pure Rust Crate** | CI + crates.io publishing | Library projects |
| **Binary Crate** | CI + multi-platform binary releases | CLI tools like [vx](https://github.com/loonghao/vx), [clawup](https://github.com/loonghao/clawup) |
| **Workspace / Monorepo** | CI with `working-directory` support | Multi-crate projects |
| **MSVC Project** | CI with MSVC developer environment | Windows-native tools like [msvc-kit](https://github.com/loonghao/msvc-kit) |
| **Python Wheels** | CI + maturin wheel building | Rust + Python bindings like [auroraview](https://github.com/loonghao/auroraview) |

## ⚙️ Reusable Workflow Options

### Reusable CI (`reusable-ci.yml`)

| Input | Description | Default |
|-------|-------------|---------|
| `rust-toolchain` | Rust toolchain version | `stable` |
| `working-directory` | Working directory | `.` |
| `cargo-features` | Features to enable | `''` |
| `use-nextest` | Use cargo-nextest | `false` |
| `enable-coverage` | Enable code coverage | `false` |
| `enable-audit` | Enable security audit | `true` |
| `enable-python-wheel` | Enable Python wheel testing | `false` |
| `setup-msvc` | Setup MSVC on Windows | `false` |
| `test-platforms` | JSON array of test runners | `["ubuntu-latest", "macos-latest", "windows-latest"]` |

### Reusable Release (`reusable-release.yml`)

| Input | Description | Default |
|-------|-------------|---------|
| `binary-name` | Binary name(s) | Auto-detected |
| `enable-python-wheels` | Build Python wheels | `false` |
| `setup-msvc` | Setup MSVC on Windows | `false` |
| `target-platforms` | JSON array of build targets | All major platforms |

### Reusable Release-plz (`reusable-release-plz.yml`)

For projects that use [release-plz](https://release-plz.ieni.dev/) for automated version management and crates.io publishing.

## 📚 Examples

### Workspace Project (like clawup, vx)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      use-nextest: true
      enable-coverage: true
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

### MSVC Project (like msvc-kit)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      setup-msvc: true
      test-platforms: '["windows-latest"]'
```

### Python Wheel Project (like auroraview)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      enable-python-wheel: true
      enable-coverage: true
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@main
    with:
      enable-python-wheels: true
```

### Release with release-plz (for crates.io publishing)

```yaml
# .github/workflows/release-plz.yml
name: Release-plz
on:
  push:
    branches: [main]
permissions:
  contents: write
  pull-requests: write
jobs:
  release-plz:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release-plz.yml@main
    secrets:
      CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

See the `examples/` directory for more complete project setups.

## ⚙️ Project Setup

### Required Files

To use this toolkit in your Rust project, you only need:

1. **Cargo.toml** - Standard Rust project file

### Optional Secrets

Add these secrets to your GitHub repository if needed:

- `CARGO_REGISTRY_TOKEN` - Your crates.io API token (for publishing via release-plz)
- `CODECOV_TOKEN` - Your Codecov token (for coverage reporting)

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
- [release-please Documentation](https://github.com/googleapis/release-please)
- [release-plz Documentation](https://release-plz.ieni.dev/)
- [Maturin Documentation](https://www.maturin.rs/)
