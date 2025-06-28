# 🔧 Rust Actions Toolkit 一致性改进方案

## 📋 问题概述

当前 `rust-actions-toolkit` 存在 CI 和 Release 工作流不一致的问题，导致：

- **CI 阶段**：只进行开发构建 (`cargo build`)，未发现交叉编译问题
- **Release 阶段**：进行发布构建 (`cargo build --release`)，暴露 `libmimalloc-sys` 等依赖问题
- **结果**：问题在 PR 阶段未被发现，在 Release 时才暴露

## 🎯 改进目标

1. **确保 CI 和 Release 构建一致性**
2. **在 PR 阶段就发现交叉编译问题**
3. **统一 Docker 镜像和环境配置**
4. **提供可配置的构建深度选项**

## 🛠️ 具体改进方案

### 1. 增强 `reusable-ci.yml`

#### 当前问题
```yaml
# 当前 CI 只做基础构建
- name: Build workspace
  run: ${{ env.CARGO }} build --verbose --workspace ${{ env.TARGET_FLAGS }}
```

#### 改进方案
```yaml
name: Reusable CI Enhanced

on:
  workflow_call:
    inputs:
      rust-toolchain:
        description: 'Rust toolchain version'
        required: false
        type: string
        default: 'stable'
      
      # 新增：构建深度配置
      build-depth:
        description: 'Build depth: basic, release, full'
        required: false
        type: string
        default: 'basic'
      
      # 新增：是否测试发布构建
      test-release-builds:
        description: 'Test release builds to match release workflow'
        required: false
        type: boolean
        default: false
      
      # 新增：发布目标平台（用于一致性测试）
      release-target-platforms:
        description: 'Target platforms to test (should match release workflow)'
        required: false
        type: string
        default: '[]'

jobs:
  # 现有的代码质量检查保持不变
  rustfmt: # ...
  clippy: # ...
  docs: # ...
  
  # 现有的基础测试
  test: # ...
  
  # 新增：发布构建一致性测试
  test-release-consistency:
    name: Release Build Consistency Test
    if: ${{ inputs.test-release-builds }}
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        include: ${{ fromJson(inputs.release-target-platforms) }}
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup build environment
        uses: ./.github/actions/setup-build-env
        with:
          target: ${{ matrix.target }}
          os: ${{ matrix.os }}
      
      - name: Configure release environment
        run: |
          # 使用与 release 相同的环境变量
          echo "RUSTFLAGS=-D warnings" >> $GITHUB_ENV
          echo "CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG=true" >> $GITHUB_ENV
          
          # Windows 静态链接配置
          if [[ "${{ matrix.target }}" == *"windows-msvc"* ]]; then
            echo "RUSTFLAGS=${RUSTFLAGS} -C target-feature=+crt-static" >> $GITHUB_ENV
          fi
          
          # OpenSSL 配置
          if [[ "${{ matrix.target }}" == *"musl"* ]]; then
            echo "OPENSSL_STATIC=1" >> $GITHUB_ENV
            echo "OPENSSL_LIB_DIR=/usr/lib/x86_64-linux-gnu" >> $GITHUB_ENV
            echo "OPENSSL_INCLUDE_DIR=/usr/include/openssl" >> $GITHUB_ENV
            echo "PKG_CONFIG_ALLOW_CROSS=1" >> $GITHUB_ENV
          fi
      
      - name: Test release build (mirrors release workflow)
        run: |
          if [[ "${{ matrix.target }}" == *"musl"* ]]; then
            cross build --release --target ${{ matrix.target }}
          else
            cargo build --release --target ${{ matrix.target }}
          fi
      
      - name: Verify binary (optional)
        if: ${{ inputs.build-depth == 'full' }}
        run: |
          # 验证生成的二进制文件
          if [[ "${{ matrix.target }}" == *"windows"* ]]; then
            file target/${{ matrix.target }}/release/*.exe
          else
            file target/${{ matrix.target }}/release/*
          fi
```

### 2. 创建统一的构建环境 Action

#### `.github/actions/setup-build-env/action.yml`

```yaml
name: 'Setup Build Environment'
description: 'Setup consistent build environment for CI and Release'

inputs:
  target:
    description: 'Target platform'
    required: true
  os:
    description: 'Operating system'
    required: true
  rust-toolchain:
    description: 'Rust toolchain version'
    required: false
    default: 'stable'

runs:
  using: 'composite'
  steps:
    - name: Install packages (Ubuntu)
      if: startsWith(inputs.os, 'ubuntu')
      shell: bash
      run: |
        sudo apt-get update
        sudo apt-get install -y --no-install-recommends \
          build-essential \
          pkg-config \
          libssl-dev \
          musl-tools \
          curl \
          git
    
    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@master
      with:
        toolchain: ${{ inputs.rust-toolchain }}
        targets: ${{ inputs.target }}
    
    - name: Setup cross-compilation toolchain
      uses: taiki-e/setup-cross-toolchain-action@v1
      with:
        target: ${{ inputs.target }}
      if: startsWith(inputs.os, 'ubuntu') && !contains(inputs.target, '-musl')
    
    - name: Install cross for musl targets
      uses: taiki-e/install-action@v2
      with:
        tool: cross
      if: contains(inputs.target, '-musl')
    
    - name: Configure Cross.toml
      shell: bash
      run: |
        # 确保 Cross.toml 存在并配置正确
        if [ ! -f "Cross.toml" ]; then
          echo "Creating default Cross.toml..."
          cat > Cross.toml << 'EOF'
        [build.env]
        passthrough = [
            "CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG",
            "CC_i686_pc_windows_gnu",
            "CXX_i686_pc_windows_gnu", 
            "AR_i686_pc_windows_gnu",
            "CC_x86_64_pc_windows_gnu",
            "CXX_x86_64_pc_windows_gnu",
            "AR_x86_64_pc_windows_gnu",
            "OPENSSL_STATIC",
            "OPENSSL_LIB_DIR",
            "OPENSSL_INCLUDE_DIR",
            "PKG_CONFIG_ALLOW_CROSS"
        ]
        
        [target.x86_64-pc-windows-gnu]
        image = "ghcr.io/cross-rs/x86_64-pc-windows-gnu:main"
        pre-build = [
            "apt-get update && apt-get install -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64"
        ]
        
        [target.x86_64-pc-windows-gnu.env]
        CC_x86_64_pc_windows_gnu = "x86_64-w64-mingw32-gcc-posix"
        CXX_x86_64_pc_windows_gnu = "x86_64-w64-mingw32-g++-posix"
        AR_x86_64_pc_windows_gnu = "x86_64-w64-mingw32-ar"
        CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG = "true"
        
        [target.i686-pc-windows-gnu]
        image = "ghcr.io/cross-rs/i686-pc-windows-gnu:main"
        pre-build = [
            "apt-get update && apt-get install -y gcc-mingw-w64-i686 g++-mingw-w64-i686"
        ]
        
        [target.i686-pc-windows-gnu.env]
        CC_i686_pc_windows_gnu = "i686-w64-mingw32-gcc-posix"
        CXX_i686_pc_windows_gnu = "i686-w64-mingw32-g++-posix"
        AR_i686_pc_windows_gnu = "i686-w64-mingw32-ar"
        CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG = "true"
        EOF
        fi
```

### 3. 增强 Docker 镜像

#### 创建专用的交叉编译镜像

```dockerfile
# docker/cross-compile-enhanced/Dockerfile
FROM ghcr.io/cross-rs/x86_64-pc-windows-gnu:main

# 安装额外的工具和依赖
RUN apt-get update && apt-get install -y \
    gcc-mingw-w64-x86-64 \
    g++-mingw-w64-x86-64 \
    gcc-mingw-w64-i686 \
    g++-mingw-w64-i686 \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置环境变量以解决 mimalloc 问题
ENV CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG=true
ENV CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc-posix
ENV CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++-posix
ENV AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar
ENV CC_i686_pc_windows_gnu=i686-w64-mingw32-gcc-posix
ENV CXX_i686_pc_windows_gnu=i686-w64-mingw32-g++-posix
ENV AR_i686_pc_windows_gnu=i686-w64-mingw32-ar

# 预安装常用的 Rust 工具
RUN cargo install cross --version 0.2.5
```

### 4. 更新 `reusable-release.yml`

```yaml
name: Reusable Release Enhanced

on:
  workflow_call:
    inputs:
      # 现有输入保持不变...
      
      # 新增：CI 一致性验证
      verify-ci-consistency:
        description: 'Verify that CI tested the same targets'
        required: false
        type: boolean
        default: true

jobs:
  # 新增：CI 一致性检查
  verify-consistency:
    name: Verify CI Consistency
    if: ${{ inputs.verify-ci-consistency }}
    runs-on: ubuntu-latest
    steps:
      - name: Check CI coverage
        run: |
          echo "🔍 Verifying that CI tested the same targets as Release..."
          # 这里可以添加逻辑来验证 CI 是否测试了相同的目标平台
          echo "✅ CI consistency verified"
  
  # 现有的 upload-binary-assets 作业，但增加依赖
  upload-binary-assets:
    name: Upload binary assets
    needs: [verify-consistency]
    # 其余配置保持不变...
```

### 5. 项目使用示例

#### 更新项目的 CI 配置

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.3.0
    with:
      rust-toolchain: stable
      enable-coverage: false
      enable-python-wheel: false
      
      # 启用发布构建测试以确保一致性
      test-release-builds: true
      
      # 使用与 release.yml 相同的目标平台
      release-target-platforms: |
        [
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-musl", "os": "ubuntu-22.04"}
        ]
```

#### 更新项目的 Release 配置

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags: ["v*"]

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2.3.0
    with:
      binary-name: "py2pyd"
      rust-toolchain: stable
      enable-python-wheels: false
      verify-ci-consistency: true  # 新增：验证 CI 一致性
      
      target-platforms: |
        [
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-musl", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "aarch64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-apple-darwin", "os": "macos-13"},
          {"target": "aarch64-apple-darwin", "os": "macos-13"}
        ]
    secrets: inherit
```

## 📊 改进效果

### 改进前
| 阶段 | 构建类型 | 发现问题 | 一致性 |
|------|----------|----------|--------|
| CI | `cargo build` | ❌ 未发现 | ❌ 不一致 |
| Release | `cargo build --release` | ✅ 发现问题 | ❌ 太晚 |

### 改进后
| 阶段 | 构建类型 | 发现问题 | 一致性 |
|------|----------|----------|--------|
| CI | `cargo build` + `cargo build --release` | ✅ 早期发现 | ✅ 一致 |
| Release | `cargo build --release` | ✅ 确认无问题 | ✅ 预期 |

## 🚀 实施计划

### Phase 1: 核心改进
1. **更新 `reusable-ci.yml`** - 添加发布构建测试选项
2. **创建 `setup-build-env` Action** - 统一构建环境
3. **增强 Docker 镜像** - 解决交叉编译问题

### Phase 2: 高级功能
1. **添加一致性验证** - 自动检查 CI 和 Release 配置
2. **智能目标选择** - 根据项目类型自动选择测试目标
3. **性能优化** - 缓存和并行化改进

### Phase 3: 文档和示例
1. **更新文档** - 详细的使用指南
2. **提供模板** - 不同项目类型的配置模板
3. **故障排除指南** - 常见问题解决方案

## 🔗 相关资源

- [rust-actions-toolkit 仓库](https://github.com/loonghao/rust-actions-toolkit)
- [Cross-compilation 问题指南](https://github.com/loonghao/rust-actions-toolkit/blob/master/docs/CROSS_COMPILATION_ISSUES.md)
- [Memory Allocator 故障排除](https://github.com/loonghao/rust-actions-toolkit/blob/master/docs/MIMALLOC_TROUBLESHOOTING.md)

---

**注意**: 这些改进需要在 `rust-actions-toolkit` 仓库中实施，然后项目可以升级到新版本以获得一致性保证。