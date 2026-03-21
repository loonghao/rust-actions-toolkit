# 🦀 Rust Actions Toolkit

[![CI](https://github.com/loonghao/rust-actions-toolkit/workflows/CI/badge.svg)](https://github.com/loonghao/rust-actions-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/loonghao/rust-actions-toolkit.svg)](https://github.com/loonghao/rust-actions-toolkit/releases)
[![Marketplace](https://img.shields.io/badge/GitHub-Marketplace-blue.svg)](https://github.com/marketplace/actions/rust-actions-toolkit)

> 🚀 简单且通用的 Rust 项目 GitHub Actions 工具包 - CI/CD、原生构建和发布

[中文文档](README_zh.md) | [English](README.md)

## ✨ 特性

- **🔍 代码质量**: 自动化格式检查、代码检查和文档检查
- **🧪 测试**: 在 Linux、macOS 和 Windows 上进行跨平台测试，支持可选的 `cargo-nextest`
- **🔒 安全**: 使用 `cargo-audit` 进行自动化漏洞扫描
- **📊 覆盖率**: 与 Codecov 集成的代码覆盖率报告
- **🚀 发布**: 多平台原生二进制发布和自动上传
- **🐍 Python**: 通过 maturin 进行可选的 Python wheel 构建和分发
- **📦 发布**: 使用 release-plz 自动发布到 crates.io（可重用工作流）
- **🏗️ 工作区**: 完整支持 Cargo workspace / monorepo 项目
- **⚡ MSVC**: 一流的 Windows MSVC 开发环境支持
- **🔧 sccache**: 可选的 sccache 加速大型项目编译

## 🚀 快速开始

### 🌟 推荐：可重用工作流

**适用于现代 Rust 项目的零配置方案**

创建 `.github/workflows/ci.yml`：
```yaml
name: CI
on: [push, pull_request]

permissions:
  contents: read

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      rust-toolchain: stable
```

创建 `.github/workflows/release.yml`：
```yaml
name: Release
on:
  push:
    tags: ['v*']

permissions:
  contents: write

jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@main
```

**✨ 开箱即用：**
- ✅ **多平台测试** - 自动在 Linux、macOS 和 Windows 上测试
- ✅ **原生编译** - 平台原生构建（无需复杂的交叉编译配置）
- ✅ **零配置** - 开箱即用的合理默认设置
- ✅ **安全审计** - 自动化漏洞扫描
- ✅ **二进制发布** - 多平台二进制自动上传到 GitHub Releases

### 🔧 替代方案：单一 Action

**适用于自定义工作流或特殊需求**

```yaml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: loonghao/rust-actions-toolkit@main
        with:
          command: ci
```

## 📋 输入参数

### 通用输入

| 输入 | 描述 | 必需 | 默认值 |
|------|------|------|--------|
| `command` | 运行的命令：`ci`、`release` 或 `release-plz` | 否 | `ci` |
| `rust-toolchain` | Rust 工具链版本 | 否 | `stable` |
| `working-directory` | cargo 命令的工作目录（工作区支持） | 否 | `.` |
| `cargo-features` | 要启用的 Cargo features（`"all"` 或逗号分隔列表） | 否 | `''` |
| `enable-cache` | 启用 Rust 编译缓存 | 否 | `true` |
| `enable-sccache` | 启用 sccache 加速编译 | 否 | `false` |
| `setup-msvc` | 在 Windows 上设置 MSVC 开发环境 | 否 | `false` |

### CI 输入

| 输入 | 描述 | 必需 | 默认值 |
|------|------|------|--------|
| `check-format` | 运行 `cargo fmt --check` | 否 | `true` |
| `check-clippy` | 运行 `cargo clippy` | 否 | `true` |
| `check-docs` | 运行 `cargo doc` | 否 | `true` |
| `clippy-args` | clippy 的额外参数 | 否 | `--all-targets -- -D warnings` |
| `use-nextest` | 使用 `cargo-nextest` 进行更快的并行测试 | 否 | `false` |
| `test-args` | 测试运行器的额外参数 | 否 | `''` |

### Release 输入

| 输入 | 描述 | 必需 | 默认值 |
|------|------|------|--------|
| `binary-name` | 要发布的二进制名称，逗号分隔 | 否 | 自动检测 |
| `enable-python-wheels` | 启用 Python wheel 构建 | 否 | `false` |
| `github-token` | 用于发布上传的 GitHub token | 否 | `''` |

## 📤 输出

| 输出 | 描述 |
|------|------|
| `rust-version` | 安装的 Rust 版本 |
| `binary-path` | 构建的二进制文件路径（release 命令） |
| `wheel-path` | 构建的 Python wheel 路径（release 命令） |

## 🎯 支持的项目类型

| 项目类型 | 特性 | 示例 |
|---------|------|------|
| **纯 Rust Crate** | CI + crates.io 发布 | 库项目 |
| **二进制 Crate** | CI + 多平台二进制发布 | CLI 工具如 [vx](https://github.com/loonghao/vx)、[clawup](https://github.com/loonghao/clawup) |
| **工作区 / Monorepo** | 支持 `working-directory` 的 CI | 多 crate 项目 |
| **MSVC 项目** | 带 MSVC 开发环境的 CI | Windows 原生工具如 [msvc-kit](https://github.com/loonghao/msvc-kit) |
| **Python Wheels** | CI + maturin wheel 构建 | Rust + Python 绑定如 [auroraview](https://github.com/loonghao/auroraview) |

## ⚙️ 可重用工作流选项

### 可重用 CI (`reusable-ci.yml`)

| 输入 | 描述 | 默认值 |
|------|------|--------|
| `rust-toolchain` | Rust 工具链版本 | `stable` |
| `working-directory` | 工作目录 | `.` |
| `cargo-features` | 要启用的 features | `''` |
| `use-nextest` | 使用 cargo-nextest | `false` |
| `enable-coverage` | 启用代码覆盖率 | `false` |
| `enable-audit` | 启用安全审计 | `true` |
| `enable-python-wheel` | 启用 Python wheel 测试 | `false` |
| `setup-msvc` | 在 Windows 上设置 MSVC | `false` |
| `test-platforms` | 测试运行器的 JSON 数组 | `["ubuntu-latest", "macos-latest", "windows-latest"]` |

### 可重用 Release (`reusable-release.yml`)

| 输入 | 描述 | 默认值 |
|------|------|--------|
| `binary-name` | 二进制名称 | 自动检测 |
| `enable-python-wheels` | 构建 Python wheels | `false` |
| `setup-msvc` | 在 Windows 上设置 MSVC | `false` |
| `target-platforms` | 构建目标的 JSON 数组 | 所有主要平台 |

### 可重用 Release-plz (`reusable-release-plz.yml`)

适用于使用 [release-plz](https://release-plz.ieni.dev/) 进行自动化版本管理和 crates.io 发布的项目。

## 📚 示例

### 工作区项目（如 clawup、vx）

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      use-nextest: true
      enable-coverage: true
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

### MSVC 项目（如 msvc-kit）

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      setup-msvc: true
      test-platforms: '["windows-latest"]'
```

### Python Wheel 项目（如 auroraview）

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@main
    with:
      enable-python-wheel: true
      enable-coverage: true
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@main
    with:
      enable-python-wheels: true
```

### 使用 release-plz 发布（crates.io 发布）

```yaml
# .github/workflows/release-plz.yml
name: Release-plz
on:
  push:
    branches: [main]
permissions:
  contents: write
  pull-requests: write
jobs:
  release-plz:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release-plz.yml@main
    secrets:
      CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
```

查看 `examples/` 目录获取更多完整项目设置。

## ⚙️ 项目设置

### 必需文件

在你的 Rust 项目中使用此工具包，只需要：

1. **Cargo.toml** - 标准 Rust 项目文件

### 可选密钥

根据需要在 GitHub 仓库中添加这些密钥：

- `CARGO_REGISTRY_TOKEN` - 你的 crates.io API token（通过 release-plz 发布时需要）
- `CODECOV_TOKEN` - 你的 Codecov token（覆盖率报告需要）

## 📚 文档

- [使用指南](USAGE.md) - 详细使用说明
- [示例](examples/) - 完整项目设置
- [最佳实践指南](docs/BEST_PRACTICES.md) - 如何有效使用此工具包

## 🤝 贡献

欢迎贡献！请阅读我们的[贡献指南](CONTRIBUTING.md)。

## 📄 许可证

此项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [release-please 文档](https://github.com/googleapis/release-please)
- [release-plz 文档](https://release-plz.ieni.dev/)
- [Maturin 文档](https://www.maturin.rs/)
