# turbo-cdn Migration to rust-actions-toolkit v4

This guide shows how to migrate turbo-cdn from complex v3 configuration back to simple, reliable v4 configuration.

## 🎯 Migration Goal

**From**: Complex cross-compilation with proc-macro and Docker issues
**To**: Simple, reliable CI/CD that just works (like turbo-cdn v0.4.1)

## 📋 Current Issues (v3)

- ❌ Proc-macro cross-compilation errors
- ❌ Docker permission issues
- ❌ Complex Cross.toml configurations
- ❌ Slow builds due to cross-compilation
- ❌ Maintenance overhead

## ✅ v4 Solution

- ✅ Simple CI with zero configuration
- ✅ Native builds on GitHub runners
- ✅ No cross-compilation complexity
- ✅ Fast, reliable builds
- ✅ Easy maintenance

## 🔄 Migration Steps

### Step 1: Update CI Configuration

**Before (v3 - Complex)**:
```yaml
# .github/workflows/ci.yml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v3.0.5
    with:
      enable-python-wheel: false
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

  cross-platform-test:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v3.0.5
    with:
      binary-name: "turbo-cdn"
      enable-python-wheels: false
```

**After (v4 - Core)**:
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

### Step 2: Update Release Configuration

**Before (v3 - Complex)**:
```yaml
# Complex cross-compilation configuration
# Multiple workflow files
# Cross.toml configuration
# Docker permission issues
```

**After (v4 - Enhanced)**:
```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/enhanced-release.yml@v4
    with:
      binary-name: "turbo-cdn"
      platforms: "linux,macos,windows"  # Native builds only
```

### Step 3: Remove Complex Configurations

**Delete these files**:
- `Cross.toml` (if exists)
- Any custom Docker configurations
- Complex workflow configurations

### Step 4: Update Dependencies (Optional)

If you want to publish to crates.io, add a simple release-plz configuration:

```yaml
# .github/workflows/release-plz.yml
name: Release-plz
on:
  push:
    branches: [main]

jobs:
  release-plz:
    uses: loonghao/rust-actions-toolkit/.github/workflows/simple-release-plz.yml@v4
    secrets:
      CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

## 🎉 Benefits After Migration

### Performance Improvements
- ⚡ **Faster builds**: Native compilation vs cross-compilation
- ⚡ **No Docker overhead**: Direct runner execution
- ⚡ **Parallel builds**: Multiple native runners

### Reliability Improvements
- 🛡️ **No proc-macro issues**: Native compilation handles all proc-macros correctly
- 🛡️ **No Docker permissions**: No custom Docker images
- 🛡️ **Proven approach**: Based on turbo-cdn v0.4.1 success

### Maintenance Improvements
- 🧹 **Zero configuration**: Reasonable defaults for everything
- 🧹 **No Cross.toml**: No complex cross-compilation setup
- 🧹 **Clear workflows**: Simple, readable configurations

## 📊 Platform Support Comparison

### v3 (Complex)
- ✅ Linux x86_64 (cross-compiled)
- ✅ Linux aarch64 (cross-compiled, with issues)
- ✅ Linux musl (cross-compiled, with Docker issues)
- ✅ Windows (cross-compiled, with proc-macro issues)
- ✅ macOS (limited cross-compilation support)

### v4 (Simple)
- ✅ Linux x86_64 (native, fast, reliable)
- ✅ macOS x86_64 (native, fast, reliable)
- ✅ macOS aarch64 (native, fast, reliable)
- ✅ Windows x86_64 (native, fast, reliable)

**Trade-off**: Fewer exotic platforms, but 100% reliability for core platforms.

## 🚀 Expected Results

After migration, turbo-cdn should have:

1. **Faster CI**: ~5-10 minutes instead of 20-30 minutes
2. **100% success rate**: No more proc-macro or Docker failures
3. **Easier maintenance**: Simple configurations
4. **Better developer experience**: Clear, predictable builds

## 🆘 Rollback Plan

If needed, you can always rollback to v3:

```yaml
# Rollback to v3 (not recommended)
uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v3
```

But v4 is designed to be simpler and more reliable, so rollback should not be necessary.

## 📞 Support

If you encounter any issues during migration:

1. Check the [v4 documentation](../v4/)
2. Review [simple CI examples](../examples/simple/)
3. Open an issue with your specific configuration

## 🎯 Success Criteria

Migration is successful when:

- ✅ CI runs complete without errors
- ✅ Releases are created successfully
- ✅ All core platforms (Linux, macOS, Windows) have binaries
- ✅ No proc-macro or Docker errors
- ✅ Build times are faster than before
