# Cross-Compilation Issues Analysis and Solutions

This document analyzes common cross-compilation issues encountered when using the rust-actions-toolkit and provides comprehensive solutions.

## 🔍 Issue Analysis

### The `libmimalloc-sys` Problem

**Error Pattern:**
```
error: failed to run custom build command for `libmimalloc-sys v0.1.43`
process didn't exit successfully: `build-script-build` (exit status: 1)
TARGET = Some(i686-pc-windows-gnu)
HOST = Some(x86_64-unknown-linux-gnu)
CC_i686_pc_windows_gnu = Some(i686-w64-mingw32-gcc-posix)
```

**Root Causes:**
1. **Memory allocator incompatibility** with cross-compilation environments
2. **Missing or incorrect C compiler configuration** for target platforms
3. **Build script assumptions** about host environment
4. **Dependency chain issues** where transitive dependencies use problematic allocators

### Affected Scenarios

- ✅ **Native compilation**: Works fine on the same platform
- ❌ **Cross-compilation to Windows**: Fails with `i686-pc-windows-gnu`, `x86_64-pc-windows-gnu`
- ❌ **CI/CD environments**: GitHub Actions, Docker containers
- ❌ **Projects using mimalloc**: Direct or transitive dependencies

## 🛠️ Comprehensive Solutions

### 1. Immediate Fix: Disable Problematic Allocators

```toml
# Cargo.toml - Disable mimalloc in dependencies
[dependencies]
# Example: qsv uses mimalloc by default
qsv = { 
    version = "0.22", 
    default-features = false, 
    features = ["apply", "cat", "stats"]  # Exclude mimalloc
}

# For other crates, check their documentation for allocator features
your-crate = { version = "1.0", default-features = false }
```

### 2. Alternative Allocator Strategy

```toml
# Cargo.toml - Use cross-compilation friendly allocators
[dependencies]
# Platform-specific allocator
[target.'cfg(not(target_env = "msvc"))'.dependencies]
tikv-jemallocator = { version = "0.5", optional = true }

[features]
default = []
jemalloc = ["tikv-jemallocator"]

# Global allocator setup in main.rs or lib.rs
#[cfg(feature = "jemalloc")]
use tikv_jemallocator::Jemalloc;

#[cfg(feature = "jemalloc")]
#[global_allocator]
static GLOBAL: Jemalloc = Jemalloc;
```

### 3. Environment Configuration

```yaml
# GitHub Actions workflow
env:
  # Better error messages
  CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG: true
  
  # Windows cross-compilation toolchain
  CC_i686_pc_windows_gnu: i686-w64-mingw32-gcc-posix
  CXX_i686_pc_windows_gnu: i686-w64-mingw32-g++-posix
  AR_i686_pc_windows_gnu: i686-w64-mingw32-ar
  
  CC_x86_64_pc_windows_gnu: x86_64-w64-mingw32-gcc-posix
  CXX_x86_64_pc_windows_gnu: x86_64-w64-mingw32-g++-posix
  AR_x86_64_pc_windows_gnu: x86_64-w64-mingw32-ar
```

### 4. Cross.toml Configuration

```toml
# Cross.toml - Enhanced configuration
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
    "apt-get update && apt-get install -y gcc-mingw-w64-i686 g++-mingw-w64-i686"
]

[target.i686-pc-windows-gnu.env]
CC_i686_pc_windows_gnu = "i686-w64-mingw32-gcc-posix"
CXX_i686_pc_windows_gnu = "i686-w64-mingw32-g++-posix"
AR_i686_pc_windows_gnu = "i686-w64-mingw32-ar"
CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG = "true"
```

## 🎯 Prevention Strategies

### 1. Dependency Auditing

```bash
# Check for problematic dependencies
cargo tree | grep -i mimalloc
cargo tree | grep -i allocator

# Analyze features
cargo tree -f "{p} {f}" | grep -E "(mimalloc|allocator)"
```

### 2. Feature Flag Management

```toml
# Cargo.toml - Explicit feature control
[dependencies]
# Always disable default features for crates that might use problematic allocators
external-crate = { version = "1.0", default-features = false, features = ["safe-features"] }

[features]
default = ["safe-defaults"]
safe-defaults = []
performance = ["jemalloc"]  # Optional performance features
jemalloc = ["tikv-jemallocator"]
```

### 3. CI/CD Integration

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        target: 
          - x86_64-unknown-linux-gnu
          - x86_64-pc-windows-gnu
          - i686-pc-windows-gnu
          - x86_64-apple-darwin
    
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Use our toolkit for automatic handling
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: ci
          target: ${{ matrix.target }}
```

## 📊 Impact Assessment

### Before Fix
- ❌ Cross-compilation failures
- ❌ CI/CD pipeline breaks
- ❌ Inconsistent builds across platforms
- ❌ Developer productivity loss

### After Fix
- ✅ Reliable cross-compilation
- ✅ Stable CI/CD pipelines
- ✅ Consistent builds
- ✅ Better developer experience

## 🔗 Related Issues

### Similar Problems
1. **OpenSSL cross-compilation**: Solved by rustls migration
2. **Native library dependencies**: Use pure Rust alternatives
3. **Platform-specific code**: Use conditional compilation

### Best Practices
1. **Prefer pure Rust crates** over those with native dependencies
2. **Use feature flags** to make allocators optional
3. **Test cross-compilation** in CI/CD pipelines
4. **Document platform requirements** clearly

## 📚 Resources

- [Memory Allocator Troubleshooting Guide](./MIMALLOC_TROUBLESHOOTING.md)
- [OpenSSL Troubleshooting Guide](./OPENSSL_TROUBLESHOOTING.md)
- [Cross-compilation Examples](../examples/cross-compilation/)
- [Rust Cross-compilation Book](https://rust-lang.github.io/rustup/cross-compilation.html)

## 🚀 Quick Start

### For New Projects

```bash
# Use our toolkit from the start
curl -o .github/workflows/ci.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/reusable-workflows/ci.yml

# Copy Cross.toml for allocator support
curl -o Cross.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/cross-compilation/Cross-mimalloc.toml
```

### For Existing Projects

1. **Audit dependencies**: `cargo tree | grep -i mimalloc`
2. **Update Cargo.toml**: Disable problematic features
3. **Add Cross.toml**: Use our enhanced configuration
4. **Test cross-compilation**: `cross build --target i686-pc-windows-gnu`

## 💡 Future Improvements

1. **Automated dependency scanning** for problematic allocators
2. **Enhanced Docker images** with better toolchain support
3. **Documentation updates** for emerging issues
4. **Community feedback integration** for new solutions

---

**Note**: This analysis is based on real-world issues encountered in production environments. The solutions have been tested across multiple projects and platforms.
