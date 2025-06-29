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

### 🌟 Recommended: Reusable Workflows (v2.5.5+)

**Best for: Modern projects with CI/Release consistency**

Create `.github/workflows/ci.yml`:
```yaml
name: CI
on: [push, pull_request]

permissions:
  contents: read
  actions: read

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.5
    with:
      rust-toolchain: stable
      # 🎯 KEY: Specify release targets for consistency testing
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"}
        ]
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
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2.5.5
    with:
      # 🎯 KEY: Use SAME targets as CI for consistency
      target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"}
        ]
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**✨ What You Get:**
- ✅ **Automatic Release Build Consistency Testing** - CI tests exact same targets as release
- ✅ **Early Cross-Compilation Issue Detection** - Catch problems before release
- ✅ **Complete Proc-Macro Cross-Compilation Support** - Fixed async-trait, serde, tokio, etc.
- ✅ **Zero-Configuration Defaults** - Smart defaults that work out of the box
- ✅ **Comprehensive Platform Support** - Linux, Windows, macOS, musl, ARM64

### 🔧 Alternative: Single Action (Legacy)

**Best for: Simple projects or gradual migration**

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

## ⚙️ Configuration Guide (v2.5.3)

### 🎯 Project Types

#### Binary Projects
```yaml
# .github/workflows/ci.yml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      enable-coverage: true
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-apple-darwin", "os": "macos-latest"}
        ]
```

#### Rust + Python Projects
```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      enable-coverage: true
      enable-python-wheel: true  # Enable Python wheel building
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "aarch64-apple-darwin", "os": "macos-latest"}
        ]
```

#### Library Projects
```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      enable-coverage: true
      build-depth: basic  # Libraries don't need release build testing
      test-release-builds: false  # Disable for library-only projects
```

### 🔧 Advanced Configuration

#### Full Feature Set
```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      # Toolchain
      rust-toolchain: stable

      # Features
      enable-coverage: true
      enable-python-wheel: true
      enable-security-audit: true

      # Build configuration
      build-depth: release  # basic | release | full
      test-release-builds: true  # Default: true in v2.5.3
      verify-ci-consistency: true

      # Cross-compilation targets
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-apple-darwin", "os": "macos-latest"},
          {"target": "aarch64-apple-darwin", "os": "macos-latest"}
        ]
```

### 🎯 Key Configuration Tips

1. **Target Consistency**: Always use the same targets in CI and Release workflows
2. **Permissions**: Set appropriate permissions for each workflow
3. **Build Depth**: Use `basic` for libraries, `release` for binaries
4. **Python Wheels**: Enable only if your project has Python bindings
5. **Security Audit**: Enable for production projects

## 📚 Examples

See the `examples/` directory for complete project setups:

- `ci-release-consistency-test/` - CI/Release consistency example
- `enhanced-ci/` - Advanced CI configuration
- `cross-compilation/` - Cross-compilation examples
- `pure-crate/` - Pure crate example
- `binary-crate/` - CLI tool example
- `python-wheel/` - Python binding example

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

### 📚 Documentation & Best Practices
- [Best Practices for v2.5.3](docs/BEST_PRACTICES_V2_5_3.md) - **Comprehensive configuration guide and best practices**
- [Migration Guide to v2.5.3](docs/MIGRATION_TO_V2_5_3.md) - **Step-by-step upgrade guide from older versions**
- [Release Build Consistency](docs/RELEASE_BUILD_CONSISTENCY.md) - Fix disabled consistency tests and configuration
- [CI Consistency Improvements](docs/CI_CONSISTENCY_IMPROVEMENTS.md) - Enhanced CI/Release workflow alignment

### 🔧 Troubleshooting Guides
- [Proc-Macro Cross-Compilation](docs/PROC_MACRO_CROSS_COMPILATION.md) - Fix proc-macro cross-compilation issues
- [Cross-Compilation Issues](docs/CROSS_COMPILATION_ISSUES.md) - Comprehensive analysis and solutions
- [Workflow Robustness Fixes](docs/WORKFLOW_ROBUSTNESS_FIXES.md) - Fix cross-platform workflow issues
- [Memory Allocator Issues](docs/MIMALLOC_TROUBLESHOOTING.md) - Fix mimalloc and other allocator problems
- [OpenSSL Troubleshooting](docs/OPENSSL_TROUBLESHOOTING.md) - Resolve compilation issues
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