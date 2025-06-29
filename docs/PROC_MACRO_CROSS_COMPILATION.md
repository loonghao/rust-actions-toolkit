# Proc-Macro Cross-Compilation Guide

This document explains the proc-macro cross-compilation issues in rust-actions-toolkit v2.5.0 and how they were resolved.

## 🐛 The Problem

### Issue Description
In v2.5.0, cross-compilation failed for projects using proc-macros because:

1. **Proc-macros were built for target platform** instead of host platform
2. **Cross-compilation confusion** between host and target architectures
3. **Missing host toolchain** configuration in cross-compilation environment

### Root Cause
Proc-macros are **compiler plugins** that run during compilation on the **host machine**. They must be compiled for the host architecture (e.g., `x86_64-unknown-linux-gnu` in GitHub Actions), not the target architecture (e.g., `aarch64-unknown-linux-gnu`).

### Error Examples
```
error: proc-macro `my_macro` cannot be loaded
  --> src/lib.rs:1:1
   |
1  | use my_macro::derive_something;
   | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: cannot load proc-macro compiled for different target architecture
```

```
error: cannot produce proc-macro for `async-trait v0.1.88` as the target `x86_64-unknown-linux-gnu` does not support these crate types
```

## 🔧 The Solution

### 🚨 Critical Fix (v2.5.5): Global RUSTFLAGS Issue

**Problem**: The most common cause of proc-macro errors is global `RUSTFLAGS` with `crt-static`.

**Root Cause**:
```bash
# This causes proc-macro compilation to fail:
RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-gnu
# error: cannot produce proc-macro for `async-trait v0.1.88` as the target `x86_64-unknown-linux-gnu` does not support these crate types
```

**Solution**: Use target-specific RUSTFLAGS instead of global ones:

```yaml
# ❌ Before (causes proc-macro errors):
- name: Configure Windows static linking
  run: echo "RUSTFLAGS=${RUSTFLAGS} -C target-feature=+crt-static" >> "${GITHUB_ENV}"
  if: endsWith(matrix.target, 'windows-msvc')

# ✅ After (proc-macro compatible):
- name: Configure Windows static linking
  run: |
    target_env=$(echo ${{ matrix.target }} | tr '[:lower:]' '[:upper:]' | tr '-' '_')
    echo "CARGO_TARGET_${target_env}_RUSTFLAGS=-C target-feature=+crt-static" >> $GITHUB_ENV
  if: endsWith(matrix.target, 'windows-msvc')
```

**Why This Works**:
- ✅ **Proc-macros**: Compile for host platform without `crt-static`
- ✅ **Final binary**: Gets `crt-static` through target-specific flags
- ✅ **No interference**: Host and target compilation are separate

**Reference**: [Rust Issue #78210](https://github.com/rust-lang/rust/issues/78210)

### 1. Simplified Cross.toml Configuration

**New file**: `examples/cross-compilation/Cross-simple-proc-macro.toml`

Key improvements:
```toml
# DO NOT set global build targets that interfere with proc-macro compilation
[build.env]
passthrough = [
    # Minimal configuration to avoid proc-macro conflicts
    "CARGO_TARGET_DIR",
    # ... other essential environment variables
]

# Simple target configurations without proc-macro interference
[target.aarch64-unknown-linux-gnu]
image = "ghcr.io/cross-rs/aarch64-unknown-linux-gnu:main"
pre-build = [
    # ... target-specific setup only
    "apt-get update && apt-get install -y libssl-dev:arm64 pkg-config"
]

# No special proc-macro environment variables needed
# Let Cargo handle proc-macro compilation automatically
```

### 2. Workflow Configuration Updates

**Host Toolchain Installation**:
```yaml
- name: Install host toolchain for proc-macros
  uses: dtolnay/rust-toolchain@master
  with:
    toolchain: stable
    targets: x86_64-unknown-linux-gnu
```

**Simplified Environment Configuration**:
```yaml
- name: Configure cross-compilation environment
  run: |
    HOST_TARGET="x86_64-unknown-linux-gnu"

    if [ "${{ matrix.target }}" != "$HOST_TARGET" ]; then
      echo "🔄 Cross-compiling from $HOST_TARGET to ${{ matrix.target }}"
      echo "📦 Proc-macros will automatically use host platform"

      # Minimal configuration - let Cargo handle proc-macros automatically
      echo "CARGO_TARGET_DIR=target" >> $GITHUB_ENV
      # DO NOT set CARGO_BUILD_TARGET as it interferes with proc-macros
    fi
```

## 📊 Technical Details

### Host vs Target Architecture

| Component | Architecture | Reason |
|-----------|-------------|---------|
| **Proc-macros** | Host (x86_64-linux) | Run during compilation on build machine |
| **Final binary** | Target (aarch64-linux) | Run on target platform |
| **Dependencies** | Target (aarch64-linux) | Linked into final binary |

### Environment Variables

| Variable | Purpose | Example Value |
|----------|---------|---------------|
| `CARGO_BUILD_TARGET` | Specify target for main build | `aarch64-unknown-linux-gnu` |
| `CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER` | Host target runner (empty for local) | `""` |
| `CARGO_TARGET_DIR` | Build directory | `target` |

### Cross.toml Enhancements

1. **Host toolchain availability** in all target configurations
2. **Proper environment variable passthrough** for proc-macro handling
3. **Default target specification** for proc-macro builds
4. **Target-specific runner configuration** to avoid execution issues

## 🎯 Affected Scenarios

### Before Fix (v2.5.0)
```
❌ Cross-compiling project with proc-macros
❌ serde_derive, tokio-macros, etc. fail to compile
❌ "cannot load proc-macro compiled for different target" errors
❌ Build failures on non-native targets
```

### After Fix (v2.5.1+)
```
✅ Proc-macros built for host platform (x86_64-linux)
✅ Final binary built for target platform (aarch64-linux)
✅ Proper separation of host and target compilation
✅ All cross-compilation targets work correctly
```

## 🔍 Common Proc-Macro Crates

These popular crates include proc-macros and benefit from this fix:

- **serde** (`serde_derive`)
- **tokio** (`tokio-macros`)
- **clap** (`clap_derive`)
- **thiserror** (`thiserror-impl`)
- **async-trait** (`async-trait`)
- **syn** (proc-macro parsing)
- **quote** (proc-macro generation)

## 🧪 Testing

### Verification Steps

1. **Create test project with proc-macros**:
```rust
// Cargo.toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }

// src/lib.rs
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
pub struct TestStruct {
    pub field: String,
}
```

2. **Test cross-compilation**:
```bash
# Should work without proc-macro errors
cross build --target aarch64-unknown-linux-gnu
```

3. **Verify in CI**:
```yaml
jobs:
  test:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.1
    with:
      test-release-builds: true
      release-target-platforms: |
        [
          {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"}
        ]
```

## 🔗 References

### Rust Documentation
- [Procedural Macros](https://doc.rust-lang.org/reference/procedural-macros.html)
- [Cross-compilation](https://rust-lang.github.io/rustup/cross-compilation.html)
- [Cargo Build Scripts](https://doc.rust-lang.org/cargo/reference/build-scripts.html)

### Cross Tool Documentation
- [Cross Configuration](https://github.com/cross-rs/cross/wiki/Configuration)
- [Cross Environment Variables](https://github.com/cross-rs/cross/wiki/Configuration#environment-variables)

### Related Issues
- [Rust Issue #64266](https://github.com/rust-lang/rust/issues/64266) - Proc-macro cross-compilation
- [Cross Issue #260](https://github.com/cross-rs/cross/issues/260) - Proc-macro support

## 💡 Best Practices

### For Project Maintainers

1. **Use the fixed Cross.toml** from rust-actions-toolkit v2.5.1+
2. **Test cross-compilation locally** with `cross` tool
3. **Verify proc-macro dependencies** work across all targets
4. **Update CI configurations** to use latest toolkit version

### For Library Authors

1. **Document proc-macro usage** in cross-compilation scenarios
2. **Provide Cross.toml examples** for users
3. **Test on multiple architectures** in CI
4. **Consider proc-macro alternatives** for performance-critical code

## 🚀 Migration

### From v2.5.0 to v2.5.1+

**No action required** - the fix is automatic:

```yaml
# Simply update the version
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2.5.1
    # All proc-macro issues are automatically resolved
```

### Manual Cross.toml Update

If you have a custom Cross.toml, update it with proc-macro support:

```toml
# Add to your existing Cross.toml
[build]
default-target = "x86_64-unknown-linux-gnu"

[target.your-target]
pre-build = [
    # ... your existing pre-build steps
    "rustup target add x86_64-unknown-linux-gnu"
]

[target.your-target.env]
# ... your existing environment variables
CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER = ""
```

This fix ensures robust cross-compilation for all Rust projects using proc-macros.
