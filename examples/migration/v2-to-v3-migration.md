# Migration Guide: v2 to v3

This guide helps you migrate from rust-actions-toolkit v2 to v3, which includes major platform strategy optimizations and critical proc-macro fixes.

## 🚀 Quick Migration

### 1. Update Version References

**Simple Update (Recommended):**
```yaml
# From
- uses: loonghao/rust-actions-toolkit@v2

# To
- uses: loonghao/rust-actions-toolkit@v3
```

**Specific Version:**
```yaml
# From
- uses: loonghao/rust-actions-toolkit@v2.5.6

# To
- uses: loonghao/rust-actions-toolkit@v3.0.1
```

### 2. Update Platform Targets

**Windows Platform Change (BREAKING):**
```yaml
# From (v2)
target: x86_64-pc-windows-gnu

# To (v3) - Mainstream Windows
target: x86_64-pc-windows-msvc
```

**Remove Deprecated Platforms:**
```yaml
# Remove this (no longer supported)
- target: i686-pc-windows-gnu  # 32-bit Windows deprecated
```

## 📋 Detailed Migration Steps

### GitHub Actions

#### Before (v2)
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

#### After (v3)
```yaml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v3  # ✅ Updated
        with:
          command: ci
```

### Reusable Workflows

#### Before (v2)
```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2
```

#### After (v3)
```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v3  # ✅ Updated
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v3  # ✅ Updated
```

### Platform Matrix Updates

#### Before (v2)
```yaml
strategy:
  matrix:
    include:
      - { os: ubuntu-latest, target: x86_64-pc-windows-gnu }
      - { os: ubuntu-latest, target: i686-pc-windows-gnu }      # ❌ Deprecated
      - { os: ubuntu-latest, target: x86_64-unknown-linux-musl }
      - { os: macos-latest, target: x86_64-apple-darwin }
```

#### After (v3) - 2025 Optimized
```yaml
strategy:
  matrix:
    include:
      # Tier 1: Core platforms
      - { os: ubuntu-22.04, target: x86_64-unknown-linux-gnu }
      - { os: macos-13, target: x86_64-apple-darwin }
      - { os: macos-13, target: aarch64-apple-darwin }
      - { os: windows-2022, target: x86_64-pc-windows-msvc }    # ✅ New mainstream
      
      # Tier 2: Important platforms
      - { os: ubuntu-22.04, target: aarch64-unknown-linux-gnu }
      - { os: ubuntu-22.04, target: x86_64-unknown-linux-musl }
      - { os: ubuntu-22.04, target: aarch64-unknown-linux-musl }
      
      # Tier 3: Optional (for zero-dependency builds)
      - { os: ubuntu-22.04, target: x86_64-pc-windows-gnu }
```

## 🔧 Breaking Changes

### 1. Windows Platform Default

**Change:** Default Windows target changed from GNU to MSVC
**Impact:** Better compatibility with mainstream Windows development
**Action:** Update your target specifications

```yaml
# Old
target: x86_64-pc-windows-gnu

# New (recommended)
target: x86_64-pc-windows-msvc

# Alternative (for zero-dependency builds)
target: x86_64-pc-windows-gnu  # Still supported but lower priority
```

### 2. 32-bit Windows Removal

**Change:** Removed support for `i686-pc-windows-gnu`
**Impact:** 32-bit Windows builds no longer supported
**Action:** Remove from your platform matrix

```yaml
# Remove this line
- { os: ubuntu-latest, target: i686-pc-windows-gnu }
```

### 3. Runner OS Updates

**Change:** Updated to more specific runner versions
**Impact:** Better consistency and newer toolchains
**Action:** Update your runner OS specifications

```yaml
# Old
os: ubuntu-latest
os: macos-latest

# New (recommended)
os: ubuntu-22.04
os: macos-13
os: windows-2022  # For MSVC builds
```

## ✅ What's Fixed in v3

### 1. Proc-Macro Cross-Compilation

**Problem Solved:** `cannot produce proc-macro for async-trait` errors
**Benefit:** All proc-macro crates now work correctly in cross-compilation

```yaml
# These now work perfectly with v3
dependencies:
  async-trait: "0.1"
  serde: { version = "1.0", features = ["derive"] }
  tokio: { version = "1.0", features = ["macros"] }
  clap: { version = "4.0", features = ["derive"] }
```

### 2. Platform Strategy Optimization

**Improvement:** Aligned with 2025 Rust ecosystem best practices
**Benefit:** Better compatibility and reduced maintenance overhead

## 🎯 Platform Strategy Summary

### v3 Platform Tiers

**Tier 1 (Core - Essential):**
- `x86_64-unknown-linux-gnu` - Standard Linux
- `x86_64-apple-darwin` - Intel Mac
- `aarch64-apple-darwin` - Apple Silicon Mac
- `x86_64-pc-windows-msvc` - Windows MSVC (NEW)

**Tier 2 (Important - Recommended):**
- `aarch64-unknown-linux-gnu` - ARM64 Linux
- `x86_64-unknown-linux-musl` - Static Linux
- `aarch64-unknown-linux-musl` - Static ARM64 Linux

**Tier 3 (Optional - Specific Use Cases):**
- `x86_64-pc-windows-gnu` - Windows GNU (zero-dependency)

## 🔄 Migration Checklist

- [ ] Update all `@v2` references to `@v3`
- [ ] Change Windows target from `x86_64-pc-windows-gnu` to `x86_64-pc-windows-msvc`
- [ ] Remove `i686-pc-windows-gnu` from platform matrix
- [ ] Update runner OS to specific versions (`ubuntu-22.04`, `macos-13`, `windows-2022`)
- [ ] Test workflows to ensure proc-macro crates work correctly
- [ ] Update documentation and README files
- [ ] Verify CI and release workflows are consistent

## 🚨 Common Issues

### Issue: Proc-macro errors still occurring
**Solution:** Ensure you're using v3.0.1 or later
```yaml
- uses: loonghao/rust-actions-toolkit@v3  # Auto-updates to latest v3.x
```

### Issue: Windows builds failing
**Solution:** Use MSVC target and appropriate runner
```yaml
- { os: windows-2022, target: x86_64-pc-windows-msvc }
```

### Issue: Old platform configurations
**Solution:** Use the new optimized platform matrix from examples

## 📚 Resources

- [Platform Support Strategy 2025](../docs/PLATFORM_SUPPORT_STRATEGY_2025.md)
- [Proc-Macro Cross-Compilation Fix](../docs/PROC_MACRO_CROSS_COMPILATION_FIX.md)
- [Updated Examples](../examples/)
- [CHANGELOG](../CHANGELOG.md)

## 🆘 Need Help?

If you encounter issues during migration:

1. Check the [troubleshooting guide](../docs/PROC_MACRO_CROSS_COMPILATION_FIX.md#troubleshooting)
2. Review [updated examples](../examples/)
3. Open an issue with your workflow configuration and error logs

## 🎉 Benefits After Migration

- ✅ **Proc-macro compatibility** - All proc-macro crates work correctly
- ✅ **Better Windows support** - MSVC provides better compatibility
- ✅ **Industry alignment** - Matches popular Rust projects
- ✅ **Reduced complexity** - Fewer edge cases and maintenance overhead
- ✅ **Future-proof** - Prepared for ARM64 and container deployments
