# Cross-Compilation with OpenSSL and Memory Allocator Support

This example shows how to set up cross-compilation for Rust projects that depend on OpenSSL or use memory allocators like mimalloc.

## 🚨 Common Problems

### OpenSSL Issues

When cross-compiling Rust projects with OpenSSL dependencies, you might encounter:

```
error: failed to run custom build command for `openssl-sys v0.9.109`
Could not find directory of OpenSSL installation
```

### Memory Allocator Issues

When cross-compiling projects with memory allocators, you might encounter:

```
error: failed to run custom build command for `libmimalloc-sys v0.1.43`
process didn't exit successfully: `build-script-build` (exit status: 1)
TARGET = Some(i686-pc-windows-gnu)
```

## ✅ Solution

### 1. Use our toolkit (Automatic)

The rust-actions-toolkit automatically handles OpenSSL cross-compilation:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v1
    # OpenSSL dependencies are automatically installed
```

### 2. Manual setup with Cross.toml

If you need custom cross-compilation setup:

For OpenSSL issues:
```bash
# Copy our Cross.toml template for OpenSSL
curl -o Cross.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/cross-compilation/Cross.toml
```

For memory allocator issues (mimalloc, etc.):
```bash
# Copy our enhanced Cross.toml for allocator support
curl -o Cross.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/cross-compilation/Cross-mimalloc.toml

# Build with cross
cargo install cross
cross build --target i686-pc-windows-gnu --release
```

### 3. Project structure

```
your-project/
├── Cross.toml              # Cross-compilation configuration
├── Cargo.toml             # Rust project configuration
├── .github/
│   └── workflows/
│       ├── ci.yml          # CI with cross-compilation
│       └── release.yml     # Release with cross-platform builds
└── src/
    └── main.rs
```

## 🔧 Configuration Examples

### Cargo.toml with rustls (Recommended)

```toml
[package]
name = "my-cross-compiled-app"
version = "0.1.0"
edition = "2021"

[dependencies]
# Use rustls instead of OpenSSL for easier cross-compilation
reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }
tokio = { version = "1.0", features = ["full"] }
anyhow = "1.0"
```

### Cargo.toml with OpenSSL (Advanced)

```toml
[package]
name = "my-openssl-app"
version = "0.1.0"
edition = "2021"

[dependencies]
# If you must use OpenSSL
reqwest = { version = "0.12", features = ["native-tls"] }
openssl = { version = "0.10", features = ["vendored"] }  # Fallback option
tokio = { version = "1.0", features = ["full"] }

[features]
default = ["rustls"]
rustls = ["reqwest/rustls-tls"]
openssl = ["reqwest/native-tls"]
vendored-openssl = ["openssl/vendored"]
```

### Cargo.toml with Cross-Platform Allocators

```toml
[package]
name = "my-cross-platform-app"
version = "0.1.0"
edition = "2021"

[dependencies]
# Use rustls for TLS
reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }
tokio = { version = "1.0", features = ["full"] }
anyhow = "1.0"

# Cross-platform allocator (optional)
[target.'cfg(not(target_env = "msvc"))'.dependencies]
tikv-jemallocator = { version = "0.5", optional = true }

[features]
default = []
jemalloc = ["tikv-jemallocator"]

# Avoid mimalloc for cross-compilation compatibility
# mimalloc = "0.1"  # ❌ Can cause issues with Windows cross-compilation
```

### Cargo.toml for Libraries (Flexible Allocator)

```toml
[package]
name = "my-library"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }

# Let users choose allocator
[dependencies]
tikv-jemallocator = { version = "0.5", optional = true }

[features]
default = []
jemalloc = ["tikv-jemallocator"]
# Don't include mimalloc as default due to cross-compilation issues
```

### CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v1
    with:
      rust-toolchain: stable
      # Additional targets for cross-compilation testing
      additional-targets: |
        [
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-latest"},
          {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-latest"}
        ]
```

### Release Workflow

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags: ["v*"]

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v1
    with:
      # Comprehensive cross-platform support
      target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-musl", "os": "ubuntu-22.04"},
          {"target": "x86_64-apple-darwin", "os": "macos-13"},
          {"target": "aarch64-apple-darwin", "os": "macos-13"},
          {"target": "x86_64-pc-windows-msvc", "os": "windows-2022"}
        ]
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 🎯 Target Platforms

Our toolkit supports these platforms out of the box:

| Platform | Target | Notes |
|----------|--------|-------|
| Linux x64 | `x86_64-unknown-linux-gnu` | Standard glibc |
| Linux x64 (musl) | `x86_64-unknown-linux-musl` | Static linking |
| Linux ARM64 | `aarch64-unknown-linux-gnu` | Standard glibc |
| Linux ARM64 (musl) | `aarch64-unknown-linux-musl` | Static linking |
| macOS x64 | `x86_64-apple-darwin` | Intel Macs |
| macOS ARM64 | `aarch64-apple-darwin` | Apple Silicon |
| Windows x64 | `x86_64-pc-windows-msvc` | MSVC toolchain |
| Windows ARM64 | `aarch64-pc-windows-msvc` | ARM64 Windows |

## 🔍 Debugging

### Check cross-compilation setup

```bash
# Install cross
cargo install cross

# Test compilation for musl target
cross build --target x86_64-unknown-linux-musl

# Check if OpenSSL is properly configured
cross build --target x86_64-unknown-linux-musl --verbose
```

### Environment variables

```bash
# For debugging OpenSSL issues
export OPENSSL_STATIC=1
export PKG_CONFIG_ALLOW_CROSS=1
export RUST_LOG=debug

cross build --target x86_64-unknown-linux-musl
```

## 📋 Migration Checklist

- [ ] Copy `Cross.toml` to project root
- [ ] Update `Cargo.toml` to use rustls (recommended)
- [ ] Set up CI workflow with our toolkit
- [ ] Test cross-compilation locally
- [ ] Configure release workflow for target platforms
- [ ] Test release process with a pre-release tag

## 🔗 References

- [Cross Documentation](https://github.com/cross-rs/cross)
- [OpenSSL Troubleshooting Guide](../../docs/OPENSSL_TROUBLESHOOTING.md)
- [Rust Cross-Compilation Guide](https://rust-lang.github.io/rustup/cross-compilation.html)
- [rustls vs OpenSSL Comparison](https://docs.rs/rustls/latest/rustls/)
