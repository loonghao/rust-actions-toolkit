# 🦀 Rust Actions Toolkit

Simple and universal GitHub Actions toolkit for Rust projects with native builds, CI/CD, and releases.

## �?Features

- **🔍 Code Quality**: Automated formatting, linting, and documentation checks
- **🧪 Testing**: Native testing on Linux, macOS, and Windows
- **� Releases**: Native binary releases with automated uploads
- **🐍 Python**: Optional Python wheel building and distribution
- **📦 Publishing**: Automated crates.io publishing with release-plz
- **⚡ Simple**: Zero-configuration setup with sensible defaults

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
      - uses: loonghao/rust-actions-toolkit@main
        with:
          command: ci
```

### Native Platform Releases

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
```

## 📋 Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `command` | Command to run: `ci`, `release`, or `release-plz` | Yes | `ci` |
| `rust-toolchain` | Rust toolchain version | No | `stable` |
| `binary-name` | Binary name to release | No | Auto-detect |
| `enable-python-wheels` | Enable Python wheel building | No | `false` |
| `github-token` | GitHub token for uploads | No | `${{ github.token }}` |

## 🎯 Supported Project Types

- **Pure Rust Crates**: Library projects published to crates.io
- **Binary Crates**: CLI tools with native platform releases
- **Python Wheels**: Rust projects with Python bindings using maturin (optional)

## 🔧 Advanced Usage

### Python Wheel Projects

For projects with `pyproject.toml`, enable Python wheel building:

```yaml
- uses: loonghao/rust-actions-toolkit@main
  with:
    command: release
    enable-python-wheels: true
```

### Custom Clippy Configuration

```yaml
- uses: loonghao/rust-actions-toolkit@main
  with:
    command: ci
    clippy-args: '--all-targets --all-features -- -D warnings'
```

## 🏷�?Versioning

Use specific versions for stability:

```yaml
- uses: loonghao/rust-actions-toolkit@v2.0.0  # Specific version
- uses: loonghao/rust-actions-toolkit@v2      # Major version
- uses: loonghao/rust-actions-toolkit@main    # Latest (not recommended for production)
```

## 🤝 Contributing

Contributions welcome! See our [Contributing Guide](https://github.com/loonghao/rust-actions-toolkit/blob/main/CONTRIBUTING.md).

## 📄 License

MIT License - see [LICENSE](https://github.com/loonghao/rust-actions-toolkit/blob/main/LICENSE) for details.
