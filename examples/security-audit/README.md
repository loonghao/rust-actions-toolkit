# Security Audit Configuration

This guide shows different ways to configure security auditing for your Rust projects.

## 🚨 Common Issue

The `rustsec/audit-check@v2.0.0` action sometimes fails with:
```
Error: Unexpected end of JSON input
```

## ✅ Solutions

### Solution 1: Use our toolkit (Recommended)

Our toolkit automatically includes security auditing:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v1
    # Security audit is included automatically
```

### Solution 2: Manual cargo-audit

```yaml
# .github/workflows/security.yml
name: Security Audit

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday

jobs:
  security-audit:
    name: Security Audit
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Rust toolchain
        uses: dtolnay/rust-toolchain@stable

      - name: Install cargo-audit
        uses: taiki-e/install-action@v2
        with:
          tool: cargo-audit

      - name: Run security audit
        run: cargo audit --color never
        continue-on-error: true  # Don't fail CI on audit issues

      - name: Run security audit with JSON output
        run: cargo audit --json > audit-results.json
        continue-on-error: true

      - name: Upload audit results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: security-audit-results
          path: audit-results.json
```

### Solution 3: Fixed rustsec action

```yaml
# Use a more recent version or alternative
- name: Run security audit
  uses: rustsec/audit-check@v1.4.1  # Use older stable version
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
```

### Solution 4: Custom audit script

```yaml
- name: Custom security audit
  run: |
    # Install cargo-audit if not present
    if ! command -v cargo-audit &> /dev/null; then
      cargo install cargo-audit
    fi
    
    # Run audit with error handling
    if cargo audit --version; then
      echo "Running security audit..."
      cargo audit || echo "Security audit found issues (non-blocking)"
    else
      echo "cargo-audit installation failed, skipping audit"
    fi
```

## 🔧 Configuration Options

### Basic audit

```bash
cargo audit
```

### Audit with specific database

```bash
cargo audit --db /path/to/advisory-db
```

### Audit with JSON output

```bash
cargo audit --json
```

### Audit specific packages

```bash
cargo audit --package reqwest
```

### Ignore specific advisories

```bash
cargo audit --ignore RUSTSEC-2023-0001
```

## 📋 audit.toml Configuration

Create an `audit.toml` file in your project root:

```toml
# audit.toml
[advisories]
# Ignore specific advisories
ignore = [
    "RUSTSEC-2023-0001",  # Example: ignore specific advisory
]

# Only audit production dependencies
ignore-dev-dependencies = true

# Severity threshold
severity-threshold = "medium"

[licenses]
# Allow specific licenses
allow = [
    "MIT",
    "Apache-2.0",
    "BSD-3-Clause",
]

# Deny specific licenses
deny = [
    "GPL-3.0",
]
```

## 🎯 Best Practices

### 1. Regular Auditing

```yaml
# Run weekly security audits
on:
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday
```

### 2. Non-blocking Audits

```yaml
# Don't fail CI on audit issues
continue-on-error: true
```

### 3. Artifact Upload

```yaml
# Save audit results for review
- name: Upload audit results
  uses: actions/upload-artifact@v4
  with:
    name: security-audit
    path: audit-results.json
```

### 4. Notification on Issues

```yaml
# Notify on security issues
- name: Notify on security issues
  if: failure()
  run: |
    echo "Security audit found issues!"
    # Add notification logic here
```

## 🔍 Troubleshooting

### JSON parsing errors

If you encounter JSON parsing errors:

1. **Use direct cargo-audit** instead of the GitHub action
2. **Check network connectivity** during audit
3. **Use older action version** (`v1.4.1`)
4. **Add error handling** with `continue-on-error: true`

### Database update issues

```bash
# Update advisory database manually
cargo audit --update

# Use specific database version
cargo audit --db-url https://github.com/RustSec/advisory-db.git
```

### Performance issues

```bash
# Skip dev dependencies for faster audits
cargo audit --ignore-dev-dependencies

# Audit only specific packages
cargo audit --package your-main-package
```

## 📚 Examples

### Complete security workflow

```yaml
name: Security

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0'

jobs:
  audit:
    name: Security Audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: taiki-e/install-action@v2
        with:
          tool: cargo-audit
      - run: cargo audit
        continue-on-error: true

  licenses:
    name: License Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: taiki-e/install-action@v2
        with:
          tool: cargo-audit
      - run: cargo audit licenses
        continue-on-error: true
```

## 🔗 References

- [cargo-audit Documentation](https://docs.rs/cargo-audit/)
- [RustSec Advisory Database](https://rustsec.org/)
- [Security Best Practices](https://rust-lang.github.io/api-guidelines/security.html)
