# Best Practices for rust-actions-toolkit v2.5.3

This guide provides comprehensive best practices for using rust-actions-toolkit v2.5.3 effectively.

## 🎯 Quick Start Checklist

### ✅ Essential Setup
1. **Use reusable workflows** (recommended over single action)
2. **Specify release targets** in CI for consistency testing
3. **Keep CI and Release targets identical** for predictable results
4. **Set proper permissions** for each workflow
5. **Use latest version** (v2.5.3+) for all fixes and features

### ✅ Basic Configuration Template

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

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']

permissions:
  contents: write

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

## 🏗️ Project-Specific Configurations

### 🔧 Binary Projects

**Characteristics**: Produces executable binaries, needs cross-compilation testing

```yaml
# Recommended configuration
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      enable-coverage: true
      build-depth: release  # Test both debug and release builds
      
      # Cross-compilation targets for binary distribution
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-apple-darwin", "os": "macos-latest"},
          {"target": "aarch64-apple-darwin", "os": "macos-latest"}
        ]
```

**Best Practices**:
- ✅ Enable release build testing
- ✅ Include major platforms (Linux, Windows, macOS)
- ✅ Test both x86_64 and ARM64 for macOS
- ✅ Use musl for static Linux binaries if needed

### 📚 Library Projects

**Characteristics**: Provides functionality to other crates, no binary output

```yaml
# Recommended configuration
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      enable-coverage: true
      build-depth: basic  # Libraries don't need release builds
      test-release-builds: false  # No binary output to test
      enable-security-audit: true  # Important for dependencies
```

**Best Practices**:
- ✅ Disable release build testing (no binaries)
- ✅ Focus on code quality and security
- ✅ Enable comprehensive testing across Rust versions
- ✅ Use documentation testing

### 🐍 Rust + Python Projects

**Characteristics**: Rust code with Python bindings, produces Python wheels

```yaml
# Recommended configuration
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      enable-coverage: true
      enable-python-wheel: true  # Enable Python wheel building
      build-depth: release
      
      # Include Python wheel compatible targets
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-apple-darwin", "os": "macos-latest"},
          {"target": "aarch64-apple-darwin", "os": "macos-latest"}
        ]
```

**Best Practices**:
- ✅ Enable Python wheel building
- ✅ Include ARM64 targets for modern Python support
- ✅ Test wheel installation in CI
- ✅ Use maturin for Python binding builds

## 🎯 Target Platform Selection

### 🌍 Recommended Target Combinations

#### Minimal (Fast CI)
```yaml
release-target-platforms: |
  [
    {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}
  ]
```

#### Standard (Most Projects)
```yaml
release-target-platforms: |
  [
    {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
    {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
    {"target": "x86_64-apple-darwin", "os": "macos-latest"}
  ]
```

#### Comprehensive (Production Projects)
```yaml
release-target-platforms: |
  [
    {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
    {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
    {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"},
    {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"},
    {"target": "x86_64-apple-darwin", "os": "macos-latest"},
    {"target": "aarch64-apple-darwin", "os": "macos-latest"}
  ]
```

### 🚀 Performance Considerations

| Target Count | CI Time | Use Case |
|-------------|---------|----------|
| 1 target | ~5-10 min | Development, testing |
| 3 targets | ~15-25 min | Standard projects |
| 6+ targets | ~30-45 min | Production releases |

## ⚙️ Advanced Configuration

### 🔧 Feature Flags

```yaml
with:
  # Core settings
  rust-toolchain: stable  # or "1.70", "nightly"
  
  # Quality assurance
  enable-coverage: true  # Code coverage reporting
  enable-security-audit: true  # Vulnerability scanning
  
  # Build configuration
  build-depth: release  # basic | release | full
  test-release-builds: true  # Default: true in v2.5.3
  verify-ci-consistency: true  # Validate CI/Release consistency
  
  # Python support
  enable-python-wheel: true  # Only if project has Python bindings
```

### 🎯 Conditional Configuration

```yaml
# Different configurations for different branches
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      # More targets for main branch, fewer for feature branches
      release-target-platforms: |
        ${{ github.ref == 'refs/heads/main' && 
        '[
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-apple-darwin", "os": "macos-latest"}
        ]' || 
        '[
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}
        ]' }}
```

## 🔍 Troubleshooting

### ❌ Common Issues

#### 1. "Release Build Consistency Test" Disabled
**Cause**: Missing `release-target-platforms` parameter
**Solution**:
```yaml
# Add this to your CI configuration
release-target-platforms: |
  [
    {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"}
  ]
```

#### 2. Proc-Macro Cross-Compilation Errors
**Cause**: Using older version with proc-macro issues
**Solution**: Update to v2.5.3+ which includes all proc-macro fixes

#### 3. Long CI Times
**Cause**: Too many target platforms
**Solution**: Reduce targets or use conditional configuration

#### 4. Cross-Compilation Failures
**Cause**: Missing dependencies or incorrect Cross.toml
**Solution**: Check [Cross-Compilation Guide](CROSS_COMPILATION_ISSUES.md)

### ✅ Validation Checklist

Before deploying your configuration:

- [ ] CI and Release use identical target platforms
- [ ] Permissions are correctly set
- [ ] Using v2.5.3 or later
- [ ] Project type matches configuration
- [ ] Target platforms are appropriate for project needs
- [ ] Build times are acceptable

## 📚 Additional Resources

### 📖 Documentation
- [Release Build Consistency](RELEASE_BUILD_CONSISTENCY.md)
- [Proc-Macro Cross-Compilation](PROC_MACRO_CROSS_COMPILATION.md)
- [Cross-Compilation Issues](CROSS_COMPILATION_ISSUES.md)
- [Workflow Robustness Fixes](WORKFLOW_ROBUSTNESS_FIXES.md)

### 🔗 Examples
- [CI/Release Consistency Example](../examples/ci-release-consistency-test/)
- [Enhanced CI Configuration](../examples/enhanced-ci/)
- [Cross-Compilation Examples](../examples/cross-compilation/)

### 🆘 Support
- [GitHub Issues](https://github.com/loonghao/rust-actions-toolkit/issues)
- [Discussions](https://github.com/loonghao/rust-actions-toolkit/discussions)
- [Troubleshooting Guides](../docs/)

## 🎯 Summary

**Key Takeaways for v2.5.3:**

1. **Use reusable workflows** for modern projects
2. **Specify release targets** for consistency testing
3. **Keep configurations simple** and project-appropriate
4. **Update to latest version** for all fixes
5. **Follow project-specific best practices**

With these practices, you'll have a robust, reliable CI/CD pipeline that catches issues early and produces consistent results.
