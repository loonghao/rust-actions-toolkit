# Memory Allocator Issues - Troubleshooting Guide

This guide helps resolve memory allocator compilation errors, particularly with `libmimalloc-sys` when using the rust-actions-toolkit.

## 🚨 Common Error

```
error: failed to run custom build command for `libmimalloc-sys v0.1.43`

Caused by:
  process didn't exit successfully: `build-script-build` (exit status: 1)
  --- stdout
  TARGET = Some(i686-pc-windows-gnu)
  HOST = Some(x86_64-unknown-linux-gnu)
  CC_i686_pc_windows_gnu = Some(i686-w64-mingw32-gcc-posix)
```

## 🔍 Root Cause

This error typically occurs when:

1. **Cross-compiling to Windows targets** (`i686-pc-windows-gnu`, `x86_64-pc-windows-gnu`)
2. **Dependencies use mimalloc** as their default allocator
3. **Missing or incompatible C compiler** for the target platform
4. **Build script incompatibility** with cross-compilation environment

## 🔧 Solutions

### Solution 1: Disable mimalloc (Recommended)

The easiest solution is to disable mimalloc and use the system allocator:

```toml
# Cargo.toml
[dependencies]
# If your dependency uses mimalloc by default, disable it
your-crate = { version = "1.0", default-features = false, features = ["other-features"] }

# Example: qsv uses mimalloc by default
qsv = { version = "0.22", default-features = false, features = ["apply", "cat", "stats"] }
```

### Solution 2: Use Alternative Allocators

Replace mimalloc with cross-compilation friendly allocators:

```toml
# Cargo.toml
[dependencies]
# Use jemalloc instead (better cross-compilation support)
tikv-jemallocator = { version = "0.5", optional = true }

[features]
default = []
jemalloc = ["tikv-jemallocator"]

# Platform-specific allocators
[target.'cfg(not(target_env = "msvc"))'.dependencies]
tikv-jemallocator = "0.5"
```

### Solution 3: Configure Build Environment

Set proper environment variables for cross-compilation:

```yaml
# In your GitHub Actions workflow
env:
  # Better error messages
  CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG: true
  
  # Windows cross-compilation
  CC_i686_pc_windows_gnu: i686-w64-mingw32-gcc-posix
  CXX_i686_pc_windows_gnu: i686-w64-mingw32-g++-posix
  AR_i686_pc_windows_gnu: i686-w64-mingw32-ar
  
  CC_x86_64_pc_windows_gnu: x86_64-w64-mingw32-gcc-posix
  CXX_x86_64_pc_windows_gnu: x86_64-w64-mingw32-g++-posix
  AR_x86_64_pc_windows_gnu: x86_64-w64-mingw32-ar
```

### Solution 4: Use Cross.toml Configuration

Create a `Cross.toml` file in your project root:

```toml
# Cross.toml
[build.env]
passthrough = [
    "CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG",
    "CC_i686_pc_windows_gnu",
    "CXX_i686_pc_windows_gnu",
    "AR_i686_pc_windows_gnu"
]

[target.i686-pc-windows-gnu]
image = "ghcr.io/cross-rs/i686-pc-windows-gnu:main"
pre-build = [
    "apt-get update && apt-get install -y gcc-mingw-w64-i686"
]

[target.x86_64-pc-windows-gnu]
image = "ghcr.io/cross-rs/x86_64-pc-windows-gnu:main"
pre-build = [
    "apt-get update && apt-get install -y gcc-mingw-w64-x86-64"
]
```

### Solution 5: Use our toolkit (Automatic)

Our rust-actions-toolkit automatically handles these issues:

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v1
    with:
      targets: |
        x86_64-unknown-linux-gnu
        x86_64-pc-windows-gnu
        x86_64-apple-darwin
    # Automatically configures cross-compilation environment
```

## 🎯 Best Practices

### 1. Allocator Selection Strategy

```toml
# Cargo.toml - Flexible allocator configuration
[features]
default = ["system-alloc"]
system-alloc = []
jemalloc = ["tikv-jemallocator"]
# Don't include mimalloc as default due to cross-compilation issues

[dependencies]
tikv-jemallocator = { version = "0.5", optional = true }

# Platform-specific defaults
[target.'cfg(all(unix, not(target_env = "musl")))'.dependencies]
tikv-jemallocator = { version = "0.5", optional = true }
```

### 2. Dependency Audit

Check which dependencies use mimalloc:

```bash
# Find dependencies using mimalloc
cargo tree | grep -i mimalloc

# Check features of problematic crates
cargo tree -f "{p} {f}" | grep mimalloc
```

### 3. Feature Flag Management

```toml
# Example: Configure qsv without mimalloc
[dependencies]
qsv = { 
    version = "0.22", 
    default-features = false, 
    features = [
        "apply", "cat", "count", "headers", "index", "sample", 
        "select", "slice", "sort", "stats", "table"
        # Explicitly exclude "mimalloc" feature
    ] 
}
```

## 🔍 Debugging

### Check Allocator Usage

```rust
// In your code, verify which allocator is being used
#[cfg(feature = "jemalloc")]
use tikv_jemallocator::Jemalloc;

#[cfg(feature = "jemalloc")]
#[global_allocator]
static GLOBAL: Jemalloc = Jemalloc;

fn main() {
    #[cfg(feature = "jemalloc")]
    println!("Using jemalloc");
    
    #[cfg(not(feature = "jemalloc"))]
    println!("Using system allocator");
}
```

### Verify Cross-Compilation Setup

```bash
# Check available targets
rustup target list --installed

# Test cross-compilation
cargo build --target i686-pc-windows-gnu --release

# Use cross for better compatibility
cross build --target i686-pc-windows-gnu --release
```

## 📋 Project Examples

### CLI Tool (Cross-Platform)

```toml
[package]
name = "my-cli-tool"
version = "0.1.0"
edition = "2021"

[dependencies]
clap = { version = "4.0", features = ["derive"] }
anyhow = "1.0"

# Optional allocator for performance
[target.'cfg(not(target_env = "msvc"))'.dependencies]
tikv-jemallocator = { version = "0.5", optional = true }

[features]
default = []
jemalloc = ["tikv-jemallocator"]
```

### Library Crate

```toml
[package]
name = "my-library"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }

# Let users choose allocator
[features]
default = []
jemalloc = ["tikv-jemallocator"]

[dependencies]
tikv-jemallocator = { version = "0.5", optional = true }
```

## 🚀 Migration Guide

### From mimalloc to jemalloc

1. **Update Cargo.toml**:
   ```toml
   # Before
   [dependencies]
   mimalloc = "0.1"
   
   # After
   [target.'cfg(not(target_env = "msvc"))'.dependencies]
   tikv-jemallocator = "0.5"
   ```

2. **Update global allocator**:
   ```rust
   // Before
   use mimalloc::MiMalloc;
   #[global_allocator]
   static GLOBAL: MiMalloc = MiMalloc;
   
   // After
   #[cfg(not(target_env = "msvc"))]
   use tikv_jemallocator::Jemalloc;
   
   #[cfg(not(target_env = "msvc"))]
   #[global_allocator]
   static GLOBAL: Jemalloc = Jemalloc;
   ```

3. **Test compilation**:
   ```bash
   cargo clean
   cargo build --target i686-pc-windows-gnu
   ```

## 🔗 References

- [tikv-jemallocator Documentation](https://docs.rs/tikv-jemallocator/)
- [Cross-compilation Guide](https://rust-lang.github.io/rustup/cross-compilation.html)
- [Cross Tool Documentation](https://github.com/cross-rs/cross)
- [Rust Allocator Documentation](https://doc.rust-lang.org/std/alloc/trait.GlobalAlloc.html)

## 💡 Need Help?

If you're still experiencing issues:

1. Check if your dependencies require mimalloc
2. Consider using jemalloc or system allocator
3. Review our [Cross-compilation Guide](../examples/cross-compilation/README.md)
4. Open an issue with your `Cargo.toml` and error details
5. Reference this guide in your issue
