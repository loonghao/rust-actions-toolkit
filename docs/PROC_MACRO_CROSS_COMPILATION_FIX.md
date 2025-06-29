# Proc-Macro Cross-Compilation Fix

## Problem Description

When cross-compiling Rust projects that use proc-macros (like `async-trait`, `serde`, `tokio`, etc.), you might encounter this error:

```
error: cannot produce proc-macro for `async-trait v0.1.88` as the target `x86_64-unknown-linux-gnu` does not support these crate types
```

## Root Cause

Proc-macros are **compiler plugins** that run during compilation on the **host machine**. They must be compiled for the host architecture (e.g., `x86_64-unknown-linux-gnu` in GitHub Actions), not the target architecture (e.g., `aarch64-unknown-linux-gnu`).

The error occurs when:
1. `CARGO_BUILD_TARGET` is set globally, affecting ALL compilation including proc-macros
2. Cargo tries to build proc-macros for the target platform instead of the host platform
3. The target platform doesn't support proc-macro crate types

## Solution in rust-actions-toolkit v3.0.2+

### Automatic Fix

rust-actions-toolkit v3.0.2+ automatically handles this issue with enhanced proc-macro protection:

```yaml
# This now works correctly with proc-macros (enhanced fix)
- uses: loonghao/rust-actions-toolkit@v3
  with:
    command: release
    target: aarch64-unknown-linux-gnu
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Enhanced Protection

v3.0.2+ includes additional safeguards:
- Always ensures host toolchain availability
- Sets `CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER=""`
- Prevents external tools from interfering with proc-macro compilation

### How It Works

1. **Smart Target Detection**: Only sets `CARGO_BUILD_TARGET` for actual cross-compilation scenarios
2. **Host Platform Preservation**: Ensures proc-macros are built for the host platform
3. **Target Binary Building**: Final binaries are built for the specified target platform

### Technical Implementation

```bash
# Only set CARGO_BUILD_TARGET for cross-compilation scenarios
if [ "$target" != "x86_64-unknown-linux-gnu" ] && [ "$runner_os" == "Linux" ]; then
  export CARGO_BUILD_TARGET="$target"
  echo "Cross-compilation enabled: proc-macros will use host platform"
else
  echo "Native compilation: no special proc-macro handling needed"
fi
```

## Affected Crates

This fix resolves issues with all proc-macro crates:

- ✅ **async-trait** - Async trait definitions
- ✅ **serde** (`serde_derive`) - Serialization/deserialization
- ✅ **tokio** (`tokio-macros`) - Async runtime macros
- ✅ **clap** (`clap_derive`) - Command-line argument parsing
- ✅ **thiserror** (`thiserror-impl`) - Error handling
- ✅ **syn** & **quote** - Proc-macro development tools

## Cross-Compilation Targets

All cross-compilation targets now work correctly:

- ✅ **Linux ARM64**: `aarch64-unknown-linux-gnu`, `aarch64-unknown-linux-musl`
- ✅ **Windows**: `x86_64-pc-windows-gnu`, `x86_64-pc-windows-msvc`
- ✅ **macOS**: `x86_64-apple-darwin`, `aarch64-apple-darwin`

## Migration Guide

### From Broken Workflows

If you're experiencing proc-macro errors:

1. **Update to v3.0.1+**:
   ```yaml
   # From
   - uses: loonghao/rust-actions-toolkit@v3.0.0
   # To
   - uses: loonghao/rust-actions-toolkit@v3
   ```

2. **Remove manual workarounds** (if any):
   ```yaml
   # Remove these if you added them as workarounds
   env:
     CARGO_BUILD_TARGET: ""  # Remove this
   ```

3. **Test your workflow** - proc-macro errors should be resolved

### Verification

After updating, you should see logs like:

```
🔧 Configuring proc-macro cross-compilation for target: aarch64-unknown-linux-gnu
📦 Cross-compilation enabled: proc-macros will use host platform, binary will use target platform
```

## Example Scenarios

### Before Fix (v3.0.0)

```
❌ Cross-compiling project with async-trait to aarch64-linux:
error: cannot produce proc-macro for `async-trait v0.1.88` as the target `aarch64-unknown-linux-gnu` does not support these crate types

Caused by: global CARGO_BUILD_TARGET setting affecting proc-macro compilation
```

### After Fix (v3.0.1+)

```
✅ Cross-compiling project with async-trait to aarch64-linux:
🔧 Configuring proc-macro cross-compilation for target: aarch64-unknown-linux-gnu
📦 Cross-compilation enabled: proc-macros will use host platform, binary will use target platform
🔨 Building async-trait proc-macro for host...
🔨 Building main binary for aarch64-linux...
✅ Cross-compilation successful!
```

## Technical Architecture

| Component | Architecture | Reason |
|-----------|-------------|--------|
| **Proc-macros** | Host (x86_64-linux) | Run during compilation |
| **Final binary** | Target (aarch64-linux) | Run on target platform |
| **Dependencies** | Target (aarch64-linux) | Linked into final binary |

This separation ensures that:
- Proc-macros can execute during compilation
- Final binaries run on the intended target platform
- Cross-compilation works reliably across all targets

## Troubleshooting

### Still Getting Proc-Macro Errors?

#### Quick Fixes

1. **Update to latest**: Ensure you're using v3.0.2 or later
   ```yaml
   - uses: loonghao/rust-actions-toolkit@v3  # Auto-updates to latest
   ```

2. **Check Cross.toml**: If using `cross`, ensure proper configuration
   ```toml
   # Copy examples/cross-compilation/Cross-proc-macro-ultimate-fix.toml
   # to your project root as Cross.toml
   ```

3. **Manual environment fix**: Add this step before building
   ```yaml
   - name: Fix proc-macro cross-compilation
     run: |
       echo "CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER=" >> $GITHUB_ENV
       rustup target add x86_64-unknown-linux-gnu
   ```

#### Diagnostic Steps

1. **Check logs**: Look for proc-macro configuration messages
2. **Verify environment**: Check for conflicting `CARGO_BUILD_TARGET` settings
3. **Test locally**: Try building with `cross` locally first
4. **Check dependencies**: Ensure all proc-macro crates are up to date

#### Common Issues

**Issue**: Using custom Cross.toml with global `default-target`
**Solution**: Remove global `default-target` setting, use target-specific config only

**Issue**: External tools setting `CARGO_BUILD_TARGET` globally
**Solution**: Use our enhanced fix that overrides external settings

**Issue**: Missing host toolchain
**Solution**: Our fix automatically installs `x86_64-unknown-linux-gnu` target

### Manual Workaround (Not Recommended)

If you need a manual workaround:

```yaml
- name: Configure proc-macro cross-compilation
  run: |
    if [ "${{ matrix.target }}" != "x86_64-unknown-linux-gnu" ]; then
      echo "CARGO_BUILD_TARGET=${{ matrix.target }}" >> $GITHUB_ENV
    fi
```

But we recommend using rust-actions-toolkit v3.0.1+ instead.

## References

- [Rust Cross-Compilation Guide](https://rust-lang.github.io/rustup/cross-compilation.html)
- [Cargo Build Configuration](https://doc.rust-lang.org/cargo/reference/config.html)
- [Proc-Macro Book](https://doc.rust-lang.org/reference/procedural-macros.html)
