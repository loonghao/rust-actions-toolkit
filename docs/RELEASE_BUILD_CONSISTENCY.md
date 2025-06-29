# Release Build Consistency Testing

This document explains the Release Build Consistency Test feature and why it might be disabled.

## 🎯 What is Release Build Consistency Testing?

Release Build Consistency Testing ensures that your CI pipeline tests the **exact same build configuration** that will be used in your release workflow. This catches cross-compilation issues, dependency problems, and build failures early in the development process.

## 🔍 Why Was It Disabled?

The "Release Build Consistency Test" job is controlled by the `test-release-builds` parameter:

```yaml
# In reusable-ci.yml
test-release-builds:
  description: 'Test release builds to match release workflow'
  required: false
  type: boolean
  default: true  # Now enabled by default (was false before v2.5.3)
```

### Common Reasons for Disabled State

1. **Default Configuration** (before v2.5.3): The parameter defaulted to `false`
2. **Explicit Disabling**: User set `test-release-builds: false` in their workflow
3. **Missing Target Platforms**: No `release-target-platforms` specified
4. **Conditional Logic**: Other conditions in the workflow prevent execution

## 🚀 How to Enable

### Method 1: Use Default (v2.5.3+)
```yaml
# .github/workflows/ci.yml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      # test-release-builds is now true by default
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"}
        ]
```

### Method 2: Explicit Enabling
```yaml
# .github/workflows/ci.yml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.2
    with:
      test-release-builds: true  # Explicitly enable
      build-depth: release       # Test both debug and release builds
      release-target-platforms: |
        [
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"}
        ]
```

## 📊 What Does It Test?

### 1. Cross-Compilation Consistency
- Tests the same targets that will be used in release
- Catches cross-compilation issues early
- Validates toolchain and dependency compatibility

### 2. Build Configuration Matching
- Uses identical build flags and environment variables
- Tests release-mode optimizations
- Validates proc-macro cross-compilation

### 3. Target Platform Validation
- Ensures all release targets can be built successfully
- Tests platform-specific dependencies
- Validates Cross.toml configuration

## 🔧 Configuration Options

### Basic Configuration
```yaml
with:
  test-release-builds: true
  release-target-platforms: |
    [
      {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}
    ]
```

### Advanced Configuration
```yaml
with:
  test-release-builds: true
  build-depth: release  # Test both debug and release builds
  verify-ci-consistency: true  # Validate CI/Release consistency
  release-target-platforms: |
    [
      {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
      {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"},
      {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"},
      {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"}
    ]
```

## 📈 Benefits

### 1. Early Problem Detection
- **Catch issues before release**: Find cross-compilation problems in CI
- **Faster feedback**: No need to wait for release workflow to discover issues
- **Reduced failed releases**: Prevent broken releases from reaching users

### 2. Consistency Guarantee
- **Identical environment**: CI tests exactly what release builds
- **No surprises**: Release workflow won't fail with new issues
- **Predictable results**: What works in CI will work in release

### 3. Development Efficiency
- **Faster iteration**: Fix issues during development, not during release
- **Confident releases**: Know that release will succeed before triggering it
- **Better debugging**: Issues found in controlled CI environment

## 🔍 Troubleshooting

### Job Still Disabled After Enabling?

1. **Check target platforms**:
```yaml
# Make sure this is specified
release-target-platforms: |
  [
    {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}
  ]
```

2. **Verify workflow syntax**:
```yaml
# Ensure proper YAML formatting
with:
  test-release-builds: true  # Boolean, not string
```

3. **Check workflow conditions**:
```yaml
# Look for additional if conditions in the job
if: ${{ inputs.test-release-builds && inputs.release-target-platforms }}
```

### Build Failures in Consistency Test?

1. **Cross-compilation issues**: Check Cross.toml configuration
2. **Dependency problems**: Verify target-specific dependencies
3. **Proc-macro errors**: Ensure using v2.5.2+ with proc-macro fixes
4. **Environment differences**: Check environment variable configuration

## 📚 Examples

### Minimal Setup
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}
        ]
```

### Complete Setup
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
      enable-coverage: true
      enable-python-wheel: true
      test-release-builds: true
      build-depth: release
      verify-ci-consistency: true
      release-target-platforms: |
        [
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"}
        ]
```

## 🔗 Related Documentation

- [CI Consistency Improvements](CI_CONSISTENCY_IMPROVEMENTS.md)
- [Cross-Compilation Issues](CROSS_COMPILATION_ISSUES.md)
- [Proc-Macro Cross-Compilation](PROC_MACRO_CROSS_COMPILATION.md)
- [Workflow Robustness Fixes](WORKFLOW_ROBUSTNESS_FIXES.md)

## 💡 Best Practices

1. **Always enable** for projects with cross-compilation
2. **Use same targets** in CI and release workflows
3. **Test early** in development process
4. **Monitor build times** and adjust target matrix if needed
5. **Keep configurations in sync** between CI and release workflows
