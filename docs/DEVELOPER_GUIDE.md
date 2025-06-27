# 🛠️ Developer Guide

This guide helps developers correctly use rust-actions-toolkit and avoid common pitfalls.

## 📋 Quick Checklist

### ✅ Version References
- **Always use `@v2`** for the latest stable version
- **Avoid `@v1`** - deprecated and missing latest features
- **Use `@v2.x.x`** for specific version pinning

### ✅ Platform Targets
Use Docker-aligned targets for best compatibility:

```yaml
# ✅ Recommended targets
- x86_64-pc-windows-gnu      # Zero-dependency Windows
- x86_64-unknown-linux-musl  # Static Linux
- x86_64-apple-darwin        # Intel Mac
- aarch64-apple-darwin       # Apple Silicon Mac

# ❌ Avoid these (compatibility issues)
- x86_64-pc-windows-msvc     # Requires Visual C++ runtime
- x86_64-unknown-linux-gnu   # Dynamic linking dependencies
```

## 🚀 Recommended Approaches

### 1. Smart Release (Zero-Config) - 90% of Projects

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    strategy:
      matrix:
        include:
          - { os: ubuntu-latest, target: x86_64-pc-windows-gnu }
          - { os: ubuntu-latest, target: x86_64-unknown-linux-musl }
          - { os: macos-latest, target: x86_64-apple-darwin }
    
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit/actions/smart-release@v2
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          target: ${{ matrix.target }}
```

**When to use:**
- ✅ Standard Rust projects
- ✅ Want minimal configuration
- ✅ Follow best practices automatically

### 2. Upload Release Artifacts - Custom Control

```yaml
- uses: loonghao/rust-actions-toolkit@v2
  with:
    command: release
    target: ${{ matrix.target }}
    github-token: ${{ secrets.GITHUB_TOKEN }}

- uses: loonghao/rust-actions-toolkit/actions/upload-release-artifacts@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    binary-path: target/${{ matrix.target }}/release/
    create-archives: true
```

**When to use:**
- 🔧 Need custom build steps
- 🔧 Want control over artifact handling
- 🔧 Complex project structure

### 3. Reusable Workflows - Organization Standard

```yaml
uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2
with:
  rust-toolchain: stable
  enable-python-wheels: true
```

**When to use:**
- 🏢 Organization-wide standards
- 🏢 Multiple similar projects
- 🏢 Centralized configuration

## 🐛 Common Issues & Solutions

### Issue 1: "Unrecognized function: hashFiles"

**Problem:** Using `hashFiles` in job-level `if` conditions
```yaml
# ❌ Wrong
jobs:
  build:
    if: hashFiles('pyproject.toml') != ''
```

**Solution:** Move to step-level checks
```yaml
# ✅ Correct
jobs:
  build:
    steps:
      - id: check
        run: |
          if [ -f "pyproject.toml" ]; then
            echo "exists=true" >> $GITHUB_OUTPUT
          fi
      - if: steps.check.outputs.exists == 'true'
        run: echo "File exists"
```

### Issue 2: "Unrecognized named-value: inputs"

**Problem:** Using `inputs` in action version specifications
```yaml
# ❌ Wrong
uses: some-action@${{ inputs.version }}
```

**Solution:** Use fixed versions
```yaml
# ✅ Correct
uses: some-action@v1.0.0
```

### Issue 3: Cross-compilation failures

**Problem:** Missing toolchain for target platform

**Solution:** Use Docker-aligned targets and let the action handle toolchain setup
```yaml
# ✅ Correct - action handles toolchain automatically
- uses: loonghao/rust-actions-toolkit@v2
  with:
    target: x86_64-pc-windows-gnu  # Zero-dependency target
```

## 📝 Project Setup Best Practices

### 1. Cargo.toml Configuration

```toml
[package]
name = "my-project"
version = "0.1.0"
edition = "2021"

# For binary projects
[[bin]]
name = "my-project"
path = "src/main.rs"

# For library projects with binary
[[bin]]
name = "my-cli"
path = "src/bin/cli.rs"
```

### 2. Python Extension Projects

```toml
# pyproject.toml
[build-system]
requires = ["maturin>=1.0,<2.0"]
build-backend = "maturin"

[project]
name = "my-python-ext"
requires-python = ">=3.8"
```

### 3. Release Notes Templates

Create `.github/release-template.md`:
```markdown
# {{PROJECT_NAME}} {{VERSION}}

## Downloads
- Windows: `{{PROJECT_NAME}}-x86_64-pc-windows-gnu.zip`
- Linux: `{{PROJECT_NAME}}-x86_64-unknown-linux-musl.tar.gz`
- macOS: `{{PROJECT_NAME}}-x86_64-apple-darwin.tar.gz`

## Install
```bash
pip install {{PROJECT_NAME}}=={{VERSION}}
```
```

## 🔍 Debugging Tips

### 1. Check Action Logs
Look for these key sections:
- ✅ "Project detection" - Verify correct project type
- ✅ "Target platform" - Confirm correct target
- ✅ "Build artifacts" - Check what was built
- ✅ "Upload results" - Verify upload success

### 2. Validate Workflow Syntax
```bash
# Use GitHub CLI to validate
gh workflow view .github/workflows/release.yml
```

### 3. Test Locally
```bash
# Test cross-compilation locally
cargo build --target x86_64-pc-windows-gnu
cargo build --target x86_64-unknown-linux-musl
```

## 📚 Additional Resources

- [📖 Main Documentation](../README.md)
- [🎯 Examples](../examples/)
- [🐳 Docker Images](../docker/)
- [🔧 Best Practices](BEST_PRACTICES.md)
- [🚨 Troubleshooting](OPENSSL_TROUBLESHOOTING.md)

## 🆘 Getting Help

1. **Check Examples**: Look at [examples/](../examples/) for similar use cases
2. **Read Documentation**: Review relevant docs in [docs/](.)
3. **Search Issues**: Check [GitHub Issues](https://github.com/loonghao/rust-actions-toolkit/issues)
4. **Create Issue**: If problem persists, create a new issue with:
   - Workflow file
   - Error logs
   - Project structure
   - Expected vs actual behavior
