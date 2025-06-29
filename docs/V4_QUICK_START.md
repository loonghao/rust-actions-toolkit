# rust-actions-toolkit v4 Quick Start

## 🚀 Get Started in 2 Minutes

rust-actions-toolkit v4 is designed for **zero configuration** and **maximum reliability**. No complex setup, no cross-compilation issues, just working CI/CD.

## 📋 Core CI (Recommended for All Projects)

Create `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}  # Optional
```

**That's it!** This gives you:
- ✅ Code formatting (cargo fmt)
- ✅ Code quality (cargo clippy)
- ✅ Documentation (cargo doc)
- ✅ Unit tests (cargo test)
- ✅ Security audit (cargo audit)
- ✅ Code coverage (optional)

## 🎯 Enhanced Release (For Production Projects)

Create `.github/workflows/release.yml`:

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/enhanced-release.yml@v4
    with:
      binary-name: "my-tool"  # Optional: auto-detected from Cargo.toml
      platforms: "linux,macos,windows"  # Optional: default is all three
```

**This provides**:
- ✅ Multi-platform native builds (Linux, macOS, Windows)
- ✅ GitHub releases with binaries
- ✅ Fast, reliable builds
- ✅ No cross-compilation complexity

## 🎨 Customization Options

### Core CI Options

```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
    with:
      rust-toolchain: "1.70"      # Default: "stable"
      enable-coverage: false      # Default: true
      enable-audit: false         # Default: true
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

### Enhanced Release Options

```yaml
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/enhanced-release.yml@v4
    with:
      binary-name: "my-tool"           # Auto-detected if not specified
      platforms: "linux,macos"        # Default: "linux,macos,windows"
      rust-toolchain: "stable"        # Default: "stable"
      create-release: true             # Default: true
```

## 📊 Platform Support

### Core CI
- **Linux x86_64** (ubuntu-22.04) - All checks run here

### Enhanced Release
- **Linux x86_64** (ubuntu-22.04, native build)
- **macOS x86_64** (macos-13, native build)
- **macOS aarch64** (macos-14, Apple Silicon, native build)
- **Windows x86_64** (windows-2022, native build)

**Key Advantage**: All builds use **native GitHub runners** - no cross-compilation, no Docker, no complexity.

## 🔄 Migration from v3

### Before (v3 - Complex)
```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v3
    # Complex configuration, cross-compilation issues

  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v3
    # Proc-macro problems, Docker permission issues
```

### After (v4 - Clean)
```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
    # Zero configuration, just works

  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/enhanced-release.yml@v4
    # Native builds, no complexity
```

## 🎯 Why v4 is Better

### Reliability
- ✅ **No proc-macro issues**: Native builds handle all proc-macros correctly
- ✅ **No Docker problems**: No custom Docker images or permission issues
- ✅ **No cross-compilation**: Eliminates the #1 source of CI failures

### Speed
- ⚡ **Faster builds**: Native compilation is faster than cross-compilation
- ⚡ **Parallel execution**: Multiple native runners work in parallel
- ⚡ **No Docker overhead**: Direct runner execution

### Simplicity
- 🎨 **Zero configuration**: Reasonable defaults for everything
- 🎨 **Clear options**: Only expose what you actually need to configure
- 🎨 **Predictable**: Same behavior every time

## 📚 Examples

### Minimal Setup (Most Projects)
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
```

### Production Setup
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/enhanced-release.yml@v4
    with:
      binary-name: "my-awesome-tool"
```

## 🆘 Need More Features?

If you need advanced features like cross-compilation to exotic platforms:

```yaml
# Advanced users only - expect complexity
jobs:
  advanced-release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/advanced-release.yml@v4
    with:
      cross-compilation: true
      # Warning: May encounter proc-macro and Docker issues
```

But for 95% of projects, Core CI + Enhanced Release is all you need.

## 🎉 Success Stories

- **turbo-cdn**: Migrated from complex v3 to v4, now has reliable CI/CD
- **Fast builds**: 5-10 minutes instead of 20-30 minutes
- **Zero failures**: No more proc-macro or Docker issues
- **Easy maintenance**: Simple configurations that don't break

Ready to get started? Just copy the examples above! 🚀
