# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.2] - 2025-06-29

### 🐛 Enhanced Proc-Macro Cross-Compilation Fix

#### Critical Improvements
- **Enhanced Protection**: Added additional safeguards against external tool interference
- **Host Toolchain Guarantee**: Always ensures `x86_64-unknown-linux-gnu` toolchain availability
- **Environment Override**: Sets `CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER=""` to prevent conflicts
- **Ultimate Cross.toml**: Added comprehensive Cross.toml configuration example

#### Technical Enhancements
- **Automatic Host Target**: Ensures host toolchain is always available for proc-macros
- **External Tool Protection**: Prevents tools like `taiki-e/upload-rust-binary-action` from interfering
- **Robust Environment Setup**: Multiple layers of proc-macro protection
- **Enhanced Documentation**: Comprehensive troubleshooting guide with quick fixes

#### New Resources
- `examples/cross-compilation/Cross-proc-macro-ultimate-fix.toml` - Ultimate Cross.toml configuration
- Enhanced troubleshooting section in proc-macro documentation
- Quick fix examples for common issues

### 🔄 Migration
**No action required** - this is an enhanced automatic fix:
```yaml
# Simply use v3 (auto-updates to v3.0.2)
- uses: loonghao/rust-actions-toolkit@v3
```

### 📚 For Persistent Issues
If you're still experiencing proc-macro errors:
1. Copy `examples/cross-compilation/Cross-proc-macro-ultimate-fix.toml` to your project root as `Cross.toml`
2. Ensure you're using v3.0.2 or later
3. Check the enhanced troubleshooting guide

## [3.0.1] - 2025-06-29

### 🐛 Critical Bug Fix

#### Fixed: Proc-Macro Cross-Compilation Issues
- **Problem**: `error: cannot produce proc-macro for async-trait v0.1.88 as the target x86_64-unknown-linux-gnu does not support these crate types`
- **Root Cause**: Missing proc-macro cross-compilation handling in v3.0.0 platform optimization
- **Solution**: Added proper host/target separation for proc-macro compilation

#### Technical Details
- **Smart Target Detection**: Only sets `CARGO_BUILD_TARGET` for actual cross-compilation scenarios
- **Host Platform Preservation**: Ensures proc-macros are built for the host platform (x86_64-linux)
- **Target Binary Building**: Final binaries are built for the specified target platform
- **Docker Configuration**: Updated with proc-macro cross-compilation environment

#### Affected Crates (Now Fixed)
- ✅ **async-trait** - Async trait definitions
- ✅ **serde** (`serde_derive`) - Serialization/deserialization
- ✅ **tokio** (`tokio-macros`) - Async runtime macros
- ✅ **clap** (`clap_derive`) - Command-line argument parsing
- ✅ **thiserror** (`thiserror-impl`) - Error handling
- ✅ **syn** & **quote** - Proc-macro development tools

#### Cross-Compilation Targets (All Working)
- ✅ **Linux ARM64**: `aarch64-unknown-linux-gnu`, `aarch64-unknown-linux-musl`
- ✅ **Windows**: `x86_64-pc-windows-gnu`, `x86_64-pc-windows-msvc`
- ✅ **macOS**: `x86_64-apple-darwin`, `aarch64-apple-darwin`

### 📚 Documentation
- Added comprehensive proc-macro cross-compilation fix guide (`docs/PROC_MACRO_CROSS_COMPILATION_FIX.md`)
- Detailed troubleshooting and migration instructions

### 🔄 Migration
**No action required** - this is an automatic fix:
```yaml
# Simply update to v3.0.1 or use v3 (auto-updates)
- uses: loonghao/rust-actions-toolkit@v3
```

## [3.0.0] - 2025-06-29

### 🚀 Major Platform Support Strategy Optimization

This release optimizes rust-actions-toolkit's platform support strategy based on comprehensive market research of popular Rust projects (ripgrep, bat, fd, exa, tokio) and 2025 best practices.

### ✨ Added
- **x86_64-pc-windows-msvc** as core platform (mainstream Windows target)
- Comprehensive platform support strategy documentation (`docs/PLATFORM_SUPPORT_STRATEGY_2025.md`)
- Optimized Docker cross-compilation configuration for 2025 platforms
- Platform priority system (Tier 1: Core, Tier 2: Important, Tier 3: Optional)

### 🔄 Changed
- **BREAKING**: Default Windows target changed from `x86_64-pc-windows-gnu` to `x86_64-pc-windows-msvc`
- Updated all example workflows with optimized platform configurations
- Improved smart-release action to prefer MSVC over GNU for Windows
- Enhanced Docker target installation order for better caching

### ❌ Removed
- **BREAKING**: Removed support for `i686-pc-windows-gnu` (32-bit Windows, deprecated)
- Cleaned up outdated cross-compilation configurations

### 🐛 Fixed
- Fixed emoji encoding issues in action.yml output messages
- Corrected Chinese comments to English in example files

### 📚 Documentation
- Added comprehensive platform support strategy guide
- Updated all examples with 2025 best practices
- Improved Docker usage documentation

### 🎯 Platform Strategy Summary

**Tier 1 (Core Platforms - Essential):**
- x86_64-unknown-linux-gnu (Standard Linux)
- x86_64-apple-darwin (Intel Mac)
- aarch64-apple-darwin (Apple Silicon Mac)
- x86_64-pc-windows-msvc (Windows MSVC - NEW)

**Tier 2 (Important Platforms - Recommended):**
- aarch64-unknown-linux-gnu (ARM64 Linux)
- x86_64-unknown-linux-musl (Static Linux)
- aarch64-unknown-linux-musl (Static ARM64 Linux)

**Tier 3 (Optional Platforms - Specific Use Cases):**
- x86_64-pc-windows-gnu (Windows GNU - for zero-dependency builds)

### 🔗 Migration Guide

For projects using the old configuration:

1. **Update Windows target**: Change `x86_64-pc-windows-gnu` to `x86_64-pc-windows-msvc` in your workflows
2. **Remove 32-bit Windows**: Remove any references to `i686-pc-windows-gnu`
3. **Update runner OS**: Use `windows-2022` for Windows MSVC builds
4. **Review platform list**: Use the new optimized platform configurations from examples

### 📊 Research Data

This optimization is based on analysis of:
- 5+ major Rust projects with 20k+ stars each
- GitHub Actions marketplace popular actions
- 2025 platform usage statistics
- Cross-compilation best practices

The new strategy aligns with industry standards while maintaining practical maintenance considerations.

## [Previous Versions]

For versions prior to 3.0.0, please see the git history or GitHub releases.
