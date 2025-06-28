# Enhanced CI Configuration

This example demonstrates the improved rust-actions-toolkit with CI and Release consistency features.

## 🎯 Key Improvements

### 1. CI and Release Consistency
- **Problem**: CI only tested `cargo build`, but Release used `cargo build --release`
- **Solution**: CI now optionally tests release builds to match the release workflow

### 2. Unified Build Environment
- **Problem**: Different environment setup between CI and Release
- **Solution**: Shared `setup-build-env` action ensures consistency

### 3. Early Problem Detection
- **Problem**: Cross-compilation issues (like `libmimalloc-sys`) only discovered during release
- **Solution**: CI can now test the same targets and build configurations as release

## 🔧 Configuration

### CI Configuration (`ci.yml`)

```yaml
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.3.0
    with:
      # Enable release build testing
      test-release-builds: true
      build-depth: release  # basic, release, full
      
      # Match release targets exactly
      release-target-platforms: |
        [
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"}
        ]
```

### Release Configuration (`release.yml`)

```yaml
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2.3.0
    with:
      # Verify CI tested the same targets
      verify-ci-consistency: true
      
      # Should match CI configuration
      target-platforms: |
        [
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"}
        ]
```

## 📊 Build Depth Options

| Option | Description | Use Case |
|--------|-------------|----------|
| `basic` | Standard CI builds only | Fast feedback for most PRs |
| `release` | Include release builds | Catch release-specific issues |
| `full` | Release builds + binary verification | Complete validation |

## 🚀 Benefits

### Before Enhancement
- ❌ CI: `cargo build` (debug mode)
- ❌ Release: `cargo build --release` (different configuration)
- ❌ Issues discovered late in release process

### After Enhancement
- ✅ CI: Both debug and release builds (optional)
- ✅ Release: Same configuration as tested in CI
- ✅ Issues discovered early in PR stage

## 🔍 Troubleshooting

### Common Issues

1. **Target Platform Mismatch**
   ```
   Error: CI and Release target platforms don't match
   ```
   **Solution**: Ensure `release-target-platforms` in CI matches `target-platforms` in Release

2. **Cross-compilation Failures**
   ```
   Error: libmimalloc-sys build failed
   ```
   **Solution**: The enhanced configuration automatically handles this with proper toolchain setup

3. **Build Time Concerns**
   ```
   CI takes too long with release builds
   ```
   **Solution**: Use `build-depth: basic` for regular PRs, `release` for important branches

## 📚 Related Documentation

- [Memory Allocator Troubleshooting](../../docs/MIMALLOC_TROUBLESHOOTING.md)
- [Cross-compilation Issues](../../docs/CROSS_COMPILATION_ISSUES.md)
- [Best Practices Guide](../../docs/BEST_PRACTICES.md)

## 🎯 Migration Guide

### Step 1: Update CI Configuration
```yaml
# Add to your .github/workflows/ci.yml
test-release-builds: true
release-target-platforms: |
  [
    # Copy from your release.yml target-platforms
  ]
```

### Step 2: Update Release Configuration
```yaml
# Add to your .github/workflows/release.yml
verify-ci-consistency: true
```

### Step 3: Test the Configuration
1. Create a PR with these changes
2. Verify CI tests release builds
3. Check that release workflow validates consistency

## 💡 Tips

1. **Start Small**: Begin with `build-depth: basic` and gradually increase
2. **Match Exactly**: Ensure CI and Release target platforms are identical
3. **Monitor Performance**: Release builds take longer, plan accordingly
4. **Use Caching**: The toolkit automatically handles Rust compilation caching

## 🔗 Example Projects

- [py2pyd](https://github.com/loonghao/py2pyd) - Uses enhanced CI configuration
- [vx-shimexe](https://github.com/loonghao/vx-shimexe) - Cross-platform binary project
