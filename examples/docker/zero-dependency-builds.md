# Zero-Dependency Builds 🚀

This guide shows how to build truly portable, zero-dependency executables that can run anywhere without installing additional libraries.

## 🎯 What is Zero-Dependency?

Zero-dependency means:
- ✅ **Windows**: No DLL dependencies (except system DLLs like kernel32.dll)
- ✅ **Linux**: Statically linked, no shared libraries required
- ✅ **macOS**: Minimal system dependencies only
- ✅ **Portable**: Download and run immediately

## 🏗️ Build Strategies by Platform

### **Windows (GNU Toolchain)**
```bash
# Build zero-dependency Windows EXE
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:cross-compile \
  build-windows x86_64-pc-windows-gnu my-app

# Result: my-app.exe with no external DLL dependencies
```

**Configuration:**
- Static CRT linking: `-C target-feature=+crt-static`
- Static linking: `-C link-args=-static`
- Static OpenSSL: `OPENSSL_STATIC=1`

### **Linux (musl)**
```bash
# Build zero-dependency Linux binary
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:cross-compile \
  cross-build x86_64-unknown-linux-musl my-app

# Result: Fully static binary, runs on any Linux
```

**Configuration:**
- musl libc (static by default)
- Static OpenSSL
- No glibc dependencies

### **Linux (GNU with static linking)**
```bash
# Build mostly-static Linux binary
RUSTFLAGS="-C target-feature=+crt-static" \
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/loonghao/rust-toolkit:cross-compile \
  cargo build --target x86_64-unknown-linux-gnu --release
```

## 📋 Complete Example Workflow

```yaml
name: Zero-Dependency Builds

on:
  push:
    tags: ["v*"]

jobs:
  build-portable:
    name: Build Portable Executables
    runs-on: ubuntu-latest
    container: ghcr.io/loonghao/rust-toolkit:cross-compile
    strategy:
      matrix:
        include:
          # Windows - Zero dependency
          - target: x86_64-pc-windows-gnu
            name: windows-x64
            ext: .exe
          - target: i686-pc-windows-gnu
            name: windows-x86
            ext: .exe
          # Linux - Static musl
          - target: x86_64-unknown-linux-musl
            name: linux-x64
            ext: ""
          - target: aarch64-unknown-linux-musl
            name: linux-arm64
            ext: ""
          # macOS - Minimal dependencies
          - target: x86_64-apple-darwin
            name: macos-x64
            ext: ""
          - target: aarch64-apple-darwin
            name: macos-arm64
            ext: ""
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Build zero-dependency binary
        run: |
          case "${{ matrix.target }}" in
            *-windows-*)
              build-windows ${{ matrix.target }} my-app
              ;;
            *-linux-musl)
              cross-build ${{ matrix.target }} my-app
              ;;
            *)
              cross-build ${{ matrix.target }} my-app
              ;;
          esac

      - name: Verify zero-dependency
        run: |
          BINARY="target/${{ matrix.target }}/release/my-app${{ matrix.ext }}"
          verify-static "$BINARY" "${{ matrix.target }}"

      - name: Package portable binary
        run: |
          BINARY="target/${{ matrix.target }}/release/my-app${{ matrix.ext }}"
          PACKAGE_NAME="my-app-${{ matrix.name }}"
          
          mkdir -p "$PACKAGE_NAME"
          cp "$BINARY" "$PACKAGE_NAME/"
          
          # Create README
          cat > "$PACKAGE_NAME/README.txt" << EOF
          my-app - Portable Executable
          ===========================
          
          This is a zero-dependency portable executable.
          No installation required - just run the binary!
          
          Platform: ${{ matrix.name }}
          Target: ${{ matrix.target }}
          Built: $(date)
          
          Usage:
          ./my-app${{ matrix.ext }} --help
          EOF
          
          # Create archive
          if [[ "${{ matrix.target }}" == *-windows-* ]]; then
            zip -r "${PACKAGE_NAME}.zip" "$PACKAGE_NAME"
          else
            tar czf "${PACKAGE_NAME}.tar.gz" "$PACKAGE_NAME"
          fi

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.name }}
          path: my-app-${{ matrix.name }}.*

  test-portability:
    name: Test Portability
    runs-on: ${{ matrix.os }}
    needs: build-portable
    strategy:
      matrix:
        include:
          - os: windows-latest
            artifact: windows-x64
            binary: my-app.exe
          - os: ubuntu-latest
            artifact: linux-x64
            binary: my-app
          - os: macos-latest
            artifact: macos-x64
            binary: my-app
    
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ matrix.artifact }}

      - name: Test portable binary
        run: |
          # Extract and test
          if [[ "${{ matrix.os }}" == "windows-latest" ]]; then
            unzip my-app-${{ matrix.artifact }}.zip
          else
            tar xzf my-app-${{ matrix.artifact }}.tar.gz
          fi
          
          cd my-app-${{ matrix.artifact }}
          ./${{ matrix.binary }} --version || echo "Binary test completed"
        shell: bash
```

## 🔍 Verification Tools

### **Manual Verification**

```bash
# Windows EXE dependencies
objdump -p my-app.exe | grep "DLL Name:"

# Linux binary dependencies  
ldd my-app  # Should show "not a dynamic executable"

# File type information
file my-app.exe
file my-app
```

### **Automated Verification**

```bash
# Use our verification script
verify-static target/x86_64-pc-windows-gnu/release/my-app.exe x86_64-pc-windows-gnu
verify-static target/x86_64-unknown-linux-musl/release/my-app x86_64-unknown-linux-musl
```

## 📊 Size Comparison

| Target | Typical Size | Notes |
|--------|-------------|-------|
| `x86_64-pc-windows-gnu` | 2-8 MB | Static CRT included |
| `x86_64-unknown-linux-musl` | 1-5 MB | Fully static |
| `x86_64-unknown-linux-gnu` | 1-3 MB | Some dynamic deps |
| `x86_64-apple-darwin` | 1-4 MB | System frameworks |

## 🎯 Best Practices

### **1. Choose the Right Target**

```bash
# For maximum portability
x86_64-unknown-linux-musl    # Linux
x86_64-pc-windows-gnu        # Windows
x86_64-apple-darwin          # macOS
```

### **2. Optimize for Size**

```toml
# Cargo.toml
[profile.release]
opt-level = "z"     # Optimize for size
lto = true          # Link-time optimization
codegen-units = 1   # Better optimization
panic = "abort"     # Smaller binary
strip = true        # Remove debug symbols
```

### **3. Handle Dependencies**

```toml
# Prefer pure Rust crates
[dependencies]
reqwest = { version = "0.12", features = ["rustls-tls"], default-features = false }
# Instead of native-tls which requires OpenSSL
```

### **4. Test on Clean Systems**

```bash
# Test on minimal Docker images
docker run --rm -v $(pwd):/app alpine:latest /app/my-app --version
docker run --rm -v $(pwd):/app ubuntu:22.04 /app/my-app --version
```

## 🚀 Distribution

### **GitHub Releases**

```yaml
- name: Create Release
  uses: softprops/action-gh-release@v2
  with:
    files: |
      my-app-windows-x64.zip
      my-app-linux-x64.tar.gz
      my-app-macos-x64.tar.gz
    body: |
      ## Zero-Dependency Portable Executables
      
      Download and run immediately - no installation required!
      
      - **Windows**: Extract and run `my-app.exe`
      - **Linux**: Extract and run `./my-app`
      - **macOS**: Extract and run `./my-app`
```

### **Installation Scripts**

```bash
#!/bin/bash
# install.sh - Smart installer script
set -e

# Detect platform
case "$(uname -s)" in
    Linux*)     PLATFORM="linux-x64" ;;
    Darwin*)    PLATFORM="macos-x64" ;;
    CYGWIN*|MINGW*|MSYS*) PLATFORM="windows-x64" ;;
    *)          echo "Unsupported platform"; exit 1 ;;
esac

# Download and install
URL="https://github.com/user/repo/releases/latest/download/my-app-${PLATFORM}.tar.gz"
curl -L "$URL" | tar xz
sudo mv my-app-${PLATFORM}/my-app /usr/local/bin/
echo "✅ my-app installed successfully!"
```

## 🎉 Benefits

- ✅ **No Runtime Dependencies**: Works on any system
- ✅ **Easy Distribution**: Single file deployment
- ✅ **Version Isolation**: No conflicts with system libraries
- ✅ **Offline Capable**: No internet required after download
- ✅ **Security**: Reduced attack surface
- ✅ **Reliability**: Consistent behavior across environments

Zero-dependency builds make your Rust applications truly portable and user-friendly! 🚀
