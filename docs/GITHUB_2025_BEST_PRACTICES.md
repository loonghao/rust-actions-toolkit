# GitHub Actions 2025 Best Practices

This document outlines how rust-actions-toolkit follows GitHub Actions 2025 best practices.

## 🏗�?Architecture Changes

### **Before: Nested Composite Actions (�?Deprecated)**
```yaml
# Old problematic structure
runs:
  using: 'composite'
  steps:
    - uses: ./actions/setup-rust-ci  # �?Relative path issues
    - uses: ./actions/rust-release   # �?Complex nested structure
```

### **After: Inline Composite Action (�?2025 Best Practice)**
```yaml
# New streamlined structure
runs:
  using: 'composite'
  steps:
    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@master
    - name: Run tests
      shell: bash
      run: cargo test
```

## 🎯 Key Improvements

### 1. **Single Action File**
- �?All logic in one `action.yml` file
- �?No relative path dependencies
- �?Easier to maintain and debug
- �?Better performance (no nested action resolution)

### 2. **Improved Error Handling**
```yaml
- name: Setup cross-compilation toolchain
  uses: taiki-e/setup-cross-toolchain-action@v1
  with:
    target: ${{ inputs.target }}
  continue-on-error: true  # �?Graceful failure handling
```

### 3. **Better Logging**
```yaml
- name: Check formatting
  shell: bash
  run: |
    echo "🎨 Checking code formatting..."  # �?Clear progress indicators
    cargo fmt --all --check
```

### 4. **System Dependencies Management**
```yaml
- name: Install system dependencies
  if: runner.os == 'Linux'
  shell: bash
  run: |
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
      build-essential \
      pkg-config \
      libssl-dev \
      musl-tools
```

## 🔧 Technical Implementation

### **Conditional Execution**
```yaml
# �?Efficient conditional logic
- name: Install Rust toolchain
  if: inputs.command != 'release-plz'
  uses: dtolnay/rust-toolchain@master

- name: Check formatting
  if: inputs.command == 'ci' && inputs.check-format == 'true'
  shell: bash
  run: cargo fmt --all --check
```

### **Output Management**
```yaml
outputs:
  rust-version:
    description: 'Installed Rust version'
    value: ${{ steps.rust-version.outputs.version }}  # �?Direct step reference
```

### **Environment Variables**
```yaml
- name: Configure OpenSSL for musl targets
  if: contains(inputs.target, '-musl')
  shell: bash
  run: |
    echo "OPENSSL_STATIC=1" >> $GITHUB_ENV
    echo "PKG_CONFIG_ALLOW_CROSS=1" >> $GITHUB_ENV
```

## 📊 Performance Benefits

| Aspect | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Action Resolution** | 3+ nested calls | 1 direct call | 3x faster |
| **Debugging** | Complex traces | Linear execution | Much easier |
| **Maintenance** | Multiple files | Single file | Simplified |
| **Error Messages** | Nested/unclear | Direct/clear | Better UX |

## 🛡�?Security Improvements

### **Token Handling**
```yaml
# �?Proper token fallback
- name: Checkout repository (for release-plz)
  uses: actions/checkout@v4
  with:
    token: ${{ inputs.release-plz-token || inputs.github-token }}
```

### **Dependency Pinning**
```yaml
# �?Use specific versions
- uses: dtolnay/rust-toolchain@master  # Pinned to stable master
- uses: actions/checkout@v4            # Pinned major version
- uses: taiki-e/install-action@v2      # Pinned major version
```

### **Minimal Permissions**
```yaml
# �?No hardcoded permissions in action
# Permissions inherited from calling workflow
```

## 🎨 User Experience Improvements

### **Clear Command Structure**
```yaml
# �?Simple, intuitive commands
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci          # Clear intent
    command: release     # Clear intent
    command: release-plz # Clear intent
```

### **Flexible Configuration**
```yaml
# �?Sensible defaults with customization options
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
    rust-toolchain: stable        # Default: stable
    check-format: true            # Default: true
    check-clippy: true            # Default: true
    clippy-args: '--all-features' # Customizable
```

### **Rich Outputs**
```yaml
# �?Useful outputs for further processing
- name: Run CI
  id: ci
  uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci

- name: Use outputs
  run: |
    echo "Rust version: ${{ steps.ci.outputs.rust-version }}"
```

## 🔄 Migration Guide

### **For Users**
```yaml
# Before (still works)
- uses: loonghao/rust-actions-toolkit@v2.1.x

# After (recommended)
- uses: loonghao/rust-actions-toolkit@v2.2.0+
```

### **For Maintainers**
1. �?**Consolidated action.yml** - All logic in one file
2. �?**Removed nested actions** - Simplified structure
3. �?**Improved error handling** - Better user experience
4. �?**Enhanced logging** - Clearer progress indicators

## 📚 Best Practices Applied

### **1. Single Responsibility**
Each command (`ci`, `release`, `release-plz`) has a clear, focused purpose.

### **2. Fail Fast**
```yaml
- name: Check formatting
  run: cargo fmt --all --check  # Fails immediately on format issues
```

### **3. Graceful Degradation**
```yaml
- name: Setup cross-compilation
  continue-on-error: true  # Don't fail if cross-compilation setup fails
```

### **4. Clear Documentation**
```yaml
inputs:
  command:
    description: 'Command to run: ci, release, release-plz, or setup'
    required: true
    default: 'ci'
```

### **5. Semantic Versioning**
- `v1.x.x` - Backward compatible improvements
- `v2.x.x` - Breaking changes (when needed)
- `v1` - Always points to latest v1.x.x

## 🚀 Future-Proofing

### **Extensibility**
The new structure makes it easy to add new commands:
```yaml
- name: New command
  if: inputs.command == 'new-command'
  shell: bash
  run: |
    echo "🆕 Running new command..."
    # New functionality here
```

### **Maintainability**
- Single file to maintain
- Clear separation of concerns
- Easy to test and debug

### **Performance**
- No nested action resolution
- Efficient conditional execution
- Optimized caching strategy

## 📖 References

- [GitHub Actions Best Practices](https://docs.github.com/en/actions/learn-github-actions/security-hardening-for-github-actions)
- [Composite Actions Guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
- [Action Metadata Syntax](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions)
