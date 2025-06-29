# 🦀 Rust Actions Toolkit

[![CI](https://github.com/loonghao/rust-actions-toolkit/workflows/CI/badge.svg)](https://github.com/loonghao/rust-actions-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/loonghao/rust-actions-toolkit.svg)](https://github.com/loonghao/rust-actions-toolkit/releases)
[![Marketplace](https://img.shields.io/badge/GitHub-Marketplace-blue.svg)](https://github.com/marketplace/actions/rust-actions-toolkit)

> 🚀 Rust 项目的通用 GitHub Actions 工具包，支持 CI/CD、跨平台构建、发布和 Python wheels

[中文文档](README_zh.md) | [English](README.md)

## ✨ 特性

- **🔍 代码质量**: 自动化格式检查、代码检查和文档检�?
- **🧪 测试**: �?Linux、macOS �?Windows 上进行跨平台测试
- **🔒 安全**: 使用 cargo-audit 进行自动化漏洞扫�?
- **📊 覆盖�?*: �?Codecov 集成的代码覆盖率报告
- **🚀 发布**: 跨平台二进制发布和自动上�?
- **🐍 Python**: Python wheel 构建和分�?
- **📦 发布**: 使用 release-plz 自动发布�?crates.io

## 🚀 快速开始

### 🌟 推荐：可重用工作流 (v2.5.3+)

**适用于：具有 CI/Release 一致性的现代项目**

创建 `.github/workflows/ci.yml`：
```yaml
name: CI
on: [push, pull_request]

permissions:
  contents: read
  actions: read

jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-ci.yml@v2.5.3
    with:
      rust-toolchain: stable
      # 🎯 关键：指定发布目标以进行一致性测试
      release-target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"}
        ]
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
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v2.5.3
    with:
      # 🎯 关键：使用与 CI 相同的目标以保持一致性
      target-platforms: |
        [
          {"target": "x86_64-unknown-linux-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-pc-windows-gnu", "os": "ubuntu-22.04"},
          {"target": "x86_64-unknown-linux-musl", "os": "ubuntu-22.04"}
        ]
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**✨ 您将获得：**
- ✅ **自动发布构建一致性测试** - CI 测试与发布完全相同的目标
- ✅ **早期交叉编译问题检测** - 在发布前发现问题
- ✅ **Proc-Macro 交叉编译支持** - 支持 serde、tokio、async-trait 等
- ✅ **零配置默认值** - 开箱即用的智能默认设置
- ✅ **全面的平台支持** - Linux、Windows、macOS、musl、ARM64

### 🔧 替代方案：单一 Action（传统方式）

**适用于：简单项目或渐进式迁移**

```yaml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: ci
```

### 跨平台发布

```yaml
name: Release
on:
  push:
    tags: ["v*"]
jobs:
  release:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: macos-latest
            target: x86_64-apple-darwin
          - os: windows-latest
            target: x86_64-pc-windows-msvc
    steps:
      - uses: actions/checkout@v4
      - uses: loonghao/rust-actions-toolkit@v2
        with:
          command: release
          target: ${{ matrix.target }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

## 📋 输入参数

| 输入 | 描述 | 必需 | 默认�?|
|------|------|------|--------|
| `command` | 运行的命令：`ci`、`release` �?`setup` | �?| `ci` |
| `rust-toolchain` | Rust 工具链版�?| �?| `stable` |
| `check-format` | 运行 cargo fmt --check（ci 命令�?| �?| `true` |
| `check-clippy` | 运行 cargo clippy（ci 命令�?| �?| `true` |
| `check-docs` | 运行 cargo doc（ci 命令�?| �?| `true` |
| `target` | 发布的目标平�?| �?| 自动检�?|
| `binary-name` | 要发布的二进制名�?| �?| 自动检�?|
| `github-token` | 用于上传�?GitHub token | �?| `${{ github.token }}` |

## 📤 输出

| 输出 | 描述 |
|------|------|
| `rust-version` | 安装�?Rust 版本 |
| `binary-path` | 构建的二进制文件路径（release 命令�?|
| `wheel-path` | 构建�?Python wheel 路径（release 命令�?|

## 🎯 支持的项目类�?

- **�?Rust Crate**: 发布�?crates.io 的库项目
- **二进�?Crate**: 带跨平台发布�?CLI 工具
- **Python Wheels**: 使用 maturin �?Rust + Python 绑定项目

## 🔧 配置

### CI 工作�?(`ci.yml`)

CI 工作流包括：

- **代码格式�?* - `cargo fmt --check`
- **代码检�?* - `cargo clippy`
- **文档检�?* - `cargo doc`
- **测试** - 跨平台测�?
- **安全审计** - `cargo audit`
- **代码覆盖** - `cargo llvm-cov`（仅 PR�?
- **Python wheels** - 条件测试

### 发布工作�?(`release.yml`)

发布工作流支持：

- **二进制发�?* - 跨平台编�?
- **Python wheels** - 多平�?wheel 构建
- **资产上传** - 自动 GitHub 发布资产

### Release-plz (`release-plz.yml`)

自动化版本管理：

- **版本升级** - 语义化版�?
- **变更日志生成** - 自动变更日志
- **Crates.io 发布** - 自动发布
- **GitHub 发布** - 发布创建

## 🎯 支持的项�?

此工具包专为以下类型项目设计�?

- **vx shimexe** - 二进制工�?
- **py2pyd** - Python wheel 项目
- **rez-tools** - CLI 实用工具
- **rez-core** - 核心�?

## 📚 示例

查看 `examples/` 目录获取完整项目设置�?

- `pure-crate/` - �?crate 示例
- `binary-crate/` - CLI 工具示例
- `python-wheel/` - Python 绑定示例

## ⚙️ 项目设置

### 必需文件

要在你的 Rust 项目中使用此工具包，你需要：

1. **Cargo.toml** - 标准 Rust 项目文件
2. **release-plz.toml** - 自动发布配置（可选）

### 必需密钥

在你�?GitHub 仓库中添加这些密钥：

- `CARGO_REGISTRY_TOKEN` - 你的 crates.io API token（用�?Rust crate 发布�?
- `CODECOV_TOKEN` - 你的 Codecov token（可选，用于覆盖率报告）
- `RELEASE_PLZ_TOKEN` - 用于发布自动化的 GitHub PAT（可选，增强功能�?

### 自动发布设置

此工具包使用 **release-plz** 进行自动版本管理。创�?`release-plz.toml` 文件�?

```toml
[workspace]
changelog_update = true
git_release_enable = false
git_tag_enable = true
release = true

[[package]]
name = "your-package-name"  # 改为你的包名
changelog_update = true
git_release_enable = true
release = true
git_tag_name = "v{{version}}"
git_release_draft = false
```

### 工作流程

1. **推送到 main** �?`release-plz.yml` 创建发布 PR
2. **合并发布 PR** �?`release-plz.yml` 创建标签�?GitHub 发布
3. **创建标签** �?`release.yml` 构建跨平台二进制文件
4. **上传二进制文�?* �?用户可以�?GitHub 发布页面下载

## 🤝 贡献

欢迎贡献！请阅读我们的[贡献指南](CONTRIBUTING.md)�?

## 📄 许可�?

此项目采�?MIT 许可�?- 查看 [LICENSE](LICENSE) 文件了解详情�?

## 🔗 链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [release-plz 文档](https://release-plz.ieni.dev/)
- [Maturin 文档](https://www.maturin.rs/)
- [交叉编译指南](https://rust-lang.github.io/rustup/cross-compilation.html)
