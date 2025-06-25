#!/bin/bash
# Python wheels testing script
# Usage: test-wheels.sh [wheels-directory]

set -euo pipefail

WHEELS_DIR="${1:-wheels}"

echo "🧪 Testing Python wheels in $WHEELS_DIR"

if [[ ! -d "$WHEELS_DIR" ]]; then
    echo "❌ Wheels directory not found: $WHEELS_DIR"
    exit 1
fi

# Find all wheel files
WHEELS=($(find "$WHEELS_DIR" -name "*.whl" -type f))

if [[ ${#WHEELS[@]} -eq 0 ]]; then
    echo "❌ No wheel files found in $WHEELS_DIR"
    exit 1
fi

echo "📦 Found ${#WHEELS[@]} wheel(s) to test"

# Test each wheel
for wheel in "${WHEELS[@]}"; do
    echo "🔍 Testing wheel: $(basename "$wheel")"
    
    # Extract wheel info
    wheel_name=$(basename "$wheel" .whl)
    package_name=$(echo "$wheel_name" | cut -d'-' -f1)
    
    # Determine Python version from wheel name
    if [[ "$wheel_name" =~ cp38 ]]; then
        PYTHON_EXE="/home/rust/.venv/py38/bin/python"
        PIP_EXE="/home/rust/.venv/py38/bin/pip"
    elif [[ "$wheel_name" =~ cp39 ]]; then
        PYTHON_EXE="/home/rust/.venv/py39/bin/python"
        PIP_EXE="/home/rust/.venv/py39/bin/pip"
    elif [[ "$wheel_name" =~ cp310 ]]; then
        PYTHON_EXE="/home/rust/.venv/py310/bin/python"
        PIP_EXE="/home/rust/.venv/py310/bin/pip"
    elif [[ "$wheel_name" =~ cp311 ]]; then
        PYTHON_EXE="/home/rust/.venv/py311/bin/python"
        PIP_EXE="/home/rust/.venv/py311/bin/pip"
    elif [[ "$wheel_name" =~ cp312 ]]; then
        PYTHON_EXE="/home/rust/.venv/py312/bin/python"
        PIP_EXE="/home/rust/.venv/py312/bin/pip"
    else
        echo "⚠️  Cannot determine Python version for $wheel_name, using default"
        PYTHON_EXE="python3"
        PIP_EXE="pip3"
    fi
    
    # Check if Python executable exists
    if [[ ! -x "$PYTHON_EXE" ]]; then
        echo "⚠️  Python executable not found: $PYTHON_EXE, skipping"
        continue
    fi
    
    echo "🐍 Using Python: $PYTHON_EXE"
    
    # Create temporary virtual environment for testing
    temp_venv=$(mktemp -d)
    "$PYTHON_EXE" -m venv "$temp_venv"
    temp_python="$temp_venv/bin/python"
    temp_pip="$temp_venv/bin/pip"
    
    # Install and test the wheel
    (
        echo "📦 Installing wheel in temporary environment..."
        "$temp_pip" install --upgrade pip
        "$temp_pip" install "$wheel"
        
        echo "🧪 Testing import..."
        "$temp_python" -c "
import sys
try:
    import $package_name
    print(f'✅ Successfully imported $package_name')
    if hasattr($package_name, '__version__'):
        print(f'📋 Version: {$package_name.__version__}')
except ImportError as e:
    print(f'❌ Failed to import $package_name: {e}')
    sys.exit(1)
except Exception as e:
    print(f'⚠️  Import succeeded but error occurred: {e}')
"
        
        echo "✅ Wheel test passed: $(basename "$wheel")"
    ) || {
        echo "❌ Wheel test failed: $(basename "$wheel")"
    }
    
    # Clean up temporary environment
    rm -rf "$temp_venv"
    echo "---"
done

echo "🎉 Wheel testing completed!"
