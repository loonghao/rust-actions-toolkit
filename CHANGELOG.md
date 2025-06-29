# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
