# py2pyd Migration Example

This example shows how to migrate py2pyd from reusable workflows to GitHub Actions for better flexibility.

## 🔄 Before: Reusable Workflows

### `.github/workflows/release-plz.yml`
```yaml
name: Release-plz
on:
  push:
    branches: [main]

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release-plz.yml@v1
    secrets:
      CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
      RELEASE_PLZ_TOKEN: ${{ secrets.RELEASE_PLZ_TOKEN }}
```

### `.github/workflows/ci.yml`
```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v1
    with:
      rust-toolchain: stable
      enable-coverage: false
      enable-python-wheel: false
```

## ✅ After: GitHub Actions

### `.github/workflows/release-plz.yml`
```yaml
name: Release-plz
on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: release-plz
          cargo-registry-token: ${{ secrets.CARGO_REGISTRY_TOKEN }}
          release-plz-token: ${{ secrets.RELEASE_PLZ_TOKEN }}
```

### `.github/workflows/ci.yml`
```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: ci
          rust-toolchain: stable
```

## 🎯 Benefits of Migration

### 1. **Simplified Configuration**
- **Before**: Complex secrets management and input passing
- **After**: Simple, direct configuration

### 2. **Better Debugging**
- **Before**: Nested workflow errors are hard to trace
- **After**: Clear, linear execution with better error messages

### 3. **Easier Customization**
```yaml
# ✅ Now you can easily add custom steps
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Custom pre-processing for py2pyd
      - name: Setup Python test environment
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install test dependencies
        run: pip install pytest requests six certifi
      
      # Standard Rust CI
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: ci
          rust-toolchain: stable
      
      # Custom integration tests for py2pyd
      - name: Run integration tests
        run: cargo test --test integration -- --ignored
      
      # Custom performance benchmarks
      - name: Run benchmarks
        run: cargo bench
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

### 4. **Flexible Release Process**
```yaml
# ✅ Customized release workflow for py2pyd
name: Release
on:
  push:
    tags: ["v*"]

jobs:
  # Test before release
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: ci

  # Build and release binaries
  release:
    needs: test
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: ubuntu-latest
            target: x86_64-unknown-linux-musl
          - os: macos-latest
            target: x86_64-apple-darwin
          - os: macos-latest
            target: aarch64-apple-darwin
          - os: windows-latest
            target: x86_64-pc-windows-msvc
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: release
          target: ${{ matrix.target }}
          binary-name: py2pyd

  # Automated publishing
  publish:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: release-plz
          release-plz-command: release  # Only release, don't create PRs on tags
          cargo-registry-token: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

## 📊 Comparison

| Aspect | Reusable Workflows | GitHub Actions |
|--------|-------------------|----------------|
| **Lines of Code** | 15 lines | 12 lines |
| **Flexibility** | Limited | High |
| **Debugging** | Difficult | Easy |
| **Customization** | Hard | Simple |
| **Error Messages** | Nested/Unclear | Direct/Clear |
| **Integration** | Fixed | Flexible |

## 🚀 Migration Steps

### Step 1: Update release-plz workflow
```bash
# Replace the content of .github/workflows/release-plz.yml
```

### Step 2: Update CI workflow
```bash
# Replace the content of .github/workflows/ci.yml
```

### Step 3: Test the migration
```bash
# Push a commit to test CI
git commit -m "test: migrate to GitHub Actions"
git push

# Create a test tag to verify release process
git tag v0.1.0-test
git push origin v0.1.0-test
```

### Step 4: Clean up (optional)
```bash
# Remove any unused workflow files
# Update documentation to reflect new setup
```

## 🎯 py2pyd Specific Benefits

### 1. **Better Python Integration Testing**
```yaml
- name: Test Python integration
  run: |
    # Test downloading and compiling real Python packages
    cargo test test_download_six_package -- --ignored
    cargo test test_download_and_compile_package -- --ignored
```

### 2. **Turbo-CDN Integration Testing**
```yaml
- name: Test turbo-cdn integration
  run: |
    cargo run --example turbo_cdn_test
    cargo run --example test_runner
```

### 3. **Cross-Platform Python Testing**
```yaml
- name: Test cross-platform compilation
  run: |
    # Test compilation for different Python versions
    cargo test --features python39
    cargo test --features python310
    cargo test --features python311
```

## 📝 Summary

The migration from reusable workflows to GitHub Actions provides:

- ✅ **Simpler configuration**
- ✅ **Better debugging experience**
- ✅ **Easier customization**
- ✅ **More flexible CI/CD pipelines**
- ✅ **Better integration with existing workflows**

This makes the py2pyd project more maintainable and easier to extend with custom functionality.
