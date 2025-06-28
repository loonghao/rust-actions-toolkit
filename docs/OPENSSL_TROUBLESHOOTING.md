# Compilation Issues - Troubleshooting Guide

This guide helps resolve common compilation errors when using the rust-actions-toolkit, including OpenSSL and memory allocator issues.

## 🚨 Common Errors

### OpenSSL Build Errors

```
error: failed to run custom build command for `openssl-sys v0.9.109`
warning: openssl-sys@0.9.109: Could not find directory of OpenSSL installation
```

### Memory Allocator Build Errors

```
error: failed to run custom build command for `libmimalloc-sys v0.1.43`
process didn't exit successfully: `build-script-build` (exit status: 1)
TARGET = Some(i686-pc-windows-gnu)
HOST = Some(x86_64-unknown-linux-gnu)
```

This commonly occurs when:
- Cross-compiling to Windows targets (`i686-pc-windows-gnu`, `x86_64-pc-windows-gnu`)
- Using crates that depend on `mimalloc` or other native allocators
- Missing or incompatible C compiler toolchain

## 🔧 Solutions

### Solution 1: Disable problematic allocators (For mimalloc issues)

If you're experiencing `libmimalloc-sys` build failures, disable the allocator:

```toml
# Cargo.toml
[dependencies]
# If a dependency uses mimalloc, disable it
your-crate = { version = "1.0", default-features = false }

# Or explicitly exclude mimalloc features
some-crate = { version = "1.0", features = ["other-features"], default-features = false }
```

For crates that use mimalloc by default, check their documentation for feature flags to disable it:

```toml
# Example: Some crates provide allocator selection
qsv = { version = "0.22", default-features = false, features = ["apply", "cat"] }  # Excludes mimalloc

# Or use alternative allocators
[dependencies]
jemallocator = "0.5"  # Alternative allocator that works better with cross-compilation

[target.'cfg(not(target_env = "msvc"))'.dependencies]
tikv-jemallocator = "0.5"  # Only on non-MSVC targets
```

### Solution 2: Use rustls instead of OpenSSL (Recommended)

Replace OpenSSL dependencies with rustls in your `Cargo.toml`:

```toml
[dependencies]
# Instead of using default features that include native-tls
reqwest = { 
    version = "0.12", 
    features = [
        "rustls-tls",  # Use rustls instead of OpenSSL
        "json", 
        "stream"
    ], 
    default-features = false  # Important: disable default features
}

# For other crates, prefer rustls variants
tokio-native-tls = { version = "0.3", optional = true }
tokio-rustls = "0.26"  # Use this instead
```

### Solution 2: System Dependencies (Automatic in our toolkit)

Our toolkit automatically installs required system dependencies:

```bash
# Ubuntu/Debian
sudo apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    libssl-dev \
    musl-tools

# Alpine Linux
apk add --no-cache \
    build-base \
    pkgconfig \
    openssl-dev \
    musl-dev

# CentOS/RHEL/Fedora
yum install -y \
    gcc \
    pkg-config \
    openssl-devel
```

### Solution 3: Cross.toml Configuration (For cross-compilation)

Create a `Cross.toml` file in your project root:

```toml
# Cross.toml
[build.env]
passthrough = [
    "OPENSSL_STATIC",
    "OPENSSL_LIB_DIR",
    "OPENSSL_INCLUDE_DIR",
    "PKG_CONFIG_ALLOW_CROSS"
]

[target.x86_64-unknown-linux-musl]
image = "ghcr.io/cross-rs/x86_64-unknown-linux-musl:main"
pre-build = [
    "apt-get update && apt-get install -y libssl-dev pkg-config"
]
```

Copy the complete example:
```bash
curl -o Cross.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/cross-compilation/Cross.toml
```

### Solution 4: Environment Variables

If you must use OpenSSL or need to configure allocators, set these environment variables:

```yaml
# In your workflow
env:
  # OpenSSL configuration
  OPENSSL_STATIC: 1  # For musl targets
  OPENSSL_LIB_DIR: /usr/lib/x86_64-linux-gnu
  OPENSSL_INCLUDE_DIR: /usr/include/openssl
  PKG_CONFIG_ALLOW_CROSS: 1

  # Memory allocator configuration
  CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG: true  # Better error messages

  # For Windows cross-compilation
  CC_i686_pc_windows_gnu: i686-w64-mingw32-gcc-posix
  CXX_i686_pc_windows_gnu: i686-w64-mingw32-g++-posix
  AR_i686_pc_windows_gnu: i686-w64-mingw32-ar

  # Disable problematic features
  CARGO_CFG_TARGET_FEATURE: ""  # Reset target features if needed
```

### Solution 5: Vendored OpenSSL

Force vendored OpenSSL compilation:

```toml
[dependencies]
openssl = { version = "0.10", features = ["vendored"] }
```

### Solution 6: Use our toolkit (Automatic)

Our rust-actions-toolkit automatically handles OpenSSL issues:

```yaml
# Automatically installs dependencies and sets environment variables
- uses: loonghao/rust-actions-toolkit@v1
  with:
    command: ci
```

## 🎯 Best Practices

### 1. Prefer rustls over OpenSSL

```toml
# ✅ Good - uses rustls
reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }

# ❌ Avoid - uses OpenSSL by default
reqwest = "0.12"
```

### 2. Choose Cross-Platform Compatible Allocators

```toml
# ✅ Good - works across all platforms
[dependencies]
# Use default system allocator or jemallocator
tikv-jemallocator = { version = "0.5", optional = true }

[features]
default = []
jemalloc = ["tikv-jemallocator"]

# ❌ Problematic - mimalloc has cross-compilation issues
mimalloc = "0.1"  # Can fail on Windows cross-compilation
```

### 2. Feature Flags for Flexibility

```toml
[features]
default = ["rustls-tls"]
rustls-tls = ["reqwest/rustls-tls"]
native-tls = ["reqwest/native-tls"]

[dependencies]
reqwest = { version = "0.12", default-features = false }
```

### 3. Cross-compilation Considerations

For cross-compilation, prefer pure Rust implementations:

```toml
# ✅ Works everywhere without system dependencies
reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }

# ✅ Cross-platform allocator
[target.'cfg(not(target_env = "msvc"))'.dependencies]
tikv-jemallocator = "0.5"

# ❌ Requires OpenSSL on target system
reqwest = { version = "0.12", features = ["native-tls"] }

# ❌ Problematic for Windows cross-compilation
mimalloc = "0.1"
```

### 4. Target-Specific Dependencies

```toml
# Use different allocators per platform
[target.'cfg(unix)'.dependencies]
tikv-jemallocator = "0.5"

[target.'cfg(windows)'.dependencies]
# Use system allocator on Windows to avoid cross-compilation issues

[target.'cfg(target_env = "musl")'.dependencies]
# Musl targets work well with most allocators
tikv-jemallocator = "0.5"
```

## 🔍 Debugging

### Check Dependencies

```bash
# See what's pulling in OpenSSL
cargo tree | grep openssl

# Check features
cargo tree -f "{p} {f}"
```

### Verify TLS Backend

```rust
// In your code, verify which TLS backend is being used
#[cfg(feature = "rustls-tls")]
println!("Using rustls");

#[cfg(feature = "native-tls")]
println!("Using native-tls (OpenSSL)");
```

## 📋 Project Examples

### Web Client Project

```toml
[dependencies]
reqwest = { version = "0.12", features = ["json", "rustls-tls"], default-features = false }
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
```

### CLI Tool with HTTPS

```toml
[dependencies]
clap = { version = "4.0", features = ["derive"] }
reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }
anyhow = "1.0"
```

### Library Crate

```toml
[dependencies]
# Provide both options, let users choose
reqwest = { version = "0.12", default-features = false, optional = true }

[features]
default = ["rustls"]
rustls = ["reqwest?/rustls-tls"]
native-tls = ["reqwest?/native-tls"]
http-client = ["reqwest"]
```

## 🚀 Migration Guide

### From OpenSSL to rustls

1. **Update Cargo.toml**:
   ```toml
   # Before
   reqwest = "0.12"
   
   # After
   reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }
   ```

2. **Update feature flags**:
   ```toml
   # Before
   [features]
   default = ["native-tls"]
   
   # After
   [features]
   default = ["rustls-tls"]
   ```

3. **Test compilation**:
   ```bash
   cargo clean
   cargo build
   ```

## 🔗 References

- [rustls Documentation](https://docs.rs/rustls/)
- [reqwest TLS Documentation](https://docs.rs/reqwest/latest/reqwest/#tls)
- [Cross-compilation Guide](https://rust-lang.github.io/rustup/cross-compilation.html)
- [OpenSSL-sys Documentation](https://docs.rs/openssl-sys/)

## 🔒 Security Considerations

When dealing with TLS libraries, security is paramount:

### Security Auditing

```bash
# Regular security audits
cargo audit

# Check for OpenSSL-specific vulnerabilities
cargo audit --package openssl
```

### Keep Dependencies Updated

```toml
# Use recent versions
reqwest = "0.12"  # Latest version
rustls = "0.23"   # Latest rustls
```

## 💡 Need Help?

If you're still experiencing issues:

1. Check if your dependencies require OpenSSL
2. Consider using rustls alternatives
3. Review our [Security Audit Guide](../examples/security-audit/README.md)
4. Open an issue with your `Cargo.toml` and error details
5. Reference this guide in your issue
