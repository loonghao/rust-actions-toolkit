# 🚀 Smart Release Action

**Zero-configuration release action with automatic project detection and optimal defaults.**

## ✨ Why Smart Release?

- 🔍 **Auto-Detection**: Automatically detects project type, binary name, and target platform
- 🎯 **Zero Config**: Works out of the box with minimal configuration
- 🚀 **Optimal Defaults**: Applies best practices automatically
- 📦 **Universal**: Supports binary, Python extension, and hybrid projects
- 🔧 **Flexible**: Easy to override when needed

## 🎯 Quick Start

### Minimal Configuration (Recommended)

```yaml
- name: Release
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

That's it! The action will:
- ✅ Detect your project name from `Cargo.toml`
- ✅ Detect project type (binary/Python extension/hybrid)
- ✅ Detect target platform from runner
- ✅ Build appropriate artifacts
- ✅ Create optimized archives
- ✅ Upload to GitHub releases

### Multi-Platform Release

```yaml
name: Release

on:
  push:
    tags: ['v*']

jobs:
  release:
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
      
      - name: Release
        uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          target: ${{ matrix.target }}
```

## 🔍 Auto-Detection Features

### Project Type Detection

| Project Type | Detection Logic | Actions |
|--------------|-----------------|---------|
| **Binary** | `src/main.rs` or `[[bin]]` in Cargo.toml | Build and upload binary |
| **Python Extension** | `pyproject.toml` exists | Build and upload wheels |
| **Hybrid** | Both binary and Python configs | Build and upload both |
| **Library** | Neither binary nor Python | Skip binary build |

### Platform Detection

| Runner | Auto-Detected Target | Notes |
|--------|---------------------|-------|
| `ubuntu-latest` | `x86_64-unknown-linux-gnu` | Standard GNU build |
| `windows-latest` | `x86_64-pc-windows-gnu` | Zero-dependency build |
| `macos-latest` (Intel) | `x86_64-apple-darwin` | Intel Mac |
| `macos-latest` (ARM64) | `aarch64-apple-darwin` | Apple Silicon |

**Supported Targets** (aligned with Docker base image):
- **Zero-dependency Windows**: `x86_64-pc-windows-gnu`, `i686-pc-windows-gnu`
- **Static Linux**: `x86_64-unknown-linux-musl`, `aarch64-unknown-linux-musl`
- **Standard builds**: `x86_64-unknown-linux-gnu`, `aarch64-unknown-linux-gnu`
- **macOS**: `x86_64-apple-darwin`, `aarch64-apple-darwin`

### Name Detection

- **Project Name**: From `Cargo.toml` `name` field
- **Binary Name**: Same as project name (unless overridden)
- **Archive Name**: `{project-name}-{target}`

### Release Notes Templates

The action supports custom release notes templates with variable substitution:

**Template Locations** (checked in order):
1. Custom path via `release-notes-template` input
2. `.github/release-template.md`
3. `.github/RELEASE_TEMPLATE.md`
4. `release-template.md`
5. `RELEASE_TEMPLATE.md`

**Available Variables**:
- `{{PROJECT_NAME}}` - Project name from Cargo.toml
- `{{VERSION}}` - Version without 'v' prefix
- `{{TAG_NAME}}` - Full tag name (e.g., v1.0.0)
- `{{TARGET}}` - Target platform
- `{{REPOSITORY}}` - GitHub repository (owner/repo)
- `{{PROJECT_TYPE}}` - Detected project type

## 📋 Inputs

### Required

| Input | Description |
|-------|-------------|
| `github-token` | GitHub token for release operations |

### Optional

| Input | Description | Default |
|-------|-------------|---------|
| `target` | Target platform | Auto-detected |
| `binary-name` | Binary name | Auto-detected from Cargo.toml |
| `rust-toolchain` | Rust toolchain version | `stable` |
| `skip-build` | Skip building, only upload existing artifacts | `false` |
| `draft` | Create as draft release | `false` |
| `prerelease` | Mark as prerelease | Auto-detected from tag |
| `release-notes-template` | Path to release notes template | `''` |
| `generate-release-notes` | Auto-generate if no template | `true` |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `release-url` | URL of the created release |
| `binary-path` | Path to the built binary |
| `wheel-path` | Path to the built wheel (if applicable) |
| `project-type` | Detected project type |

## 🎯 Real-World Examples

### py2pyd Project

**Before** (complex configuration):
```yaml
- name: Build binary
  uses: loonghao/rust-actions-toolkit@v2
  with:
    command: release
    target: ${{ matrix.target }}
    binary-name: py2pyd
    enable-python-wheels: true
    github-token: ${{ secrets.GITHUB_TOKEN }}

- name: Upload artifacts
  uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    binary-name: py2pyd
    binary-path: target/${{ matrix.target }}/release/
    wheel-path: target/wheels/
    archive-name: py2pyd-${{ matrix.target }}
```

**After** (zero configuration):
```yaml
- name: Release
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    target: ${{ matrix.target }}
```

### Binary-Only Project

```yaml
# Cargo.toml has: name = "my-tool"
# src/main.rs exists

- name: Release
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}

# Automatically:
# - Detects binary name: my-tool
# - Builds for current platform
# - Creates my-tool-{target}.tar.gz
# - Uploads to GitHub release
```

### Python Extension Project

```yaml
# pyproject.toml exists
# No src/main.rs

- name: Release
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}

# Automatically:
# - Detects Python extension project
# - Builds wheels only
# - Uploads .whl files to release
```

## 🔧 Advanced Usage

### Override Detection

```yaml
- name: Release with overrides
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    binary-name: custom-name
    target: aarch64-unknown-linux-musl
    rust-toolchain: 1.75.0
```

### Upload Pre-built Artifacts

```yaml
- name: Build elsewhere
  run: cargo build --release

- name: Upload only
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    skip-build: true
```

### Draft Release

```yaml
- name: Create draft
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    draft: true
```

### Custom Release Notes Template

Create `.github/release-template.md`:
```markdown
# {{PROJECT_NAME}} {{VERSION}}

🎉 New release available!

## 📦 Downloads

### Binaries
- Windows: `{{PROJECT_NAME}}-x86_64-pc-windows-gnu.zip`
- Linux: `{{PROJECT_NAME}}-x86_64-unknown-linux-gnu.tar.gz`
- macOS: `{{PROJECT_NAME}}-x86_64-apple-darwin.tar.gz`

### Python Package
```bash
pip install {{PROJECT_NAME}}=={{VERSION}}
```

## Changes
<!-- Add your changes here -->
```

Then use the action normally:
```yaml
- name: Release with template
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    # Template will be auto-detected
```

Or specify a custom path:
```yaml
- name: Release with custom template
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    release-notes-template: docs/release-notes.md
```

## 🆚 Comparison

| Approach | Lines of Config | Maintenance | Flexibility |
|----------|----------------|-------------|-------------|
| **Manual Setup** | 50+ lines | High | High |
| **upload-release-artifacts** | 15-20 lines | Medium | Medium |
| **smart-release** | 3-5 lines | Low | Medium |

## 🎯 When to Use

### Use Smart Release When:
- ✅ You want minimal configuration
- ✅ Your project follows standard conventions
- ✅ You need consistent behavior across projects
- ✅ You want automatic best practices

### Use upload-release-artifacts When:
- 🔧 You need fine-grained control
- 🔧 You have non-standard project structure
- 🔧 You want to customize archive creation
- 🔧 You're migrating from existing setup

### Use Main Action When:
- ⚙️ You need maximum flexibility
- ⚙️ You have complex build requirements
- ⚙️ You want to compose your own workflow
- ⚙️ You need custom CI steps

## 🚀 Migration Guide

### From Complex Workflows

Replace this:
```yaml
# 20+ lines of configuration
- name: Setup cross-compilation
- name: Build binary
- name: Build wheels
- name: Create archives
- name: Upload to release
```

With this:
```yaml
- name: Release
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### From upload-release-artifacts

Replace this:
```yaml
- name: Build
  uses: loonghao/rust-actions-toolkit@v2
  # ... configuration

- name: Upload
  uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
  # ... configuration
```

With this:
```yaml
- name: Release
  uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

## 🎉 Benefits

- 📉 **90% less configuration** - From 20+ lines to 3 lines
- 🔄 **Consistent behavior** - Same setup across all projects
- 🛡️ **Best practices** - Automatically applied
- 🚀 **Faster setup** - New projects work immediately
- 🔧 **Easy maintenance** - Updates happen automatically
