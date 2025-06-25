# OpenSSL Compilation Issues - Troubleshooting Guide

This guide helps resolve common OpenSSL compilation errors when using the rust-actions-toolkit.

## 🚨 Common Error

```
error: failed to run custom build command for `openssl-sys v0.9.109`
warning: openssl-sys@0.9.109: Could not find directory of OpenSSL installation
```

## 🔧 Solutions

### Solution 1: Use rustls instead of OpenSSL (Recommended)

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

### Solution 3: Environment Variables

If you must use OpenSSL, set these environment variables:

```yaml
# In your workflow
env:
  OPENSSL_DIR: /usr
  OPENSSL_LIB_DIR: /usr/lib/x86_64-linux-gnu
  OPENSSL_INCLUDE_DIR: /usr/include/openssl
```

### Solution 4: Vendored OpenSSL

Force vendored OpenSSL compilation:

```toml
[dependencies]
openssl = { version = "0.10", features = ["vendored"] }
```

## 🎯 Best Practices

### 1. Prefer rustls over OpenSSL

```toml
# ✅ Good - uses rustls
reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }

# ❌ Avoid - uses OpenSSL by default
reqwest = "0.12"
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

For cross-compilation, rustls is much easier:

```toml
# Works everywhere without system dependencies
reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }

# Requires OpenSSL on target system
reqwest = { version = "0.12", features = ["native-tls"] }
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

## 💡 Need Help?

If you're still experiencing issues:

1. Check if your dependencies require OpenSSL
2. Consider using rustls alternatives
3. Open an issue with your `Cargo.toml` and error details
4. Reference this guide in your issue
