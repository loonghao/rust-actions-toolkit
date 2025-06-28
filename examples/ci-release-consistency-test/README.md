# CI and Release Consistency Test

This example demonstrates how to achieve perfect consistency between CI and Release workflows using the enhanced rust-actions-toolkit.

## 🎯 Problem Solved

**Before Enhancement:**
- CI: `cargo build` (debug mode) - Fast but incomplete testing
- Release: `cargo build --release` (release mode) - Different configuration
- Result: Issues like `libmimalloc-sys` failures discovered only during release

**After Enhancement:**
- CI: Both debug and release builds with same targets as release
- Release: Same configuration as tested in CI
- Result: Issues caught early in PR stage

## ✅ Consistency Guarantees

### 1. Build Type Consistency
```yaml
# CI tests both debug AND release builds
test-release-builds: true
build-depth: release
```

### 2. Target Platform Consistency
```yaml
# CI and Release use IDENTICAL target lists
release-target-platforms: |
  [
    {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
    {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"}
  ]

target-platforms: |
  [
    {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
    {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"}
  ]
```

### 3. Environment Consistency
- Both CI and Release use identical inline build environment setup
- Identical Cross.toml configuration with mimalloc support
- Same environment variables and toolchain setup

### 4. Verification
```yaml
# Release workflow verifies CI tested same targets
verify-ci-consistency: true
```

## 🔧 How It Works

### CI Workflow
1. **Standard CI checks**: format, clippy, docs, tests
2. **Release build testing**: Tests `cargo build --release` for all targets
3. **Cross-compilation testing**: Uses same environment as release
4. **Early problem detection**: Catches mimalloc and other issues

### Release Workflow
1. **Consistency verification**: Ensures CI tested same targets
2. **Unified environment**: Uses identical inline build environment setup as CI
3. **Predictable results**: No surprises since CI already tested everything

## 📊 Benefits

| Aspect | Before | After |
|--------|--------|-------|
| **Issue Detection** | Release time ❌ | PR time ✅ |
| **Build Consistency** | Different configs ❌ | Identical configs ✅ |
| **Cross-compilation** | Untested ❌ | Fully tested ✅ |
| **Developer Experience** | Surprises ❌ | Predictable ✅ |

## 🚀 Usage

### Step 1: Copy Configuration Files
```bash
# Copy to your project
cp examples/ci-release-consistency-test/ci.yml .github/workflows/
cp examples/ci-release-consistency-test/release.yml .github/workflows/
```

### Step 2: Customize for Your Project
```yaml
# Update binary name in release.yml
binary-name: "your-app-name"

# Adjust target platforms as needed
target-platforms: |
  [
    {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
    # Add/remove targets as needed
  ]
```

### Step 3: Ensure Consistency
- CI `release-target-platforms` MUST match Release `target-platforms`
- Both workflows MUST use the same rust-toolchain version
- Keep configurations synchronized

## 🔍 Verification

### Manual Verification
1. Create a PR with these configurations
2. Check that CI tests release builds for all targets
3. Merge PR and create a release tag
4. Verify release workflow validates consistency
5. Confirm no build failures

### Automated Verification
The toolkit automatically:
- Validates target platform consistency
- Ensures environment setup is identical
- Reports any configuration mismatches

## 💡 Best Practices

1. **Keep Configurations in Sync**: Always update both CI and Release when changing targets
2. **Start Small**: Begin with a few targets, gradually add more
3. **Monitor Performance**: Release builds take longer, plan accordingly
4. **Use Caching**: The toolkit automatically handles Rust compilation caching
5. **Test Thoroughly**: Create test PRs to verify the setup works

## 🔗 Related Documentation

- [CI Consistency Improvements](../../docs/CI_CONSISTENCY_IMPROVEMENTS.md)
- [Memory Allocator Troubleshooting](../../docs/MIMALLOC_TROUBLESHOOTING.md)
- [Cross-compilation Issues](../../docs/CROSS_COMPILATION_ISSUES.md)

## ⚠️ Important Notes

- **Target Consistency**: CI and Release target lists MUST be identical
- **Performance Impact**: Release builds in CI will increase build time
- **Resource Usage**: Consider GitHub Actions minute limits
- **Caching**: Proper caching is essential for reasonable build times
