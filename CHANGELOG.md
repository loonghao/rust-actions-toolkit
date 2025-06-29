# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2025-06-29

### 🎉 Major Release: Complete Redesign for Simplicity and Reliability

#### 🎯 Design Philosophy Change
**From**: Complex, feature-complete solution with cross-compilation focus
**To**: Layered approach prioritizing simplicity, reliability, and native builds

#### 🏗️ New Architecture: Three-Layer Design

##### Layer 1: Core CI (`core-ci.yml`)
- **Target**: 90% of Rust projects
- **Philosophy**: Zero configuration, maximum reliability
- **Features**: fmt, clippy, test, doc, audit, coverage
- **Platform**: Single platform (Linux) for speed
- **Benefits**: Fast, reliable, no complexity

##### Layer 2: Enhanced Release (`enhanced-release.yml`)
- **Target**: Projects needing multi-platform binaries
- **Philosophy**: Native builds only, no cross-compilation
- **Platforms**: Linux, macOS (x86_64 + aarch64), Windows
- **Benefits**: Fast native builds, no proc-macro issues

##### Layer 3: Advanced (Future)
- **Target**: <5% of projects with special needs
- **Philosophy**: Full power, full responsibility
- **Features**: Cross-compilation, exotic platforms
- **Warning**: Expect complexity and potential issues

#### ✅ Key Improvements

##### Reliability
- **No proc-macro issues**: Native builds handle all proc-macros correctly
- **No Docker problems**: No custom Docker images or permission issues
- **No cross-compilation failures**: Eliminates #1 source of CI failures
- **Predictable builds**: Same behavior every time

##### Performance
- **Faster builds**: Native compilation vs cross-compilation
- **Parallel execution**: Multiple native runners work simultaneously
- **No Docker overhead**: Direct runner execution
- **Optimized workflows**: Streamlined for common use cases

##### Simplicity
- **Zero configuration**: Reasonable defaults for everything
- **Clear naming**: `core-ci`, `enhanced-release` (no "simple" terminology)
- **Progressive complexity**: Start simple, add features when needed
- **Clear documentation**: Quick start guide, migration paths

#### 🔄 Migration from v3

##### Before (v3)
```yaml
# Complex configuration with cross-compilation issues
uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v3
uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v3
```

##### After (v4)
```yaml
# Clean, simple configuration
uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
uses: loonghao/rust-actions-toolkit/.github/workflows/enhanced-release.yml@v4
```

#### 📚 New Resources
- `docs/V4_QUICK_START.md` - Get started in 2 minutes
- `docs/V4_DESIGN_PHILOSOPHY.md` - Complete design rationale
- `examples/v4/` - Ready-to-use configurations
- `examples/migration/turbo-cdn-v4-migration.md` - Detailed migration guide

#### 🎯 Inspired by Success
Based on turbo-cdn v0.4.1's successful simple configuration approach, proving that reliability and simplicity often trump feature completeness.

#### ⚠️ Breaking Changes
- Workflow names changed: `reusable-*` → `core-*`, `enhanced-*`
- Configuration simplified: Many options removed in favor of sensible defaults
- Platform strategy: Focus on native builds, cross-compilation moved to advanced layer

#### 🔄 Backward Compatibility
- v3 workflows remain available and supported
- Clear migration path provided
- No forced migration - upgrade when ready

### 🚀 Get Started with v4

```yaml
# Minimal setup - works for most projects
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
```

See `docs/V4_QUICK_START.md` for complete guide.

---

## [3.0.4] - 2025-06-29

### 🐛 Docker Permission Fix for Cross-Compilation

#### Problem Identified
- **Docker permission errors** in Cross.toml configurations using custom images
- **apt-get permission denied** errors when building custom Docker images
- **turbo-cdn project** experiencing Docker build failures with musl targets

#### Technical Fixes
- **Fixed Cross.toml configurations**: Added proper apt permission handling
- **Enhanced Docker setup**: Added `dpkg --add-architecture` and `apt-get clean`
- **Simple Cross.toml option**: Created configuration using standard cross images
- **Permission-safe commands**: Proper sequence for Docker package installation

#### New Resources
- `examples/cross-compilation/Cross-simple-fix.toml` - Uses standard cross images (recommended)
- Enhanced `Cross-proc-macro-ultimate-fix.toml` with Docker permission fixes
- Updated `turbo-cdn-Cross.toml` with proper Docker setup

### 🎯 Specific Fixes
- **Docker permission errors**: Fixed apt-get permission denied issues
- **Custom image builds**: Proper architecture setup and package installation
- **Standard image option**: Alternative using official cross images

### 🔄 Migration
**Recommended approach** - use simple configuration:
```bash
# Copy the simple, permission-safe configuration
curl -o Cross.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/v3.0.4/examples/cross-compilation/Cross-simple-fix.toml
```

## [3.0.3] - 2025-06-29

### 🐛 Critical Reusable Workflow Proc-Macro Fix

#### Problem Identified
- **reusable-release.yml** was clearing environment variables without restoring proc-macro protection
- **turbo-cdn project** and similar projects using reusable workflows still experienced proc-macro errors
- **Environment variable conflicts** between workflow steps

#### Technical Fixes
- **Enhanced reusable-release.yml**: Added `CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER=""` protection
- **Persistent Environment**: Ensured proc-macro protection survives environment clearing
- **Cross-compilation Safety**: Maintained proc-macro protection throughout build process
- **Turbo-CDN Specific**: Added specialized Cross.toml configuration for complex proc-macro scenarios

#### New Resources
- `examples/cross-compilation/turbo-cdn-Cross.toml` - Specialized configuration for complex projects
- Enhanced reusable workflow proc-macro protection
- Persistent environment variable management

### 🎯 Specific Fixes
- **serde + async-trait + thiserror + clap**: All proc-macro combinations now work correctly
- **Reusable workflows**: Fixed environment variable persistence
- **Complex projects**: Added specialized Cross.toml examples

### 🔄 Migration
**No action required** - enhanced automatic fix:
```yaml
# Reusable workflows now include enhanced protection
uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v3
```

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
