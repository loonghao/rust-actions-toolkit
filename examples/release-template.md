# {{PROJECT_NAME}} {{VERSION}}

🎉 **New release of {{PROJECT_NAME}} is now available!**

## 📦 What's Included

This release provides pre-built binaries and packages for multiple platforms, making it easy to get started with {{PROJECT_NAME}}.

### 🔧 Binaries

Download the appropriate binary for your platform:

- **Windows**: `{{PROJECT_NAME}}-x86_64-pc-windows-gnu.zip`
- **Linux (GNU)**: `{{PROJECT_NAME}}-x86_64-unknown-linux-gnu.tar.gz`
- **Linux (musl)**: `{{PROJECT_NAME}}-x86_64-unknown-linux-musl.tar.gz` (static binary)
- **macOS (Intel)**: `{{PROJECT_NAME}}-x86_64-apple-darwin.tar.gz`
- **macOS (Apple Silicon)**: `{{PROJECT_NAME}}-aarch64-apple-darwin.tar.gz`

### 🐍 Python Packages

Install via pip:

```bash
pip install {{PROJECT_NAME}}
```

Or download wheels directly:
- **Linux x64**: `{{PROJECT_NAME}}-{{VERSION}}-cp311-cp311-linux_x86_64.whl`
- **Windows x64**: `{{PROJECT_NAME}}-{{VERSION}}-cp311-cp311-win_amd64.whl`
- **macOS**: `{{PROJECT_NAME}}-{{VERSION}}-cp311-cp311-macosx_10_9_x86_64.whl`

## 🚀 Quick Start

### Using the Binary

```bash
# Download and extract (replace {platform} with your platform)
curl -L https://github.com/{{REPOSITORY}}/releases/download/{{TAG_NAME}}/{{PROJECT_NAME}}-{platform}.tar.gz | tar xz

# Run the tool
./{{PROJECT_NAME}} --help
```

### Using Python Package

```bash
# Install
pip install {{PROJECT_NAME}}

# Use as module
python -m {{PROJECT_NAME}} --help

# Or use in Python code
import {{PROJECT_NAME}}
```

## 🔧 Installation Methods

### 📥 Direct Download

Visit the [releases page](https://github.com/{{REPOSITORY}}/releases/latest) and download the appropriate file for your platform.

### 🐍 Python Package Manager

```bash
# Install from PyPI
pip install {{PROJECT_NAME}}

# Install specific version
pip install {{PROJECT_NAME}}=={{VERSION}}

# Upgrade to latest
pip install --upgrade {{PROJECT_NAME}}
```

### 📦 Package Managers

```bash
# Homebrew (macOS/Linux)
brew install {{PROJECT_NAME}}

# Chocolatey (Windows)
choco install {{PROJECT_NAME}}

# Scoop (Windows)
scoop install {{PROJECT_NAME}}
```

## 🆕 What's New

<!-- Add your changelog content here -->

### ✨ New Features

- Feature 1: Description
- Feature 2: Description

### 🐛 Bug Fixes

- Fix 1: Description
- Fix 2: Description

### 🔧 Improvements

- Improvement 1: Description
- Improvement 2: Description

### ⚠️ Breaking Changes

- Breaking change 1: Description and migration guide
- Breaking change 2: Description and migration guide

## 🔗 Links

- 📖 [Documentation](https://github.com/{{REPOSITORY}}/blob/main/README.md)
- 🐛 [Report Issues](https://github.com/{{REPOSITORY}}/issues)
- 💬 [Discussions](https://github.com/{{REPOSITORY}}/discussions)
- 📝 [Changelog](https://github.com/{{REPOSITORY}}/blob/main/CHANGELOG.md)

## 🙏 Contributors

Thanks to all contributors who made this release possible!

<!-- GitHub will automatically add contributor list if generate_release_notes is enabled -->

---

**Full Changelog**: https://github.com/{{REPOSITORY}}/compare/v{{PREVIOUS_VERSION}}...{{TAG_NAME}}

> 💡 **Tip**: For the best experience, we recommend using the static musl builds on Linux as they have no dependencies and work on any distribution.
