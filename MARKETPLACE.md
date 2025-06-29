# ๐ฆ Rust Actions Toolkit

Universal GitHub Actions toolkit for Rust projects with support for CI/CD, cross-platform builds, releases, and Python wheels.

## โ?Features

- **๐ Code Quality**: Automated formatting, linting, and documentation checks
- **๐งช Testing**: Cross-platform testing on Linux, macOS, and Windows
- **๐ Security**: Automated vulnerability scanning with cargo-audit
- **๐ Coverage**: Code coverage reporting with Codecov integration
- **๐ Releases**: Cross-platform binary releases with automated uploads
- **๐ Python**: Python wheel building and distribution
- **๐ฆ Publishing**: Automated crates.io publishing with release-plz

## ๐ Quick Start

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

## ๐ Inputs

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

## ๐ค Outputs

| Output | Description |
|--------|-------------|
| `rust-version` | Installed Rust version |
| `binary-path` | Path to built binary (release command) |
| `wheel-path` | Path to built Python wheel (release command) |

## ๐ฏ Supported Project Types

- **Pure Rust Crates**: Library projects published to crates.io
- **Binary Crates**: CLI tools with cross-platform releases
- **Python Wheels**: Rust projects with Python bindings using maturin

## ๐ง Advanced Usage

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

## ๐ท๏ธ?Versioning

Use specific versions for stability:

```yaml
- uses: loonghao/rust-actions-toolkit@v2.0.0  # Specific version
- uses: loonghao/rust-actions-toolkit@v2      # Major version
- uses: loonghao/rust-actions-toolkit@main    # Latest (not recommended for production)
```

## ๐ค Contributing

Contributions welcome! See our [Contributing Guide](https://github.com/loonghao/rust-actions-toolkit/blob/main/CONTRIBUTING.md).

## ๐ License

MIT License - see [LICENSE](https://github.com/loonghao/rust-actions-toolkit/blob/main/LICENSE) for details.
