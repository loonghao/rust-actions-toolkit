# AGENTS.md — AI Agent Guide for rust-actions-toolkit

> This document is written for AI coding agents (Copilot, CodeBuddy, Claude, Cursor, etc.)
> to quickly understand this repository and make correct, context-aware changes.

## Project Identity

| Field | Value |
|-------|-------|
| **Name** | rust-actions-toolkit |
| **Purpose** | All-in-one GitHub Actions CI/CD toolkit for Rust projects |
| **Current Version** | 4.0.0 |
| **License** | MIT |
| **Owner** | loonghao (Hal) |
| **Repository** | `https://github.com/loonghao/rust-actions-toolkit` |
| **Primary Language** | YAML (GitHub Actions workflows), with a placeholder Rust crate |

## ⚠️ Critical Context

**This is NOT a Rust library.** The `Cargo.toml` and `src/lib.rs` exist **solely for release-please compatibility**. The actual deliverable is a set of GitHub Actions composite actions and reusable workflows defined in YAML.

Do **not**:
- Add Rust dependencies to `Cargo.toml`
- Write real Rust code in `src/lib.rs`
- Treat this as a crate that publishes to crates.io

---

## Architecture Overview

### Three-Layer Design (v4 Philosophy)

```
Layer 1: Core CI (core-ci.yml)
  └─ Target: 90% of Rust projects
  └─ Zero-config, single runner (Linux), fast & reliable

Layer 2: Reusable CI/Release (reusable-ci.yml, reusable-release.yml)
  └─ Target: Projects needing multi-platform support
  └─ Native builds (no cross-compilation), flexible

Layer 3: Advanced (future)
  └─ Target: <5% special cases
  └─ Cross-compilation, exotic platforms
```

### Design Principles

1. **Native-First** — Use GitHub native runners instead of cross-compilation
2. **Progressive Disclosure** — Start simple, add complexity only when needed
3. **Fail-Safe Defaults** — Zero-config should work out of the box
4. **Maintainability** — Minimize technical debt

---

## Repository Structure

```
rust-actions-toolkit/
├── action.yml                     # ★ Core composite action (GitHub Marketplace entry)
├── Cargo.toml                     # Placeholder for release-please (NOT a real crate)
├── src/lib.rs                     # Placeholder (NOT real code)
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                 # This project's own CI
│   │   ├── core-ci.yml            # ★ Reusable: Core CI (single runner)
│   │   ├── reusable-ci.yml        # ★ Reusable: Full CI (multi-platform)
│   │   ├── reusable-release.yml   # ★ Reusable: Multi-platform release
│   │   ├── reusable-release-plz.yml # ★ Reusable: release-plz automation
│   │   ├── release.yml            # This project's release workflow
│   │   ├── release-plz.yml        # This project's release-please workflow
│   │   └── publish-action.yml     # Publish to GitHub Marketplace
│   └── scripts/
│       ├── build-binary.sh        # Build binary for target platform
│       ├── detect-binary.sh       # Auto-detect binary name from Cargo.toml
│       ├── create-archive.sh      # Create platform-specific archives
│       ├── check-build-results.sh # Validate build outputs
│       ├── run-ci-checks.sh       # Standalone CI check script
│       └── setup-build-env.sh     # Build environment setup
│
├── docs/
│   ├── V4_DESIGN_PHILOSOPHY.md    # v4 architecture rationale
│   ├── V4_QUICK_START.md          # Quick start guide for v4
│   ├── BEST_PRACTICES.md          # Best practices for using the toolkit
│   └── DEVELOPER_GUIDE.md         # Contributing & development guide
│
├── examples/
│   ├── github-action/             # Examples using composite action
│   │   ├── simple-ci.yml
│   │   ├── complete-setup.yml
│   │   └── release-plz.yml
│   ├── reusable-workflows/        # Examples using reusable workflows
│   │   ├── ci.yml
│   │   ├── release.yml
│   │   └── release-plz.yml
│   ├── composite-actions/ci.yml   # Granular composite action usage
│   ├── pure-crate/                # Config template for pure Rust libraries
│   ├── binary-crate/              # Config template for CLI binaries
│   ├── python-wheel/              # Config for Rust+Python (maturin) projects
│   ├── security-audit/            # Security audit setup guide
│   ├── complete-project-setup/    # Full project setup walkthrough
│   ├── release-template.md        # Detailed release description template
│   └── simple-release-template.md # Simplified release template
│
├── README.md                      # English documentation
├── README_zh.md                   # Chinese documentation (must stay in sync)
├── USAGE.md                       # Detailed usage guide
├── MARKETPLACE.md                 # GitHub Marketplace description
├── CHANGELOG.md                   # Version history
├── release-please-config.json     # release-please configuration
├── .release-please-manifest.json  # Version manifest {"." : "4.0.0"}
├── renovate.json                  # Dependency auto-update config
└── .actionlint.yml                # Workflow linting config
```

### Files marked with ★ are the primary deliverables

---

## action.yml — The Core Action

The `action.yml` is a **composite action** (`runs: using: 'composite'`) with three command modes:

### Commands

| Command | Purpose | Key Steps |
|---------|---------|-----------|
| `ci` | Code quality & testing | fmt → clippy → doc-check → test (nextest optional) |
| `release` | Build & upload binaries | Build binary → upload via `taiki-e/upload-rust-binary-action` → optional Python wheels via maturin |
| `release-plz` | Automated versioning & publish | Version management → changelog → crates.io publish via `release-plz/action@v0.5` |

### Input Parameters (17 total)

**General:**
- `command` (required): `ci`, `release`, or `release-plz`
- `toolchain`: Rust toolchain version (default: `stable`)
- `cache`: Enable Rust caching (default: `true`)
- `sccache`: Enable sccache (default: `false`)
- `msvc`: Enable MSVC environment on Windows (default: `true`)
- `working-directory`: For workspace/monorepo projects

**CI-specific:**
- `format`: Run `cargo fmt --check` (default: `true`)
- `clippy`: Run clippy (default: `true`)
- `clippy-args`: Extra clippy arguments
- `docs`: Run doc checks (default: `true`)
- `nextest`: Use cargo-nextest (default: `false`)
- `audit`: Run security audit (default: `false`)
- `coverage`: Generate coverage report (default: `false`)
- `codecov-token`: Codecov upload token

**Release-specific:**
- `binary-name`: Override auto-detected binary name
- `python-wheels`: Build Python wheels (default: `false`)
- `token`: GitHub token for release operations

### Outputs

- `rust-version`: Installed Rust version
- `binary-path`: Path to built binary
- `wheel-path`: Path to built Python wheel
- `release-created`: Whether release-plz created a release
- `pr-created`: Whether release-plz created a PR
- `version`: Released version

---

## Reusable Workflows

### core-ci.yml (Layer 1)
- **Type**: `workflow_call`
- **Runner**: Single (default `ubuntu-22.04`)
- **Steps**: fmt → clippy → doc → test → audit → coverage → Codecov
- **Best for**: 90% of projects that only need Linux CI

### reusable-ci.yml (Layer 2)
- **Type**: `workflow_call`
- **Jobs**: check (Linux only) + test (cross-platform matrix) + audit + coverage + python-wheel
- **Note**: All steps are inlined (not `uses: ./`) to work when called from external repos

### reusable-release.yml (Layer 2)
- **Type**: `workflow_call`
- **Matrix**: 8 targets (Linux gnu/musl × x86_64/aarch64, macOS × x86_64/aarch64, Windows × x86_64/aarch64)
- **Features**: Platform-specific static linking, optional Python wheels

### reusable-release-plz.yml
- **Type**: `workflow_call`
- **Jobs**: `release-plz-release` (publish to crates.io) + `release-plz-pr` (create release PR)
- **Concurrency**: Controlled to prevent conflicts

---

## Key External Dependencies

| Action | Purpose | Version |
|--------|---------|---------|
| `dtolnay/rust-toolchain@master` | Install Rust toolchain | master |
| `Swatinem/rust-cache@v2` | Rust compilation caching | v2 |
| `mozilla-actions/sccache-action@v0.0.6` | sccache support | v0.0.6 |
| `ilammy/msvc-dev-cmd@v1` | MSVC environment setup | v1 |
| `taiki-e/upload-rust-binary-action@v1` | Binary upload to GitHub Release | v1 |
| `taiki-e/install-action@v2` | Install Rust tools (nextest, cargo-audit) | v2 |
| `release-plz/action@v0.5` | Automated release management | v0.5 |
| `softprops/action-gh-release@v2` | Upload wheels to GitHub Release | v2 |
| `codecov/codecov-action@v5` | Coverage report upload | v5 |
| `actions/checkout@v6` | Repository checkout | v6 |

---

## Supported Project Types

| Type | CI | Release | Example Config |
|------|-----|---------|----------------|
| Pure Rust library | fmt/clippy/test/doc/audit | crates.io via release-plz | `examples/pure-crate/` |
| Binary crate (CLI) | Same as above | Multi-platform native binaries | `examples/binary-crate/` |
| Workspace / Monorepo | `working-directory` support | Same as above | — |
| MSVC projects | Auto MSVC setup | Windows MSVC targets | — |
| Python wheels (maturin) | Rust CI + wheel build | Multi-platform wheels | `examples/python-wheel/` |

---

## Version Management

This project uses a **dual release system**:

1. **release-please** (via `release-plz.yml`) — manages the toolkit's own versioning
   - Config: `release-please-config.json`
   - Manifest: `.release-please-manifest.json`
   - Uses conventional commits for automatic changelog generation

2. **release-plz** (via `reusable-release-plz.yml`) — provided as a reusable workflow for downstream projects
   - Manages crates.io publishing for projects using this toolkit

### Version Bump Flow
1. Push conventional commits to `master`
2. release-please automatically creates/updates a release PR
3. Merging the PR triggers a GitHub Release
4. `publish-action.yml` creates/updates major version tag (e.g., `v4`)

---

## Conventions & Rules

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` — New feature (minor bump)
- `fix:` — Bug fix (patch bump)
- `feat!:` or `BREAKING CHANGE:` — Breaking change (major bump)
- `docs:`, `chore:`, `ci:`, `refactor:` — No version bump

### Documentation
- `README.md` (English) and `README_zh.md` (Chinese) **must stay in sync**
- Same structure, examples, and feature coverage in both languages
- Update both when making documentation changes

### Workflow Conventions
- Reusable workflows use `workflow_call` trigger
- All reusable workflows inline their steps (no `uses: ./` references) for external compatibility
- Use `actions/checkout@v6` and other v6 actions (current as of 2026)
- Shell scripts in `.github/scripts/` use `#!/bin/bash` with `set -euo pipefail`

### Testing
- The project's own CI (`ci.yml`) validates:
  - actionlint on all workflow files
  - action.yml schema validation
  - Cross-platform action execution (Linux, macOS, Windows)
  - Example configuration syntax
  - Documentation link checking

---

## Common Tasks for AI Agents

### Adding a new input parameter to action.yml
1. Add the input definition under `inputs:` with description, required flag, and default value
2. Wire it into the appropriate command section in `runs.steps`
3. Update `README.md` and `README_zh.md` parameter tables
4. Add relevant example in `examples/`
5. Update `USAGE.md` if it affects usage patterns

### Adding a new reusable workflow
1. Create `.github/workflows/reusable-<name>.yml` with `workflow_call` trigger
2. Define inputs/outputs/secrets at the workflow level
3. Inline all steps (no `uses: ./` references)
4. Add example in `examples/reusable-workflows/`
5. Document in `README.md`, `README_zh.md`, and `USAGE.md`

### Updating external action versions
1. Update the version in all workflow files that reference it
2. Check `renovate.json` for auto-update rules
3. Test across platforms if the action is platform-sensitive

### Modifying shell scripts
1. Scripts are in `.github/scripts/`
2. Must be POSIX-compatible bash (`#!/bin/bash`, `set -euo pipefail`)
3. Used by workflow steps via `bash .github/scripts/<name>.sh`
4. Test changes on all three platforms (Linux, macOS, Windows)

### Bumping the toolkit version
- Do **not** manually edit version numbers
- Push conventional commits; release-please handles the rest
- The version in `Cargo.toml` and `.release-please-manifest.json` are managed automatically

---

## File Dependency Graph

```
Downstream Rust projects
    │
    ├──► action.yml (composite action)
    │       └── references .github/scripts/*
    │
    ├──► .github/workflows/core-ci.yml
    ├──► .github/workflows/reusable-ci.yml
    ├──► .github/workflows/reusable-release.yml
    └──► .github/workflows/reusable-release-plz.yml

Internal (this repo only):
    .github/workflows/ci.yml          → validates action.yml + examples
    .github/workflows/release.yml     → triggered by v* tags
    .github/workflows/release-plz.yml → release-please automation
    .github/workflows/publish-action.yml → major version tag management
```

---

## Quick Reference: User-Facing Usage Patterns

### Pattern 1: Reusable Workflow (Recommended)
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: loonghao/rust-actions-toolkit/.github/workflows/core-ci.yml@v4
    with:
      toolchain: stable
```

### Pattern 2: Composite Action
```yaml
# Embed in existing workflow
- uses: loonghao/rust-actions-toolkit@v4
  with:
    command: ci
    toolchain: stable
    nextest: true
```

### Pattern 3: Multi-Platform Release
```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']
jobs:
  release:
    uses: loonghao/rust-actions-toolkit/.github/workflows/reusable-release.yml@v4
    with:
      binary-name: my-tool
```

---

## Gotchas & Edge Cases

1. **Windows MSVC**: Automatically enabled via `ilammy/msvc-dev-cmd@v1`. Set `msvc: false` to disable.
2. **Cross-compilation**: v4 uses native runners instead of cross-compilation. The `reusable-release.yml` uses `taiki-e/setup-cross-toolchain-action` only for Linux aarch64 targets.
3. **Python wheels**: Requires `maturin` and a valid `pyproject.toml`. Only built when `python-wheels: true`.
4. **Nextest**: Optional but recommended for large test suites. Set `nextest: true` to use it.
5. **sccache vs rust-cache**: They serve different purposes. `rust-cache` caches compiled dependencies; `sccache` caches individual compilation units. Usually `rust-cache` alone suffices.
6. **Release-plz vs release-please**: This project uses **release-please** for its own versioning. The **release-plz** reusable workflow is provided for downstream projects.
