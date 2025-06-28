# 🔧 Rust Actions Toolkit 一致性改进项目

这个项目包含了对 [rust-actions-toolkit](https://github.com/loonghao/rust-actions-toolkit) 的一致性改进方案，旨在解决 CI 和 Release 工作流不一致导致的问题。

## 📋 项目背景

在使用 rust-actions-toolkit 时发现了一个关键问题：

- **CI 阶段**：只进行开发构建 (`cargo build`)，未发现交叉编译问题
- **Release 阶段**：进行发布构建 (`cargo build --release`)，暴露 `libmimalloc-sys` 等依赖问题
- **结果**：问题在 PR 阶段未被发现，在 Release 时才暴露

## 🎯 解决方案

### 核心改进

1. **增强 CI 工作流** - 添加发布构建测试以确保一致性
2. **统一构建环境** - 创建可重用的构建环境 Action
3. **增强 Docker 镜像** - 解决交叉编译和 mimalloc 问题
4. **配置验证** - 自动检查 CI 和 Release 配置一致性

### 文件结构

```
rust-release-action/
├── README.md                                    # 项目说明
├── rust-actions-toolkit-consistency-improvement.md  # 详细改进方案
└── examples/
    ├── setup-build-env-action.yml              # 统一构建环境 Action
    ├── enhanced-reusable-ci.yml                 # 增强的 CI 工作流
    ├── enhanced-dockerfile.dockerfile           # 增强的 Docker 镜像
    ├── project-ci-example.yml                  # 项目 CI 配置示例
    └── project-release-example.yml             # 项目 Release 配置示例
```

## 📚 文档说明

### 主要文档

- **[rust-actions-toolkit-consistency-improvement.md](rust-actions-toolkit-consistency-improvement.md)** - 完整的改进方案文档，包含：
  - 问题分析
  - 解决方案设计
  - 实施计划
  - 使用示例

### 示例文件

#### 1. [setup-build-env-action.yml](examples/setup-build-env-action.yml)
统一的构建环境设置 Action，提供：
- 跨平台构建环境配置
- 自动 Cross.toml 生成
- 环境变量统一设置
- 工具链验证

#### 2. [enhanced-reusable-ci.yml](examples/enhanced-reusable-ci.yml)
增强的可重用 CI 工作流，新增：
- 发布构建一致性测试
- 可配置的构建深度
- 严格模式支持
- CI 状态汇总

#### 3. [enhanced-dockerfile.dockerfile](examples/enhanced-dockerfile.dockerfile)
增强的 Docker 镜像，包含：
- mimalloc 兼容性修复
- 完整的交叉编译工具链
- 便捷脚本和验证工具
- 健康检查

#### 4. [project-ci-example.yml](examples/project-ci-example.yml)
项目 CI 配置示例，展示：
- 如何启用发布构建测试
- 目标平台一致性配置
- 项目特定检查
- 状态汇总

#### 5. [project-release-example.yml](examples/project-release-example.yml)
项目 Release 配置示例，包含：
- CI 一致性验证
- 发布后验证
- 通知和集成
- 文档自动更新

## 🚀 快速开始

### 1. 应用到现有项目

1. **更新 CI 配置**：
   ```yaml
   # .github/workflows/ci.yml
   jobs:
     ci:
       uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.3.0
       with:
         test-release-builds: true  # 启用发布构建测试
         release-target-platforms: |  # 与 release.yml 保持一致
           [
             {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
             {"target": "i686-pc-windows-gnu", "os": "ubuntu-22.04"}
           ]
   ```

2. **更新 Release 配置**：
   ```yaml
   # .github/workflows/release.yml
   jobs:
     release:
       uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2.3.0
       with:
         verify-ci-consistency: true  # 启用一致性验证
   ```

### 2. 创建构建环境 Action

复制 `examples/setup-build-env-action.yml` 到你的项目：
```bash
mkdir -p .github/actions/setup-build-env
cp examples/setup-build-env-action.yml .github/actions/setup-build-env/action.yml
```

### 3. 配置 Cross.toml

项目根目录创建或更新 `Cross.toml`：
```toml
[build.env]
passthrough = [
    "CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG",
    "CC_x86_64_pc_windows_gnu",
    "CXX_x86_64_pc_windows_gnu",
    "AR_x86_64_pc_windows_gnu"
]

[target.x86_64-pc-windows-gnu]
image = "ghcr.io/cross-rs/x86_64-pc-windows-gnu:main"

[target.x86_64-pc-windows-gnu.env]
CC_x86_64_pc_windows_gnu = "x86_64-w64-mingw32-gcc-posix"
CXX_x86_64_pc_windows_gnu = "x86_64-w64-mingw32-g++-posix"
AR_x86_64_pc_windows_gnu = "x86_64-w64-mingw32-ar"
CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG = "true"
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

## 🔗 相关资源

- [rust-actions-toolkit 仓库](https://github.com/loonghao/rust-actions-toolkit)
- [Cross-compilation 问题指南](https://github.com/loonghao/rust-actions-toolkit/blob/master/docs/CROSS_COMPILATION_ISSUES.md)
- [Memory Allocator 故障排除](https://github.com/loonghao/rust-actions-toolkit/blob/master/docs/MIMALLOC_TROUBLESHOOTING.md)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个方案！

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件。

---

**注意**: 这些改进需要在 `rust-actions-toolkit` 仓库中实施，然后项目可以升级到新版本以获得一致性保证。