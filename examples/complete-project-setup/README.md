# Complete Project Setup Example

This example shows how to set up a complete Rust project with the rust-actions-toolkit.

## Project Structure

```
my-rust-project/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI workflow
│       ├── release-plz.yml     # Automated releases
│       └── release.yml         # Cross-platform builds
├── src/
│   ├── lib.rs                  # Library code
│   ├── main.rs                 # Binary code (optional)
│   └── bin/                    # Additional binaries (optional)
├── tests/                      # Integration tests
├── examples/                   # Usage examples
├── Cargo.toml                  # Rust project configuration
├── release-plz.toml           # Release automation configuration
├── pyproject.toml             # Python wheel configuration (optional)
├── README.md                  # Project documentation
└── CHANGELOG.md               # Generated by release-plz
```

## Setup Steps

### 1. Initialize Rust Project

```bash
cargo new my-rust-project --lib
cd my-rust-project
```

### 2. Copy Workflow Files

Choose one of these methods:

#### Method A: Using GitHub Action (Recommended)

Create `.github/workflows/ci.yml`:
```yaml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v1
        with:
          command: ci
```

#### Method B: Using Reusable Workflows

```bash
# Copy example workflows
curl -o .github/workflows/ci.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/reusable-workflows/ci.yml
curl -o .github/workflows/release-plz.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/reusable-workflows/release-plz.yml
curl -o .github/workflows/release.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/reusable-workflows/release.yml
```

### 3. Configure Release Automation

Copy the appropriate release-plz.toml:

```bash
# For library crates
curl -o release-plz.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/pure-crate/release-plz.toml

# For binary crates
curl -o release-plz.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/binary-crate/release-plz.toml

# For Python wheel projects
curl -o release-plz.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/python-wheel/release-plz.toml
curl -o pyproject.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/examples/python-wheel/pyproject.toml
```

### 4. Update Configuration

Edit the copied files and replace placeholders:
- `my-awesome-lib` → your actual package name
- `your-username` → your GitHub username
- `your.email@example.com` → your email

### 5. Set Up GitHub Secrets

In your GitHub repository settings, add:
- `CARGO_REGISTRY_TOKEN` - Your crates.io API token
- `CODECOV_TOKEN` - Your Codecov token (optional)
- `RELEASE_PLZ_TOKEN` - GitHub PAT (optional)

### 6. First Commit

```bash
git add .
git commit -m "feat: initial project setup with rust-actions-toolkit"
git push origin main
```

## What Happens Next

1. **CI runs automatically** on every push and PR
2. **Release-plz creates release PRs** when you push to main
3. **Merge the release PR** to trigger automated releases
4. **Cross-platform binaries** are built and uploaded automatically
5. **Users can download** from GitHub releases or install via cargo

## Customization

### Adding More Platforms

Edit the release workflow to add more target platforms:

```yaml
target-platforms: |
  [
    {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
    {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"},
    {"target": "x86_64-apple-darwin", "os": "macos-13"},
    {"target": "aarch64-apple-darwin", "os": "macos-13"},
    {"target": "x86_64-pc-windows-msvc", "os": "windows-2022"},
    {"target": "aarch64-pc-windows-msvc", "os": "windows-2022"}
  ]
```

### Custom Clippy Rules

```yaml
- uses: loonghao/rust-actions-toolkit@v1
  with:
    command: ci
    clippy-args: '--all-targets --all-features -- -D warnings -D clippy::pedantic'
```

### Disable Features

```yaml
uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v1
with:
  enable-coverage: false
  enable-python-wheel: false
```

## Troubleshooting

### Release-plz Not Creating PRs

1. Check that you have commits with conventional commit messages
2. Ensure `CARGO_REGISTRY_TOKEN` is set (if publishing to crates.io)
3. Verify the release-plz.toml configuration

### Binary Releases Not Working

1. Ensure your Cargo.toml has a `[[bin]]` section
2. Check that the binary name matches in release-plz.toml
3. Verify the release workflow is triggered by tags

### Python Wheels Not Building

1. Ensure pyproject.toml exists and is valid
2. Check that your Cargo.toml has `crate-type = ["cdylib"]`
3. Verify PyO3 dependencies are correctly configured

## Examples

See the other examples in this directory for specific project types:
- [Pure Crate](../pure-crate/) - Library only
- [Binary Crate](../binary-crate/) - CLI tool
- [Python Wheel](../python-wheel/) - Python bindings
