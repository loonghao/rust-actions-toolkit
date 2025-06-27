# üéØ Best Practices Guide

This guide helps you choose the best approach for using rust-actions-toolkit in your projects.

## üöÄ Quick Decision Guide

### **New Project? ‚Ü?Use GitHub Actions**
```yaml
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
```

### **Need Full Control? ‚Ü?Use Reusable Workflows**
```yaml
uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2
```

### **Existing Project? ‚Ü?Use GitHub Actions**
```yaml
# Easy to integrate into existing workflows
- name: Existing step
  run: make test
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
```

## üìä Comparison: GitHub Actions vs Reusable Workflows

| Feature | GitHub Actions | Reusable Workflows |
|---------|---------------|-------------------|
| **Ease of Use** | ‚≠ê‚≠ê‚≠ê‚≠ê‚≠?Simple | ‚≠ê‚≠ê‚≠?Moderate |
| **Flexibility** | ‚≠ê‚≠ê‚≠ê‚≠ê‚≠?High | ‚≠ê‚≠ê Limited |
| **Integration** | ‚≠ê‚≠ê‚≠ê‚≠ê‚≠?Easy | ‚≠ê‚≠ê‚≠?Moderate |
| **Debugging** | ‚≠ê‚≠ê‚≠ê‚≠ê Good | ‚≠ê‚≠ê Difficult |
| **Standardization** | ‚≠ê‚≠ê‚≠?Good | ‚≠ê‚≠ê‚≠ê‚≠ê‚≠?Excellent |
| **Performance** | ‚≠ê‚≠ê‚≠ê‚≠ê Good | ‚≠ê‚≠ê‚≠ê‚≠ê‚≠?Better |

## üéØ Use Cases and Recommendations

### 1. **Simple CI/CD (Recommended: GitHub Actions)**

```yaml
# ‚ú?Perfect for most projects
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
          rust-toolchain: stable
```

**Why GitHub Actions?**
- Simple and straightforward
- Easy to customize
- Great for learning and experimentation

### 2. **Complex Multi-Platform Releases (Recommended: GitHub Actions)**

```yaml
# ‚ú?Flexible matrix builds
name: Release
on:
  push:
    tags: ["v*"]
jobs:
  release:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: macos-latest
            target: x86_64-apple-darwin
          - os: windows-latest
            target: x86_64-pc-windows-msvc
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: release
          target: ${{ matrix.target }}
```

### 3. **Automated Publishing (Recommended: GitHub Actions)**

```yaml
# ‚ú?Simple release-plz integration
name: Release-plz
on:
  push:
    branches: [main]
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: release-plz
          cargo-registry-token: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

### 4. **Enterprise/Team Standardization (Recommended: Reusable Workflows)**

```yaml
# ‚ú?Enforced standards across all projects
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: company/rust-toolkit/.github/workflows/reusable-ci.yml@v2
    with:
      rust-toolchain: stable
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

**Why Reusable Workflows?**
- Enforces company standards
- Centralized updates
- Consistent across all projects

### 5. **Custom Integration (Recommended: GitHub Actions)**

```yaml
# ‚ú?Mix with existing logic
name: Custom CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Custom pre-processing
      - name: Setup custom environment
        run: ./scripts/setup.sh
      
      # Use our toolkit for Rust tasks
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: ci
          clippy-args: '--all-targets --all-features -- -D warnings -D clippy::all'
      
      # Custom post-processing
      - name: Upload custom artifacts
        uses: actions/upload-artifact@v4
        with:
          name: custom-reports
          path: target/reports/
```

## üõ† Configuration Best Practices

### **1. Version Pinning**

```yaml
# ‚ú?Recommended: Use major version
- uses: loonghao/rust-actions-toolkit@v2

# ‚ú?Also good: Pin to specific version for stability
- uses: loonghao/rust-actions-toolkit@v2.1.7

# ‚ù?Avoid: Using latest or main branch
- uses: loonghao/rust-actions-toolkit@main
```

### **2. Input Configuration**

```yaml
# ‚ú?Explicit configuration
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
    rust-toolchain: stable
    check-format: true
    check-clippy: true
    clippy-args: '--all-targets --all-features -- -D warnings'

# ‚ú?Minimal configuration (uses defaults)
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
```

### **3. Secret Management**

```yaml
# ‚ú?Required secrets only
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: release-plz
    cargo-registry-token: ${{ secrets.CARGO_REGISTRY_TOKEN }}
    # Optional: Enhanced token for cross-workflow triggers
    release-plz-token: ${{ secrets.RELEASE_PLZ_TOKEN }}

# ‚ú?Conditional secrets
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
  env:
    CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}  # Optional
```

## üîß Migration Strategies

### **From Manual Workflows ‚Ü?GitHub Actions**

```yaml
# Before: Manual steps
- name: Install Rust
  uses: dtolnay/rust-toolchain@stable
- name: Check formatting
  run: cargo fmt --check
- name: Run clippy
  run: cargo clippy -- -D warnings
- name: Run tests
  run: cargo test

# After: Single action
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
```

### **From Reusable Workflows ‚Ü?GitHub Actions**

```yaml
# Before: Reusable workflow
jobs:
  ci:
    uses: org/toolkit/.github/workflows/ci.yml@v2

# After: GitHub Action (more flexible)
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: ci
```

## üéØ Project Type Recommendations

### **Library Crate**
```yaml
# Simple CI with documentation checks
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
    check-docs: true
```

### **Binary Crate**
```yaml
# CI + Release workflow
# CI
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci

# Release (separate workflow)
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: release
    target: ${{ matrix.target }}
```

### **Python Extension**
```yaml
# Automatic Python wheel building
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: release
    enable-python-wheels: true
```

### **Workspace Project**
```yaml
# Full workspace testing
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
    clippy-args: '--workspace --all-targets --all-features -- -D warnings'
```

## üìö Advanced Patterns

### **Conditional Execution**
```yaml
- uses: loonghao/rust-actions-toolkit@v2
  if: matrix.rust == 'stable'
  with:
    command: ci
    check-format: true
```

### **Output Usage**
```yaml
- name: Run CI
  id: ci
  uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci

- name: Use outputs
  run: echo "Rust version: ${{ steps.ci.outputs.rust-version }}"
```

### **Error Handling**
```yaml
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
  continue-on-error: ${{ matrix.experimental }}
```

## üîç Troubleshooting

### **Common Issues and Solutions**

1. **OpenSSL compilation errors** ‚Ü?Automatically handled by our toolkit
2. **Permission errors** ‚Ü?Use proper GitHub token configuration
3. **Cross-compilation issues** ‚Ü?Use our built-in cross-compilation support

### **Debug Mode**
```yaml
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
  env:
    RUST_LOG: debug
    RUST_BACKTRACE: 1
```

## üéâ Summary

**For most users**: Start with **GitHub Actions** - they're simpler, more flexible, and easier to debug.

**For enterprises**: Consider **Reusable Workflows** for standardization across teams.

**For migration**: **GitHub Actions** provide the smoothest migration path from existing workflows.
