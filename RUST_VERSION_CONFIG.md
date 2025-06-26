# 🦀 Rust Version Configuration

## Overview

The rust-actions-toolkit now supports configurable Rust versions through GitHub Actions parameters, providing flexibility for different project requirements.

## 🚀 Usage Methods

### 1. **Default Behavior (Automatic)**
```yaml
# Automatically uses Rust 1.83.0 (current default)
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: ci
```

### 2. **Manual Trigger with Custom Version**

#### Via GitHub UI:
1. Go to **Actions** tab in GitHub repository
2. Select **"Build and Push Docker Images"** workflow
3. Click **"Run workflow"**
4. Enter desired Rust version (e.g., `1.82.0`, `1.81.0`)
5. Click **"Run workflow"**

#### Via GitHub CLI:
```bash
# Trigger with specific Rust version
gh workflow run docker-build.yml \
  --ref master \
  -f rust_version=1.82.0 \
  -f force_rebuild=true
```

### 3. **API Trigger**
```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/loonghao/rust-actions-toolkit/actions/workflows/docker-build.yml/dispatches \
  -d '{"ref":"master","inputs":{"rust_version":"1.82.0","force_rebuild":"true"}}'
```

## 📋 Configuration Details

### Workflow Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `rust_version` | string | `1.83.0` | Rust toolchain version to install |
| `force_rebuild` | boolean | `false` | Force rebuild all images |

### Supported Rust Versions

| Version | Status | Notes |
|---------|--------|-------|
| `1.83.0` | ✅ Recommended | Current default, latest stable |
| `1.82.0` | ✅ Supported | Previous stable |
| `1.81.0` | ✅ Supported | Older stable |
| `1.80.0` | ⚠️ Limited | May have dependency issues |
| `nightly` | ❌ Not recommended | Unstable, may break builds |

## 🔧 Technical Implementation

### Docker Build Arguments
```dockerfile
# Dockerfile receives version as build argument
ARG RUST_VERSION=1.83.0
ENV RUST_VERSION=${RUST_VERSION}

# Used in rustup installation
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain $RUST_VERSION
```

### GitHub Actions Integration
```yaml
# Workflow accepts input parameter
workflow_dispatch:
  inputs:
    rust_version:
      description: 'Rust version to use (e.g., 1.83.0, 1.82.0)'
      required: false
      default: '1.83.0'
      type: string

# Passes to Docker build
build-args: |
  RUST_VERSION=${{ github.event.inputs.rust_version || '1.83.0' }}
```

## 🎯 Use Cases

### 1. **Testing Compatibility**
```bash
# Test with older Rust version for compatibility
gh workflow run docker-build.yml -f rust_version=1.81.0
```

### 2. **Emergency Rollback**
```bash
# Rollback to previous version if issues occur
gh workflow run docker-build.yml -f rust_version=1.82.0 -f force_rebuild=true
```

### 3. **Beta Testing**
```bash
# Test with newer version (when available)
gh workflow run docker-build.yml -f rust_version=1.84.0
```

## ⚠️ Important Notes

1. **Dependency Compatibility**: Some cargo tools may require specific Rust versions
2. **Build Time**: Different versions may have different build times
3. **Cache Impact**: Changing versions invalidates Docker layer cache
4. **Testing Required**: Always test with your specific use case

## 🔍 Verification

After building with custom version:
```bash
# Check Rust version in built image
docker run --rm ghcr.io/loonghao/rust-toolkit:base rustc --version

# Expected output: rustc 1.82.0 (f6e511eec 2024-10-15)
```

## 📝 Best Practices

1. **Stick to stable versions** for production use
2. **Test thoroughly** when changing versions
3. **Document version requirements** in your project
4. **Use default version** unless specific needs require otherwise

---

**Default Version**: `1.83.0` (automatically updated for compatibility)
