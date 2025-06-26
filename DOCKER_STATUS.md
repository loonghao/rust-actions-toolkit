# 🐳 Docker Images Status

## Current Status: 🚧 Building

The Docker images for rust-actions-toolkit are currently being built. This was caused by a configuration issue where the Docker build workflow was set to trigger on `main` branch instead of `master`.

### ✅ What's Fixed

1. **Docker build workflow** - Updated to use `master` branch
2. **Base image reliability** - Simplified to only install essential tools
3. **Build process** - Improved error handling and tool installation

### 🕐 Expected Timeline

- **Base image**: ~30-45 minutes
- **Specialized images**: ~60-90 minutes total
- **Full availability**: Within 2 hours

### 🚀 Temporary Workaround

While Docker images are building, you can use the action without Docker:

```yaml
# This works immediately (no Docker required)
- uses: loonghao/rust-actions-toolkit@v2.0.2
  with:
    command: ci
    # Don't set use-docker: true until images are ready
```

### 📦 Available Images (Once Built)

| Image | Purpose | Status |
|-------|---------|--------|
| `ghcr.io/loonghao/rust-toolkit:base` | Basic Rust development | 🚧 Building |
| `ghcr.io/loonghao/rust-toolkit:cross-compile` | Cross-compilation | 🚧 Pending |
| `ghcr.io/loonghao/rust-toolkit:python-wheels` | Python extensions | 🚧 Pending |
| `ghcr.io/loonghao/rust-toolkit:security-audit` | Security scanning | 🚧 Pending |

### 🔍 How to Check Status

You can check if images are ready by trying to pull them:

```bash
# Check if base image is ready
docker pull ghcr.io/loonghao/rust-toolkit:base

# If successful, you can use Docker options
```

### 📝 What Caused This

The Docker build workflow was configured for `main` branch, but this repository uses `master`. This has been fixed and images are now building automatically.

---

**This file will be removed once all Docker images are successfully built and available.**
