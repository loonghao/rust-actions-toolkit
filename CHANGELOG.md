# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.0.0](https://github.com/loonghao/rust-actions-toolkit/compare/rust-actions-toolkit-v4.0.0...rust-actions-toolkit-v5.0.0) (2026-03-21)


### ⚠ BREAKING CHANGES

* v4 rewrite with native-first architecture and AGENTS.md
* Removed complex cross-compilation features in favor of simple native compilation approach. Projects using advanced cross-compilation features will need to migrate to the simplified native build approach.
* Workflow names changed from reusable-* to core-*, enhanced-* Migration path provided, v3 remains supported
* None - this is a critical bug fix
* Removed support for i686-pc-windows-gnu target

### 🚀 Features

* add comprehensive GitHub Actions linting ([27c7d40](https://github.com/loonghao/rust-actions-toolkit/commit/27c7d4099b33f40f309fef905a1c0b6238f1d58e))
* add comprehensive memory allocator troubleshooting guides ([0512165](https://github.com/loonghao/rust-actions-toolkit/commit/0512165212d4dfef31b04231b36c783a1b420faa))
* add configurable Rust version support via GitHub Actions ([6cdae67](https://github.com/loonghao/rust-actions-toolkit/commit/6cdae67be7cebd765f3b0c7f9984b519316a3ec8))
* add GitHub Action for marketplace publishing ([da1279b](https://github.com/loonghao/rust-actions-toolkit/commit/da1279b6af88d3e1bf1d0eaa974fe0be6afe5c50))
* add minimal lib.rs for release-plz compatibility ([0744419](https://github.com/loonghao/rust-actions-toolkit/commit/0744419a5278a1d5605d41a689b25467d7d8a728))
* add release-plz GitHub Action and comprehensive best practices ([241bfe5](https://github.com/loonghao/rust-actions-toolkit/commit/241bfe5338552ca148ff02725da3c87db7cf70b7))
* add reusable workflows and composite actions ([a15adad](https://github.com/loonghao/rust-actions-toolkit/commit/a15adadc66a7b47727a063e53c8fb4b6937be4c6))
* add specialized upload-release-artifacts action for binaries and wheels ([1713fcb](https://github.com/loonghao/rust-actions-toolkit/commit/1713fcbf5e88c6862b6426cecdc33c5c08ecdeea))
* add zero-config smart-release action for ultimate simplicity ([f4686bc](https://github.com/loonghao/rust-actions-toolkit/commit/f4686bc7ca177739294f961ca5bf40aa17bb9d21))
* align smart-release with Docker targets and add release notes templates ([071f73a](https://github.com/loonghao/rust-actions-toolkit/commit/071f73af02750eb55bcfcd846703aac889236edc))
* complete dependency upgrades and cleanup obsolete documentation ([419d8a3](https://github.com/loonghao/rust-actions-toolkit/commit/419d8a3af75805596ee94dc5434106f162664dc6))
* comprehensive Docker support with zero-dependency builds ([c5c35a9](https://github.com/loonghao/rust-actions-toolkit/commit/c5c35a9cf9f29f57ed98ede5d34783f6dbe0beea))
* configure automated GitHub Actions publishing ([d9defac](https://github.com/loonghao/rust-actions-toolkit/commit/d9defacca1107da931d6b4140870840f61d2f160))
* enable release build consistency testing by default ([ccc174c](https://github.com/loonghao/rust-actions-toolkit/commit/ccc174c3581c90bbf7e631dc4d440e12c852d3ac))
* implement CI and Release consistency improvements ([21f2558](https://github.com/loonghao/rust-actions-toolkit/commit/21f2558c58f9277a89581b8224a3caa606994cc6))
* implement graceful failure handling and smart project detection ([a7b9137](https://github.com/loonghao/rust-actions-toolkit/commit/a7b913762d8238f0b0fe5e1a1cda89c0d3413350))
* initial release of rust actions toolkit ([af4fc3d](https://github.com/loonghao/rust-actions-toolkit/commit/af4fc3d6f8c4f0b0f63575315dd39dfddf8afb0b))
* optimize platform support strategy for 2025 ([6ced4d4](https://github.com/loonghao/rust-actions-toolkit/commit/6ced4d452a79f915597bb6a75b5c12b7ce6cc09c))
* rust-actions-toolkit v4.0.0 - complete redesign for simplicity ([e7988d7](https://github.com/loonghao/rust-actions-toolkit/commit/e7988d76b6320c9a400193ab59af07c68cfe7316))
* update all examples to v2 and showcase smart-release simplification ([2bb00ea](https://github.com/loonghao/rust-actions-toolkit/commit/2bb00ea2d6f3a892229a416048c7a4171a0c7ec5))
* upgrade renovate config to best practices and audit third-party actions ([87a6bb3](https://github.com/loonghao/rust-actions-toolkit/commit/87a6bb3d12efd4351b5f5f154b0c00abca075cdf))
* v4 rewrite with native-first architecture and AGENTS.md ([c999a77](https://github.com/loonghao/rust-actions-toolkit/commit/c999a77db0449e6db01cb4ec8d544aeb44205a84))


### 🐛 Bug Fixes

* add comprehensive Rust target support including macOS and Windows ([aa599d2](https://github.com/loonghao/rust-actions-toolkit/commit/aa599d29e35dff0ab55705e27baebe618b1454aa))
* add GitHub CLI installation to resolve 'gh: command not found' error ([2b4e133](https://github.com/loonghao/rust-actions-toolkit/commit/2b4e133e59a680f6649c9452a01c25afe616c616))
* add GitHub CLI to Docker base image and simplify release-plz workflow ([7aec46e](https://github.com/loonghao/rust-actions-toolkit/commit/7aec46ef5ce77052346115083bbfa6a62225d560))
* add packages write permission for Docker image publishing ([1221bd3](https://github.com/loonghao/rust-actions-toolkit/commit/1221bd394fa8942d9bfc09f656d45855c490d66f))
* change Rust version parameter from specific version to stable ([1e25646](https://github.com/loonghao/rust-actions-toolkit/commit/1e25646e58fe78536c6abcd2cb3dced63457a074))
* complete Chinese to English conversion in all workflow files ([e8565e1](https://github.com/loonghao/rust-actions-toolkit/commit/e8565e1abc748b1a9932db76397b696f5713c568))
* comprehensive OpenSSL cross-compilation support ([5e69407](https://github.com/loonghao/rust-actions-toolkit/commit/5e694070771f4ad791a81c01e3d9152615e952c5))
* convert hyphenated input names to underscore format in action.yml ([4b9c95c](https://github.com/loonghao/rust-actions-toolkit/commit/4b9c95c356cc71ee0d6e77ecb9cd0aaaa458f33c))
* correct CI trigger branches from main to master ([34b4455](https://github.com/loonghao/rust-actions-toolkit/commit/34b4455f7799799fc9ba439ef8cddb672c2857b1))
* correct external action versions to existing releases ([b69571e](https://github.com/loonghao/rust-actions-toolkit/commit/b69571e006c565e5eeb34410fc2b34141f757f6e))
* correct shellcheck directive placement in reusable-ci.yml ([fd820f3](https://github.com/loonghao/rust-actions-toolkit/commit/fd820f3e63bb90916f0a0dca88ebeb91cac25221))
* critical reusable workflow proc-macro protection ([f6f2e2a](https://github.com/loonghao/rust-actions-toolkit/commit/f6f2e2ae4990fdb607e4f0c0e4fc7eb249954705))
* docker permission issues in Cross.toml configurations ([facdca2](https://github.com/loonghao/rust-actions-toolkit/commit/facdca20183c90963557b4e12633635cdfd4951e))
* enhanced proc-macro cross-compilation protection ([8503e6b](https://github.com/loonghao/rust-actions-toolkit/commit/8503e6bc998ebf990cd93cc483d0c835e3a53286))
* handle missing cargo tools gracefully in security-audit image ([9780ec1](https://github.com/loonghao/rust-actions-toolkit/commit/9780ec1232e856bf16113acbd0d6e7e05e075996))
* improve Docker base image build reliability ([944269e](https://github.com/loonghao/rust-actions-toolkit/commit/944269eb119dec71711af713c2f2a385d010dba3))
* move setup-build-env action to correct location and fix workflow references ([74c59b5](https://github.com/loonghao/rust-actions-toolkit/commit/74c59b5c34232c2374eabec71bfdb6807bc358a1))
* optimize redirects in enhanced-release.yml build summary ([f201816](https://github.com/loonghao/rust-actions-toolkit/commit/f201816d2a78f44cc8431e0b3e514b7b1ddadfd1))
* remove dynamic uses expressions in composite action ([c84bde1](https://github.com/loonghao/rust-actions-toolkit/commit/c84bde17222323a25772ba9206ff2784d0a65ba6))
* remove hardcoded permissions from reusable workflows ([ad19fe2](https://github.com/loonghao/rust-actions-toolkit/commit/ad19fe2ba52f0dfb184098d38bb3120f231317fb))
* remove invalid GitHub Actions syntax in action.yml default value ([1084183](https://github.com/loonghao/rust-actions-toolkit/commit/108418356560395cec32c932e60996d11c53f169))
* remove remaining .github/actions directory ([f9ba6f2](https://github.com/loonghao/rust-actions-toolkit/commit/f9ba6f294ede407a687fa720c3855d8237fd4a64))
* remove workflows that reference deleted directories ([f992847](https://github.com/loonghao/rust-actions-toolkit/commit/f992847794100e91e789019303df7a67c6d98be9))
* replace Chinese comments with English in workflows and actions ([224add3](https://github.com/loonghao/rust-actions-toolkit/commit/224add343d692b0fe360569a6ddd8fc55aca35d1))
* resolve 'cannot produce proc-macro for target' error with simplified approach ([f22af85](https://github.com/loonghao/rust-actions-toolkit/commit/f22af8504bdb9bd74b21afba0509a47ee2290cab))
* resolve aarch64-linux-musl-gcc cross-compilation toolchain issues ([15b79ab](https://github.com/loonghao/rust-actions-toolkit/commit/15b79ab85cb5cd6fd4ccfd948ad7d696890f6b39))
* resolve actionlint errors - context availability and icon issues ([67ec4a6](https://github.com/loonghao/rust-actions-toolkit/commit/67ec4a685b4c9c382a23a93a898239b20be0e6ae))
* resolve all remaining shellcheck issues in reusable-ci.yml ([0877804](https://github.com/loonghao/rust-actions-toolkit/commit/0877804a10a8c74963db1c9a5fadabf5386e9f3c))
* resolve cargo permissions issues in all Docker images ([475762b](https://github.com/loonghao/rust-actions-toolkit/commit/475762b0f79c91c9f231309e41bc80667cb2eef7))
* resolve CARGO_BUILD_TARGET affecting CI tests ([7ba0747](https://github.com/loonghao/rust-actions-toolkit/commit/7ba0747e12436d346c1f3ee58e082ec6153d227b))
* resolve cargo-audit JSON parsing errors ([7c8a7c1](https://github.com/loonghao/rust-actions-toolkit/commit/7c8a7c181bc2b35407263eedcbc7a76c8a154c6d))
* resolve Docker ARG scope issue for RUST_VERSION ([68009e3](https://github.com/loonghao/rust-actions-toolkit/commit/68009e3986171fe19155b1f9d31b05c2773f7b23))
* resolve Docker user creation conflict in base image ([11c2632](https://github.com/loonghao/rust-actions-toolkit/commit/11c26321bfa1f86e6998149590c2b4897dd28513))
* resolve dtolnay/rust-toolchain empty toolchain parameter issue ([0923912](https://github.com/loonghao/rust-actions-toolkit/commit/092391263283a2346f5280fef6f26c1fb597112b))
* resolve GitHub Actions cascading failures and extract complex logic to scripts ([c13d1cb](https://github.com/loonghao/rust-actions-toolkit/commit/c13d1cb6fb6c48ed231f7e959124bfaa744049fa))
* resolve GITHUB_TOKEN system reserved name collision ([8cc7fd1](https://github.com/loonghao/rust-actions-toolkit/commit/8cc7fd1ff4a74ae8b01f19e6fe11779acc1a29fb))
* resolve hashFiles function error in release workflow ([469b954](https://github.com/loonghao/rust-actions-toolkit/commit/469b954b7af276ece8f155fd9e4a694fbb720194))
* resolve inputs context error in reusable-release-plz workflow ([c40ef54](https://github.com/loonghao/rust-actions-toolkit/commit/c40ef541f949070299867228a50b3de485ed918a))
* resolve OpenSSL compilation issues ([713219f](https://github.com/loonghao/rust-actions-toolkit/commit/713219f3e55963fad53a3016e4dc8ef7cf78c3ac))
* resolve pip upgrade conflicts in python-wheels Docker image ([138c15b](https://github.com/loonghao/rust-actions-toolkit/commit/138c15b126858a8322408b35faa868ed7f2701a7))
* resolve proc-macro cross-compilation issues ([83b6fe3](https://github.com/loonghao/rust-actions-toolkit/commit/83b6fe37ec6bbad59f3487d9d5a7230c52c9e262))
* resolve proc-macro cross-compilation issues in v2.5.0 ([2a5fab6](https://github.com/loonghao/rust-actions-toolkit/commit/2a5fab6ea9f23bb8d0ad12536e320c8224beeee6))
* resolve proc-macro cross-compilation issues with global RUSTFLAGS ([ddcbe43](https://github.com/loonghao/rust-actions-toolkit/commit/ddcbe43d46e0e8fc6305d2af16ebd5ca49c29e05))
* resolve remaining shell syntax and binary name detection issues ([5a7fda7](https://github.com/loonghao/rust-actions-toolkit/commit/5a7fda79cba2501fdc4fdfd6f4316f4ff112b654))
* resolve remaining shellcheck issues and add missing Action files ([e5428ac](https://github.com/loonghao/rust-actions-toolkit/commit/e5428acd85d1f323f5c9dab6412fc63decdaa0ef))
* resolve reusable workflow syntax errors ([1b8c687](https://github.com/loonghao/rust-actions-toolkit/commit/1b8c6871f4ead10b1ea57fb686c854482aeef792))
* resolve shellcheck warnings in reusable-release.yml - add quotes around variables ([7827a5f](https://github.com/loonghao/rust-actions-toolkit/commit/7827a5f1c39b0afdaa9e3990d50835256232aad1))
* resolve workflow robustness issues for cross-platform compatibility ([a8bc21f](https://github.com/loonghao/rust-actions-toolkit/commit/a8bc21f9f2117a9a66a1e07c75d124fa7b51f8f0))
* simplify base Docker image to only essential tools ([05722f2](https://github.com/loonghao/rust-actions-toolkit/commit/05722f23c3ba837e93e2f640fa28fc54def80031))
* simplify Docker images to avoid build failures ([e6ba36a](https://github.com/loonghao/rust-actions-toolkit/commit/e6ba36a218c906aea3bc843974ad6911c2df48e4))
* simplify python-wheels Docker image for Ubuntu 24.04 compatibility ([e20c8e5](https://github.com/loonghao/rust-actions-toolkit/commit/e20c8e5f5d40492b6efb5e41531c9524195a46fc))
* standardize README language conventions ([a361e13](https://github.com/loonghao/rust-actions-toolkit/commit/a361e1313732c4e8168df501ae0bc0195790c804))
* update CI workflow to work with simplified action structure ([d9e6e63](https://github.com/loonghao/rust-actions-toolkit/commit/d9e6e634c806ce8d3314ab3f32c7675dd5f98237))
* update Docker build workflow to use master branch ([40f25a6](https://github.com/loonghao/rust-actions-toolkit/commit/40f25a68d3b8da964d5acfb2bc4afa267fb5a12c))
* update security-audit image test to match installed tools ([1f75ad4](https://github.com/loonghao/rust-actions-toolkit/commit/1f75ad492141dae61d0e47a5d6f53ebca9595374))
* upgrade Rust version to 1.83.0 for dependency compatibility ([6c2b074](https://github.com/loonghao/rust-actions-toolkit/commit/6c2b0747e4c23fed9627da183aa71346e994bc4e))


### ⚡ Performance Improvements

* add comprehensive Docker cache optimization ([f915ad2](https://github.com/loonghao/rust-actions-toolkit/commit/f915ad2c5ebe71b01442c000d58b89c5e5c32aa1))
* optimize Docker build time and reduce complexity ([e0065b0](https://github.com/loonghao/rust-actions-toolkit/commit/e0065b040b611167b84c20e1636bdc9562adaccd))


### 📚 Documentation

* add Chinese setup documentation ([5dd7e4b](https://github.com/loonghao/rust-actions-toolkit/commit/5dd7e4bdeeffa274152e4149491681c968593fee))
* add comprehensive migration guide to v2.5.3 ([3966f68](https://github.com/loonghao/rust-actions-toolkit/commit/3966f68746102efc808b00c4b6cbbee18d93724e))
* add Docker images build status information ([3fcab4d](https://github.com/loonghao/rust-actions-toolkit/commit/3fcab4dae2e3dcc2c58fc129c0703069ba04b0bf))
* add Rust version configuration guide ([07fd97e](https://github.com/loonghao/rust-actions-toolkit/commit/07fd97eb4ec0cd8c09a2d117741c15d3148e8651))
* comprehensive documentation update and version alignment ([0aaf94c](https://github.com/loonghao/rust-actions-toolkit/commit/0aaf94c94a8443f3eeb8e16e091418c89f8d0a90))
* comprehensive documentation update for v2.5.3 best practices ([3382c37](https://github.com/loonghao/rust-actions-toolkit/commit/3382c3794f5101ed79faa9f5f5ca4447f701c725))
* recreate Docker status file with all fixes ([d6d8a5e](https://github.com/loonghao/rust-actions-toolkit/commit/d6d8a5e8bba0ad275df760714b3a5f4330c3b847))
* update all documentation to v2.5.6 and add release notes ([e62eb07](https://github.com/loonghao/rust-actions-toolkit/commit/e62eb073e4c26f37c34cda41490db31eb73b9929))
* update all examples with latest best practices ([6b6ad26](https://github.com/loonghao/rust-actions-toolkit/commit/6b6ad26e37b95a1729a01bf0d7e08757cc8e30ba))
* update Docker status with ARG scope fix ([18d8880](https://github.com/loonghao/rust-actions-toolkit/commit/18d8880fee84b18e38c1e3ce0a8ebe093e61edce))
* update Docker status with cargo permissions fix ([2ef7b8c](https://github.com/loonghao/rust-actions-toolkit/commit/2ef7b8ce48ee82e451925f50aeac53b0be54353a))
* update Docker status with GHCR permission fix ([823e8cd](https://github.com/loonghao/rust-actions-toolkit/commit/823e8cda8fd0fb33852c53cb16fac635fd1679f6))
* update Docker status with pip conflict resolution ([0e4b520](https://github.com/loonghao/rust-actions-toolkit/commit/0e4b52090c5893e4114432106b8765c74c7e783d))
* update Docker status with python-wheels compatibility fix ([92676cb](https://github.com/loonghao/rust-actions-toolkit/commit/92676cbe2bfd422bbe3cdab3b4ae687068ceefc2))
* update Docker status with Rust version upgrade ([80c9607](https://github.com/loonghao/rust-actions-toolkit/commit/80c9607c514d252286dacd6047f6cb9a0d106fad))
* update Docker status with security tool verification fix ([2f159d8](https://github.com/loonghao/rust-actions-toolkit/commit/2f159d8f86eb319f2789a86af3e60ce3906b203b))
* update Docker status with target and tool simplification ([ad79416](https://github.com/loonghao/rust-actions-toolkit/commit/ad7941678d3c53e03be99a198b69dc2d868d073f))
* update Docker status with test script fix ([98eba2e](https://github.com/loonghao/rust-actions-toolkit/commit/98eba2ea92d46ae1f33b017e889952eead785b72))
* update Docker status with user creation fix ([88da491](https://github.com/loonghao/rust-actions-toolkit/commit/88da491efc9d724ac6d64305b14aa02c036f8897))
* update example configurations to use v2.3.2 ([610accc](https://github.com/loonghao/rust-actions-toolkit/commit/610accc351ba1e5fa50c7bcb96f7f5ead270d97f))
* update README to reflect v2.5.5 proc-macro fixes ([958307a](https://github.com/loonghao/rust-actions-toolkit/commit/958307a368ec4bf524297b7b2960c49e8ce0d56a))
* update README with marketplace-style documentation ([ef490d6](https://github.com/loonghao/rust-actions-toolkit/commit/ef490d6b3ea95f55028832cc119a9e11eab1fba1))


### 🔧 Miscellaneous

* add .vscode directory and update .gitignore ([6f5cd9c](https://github.com/loonghao/rust-actions-toolkit/commit/6f5cd9c49eb004b4a79a69d5dba454006b937892))
* bump version to 2.0.1 ([0bb899f](https://github.com/loonghao/rust-actions-toolkit/commit/0bb899f46c54de1c7bbcf7f72c701ce2e3b55ae3))
* bump version to 2.0.2 ([ae6ea33](https://github.com/loonghao/rust-actions-toolkit/commit/ae6ea33f92ac54b71d9d181b606ebcdab173ac0f))
* **config:** migrate config renovate.json ([032b28f](https://github.com/loonghao/rust-actions-toolkit/commit/032b28fcb2436fd059c82d019e7914f880a8ea48))
* **deps:** update dependency node to v22 ([2233d98](https://github.com/loonghao/rust-actions-toolkit/commit/2233d9864cdf1ad8ade2d805fff3c76578b06ce4))
* **deps:** update dependency python to 3.13 ([0c12e03](https://github.com/loonghao/rust-actions-toolkit/commit/0c12e030ff56cc157aae7fb1e44ea568ccf83b7f))
* **deps:** update dependency python to 3.13 ([b3367e3](https://github.com/loonghao/rust-actions-toolkit/commit/b3367e36207ae5ad47bfcab86e7f9cfebb6468b3))
* **deps:** update docker/build-push-action action to v6 ([8abbae9](https://github.com/loonghao/rust-actions-toolkit/commit/8abbae9134c72638d091ec788d8ad75ce5e03d4d))
* **deps:** update ubuntu docker tag to v24 ([62167dd](https://github.com/loonghao/rust-actions-toolkit/commit/62167ddc2e3007d50dfffedf4c94e5b668184b79))
* prepare v3.0.0 release ([3adcf4c](https://github.com/loonghao/rust-actions-toolkit/commit/3adcf4c3974827857d3edd17aa951f45256f11a3))
* prepare v3.0.1 release ([b267df1](https://github.com/loonghao/rust-actions-toolkit/commit/b267df1f007c56098f80b61ad27b56a88721e71e))
* trigger Docker build workflow ([bc7cc7f](https://github.com/loonghao/rust-actions-toolkit/commit/bc7cc7fca197ded9c5806b8b0991bb8f674120b3))
* trigger Docker image build ([f3ca886](https://github.com/loonghao/rust-actions-toolkit/commit/f3ca88604d77444a9a2ac72778677746bf30d1cc))


### Code Refactoring

* simplify rust-actions-toolkit by removing cross-compilation complexity ([cd119e7](https://github.com/loonghao/rust-actions-toolkit/commit/cd119e72a6d7e864565cd3b280f4da0949409400))

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
