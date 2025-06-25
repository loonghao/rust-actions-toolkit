# 🦀 Rust Actions Toolkit

[![CI](https://github.com/loonghao/rust-actions-toolkit/workflows/CI/badge.svg)](https://github.com/loonghao/rust-actions-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/loonghao/rust-actions-toolkit.svg)](https://github.com/loonghao/rust-actions-toolkit/releases)

> 🚀 Rust 项目的通用 GitHub Actions 工具包 - CI/CD、跨平台构建、发布和 Python wheels

[中文文档](README_zh.md) | [English](README.md)

## ✨ 特性

- ✅ **纯 Rust crate** - 库 crate 的完整 CI/CD
- ✅ **二进制发布** - 跨平台编译和分发
- ✅ **Python wheels** - 使用 maturin 的 Rust + Python 集成
- ✅ **全面的 CI** - 代码质量、测试、安全、覆盖率
- ✅ **自动化发布** - 使用 release-plz 的版本管理
- ✅ **跨平台** - Linux、macOS、Windows（x86_64 + ARM64）
- ✅ **安全审计** - 自动化漏洞扫描
- ✅ **代码覆盖** - Codecov 集成

## 🚀 快速开始

### 1. 复制工作流文件

将工作流文件复制到你的 Rust 项目：

```bash
# 创建 .github/workflows 目录
mkdir -p .github/workflows

# 复制工作流文件
curl -o .github/workflows/ci.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/ci.yml
curl -o .github/workflows/release-plz.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release-plz.yml
curl -o .github/workflows/release.yml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/.github/workflows/release.yml
curl -o release-plz.toml https://raw.githubusercontent.com/loonghao/rust-actions-toolkit/main/release-plz.toml
```

### 2. 为你的项目配置

编辑 `release-plz.toml` 并更新包名：

```toml
[[package]]
name = "your-package-name"  # 改为你的实际包名
# ... 其余配置
```

### 3. 设置密钥

在你的 GitHub 仓库中添加这些密钥：

- `CARGO_REGISTRY_TOKEN` - 你的 crates.io API token
- `CODECOV_TOKEN` - 你的 Codecov token（可选）
- `RELEASE_PLZ_TOKEN` - 用于发布自动化的 GitHub PAT（可选）

### 4. 更新仓库所有者

在 `release-plz.yml` 中，更新仓库所有者检查：

```yaml
if: ${{ github.repository_owner == 'your-username' }}
```

## 📋 项目类型

### 纯 Rust Crate

对于没有二进制文件的库 crate：

1. 使用默认配置
2. 如需要，从 `release.yml` 中移除二进制相关部分
3. 专注于 `cargo test` 和文档

### 二进制 Crate

对于有可执行二进制文件的项目：

1. 确保你的 `Cargo.toml` 有 `[[bin]]` 部分
2. `upload-rust-binary-action` 会自动检测二进制名称
3. 跨平台二进制文件会自动构建

### Python Wheel 项目

对于有 Python 绑定的 Rust 项目：

1. 在项目中添加 `pyproject.toml`
2. 使用 maturin 进行 Python 集成
3. 当存在 `pyproject.toml` 时会自动构建 Python wheels

示例 `pyproject.toml`：

```toml
[build-system]
requires = ["maturin>=1.0,<2.0"]
build-backend = "maturin"

[project]
name = "your-python-package"
requires-python = ">=3.8"
```

## 🔧 配置

### CI 工作流 (`ci.yml`)

CI 工作流包括：

- **代码格式化** - `cargo fmt --check`
- **代码检查** - `cargo clippy`
- **文档检查** - `cargo doc`
- **测试** - 跨平台测试
- **安全审计** - `cargo audit`
- **代码覆盖** - `cargo llvm-cov`（仅 PR）
- **Python wheels** - 条件测试

### 发布工作流 (`release.yml`)

发布工作流支持：

- **二进制发布** - 跨平台编译
- **Python wheels** - 多平台 wheel 构建
- **资产上传** - 自动 GitHub 发布资产

### Release-plz (`release-plz.yml`)

自动化版本管理：

- **版本升级** - 语义化版本
- **变更日志生成** - 自动变更日志
- **Crates.io 发布** - 自动发布
- **GitHub 发布** - 发布创建

## 🎯 支持的项目

此工具包专为以下类型项目设计：

- **vx shimexe** - 二进制工具
- **py2pyd** - Python wheel 项目
- **rez-tools** - CLI 实用工具
- **rez-core** - 核心库

## 📚 示例

查看 `examples/` 目录获取完整项目设置：

- `pure-crate/` - 库 crate 示例
- `binary-crate/` - CLI 工具示例
- `python-wheel/` - Python 绑定示例

## 🤝 贡献

欢迎贡献！请阅读我们的[贡献指南](CONTRIBUTING.md)。

## 📄 许可证

此项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [release-plz 文档](https://release-plz.ieni.dev/)
- [Maturin 文档](https://www.maturin.rs/)
- [交叉编译指南](https://rust-lang.github.io/rustup/cross-compilation.html)
