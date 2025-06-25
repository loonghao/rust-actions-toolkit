# GitHub Token Issues in Reusable Workflows

This document explains and resolves GitHub Token related issues in reusable workflows.

## 🚨 Common Error

```
error parsing called workflow
secret name `GITHUB_TOKEN` within `workflow_call` can not be used since it would collide with system reserved name
```

## 🔍 Problem Explanation

`GITHUB_TOKEN` is a **system-reserved secret** automatically provided by GitHub Actions. You cannot declare it in the `secrets` section of a `workflow_call` because it conflicts with the built-in token.

## ✅ Solution

### Before (❌ Incorrect)

```yaml
# reusable-workflow.yml
on:
  workflow_call:
    secrets:
      GITHUB_TOKEN:  # ❌ This causes the error
        description: 'GitHub token'
        required: true

# calling-workflow.yml
jobs:
  call-workflow:
    uses: ./.github/workflows/reusable-workflow.yml
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # ❌ Not needed
```

### After (✅ Correct)

```yaml
# reusable-workflow.yml
on:
  workflow_call:
    # ✅ Don't declare GITHUB_TOKEN in secrets
    secrets:
      CUSTOM_TOKEN:
        description: 'Custom token if needed'
        required: false

jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - name: Use GitHub token
        run: echo "Token available"
        env:
          # ✅ GITHUB_TOKEN is automatically available
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# calling-workflow.yml
jobs:
  call-workflow:
    uses: ./.github/workflows/reusable-workflow.yml
    # ✅ No need to pass GITHUB_TOKEN
    secrets:
      CUSTOM_TOKEN: ${{ secrets.CUSTOM_TOKEN }}
```

## 🔧 Migration Guide

### Step 1: Update Reusable Workflows

Remove `GITHUB_TOKEN` from the `secrets` declaration:

```yaml
# Before
on:
  workflow_call:
    secrets:
      GITHUB_TOKEN:
        required: true
      OTHER_TOKEN:
        required: true

# After
on:
  workflow_call:
    secrets:
      OTHER_TOKEN:
        required: true
    # GITHUB_TOKEN is automatically available
```

### Step 2: Update Calling Workflows

Remove `GITHUB_TOKEN` from the secrets passed to reusable workflows:

```yaml
# Before
jobs:
  call:
    uses: org/repo/.github/workflows/reusable.yml@v1
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      OTHER_TOKEN: ${{ secrets.OTHER_TOKEN }}

# After
jobs:
  call:
    uses: org/repo/.github/workflows/reusable.yml@v1
    secrets:
      OTHER_TOKEN: ${{ secrets.OTHER_TOKEN }}
```

### Step 3: Verify Token Usage

Ensure your reusable workflows can still access the GitHub token:

```yaml
# In reusable workflow
steps:
  - name: Use GitHub API
    run: |
      curl -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
           https://api.github.com/user
```

## 📋 Examples

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
      binary-name: my-app
    # ✅ No GITHUB_TOKEN needed
```

### Release-plz Workflow

```yaml
# .github/workflows/release-plz.yml
name: Release-plz
on:
  push:
    branches: [main]

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release-plz.yml@v1
    secrets:
      CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
      # ✅ Only pass custom tokens, not GITHUB_TOKEN
      RELEASE_PLZ_TOKEN: ${{ secrets.RELEASE_PLZ_TOKEN }}
```

### CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v1
    with:
      rust-toolchain: stable
    # ✅ No secrets needed for basic CI
```

## 🎯 Best Practices

### 1. Use Automatic GITHUB_TOKEN

```yaml
# ✅ Let GitHub provide the token automatically
- name: Create release
  uses: softprops/action-gh-release@v2
  with:
    files: dist/*
    token: ${{ secrets.GITHUB_TOKEN }}  # Automatically available
```

### 2. Custom Tokens for Enhanced Permissions

```yaml
# ✅ Use custom PAT for cross-workflow triggers
- name: Trigger other workflow
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.CUSTOM_PAT }}
    script: |
      // Custom logic requiring enhanced permissions
```

### 3. Conditional Token Usage

```yaml
# ✅ Fallback to GITHUB_TOKEN if custom token not available
- name: Checkout with token
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.CUSTOM_TOKEN || secrets.GITHUB_TOKEN }}
```

## 🔍 Troubleshooting

### Error: "secret name GITHUB_TOKEN within workflow_call can not be used"

**Solution**: Remove `GITHUB_TOKEN` from the `secrets` section of your reusable workflow.

### Error: "GITHUB_TOKEN not found"

**Cause**: This shouldn't happen as `GITHUB_TOKEN` is always provided.
**Solution**: Check your workflow syntax and ensure you're using `${{ secrets.GITHUB_TOKEN }}`.

### Error: "Insufficient permissions"

**Cause**: Default `GITHUB_TOKEN` has limited permissions.
**Solution**: 
1. Add required permissions to your workflow
2. Use a custom PAT with enhanced permissions

```yaml
# Add permissions to workflow
permissions:
  contents: write
  pull-requests: write
```

## 📚 References

- [GitHub Actions: Automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
- [Reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Workflow permissions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#permissions)

## 🔄 Version Compatibility

This issue affects:
- ✅ **v1.1.6+**: Fixed - `GITHUB_TOKEN` removed from reusable workflow secrets
- ❌ **v1.1.5 and earlier**: Contains the issue

**Migration**: Update to `@v1` or `@v1.1.6+` to get the fix automatically.
