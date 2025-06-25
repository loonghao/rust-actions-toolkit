# 📖 Usage Guide

This guide provides detailed instructions for setting up and using the Rust Actions Toolkit in different project scenarios.

## 🎯 Project Setup by Type

### 1. Pure Rust Library Crate

For libraries that only publish to crates.io without binaries:

```bash
# 1. Copy the workflow files
curl -o .github/workflows/ci.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/ci.yml
curl -o .github/workflows/release-plz.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release-plz.yml

# 2. Copy the pure crate configuration
curl -o release-plz.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/pure-crate/release-plz.toml

# 3. Edit release-plz.toml and update the package name
sed -i 's/my-awesome-lib/your-actual-package-name/g' release-plz.toml
```

**What you get:**
- Code quality checks (rustfmt, clippy, docs)
- Cross-platform testing
- Security auditing
- Automated crates.io publishing
- Changelog generation

### 2. Binary Crate (CLI Tools)

For projects with executable binaries:

```bash
# 1. Copy all workflow files
curl -o .github/workflows/ci.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/ci.yml
curl -o .github/workflows/release-plz.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release-plz.yml
curl -o .github/workflows/release.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release.yml

# 2. Copy the binary crate configuration
curl -o release-plz.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/binary-crate/release-plz.toml

# 3. Edit release-plz.toml and update the package name
sed -i 's/my-cli-tool/your-actual-binary-name/g' release-plz.toml
```

**What you get:**
- Everything from pure crate setup
- Cross-platform binary compilation (Linux, macOS, Windows)
- Automatic GitHub release with binaries
- Support for multiple architectures (x86_64, ARM64)

### 3. Python Wheel Project

For Rust projects with Python bindings:

```bash
# 1. Copy all workflow files
curl -o .github/workflows/ci.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/ci.yml
curl -o .github/workflows/release-plz.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release-plz.yml
curl -o .github/workflows/release.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release.yml

# 2. Copy the Python wheel configuration
curl -o release-plz.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/python-wheel/release-plz.toml
curl -o pyproject.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/python-wheel/pyproject.toml

# 3. Edit configuration files
sed -i 's/my-python-rust-lib/your-actual-package-name/g' release-plz.toml pyproject.toml
```

**What you get:**
- Everything from binary crate setup
- Python wheel building for multiple platforms
- Automatic PyPI publishing (when configured)
- Python package testing

## 🔧 Configuration Details

### Required Secrets

Add these to your GitHub repository settings:

| Secret | Required | Description |
|--------|----------|-------------|
| `CARGO_REGISTRY_TOKEN` | Yes | Your crates.io API token |
| `CODECOV_TOKEN` | No | For code coverage reporting |
| `RELEASE_PLZ_TOKEN` | No | GitHub PAT for enhanced release automation |

### Repository Owner Configuration

Update the repository owner check in `release-plz.yml`:

```yaml
# Change 'loonghao' to your GitHub username
if: ${{ github.repository_owner == 'your-username' }}
```

### Binary Name Detection

The toolkit automatically detects binary names from your `Cargo.toml`. For multiple binaries:

```toml
# Cargo.toml
[[bin]]
name = "tool1"
path = "src/bin/tool1.rs"

[[bin]]
name = "tool2"
path = "src/bin/tool2.rs"
```

To specify which binaries to release, edit `release.yml`:

```yaml
- name: Upload binary assets
  uses: taiki-e/upload-rust-binary-action@v1
  with:
    bin: tool1,tool2  # Specify multiple binaries
    target: ${{ matrix.target }}
    tar: all
    zip: windows
    token: ${{ secrets.GITHUB_TOKEN }}
```

## 🚀 Workflow Triggers

### CI Workflow (`ci.yml`)

Triggers on:
- Pull requests to `main`
- Pushes to `main` and `develop`
- Daily schedule (1 AM UTC)

### Release-plz Workflow (`release-plz.yml`)

Triggers on:
- Pushes to `main` branch
- Creates release PRs and publishes releases

### Release Workflow (`release.yml`)

Triggers on:
- Git tags starting with `v` (e.g., `v1.0.0`)
- Builds and uploads cross-platform assets

## 🎨 Customization

### Adding New Target Platforms

Edit the matrix in `ci.yml` and `release.yml`:

```yaml
strategy:
  matrix:
    include:
      # Add new targets here
      - target: riscv64gc-unknown-linux-gnu
        os: ubuntu-latest
```

### Custom Release Body

Modify the `git_release_body` in `release-plz.toml`:

```toml
git_release_body = """
## 🚀 Custom Release Notes

{{changelog}}

## 📦 Custom Installation Instructions

Your custom installation instructions here...
"""
```

### Conditional Features

Use environment variables and conditions:

```yaml
# In ci.yml
- name: Build with feature
  if: contains(github.event.head_commit.message, '[feature]')
  run: cargo build --features special-feature
```

## 🔍 Troubleshooting

### Common Issues

1. **Binary not found in release**
   - Check your `Cargo.toml` has `[[bin]]` sections
   - Verify binary names in `release.yml`

2. **Python wheel build fails**
   - Ensure `pyproject.toml` exists
   - Check maturin configuration

3. **Release-plz doesn't trigger**
   - Verify repository owner setting
   - Check `CARGO_REGISTRY_TOKEN` secret

4. **Cross-compilation fails**
   - Some dependencies may not support all targets
   - Consider using feature flags for platform-specific code

### Debug Mode

Enable debug logging by adding to workflow files:

```yaml
env:
  RUST_LOG: debug
  CARGO_TERM_VERBOSE: true
```

## 📚 Examples in the Wild

Projects using this toolkit:

- [vx shimexe](https://github.com/loonghao/vx-shimexe) - Binary tool
- [py2pyd](https://github.com/loonghao/py2pyd) - Python wheel project
- [rez-tools](https://github.com/loonghao/rez-tools) - CLI utilities
- [rez-core](https://github.com/loonghao/rez-core) - Core library

## 🤝 Getting Help

- 📖 Check the [README](README.md) for basic setup
- 🐛 [Open an issue](https://github.com/loonghao/rust-actions-toolkit/issues) for bugs
- 💡 [Start a discussion](https://github.com/loonghao/rust-actions-toolkit/discussions) for questions
