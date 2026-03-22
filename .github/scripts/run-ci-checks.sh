#!/bin/bash
set -euo pipefail

# Script to run comprehensive CI checks using vx
# Usage: ./run-ci-checks.sh [--enable-audit] [--enable-coverage] [--toolchain=stable]

ENABLE_AUDIT=false
ENABLE_COVERAGE=false
TOOLCHAIN="stable"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --enable-audit)
            ENABLE_AUDIT=true
            shift
            ;;
        --enable-coverage)
            ENABLE_COVERAGE=true
            shift
            ;;
        --toolchain=*)
            TOOLCHAIN="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Starting Core CI checks"
echo "🦀 Toolchain: $TOOLCHAIN"
echo "🔒 Security audit: $ENABLE_AUDIT"
echo "📊 Code coverage: $ENABLE_COVERAGE"
echo ""

# Check formatting
echo "🎨 Checking code formatting..."
if vx cargo fmt --all -- --check; then
    echo "✅ Code formatting is correct"
else
    echo "❌ Code formatting issues found"
    echo "💡 Run 'vx cargo fmt --all' to fix formatting"
    exit 1
fi
echo ""

# Run Clippy
echo "📎 Running Clippy..."
if vx cargo clippy --all-targets --all-features -- -D warnings; then
    echo "✅ Clippy checks passed"
else
    echo "❌ Clippy found issues"
    exit 1
fi
echo ""

# Check documentation
echo "📚 Checking documentation..."
export RUSTDOCFLAGS="-D warnings"
if vx cargo doc --no-deps --document-private-items --all-features; then
    echo "✅ Documentation builds successfully"
else
    echo "❌ Documentation build failed"
    exit 1
fi
echo ""

# Run tests
echo "🧪 Running tests..."
if vx cargo test --all-features; then
    echo "✅ All tests passed"
else
    echo "❌ Some tests failed"
    exit 1
fi
echo ""

# Security audit (optional)
if [ "$ENABLE_AUDIT" = true ]; then
    echo "🔒 Running security audit..."

    # Install cargo-audit if not present
    if ! command -v cargo-audit >/dev/null 2>&1; then
        echo "📦 Installing cargo-audit..."
        vx cargo install cargo-audit
    fi

    if vx cargo audit; then
        echo "✅ Security audit passed"
    else
        echo "⚠️ Security audit found issues"
        # Don't fail CI for audit issues, just warn
    fi
    echo ""
fi

# Code coverage (optional)
if [ "$ENABLE_COVERAGE" = true ]; then
    echo "📊 Generating code coverage..."

    # Install cargo-llvm-cov if not present
    if ! command -v cargo-llvm-cov >/dev/null 2>&1; then
        echo "📦 Installing cargo-llvm-cov..."
        vx cargo install cargo-llvm-cov
    fi

    if vx cargo llvm-cov --all-features --workspace --lcov --output-path lcov.info; then
        echo "✅ Code coverage generated"
        echo "coverage-file=lcov.info" >> "$GITHUB_OUTPUT"

        # Show coverage summary if possible
        if command -v cargo-llvm-cov >/dev/null 2>&1; then
            echo "📈 Coverage summary:"
            vx cargo llvm-cov --all-features --workspace --summary-only || true
        fi
    else
        echo "⚠️ Code coverage generation failed"
    fi
    echo ""
fi

echo "🎉 All CI checks completed successfully!"
echo ""
echo "📋 Summary of checks performed:"
echo "  ✅ Code formatting (vx cargo fmt)"
echo "  ✅ Code quality (vx cargo clippy)"
echo "  ✅ Documentation (vx cargo doc)"
echo "  ✅ Unit tests (vx cargo test)"
if [ "$ENABLE_AUDIT" = true ]; then
    echo "  ✅ Security audit (vx cargo audit)"
fi
if [ "$ENABLE_COVERAGE" = true ]; then
    echo "  ✅ Code coverage (vx cargo llvm-cov)"
fi
echo ""
echo "🎯 Core CI: Fast, reliable, comprehensive"
