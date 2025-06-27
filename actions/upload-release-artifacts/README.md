# 📦 Upload Release Artifacts Action

A specialized GitHub Action for uploading binaries and Python wheels to GitHub releases with smart artifact detection and flexible configuration.

## ✨ Features

- 🔍 **Smart Detection**: Automatically finds binaries and wheels in specified directories
- 📦 **Multi-format Support**: Handles both binary executables and Python wheels
- 🗜️ **Archive Creation**: Optional tar.gz/zip archive creation for binaries
- 🎯 **Flexible Paths**: Supports both file and directory inputs
- 📊 **Detailed Output**: Provides counts and lists of uploaded artifacts
- 🔧 **Configurable**: Extensive customization options

## 🚀 Quick Start

### Basic Usage

```yaml
- name: Upload release artifacts
  uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Upload Only Binaries

```yaml
- name: Upload binaries
  uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    upload-wheels: false
    binary-path: target/release/my-app
```

### Upload Only Python Wheels

```yaml
- name: Upload wheels
  uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    upload-binaries: false
    wheel-path: dist/
```

### Complete Configuration

```yaml
- name: Upload release artifacts
  uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    binary-name: my-app
    binary-path: target/release/
    wheel-path: target/wheels/
    create-archives: true
    archive-name: my-app
    tag-name: v1.0.0
    release-name: "My App v1.0.0"
    generate-release-notes: true
```

## 📋 Inputs

### Required

| Input | Description |
|-------|-------------|
| `github-token` | GitHub token for release uploads |

### Artifact Configuration

| Input | Description | Default |
|-------|-------------|---------|
| `binary-name` | Binary name to upload (auto-detected if not specified) | `''` |
| `binary-path` | Path to binary file or directory containing binaries | `target/release` |
| `wheel-path` | Path to wheel file or directory containing wheels | `target/wheels` |

### Upload Options

| Input | Description | Default |
|-------|-------------|---------|
| `upload-binaries` | Upload binary artifacts | `true` |
| `upload-wheels` | Upload Python wheel artifacts | `true` |

### Archive Options

| Input | Description | Default |
|-------|-------------|---------|
| `create-archives` | Create tar.gz/zip archives for binaries | `true` |
| `archive-name` | Base name for archives (defaults to binary name) | `''` |

### Release Configuration

| Input | Description | Default |
|-------|-------------|---------|
| `tag-name` | Release tag name (auto-detected if not specified) | `''` |
| `release-name` | Release name (defaults to tag name) | `''` |
| `draft` | Create as draft release | `false` |
| `prerelease` | Mark as prerelease | `false` |
| `generate-release-notes` | Auto-generate release notes | `true` |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `release-url` | URL of the created/updated release |
| `release-id` | ID of the created/updated release |
| `uploaded-files` | Comma-separated list of uploaded files |
| `binary-count` | Number of binary files uploaded |
| `wheel-count` | Number of wheel files uploaded |

## 🎯 Use Cases

### 1. Rust Binary Release

```yaml
name: Release Binary

on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build binary
        run: cargo build --release
      
      - name: Upload binary
        uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          binary-name: my-app
          upload-wheels: false
```

### 2. Python Extension Release

```yaml
name: Release Python Extension

on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build wheels
        run: maturin build --release
      
      - name: Upload wheels
        uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          upload-binaries: false
          wheel-path: target/wheels/
```

### 3. Multi-Platform Release

```yaml
name: Multi-Platform Release

on:
  push:
    tags: ['v*']

jobs:
  build:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: windows-latest
            target: x86_64-pc-windows-msvc
          - os: macos-latest
            target: x86_64-apple-darwin
    
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Build
        run: cargo build --release --target ${{ matrix.target }}
      
      - name: Upload artifacts
        uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          binary-path: target/${{ matrix.target }}/release/
          archive-name: my-app-${{ matrix.target }}
```

## 🔧 Advanced Configuration

### Custom Archive Names

The action automatically creates meaningful archive names:
- `{binary-name}-{target}.tar.gz`
- `{binary-name}-{target}.zip`

### Smart Detection

The action intelligently detects artifacts:
- **Binaries**: Looks for executable files in the specified path
- **Wheels**: Searches for `*.whl` files in the specified directory
- **Auto-naming**: Uses project name if binary name not specified

### Error Handling

The action gracefully handles:
- Missing directories
- No artifacts found
- Permission issues
- Network failures

## 🤝 Integration with Main Action

This action is designed to work seamlessly with the main rust-actions-toolkit:

```yaml
- name: Build and release
  uses: loonghao/rust-actions-toolkit@v2
  with:
    command: release
    target: ${{ matrix.target }}
    binary-name: my-app
    github-token: ${{ secrets.GITHUB_TOKEN }}

# Or use the specialized action for more control
- name: Upload with custom configuration
  uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    binary-path: target/${{ matrix.target }}/release/
    create-archives: true
    archive-name: my-app-${{ matrix.target }}
```
