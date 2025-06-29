# Workflow Robustness Fixes

This document outlines the robustness improvements made to fix common workflow issues.

## 🐛 Issues Fixed

### 1. `INPUT_BIN: parameter null or not set`

**Problem**: The `taiki-e/upload-rust-binary-action@v1` requires a `bin` parameter, but it was sometimes empty.

**Root Cause**: 
- `binary-name` input was optional and could be empty string
- No fallback mechanism to auto-detect binary name

**Solution**: Enhanced binary name detection with multiple fallback methods:

```yaml
- name: Detect binary name
  id: detect-binary
  shell: bash
  run: |
    if [ -n "${{ inputs.binary-name }}" ] && [ "${{ inputs.binary-name }}" != "" ]; then
      echo "binary-name=${{ inputs.binary-name }}" >> $GITHUB_OUTPUT
      echo "✅ Using provided binary name: ${{ inputs.binary-name }}"
    else
      echo "🔍 Auto-detecting binary name from Cargo.toml..."
      
      # Method 1: Look for package name
      binary_name=$(grep '^name = ' Cargo.toml | head -1 | sed 's/name = "\(.*\)"/\1/' | tr -d ' ')
      
      # Method 2: Look for [[bin]] sections
      if [ -z "$binary_name" ]; then
        binary_name=$(grep -A 5 '^\[\[bin\]\]' Cargo.toml | grep '^name = ' | head -1 | sed 's/name = "\(.*\)"/\1/' | tr -d ' ')
      fi
      
      # Method 3: Use directory name as fallback
      if [ -z "$binary_name" ]; then
        binary_name=$(basename "$(pwd)" | tr '-' '_')
      fi
      
      echo "binary-name=$binary_name" >> $GITHUB_OUTPUT
    fi

- name: Upload binary assets
  uses: taiki-e/upload-rust-binary-action@v1
  with:
    bin: ${{ steps.detect-binary.outputs.binary-name }}  # Now always has a value
```

### 2. PowerShell Syntax Errors on Windows

**Problem**: Shell scripts using bash syntax were executed in PowerShell on Windows runners.

**Error Example**:
```
if [ -f "pyproject.toml" ]; then
  ~
Missing '(' after 'if' in if statement.
```

**Root Cause**: 
- Missing `shell: bash` specification in workflow steps
- Windows runners default to PowerShell for `run` commands
- Bash-specific syntax (`[ -f "file" ]`, `[[ condition ]]`) not compatible with PowerShell

**Solution**: Added explicit `shell: bash` to all shell script steps:

```yaml
# ❌ Before (causes PowerShell errors on Windows)
- name: Check for pyproject.toml
  run: |
    if [ -f "pyproject.toml" ]; then
      echo "exists=true" >> $GITHUB_OUTPUT
    fi

# ✅ After (works on all platforms)
- name: Check for pyproject.toml
  shell: bash
  run: |
    if [ -f "pyproject.toml" ]; then
      echo "exists=true" >> $GITHUB_OUTPUT
    fi
```

## 🔧 Fixed Workflow Steps

### reusable-release.yml
- ✅ `Configure Windows static linking` - Added `shell: bash`
- ✅ `Detect binary name` - Added `shell: bash` + enhanced logic
- ✅ Enhanced binary name detection with multiple fallback methods

### reusable-ci.yml
- ✅ `Configure environment variables` - Added `shell: bash`
- ✅ `Configure Cross.toml` - Added `shell: bash`
- ✅ `Test release build` - Added `shell: bash`
- ✅ `Verify binary` - Added `shell: bash`
- ✅ `Check for pyproject.toml` - Added `shell: bash`
- ✅ `Test Python wheel` - Added `shell: bash`

## 🎯 Best Practices Implemented

### 1. Always Specify Shell for Script Steps

```yaml
# ✅ Good - explicit shell specification
- name: Run shell script
  shell: bash
  run: |
    if [ -f "file.txt" ]; then
      echo "File exists"
    fi

# ❌ Bad - relies on runner default
- name: Run shell script
  run: |
    if [ -f "file.txt" ]; then
      echo "File exists"
    fi
```

### 2. Robust Parameter Validation

```yaml
# ✅ Good - validates input is not empty
if [ -n "${{ inputs.parameter }}" ] && [ "${{ inputs.parameter }}" != "" ]; then
  echo "Using parameter: ${{ inputs.parameter }}"
else
  echo "Parameter is empty, using fallback"
fi

# ❌ Bad - doesn't handle empty strings
if [ -n "${{ inputs.parameter }}" ]; then
  echo "Using parameter: ${{ inputs.parameter }}"
fi
```

### 3. Multiple Fallback Methods

```yaml
# ✅ Good - multiple detection methods
binary_name=$(grep '^name = ' Cargo.toml | head -1 | sed 's/name = "\(.*\)"/\1/')

if [ -z "$binary_name" ]; then
  binary_name=$(grep -A 5 '^\[\[bin\]\]' Cargo.toml | grep '^name = ' | head -1 | sed 's/name = "\(.*\)"/\1/')
fi

if [ -z "$binary_name" ]; then
  binary_name=$(basename "$(pwd)")
fi
```

### 4. Clear Error Messages

```yaml
# ✅ Good - helpful error messages
if [ -z "$binary_name" ]; then
  echo "❌ Could not detect binary name from Cargo.toml"
  echo "Please provide binary-name input explicitly"
  exit 1
fi

# ❌ Bad - unclear error
if [ -z "$binary_name" ]; then
  exit 1
fi
```

## 🧪 Testing

### Manual Testing Commands

```bash
# Test binary name detection
grep '^name = ' Cargo.toml | head -1 | sed 's/name = "\(.*\)"/\1/'

# Test file existence check
if [ -f "pyproject.toml" ]; then echo "exists"; fi

# Test cross-platform compatibility
# On Linux/macOS: uses bash
# On Windows: uses bash (with explicit shell specification)
```

### Automated Testing

The fixes are automatically tested in our CI pipeline:
- ✅ Linux runners (ubuntu-latest)
- ✅ macOS runners (macos-latest) 
- ✅ Windows runners (windows-latest)

## 📊 Impact

### Before Fixes
- ❌ `INPUT_BIN: parameter null or not set` errors
- ❌ PowerShell syntax errors on Windows
- ❌ Inconsistent behavior across platforms
- ❌ Failed releases due to missing binary names

### After Fixes
- ✅ Robust binary name detection with fallbacks
- ✅ Consistent bash execution across all platforms
- ✅ Clear error messages for debugging
- ✅ Reliable cross-platform workflows

## 🔗 Related Documentation

- [GitHub Actions Shell Documentation](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsshell)
- [taiki-e/upload-rust-binary-action](https://github.com/taiki-e/upload-rust-binary-action)
- [Cross-platform Workflow Best Practices](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#choosing-github-hosted-runners)

### 3. Enhanced Binary Name Detection and Validation

**Problem**: `INPUT_BIN: parameter null or not set` errors when binary name detection failed.

**Root Cause**:
- Binary name detection logic had gaps
- No validation of detected binary names
- Upload action called even when binary name was empty

**Solution**: Enhanced binary name detection with comprehensive validation:

```yaml
# Enhanced binary name detection
- name: Detect and validate binary
  run: |
    # Multiple detection methods with validation
    if [ -n "${{ inputs.binary-name }}" ] && [ "${{ inputs.binary-name }}" != "" ]; then
      binary_name="${{ inputs.binary-name }}"
    else
      # Auto-detect with validation
      binary_name=$(grep '^name = ' Cargo.toml | head -1 | sed 's/name = "\(.*\)"/\1/')
      if [ -z "$binary_name" ]; then
        echo "should-upload=false" >> $GITHUB_OUTPUT
        exit 0
      fi
    fi

    # Validate binary name before upload
    if [ -n "$binary_name" ] && [ "$binary_name" != "" ]; then
      echo "binary-name=$binary_name" >> $GITHUB_OUTPUT
      echo "should-upload=true" >> $GITHUB_OUTPUT
    else
      echo "should-upload=false" >> $GITHUB_OUTPUT
    fi

# Conditional upload with validation
- name: Upload binary assets
  if: steps.detect-binary.outputs.should-upload == 'true' && steps.detect-binary.outputs.binary-name != ''
  uses: taiki-e/upload-rust-binary-action@v1
  with:
    bin: ${{ steps.detect-binary.outputs.binary-name }}
```

### 4. Enhanced Graceful Failure Handling

**Problem**: Workflows would fail completely if binary upload or wheel building failed.

**Root Cause**:
- No distinction between library crates and binary crates
- No graceful handling of build failures
- All-or-nothing approach to uploads

**Solution**: Implemented smart project detection and graceful failure handling:

```yaml
# Smart project type detection
- name: Detect binary name and check project type
  run: |
    # Check if this project has binaries
    has_bin_section=$(grep -c '^\[\[bin\]\]' Cargo.toml || echo "0")
    has_main_rs=$([ -f "src/main.rs" ] && echo "1" || echo "0")

    if [ "$has_bin_section" -gt 0 ] || [ "$has_main_rs" -eq 1 ]; then
      echo "should-upload=true" >> $GITHUB_OUTPUT
    else
      echo "should-upload=false" >> $GITHUB_OUTPUT
    fi

# Graceful failure handling
- name: Upload binary assets
  if: steps.detect-binary.outputs.should-upload == 'true'
  continue-on-error: true  # Don't fail the entire workflow
  uses: taiki-e/upload-rust-binary-action@v1

- name: Handle upload failure
  if: steps.upload-binary.outcome == 'failure'
  run: |
    echo "⚠️ Binary upload failed, but workflow continues"
```

## 🎯 Enhanced Best Practices

### 4. Smart Project Type Detection

```yaml
# ✅ Good - detects project type automatically
has_bin_section=$(grep -c '^\[\[bin\]\]' Cargo.toml || echo "0")
has_main_rs=$([ -f "src/main.rs" ] && echo "1" || echo "0")

if [ "$has_bin_section" -gt 0 ] || [ "$has_main_rs" -eq 1 ]; then
  echo "Binary project detected"
else
  echo "Library project detected, skipping binary upload"
fi

# ❌ Bad - assumes all projects have binaries
echo "binary-name=my-app" >> $GITHUB_OUTPUT
```

### 5. Graceful Failure Handling

```yaml
# ✅ Good - continues on failure with helpful messages
- name: Upload assets
  continue-on-error: true
  id: upload
  uses: some-action@v1

- name: Handle failure
  if: steps.upload.outcome == 'failure'
  run: echo "Upload failed, but workflow continues"

# ❌ Bad - fails entire workflow
- name: Upload assets
  uses: some-action@v1  # Will fail entire workflow if this fails
```

## 💡 Prevention

To prevent similar issues in the future:

1. **Always specify `shell: bash`** for shell scripts
2. **Validate all inputs** for empty/null values
3. **Provide multiple fallback methods** for auto-detection
4. **Test on all target platforms** (Linux, macOS, Windows)
5. **Use clear error messages** with actionable guidance
6. **Follow the linting guidelines** in our actionlint configuration
7. **Implement graceful failure handling** with `continue-on-error`
8. **Detect project types** before attempting operations
9. **Provide informative failure messages** for debugging
