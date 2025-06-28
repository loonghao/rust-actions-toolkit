# GitHub Actions Linting Guide

This document explains how we use GitHub Actions linting to ensure high-quality workflow configurations in the rust-actions-toolkit.

## 🎯 Why Lint GitHub Actions?

Linting GitHub Actions workflows helps us:

- **Catch syntax errors** before they cause CI failures
- **Validate workflow structure** and ensure best practices
- **Detect security issues** in workflow configurations
- **Maintain consistency** across all workflow files
- **Prevent common mistakes** like typos in action names or versions

## 🔧 Tools Used

### 1. actionlint
[actionlint](https://github.com/rhysd/actionlint) is a static checker for GitHub Actions workflow files.

**Features:**
- Validates workflow syntax and structure
- Checks action references and versions
- Validates expressions and contexts
- Integrates with shellcheck for shell script validation
- Detects common mistakes and anti-patterns

### 2. yq
[yq](https://github.com/mikefarah/yq) is used for YAML syntax validation.

**Features:**
- Validates YAML syntax
- Ensures proper formatting
- Can be used for YAML manipulation and querying

### 3. shellcheck
[shellcheck](https://github.com/koalaman/shellcheck) validates shell scripts within workflows.

**Features:**
- Detects shell script errors
- Suggests improvements
- Integrates with actionlint

## 🚀 Usage

### Automatic Validation (CI)

All workflows are automatically validated in our CI pipeline:

```yaml
# .github/workflows/ci.yml
jobs:
  actionlint:
    name: Lint GitHub Actions
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install actionlint
        run: |
          bash <(curl https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash)
          sudo mv ./actionlint /usr/local/bin/
      - name: Lint workflows
        run: actionlint -verbose
```

### Local Validation

#### Option 1: Use our script
```bash
# Run the comprehensive lint script
./scripts/lint-actions.sh
```

#### Option 2: Manual installation and usage
```bash
# Install actionlint
bash <(curl https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash)
sudo mv ./actionlint /usr/local/bin/

# Install yq
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# Install shellcheck (Ubuntu/Debian)
sudo apt-get install shellcheck

# Run validations
actionlint -verbose
actionlint -verbose -shellcheck=""
```

### Pre-commit Hook

You can set up a pre-commit hook to automatically validate workflows:

```bash
# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running GitHub Actions lint..."
./scripts/lint-actions.sh
EOF

chmod +x .git/hooks/pre-commit
```

## ⚙️ Configuration

### .actionlint.yml

We use a custom configuration file to customize actionlint behavior:

```yaml
# .actionlint.yml
shellcheck:
  enable: true
  exclude-ids:
    - SC2034  # Variable appears unused (common in GitHub Actions)

rules:
  action-ref:
    exclude:
      - "dtolnay/rust-toolchain@main"  # Allow @main for trusted actions
```

### Ignored Files

The following files are ignored during linting:
- Template files: `examples/*/template-*.yml`
- Draft files: `examples/*/draft-*.yml`
- Backup files: `**/*.bak`, `**/*~`

## 🔍 What We Validate

### 1. Workflow Structure
- Valid YAML syntax
- Required workflow fields (`name`, `on`, `jobs`)
- Job dependencies and needs
- Matrix configurations

### 2. Action References
- Valid action names and versions
- Proper input/output definitions
- Security best practices

### 3. Shell Scripts
- Shell script syntax and best practices
- Variable usage and quoting
- Command availability

### 4. Examples and Templates
- YAML syntax validation
- Version consistency across examples
- Workflow completeness

### 5. Security
- Permissions validation
- Secret usage patterns
- Injection vulnerabilities

## 📊 Validation Results

### CI Integration

The lint results are integrated into our CI pipeline:

- ✅ **Pass**: All validations successful
- ❌ **Fail**: Validation errors found
- ⚠️ **Warning**: Non-critical issues detected

### Local Development

When running locally, you'll see detailed output:

```
🔍 Linting GitHub Actions workflows...
✅ All workflows passed actionlint validation

🔍 Running actionlint with shellcheck integration...
✅ All workflows passed shellcheck validation

🔍 Checking version consistency in examples...
✅ All version references are up to date

✅ All GitHub Actions validations completed successfully!
```

## 🐛 Common Issues and Solutions

### 1. Invalid Action Reference
```yaml
# ❌ Wrong
- uses: actions/checkout@v3.0.0  # Non-existent version

# ✅ Correct
- uses: actions/checkout@v4
```

### 2. Missing Required Fields
```yaml
# ❌ Wrong
name: My Action
# Missing description

# ✅ Correct
name: My Action
description: 'Description of what this action does'
```

### 3. Shell Script Issues
```yaml
# ❌ Wrong
run: echo $VARIABLE  # Unquoted variable

# ✅ Correct
run: echo "$VARIABLE"  # Properly quoted
```

### 4. Matrix Configuration
```yaml
# ❌ Wrong
strategy:
  matrix:
    os: [ubuntu-latest]
    # Missing other required matrix values

# ✅ Correct
strategy:
  matrix:
    include:
      - os: ubuntu-latest
        target: x86_64-unknown-linux-gnu
```

## 📚 Best Practices

### 1. Pin Action Versions
```yaml
# ✅ Good - pinned to major version
- uses: actions/checkout@v4

# ⚠️ Acceptable for trusted actions
- uses: dtolnay/rust-toolchain@master

# ❌ Avoid - unpinned
- uses: actions/checkout@main
```

### 2. Use Proper Permissions
```yaml
permissions:
  contents: read
  actions: read
  security-events: write
```

### 3. Validate Inputs
```yaml
inputs:
  target:
    description: 'Target platform'
    required: true
    type: string
```

### 4. Use Conditional Logic
```yaml
- name: Install packages
  if: runner.os == 'Linux'
  run: sudo apt-get update
```

## 🔗 Resources

- [actionlint Documentation](https://github.com/rhysd/actionlint)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [YAML Specification](https://yaml.org/spec/)
- [shellcheck Documentation](https://github.com/koalaman/shellcheck)

## 🤝 Contributing

When contributing to this project:

1. **Run lint locally** before submitting PRs
2. **Fix all lint errors** - CI will fail if linting fails
3. **Update examples** to use latest versions
4. **Follow our configuration** in `.actionlint.yml`

The linting process helps maintain high code quality and prevents common issues from reaching production.
