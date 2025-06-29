# Platform Support Strategy 2025

## Overview

This document outlines the optimized platform support strategy for rust-actions-toolkit based on comprehensive market research of popular Rust projects and 2025 best practices.

## Market Research Summary

### Analyzed Projects
- **ripgrep** (53.4k stars) - Fast text search tool
- **bat** (53.2k stars) - Cat clone with syntax highlighting  
- **fd** (33k+ stars) - Find alternative
- **exa** (23k+ stars) - ls alternative
- **tokio** (26k+ stars) - Async runtime
- **taiki-e/upload-rust-binary-action** (288 stars) - Popular release action

### Key Findings

1. **Core Platforms**: All major projects support the same 4 core platforms
2. **Windows Preference**: Most projects use `windows-msvc` over `windows-gnu`
3. **32-bit Decline**: Very few projects still support 32-bit Windows
4. **Static Builds**: musl targets are increasingly important for containerized deployments
5. **ARM64 Growth**: ARM64 support is now considered essential

## Optimized Platform Configuration

### Tier 1: Core Platforms (Must Support)
```yaml
- x86_64-unknown-linux-gnu    # Standard Linux x64
- x86_64-apple-darwin         # Intel Mac
- aarch64-apple-darwin        # Apple Silicon Mac
- x86_64-pc-windows-msvc      # Windows x64 (mainstream)
```

### Tier 2: Important Platforms (Should Support)
```yaml
- aarch64-unknown-linux-gnu   # ARM64 Linux
- x86_64-unknown-linux-musl   # Static Linux x64
- aarch64-unknown-linux-musl  # Static ARM64 Linux
```

### Tier 3: Optional Platforms (Nice to Have)
```yaml
- x86_64-pc-windows-gnu       # Windows x64 (GNU toolchain)
```

### Removed Platforms
```yaml
- i686-pc-windows-gnu         # 32-bit Windows (deprecated)
```

## Implementation Changes

### Docker Configuration Updates

1. **Target Installation Order**: Prioritize core platforms first
2. **Toolchain Configuration**: Add MSVC support, optimize GNU configuration
3. **Static Linking**: Ensure proper configuration for all musl targets

### GitHub Actions Updates

1. **Default Target Selection**: Prefer `windows-msvc` over `windows-gnu`
2. **Matrix Configuration**: Update all example workflows
3. **CI/Release Consistency**: Ensure identical platform lists

### Proc-Macro Cross-Compilation

Special handling for proc-macro crates to avoid cross-compilation issues:
- Build proc-macros for host platform
- Use proper target configuration for final binaries

## Benefits of This Strategy

### ✅ Advantages
- **Mainstream Compatibility**: Aligns with popular Rust projects
- **Better Windows Support**: MSVC provides better compatibility
- **Reduced Complexity**: Fewer edge cases to handle
- **Future-Proof**: Focuses on growing platforms (ARM64)
- **Container-Ready**: Strong musl support for Docker deployments

### ⚠️ Trade-offs
- **Slightly Reduced Coverage**: Drops 32-bit Windows support
- **GNU Windows**: Moves to optional tier (still available)

## Migration Guide

### For Existing Projects

1. **Update target lists** in CI and release workflows
2. **Test Windows MSVC builds** to ensure compatibility
3. **Remove i686 dependencies** if any
4. **Verify static linking** works correctly

### For New Projects

Use the optimized platform configuration from the start:

```yaml
# .github/workflows/release.yml
target-platforms: |
  [
    {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
    {"target": "x86_64-apple-darwin", "os": "macos-13"},
    {"target": "aarch64-apple-darwin", "os": "macos-13"},
    {"target": "x86_64-pc-windows-msvc", "os": "windows-2022"},
    {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"},
    {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"},
    {"target": "aarch64-unknown-linux-musl", "os": "ubuntu-22.04"}
  ]
```

## Performance Considerations

### Build Time Optimization
- **Parallel Builds**: Core platforms can build in parallel
- **Caching Strategy**: Separate cache keys for different target types
- **Docker Layers**: Optimized layer structure for faster rebuilds

### Resource Usage
- **Runner Selection**: Use appropriate runners for each platform
- **Memory Requirements**: ARM64 builds may need more memory
- **Network Transfer**: Optimize artifact sizes

## Monitoring and Metrics

Track the following metrics to validate the strategy:
- Build success rates per platform
- Download statistics from releases
- User feedback on platform availability
- Build time and resource usage

## Future Considerations

### Emerging Platforms
- **RISC-V**: Monitor adoption, consider adding when stable
- **WebAssembly**: Evaluate for specific use cases
- **New ARM Variants**: Track ARM ecosystem evolution

### Deprecation Strategy
- **Regular Review**: Annual review of platform usage
- **Graceful Sunset**: 6-month notice for platform removal
- **Community Input**: Consider user feedback for decisions

## Conclusion

This optimized platform strategy balances mainstream compatibility with practical maintenance considerations. It aligns rust-actions-toolkit with industry best practices while maintaining flexibility for future evolution.

The strategy prioritizes:
1. **User Experience**: Support platforms users actually use
2. **Maintainability**: Focus resources on important targets
3. **Future Growth**: Prepare for ARM64 and container deployments
4. **Industry Alignment**: Match what successful Rust projects do

Regular reviews will ensure this strategy remains current with ecosystem evolution.
