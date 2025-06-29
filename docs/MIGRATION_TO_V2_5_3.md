# Migration Guide to v2.5.3

This guide helps you migrate from older versions of rust-actions-toolkit to v2.5.3 with all the latest features and fixes.

## 🎯 Why Upgrade to v2.5.3?

### ✨ New Features
- **Automatic Release Build Consistency Testing** - Enabled by default
- **Complete Proc-Macro Cross-Compilation Support** - Works with all popular crates
- **Enhanced Error Handling** - Graceful failure handling and clear error messages
- **Smart Project Detection** - Automatically handles binary vs library projects
- **Zero-Configuration Defaults** - Works out of the box with minimal setup

### 🐛 Critical Fixes
- ✅ Fixed "cannot produce proc-macro for async-trait" errors
- ✅ Fixed "INPUT_BIN: parameter null or not set" errors
- ✅ Fixed PowerShell syntax errors on Windows runners
- ✅ Fixed cross-platform compatibility issues
- ✅ Fixed disabled Release Build Consistency Tests

## 🚀 Migration Paths

### From Single Action (v1.x/v2.x) to Reusable Workflows

#### Before (Single Action)
```yaml
# .github/workflows/ci.yml
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

#### After (Reusable Workflows - Recommended)
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

permissions:
  contents: read
  actions: read

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"}
        ]
```

### From v2.5.0-v2.5.2 to v2.5.3

#### Automatic Upgrade (No Changes Required)
```yaml
# Simply update the version
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    # test-release-builds is now automatically enabled!
```

#### If You Want to Disable (Optional)
```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      test-release-builds: false  # Explicitly disable if needed
```

## 📋 Step-by-Step Migration

### Step 1: Update CI Workflow

1. **Replace single action with reusable workflow**:
```yaml
# Replace this:
- uses: loonghao/rust-actions-toolkit@v2

# With this:
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
```

2. **Add permissions**:
```yaml
permissions:
  contents: read
  actions: read
```

3. **Specify release targets**:
```yaml
with:
  release-target-platforms: |
    [
      {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}
    ]
```

### Step 2: Update Release Workflow

1. **Replace single action with reusable workflow**:
```yaml
# Replace matrix strategy with reusable workflow
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2.5.3
    with:
      target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"}
        ]
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

2. **Ensure target consistency**:
Make sure `target-platforms` in release matches `release-target-platforms` in CI.

### Step 3: Test and Validate

1. **Push changes and verify**:
   - CI runs successfully
   - "Release Build Consistency Test" is enabled (not grayed out)
   - All targets build successfully

2. **Create a test release**:
   - Tag a test version: `git tag v0.0.1-test`
   - Push tag: `git push origin v0.0.1-test`
   - Verify release workflow succeeds

## 🎯 Project-Specific Migration

### Binary Projects
```yaml
# Add these configurations
with:
  rust-toolchain: stable
  enable-coverage: true
  build-depth: release
  release-target-platforms: |
    [
      {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
      {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
      {"target": "x86_64-apple-darwin", "os": "macos-latest"}
    ]
```

### Library Projects
```yaml
# Simpler configuration for libraries
with:
  rust-toolchain: stable
  enable-coverage: true
  build-depth: basic
  test-release-builds: false  # No binaries to test
```

### Python Binding Projects
```yaml
# Enable Python wheel support
with:
  rust-toolchain: stable
  enable-coverage: true
  enable-python-wheel: true
  release-target-platforms: |
    [
      {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
      {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
      {"target": "aarch64-apple-darwin", "os": "macos-latest"}
    ]
```

## 🔍 Troubleshooting Migration

### Common Issues

#### 1. "Release Build Consistency Test" Still Disabled
**Solution**: Add `release-target-platforms` parameter:
```yaml
with:
  release-target-platforms: |
    [
      {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}
    ]
```

#### 2. Permission Errors
**Solution**: Add proper permissions:
```yaml
permissions:
  contents: read
  actions: read
  # For release workflow:
  # contents: write
```

#### 3. Proc-Macro Compilation Errors
**Solution**: Ensure using v2.5.3 which includes all proc-macro fixes.

#### 4. Target Mismatch Between CI and Release
**Solution**: Use identical target configurations:
```yaml
# CI
release-target-platforms: |
  [{"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}]

# Release  
target-platforms: |
  [{"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}]
```

## 📚 Additional Resources

### Documentation
- [Best Practices for v2.5.3](BEST_PRACTICES_V2_5_3.md)
- [Release Build Consistency](RELEASE_BUILD_CONSISTENCY.md)
- [Proc-Macro Cross-Compilation](PROC_MACRO_CROSS_COMPILATION.md)

### Examples
- [CI/Release Consistency Example](../examples/ci-release-consistency-test/)
- [Enhanced CI Configuration](../examples/enhanced-ci/)

### Support
- [GitHub Issues](https://github.com/loonghao/rust-actions-toolkit/issues)
- [Discussions](https://github.com/loonghao/rust-actions-toolkit/discussions)

## ✅ Migration Checklist

- [ ] Updated CI workflow to use reusable workflow
- [ ] Updated Release workflow to use reusable workflow
- [ ] Added proper permissions to both workflows
- [ ] Specified `release-target-platforms` in CI
- [ ] Ensured target consistency between CI and Release
- [ ] Tested CI workflow runs successfully
- [ ] Verified "Release Build Consistency Test" is enabled
- [ ] Tested release workflow with a test tag
- [ ] Updated to v2.5.3 for all latest fixes
- [ ] Reviewed project-specific configuration options

## 🎉 Benefits After Migration

- ✅ **Automatic consistency testing** between CI and Release
- ✅ **Early detection** of cross-compilation issues
- ✅ **Reliable proc-macro support** for all popular crates
- ✅ **Simplified configuration** with smart defaults
- ✅ **Better error handling** and debugging experience
- ✅ **Future-proof setup** with latest GitHub Actions best practices

Welcome to rust-actions-toolkit v2.5.3! 🚀
