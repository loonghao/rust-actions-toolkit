#!/bin/bash
# Python wheels building script
# Usage: build-wheels.sh [python-versions] [additional-maturin-args]

set -euo pipefail

PYTHON_VERSIONS="${1:-3.8,3.9,3.10,3.11,3.12}"
shift || true
MATURIN_ARGS="$*"

echo "🐍 Building Python wheels for versions: $PYTHON_VERSIONS"
echo "📦 Additional maturin args: $MATURIN_ARGS"

# Check if pyproject.toml exists
if [[ ! -f "pyproject.toml" ]]; then
    echo "❌ pyproject.toml not found. This script requires a Python project with pyproject.toml"
    exit 1
fi

# Create wheels directory
mkdir -p wheels

# Build wheels for each Python version
IFS=',' read -ra VERSIONS <<< "$PYTHON_VERSIONS"
for version in "${VERSIONS[@]}"; do
    version=$(echo "$version" | tr -d ' ')
    echo "🔨 Building wheel for Python $version"
    
    # Determine Python executable
    case "$version" in
        3.8)
            PYTHON_EXE="/home/rust/.venv/py38/bin/python"
            MATURIN_EXE="/home/rust/.venv/py38/bin/maturin"
            ;;
        3.9)
            PYTHON_EXE="/home/rust/.venv/py39/bin/python"
            MATURIN_EXE="/home/rust/.venv/py39/bin/maturin"
            ;;
        3.10)
            PYTHON_EXE="/home/rust/.venv/py310/bin/python"
            MATURIN_EXE="/home/rust/.venv/py310/bin/maturin"
            ;;
        3.11)
            PYTHON_EXE="/home/rust/.venv/py311/bin/python"
            MATURIN_EXE="/home/rust/.venv/py311/bin/maturin"
            ;;
        3.12)
            PYTHON_EXE="/home/rust/.venv/py312/bin/python"
            MATURIN_EXE="/home/rust/.venv/py312/bin/maturin"
            ;;
        *)
            echo "⚠️  Unsupported Python version: $version, using system maturin"
            PYTHON_EXE="python$version"
            MATURIN_EXE="maturin"
            ;;
    esac
    
    # Check if Python version is available
    if [[ ! -x "$PYTHON_EXE" ]]; then
        echo "⚠️  Python $version not available, skipping"
        continue
    fi
    
    # Build wheel
    echo "📦 Using $PYTHON_EXE and $MATURIN_EXE"
    "$MATURIN_EXE" build \
        --release \
        --interpreter "$PYTHON_EXE" \
        --out wheels \
        $MATURIN_ARGS
    
    echo "✅ Wheel built for Python $version"
done

echo "🎉 All wheels built successfully!"
echo "📁 Wheels directory contents:"
ls -la wheels/

# Verify wheels
echo "🔍 Verifying wheels..."
for wheel in wheels/*.whl; do
    if [[ -f "$wheel" ]]; then
        echo "📦 $wheel"
        python3 -m zipfile -l "$wheel" | head -10
        echo "---"
    fi
done
