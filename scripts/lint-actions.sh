#!/bin/bash
# GitHub Actions Lint Script
# This script can be used locally or in CI to validate GitHub Actions workflows

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if actionlint is installed
check_actionlint() {
    if ! command -v actionlint &> /dev/null; then
        print_status "Installing actionlint..."
        
        # Download and install actionlint
        if command -v curl &> /dev/null; then
            bash <(curl -s https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash)
        else
            print_error "curl is required to install actionlint"
            exit 1
        fi
        
        # Move to PATH
        if [ -f "./actionlint" ]; then
            if [ -w "/usr/local/bin" ]; then
                sudo mv ./actionlint /usr/local/bin/
            else
                mkdir -p "$HOME/.local/bin"
                mv ./actionlint "$HOME/.local/bin/"
                export PATH="$HOME/.local/bin:$PATH"
            fi
        fi
        
        print_success "actionlint installed successfully"
    else
        print_status "actionlint is already installed"
    fi
}

# Check if yq is installed
check_yq() {
    if ! command -v yq &> /dev/null; then
        print_status "Installing yq..."
        
        # Download and install yq
        if command -v wget &> /dev/null; then
            sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
        elif command -v curl &> /dev/null; then
            sudo curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq
            sudo chmod +x /usr/local/bin/yq
        else
            print_error "wget or curl is required to install yq"
            exit 1
        fi
        
        print_success "yq installed successfully"
    else
        print_status "yq is already installed"
    fi
}

# Validate YAML syntax
validate_yaml_syntax() {
    print_status "Validating YAML syntax..."
    
    local error_count=0
    
    # Check workflows
    for workflow in .github/workflows/*.yml; do
        if [ -f "$workflow" ]; then
            if ! yq eval '.' "$workflow" > /dev/null 2>&1; then
                print_error "Invalid YAML syntax in $workflow"
                ((error_count++))
            fi
        fi
    done
    
    # Check action files
    if [ -f "action.yml" ]; then
        if ! yq eval '.' action.yml > /dev/null 2>&1; then
            print_error "Invalid YAML syntax in action.yml"
            ((error_count++))
        fi
    fi
    
    for action_file in actions/*/action.yml; do
        if [ -f "$action_file" ]; then
            if ! yq eval '.' "$action_file" > /dev/null 2>&1; then
                print_error "Invalid YAML syntax in $action_file"
                ((error_count++))
            fi
        fi
    done
    
    # Check example files
    for example_file in examples/**/*.yml; do
        if [ -f "$example_file" ]; then
            if ! yq eval '.' "$example_file" > /dev/null 2>&1; then
                print_error "Invalid YAML syntax in $example_file"
                ((error_count++))
            fi
        fi
    done
    
    if [ $error_count -eq 0 ]; then
        print_success "All YAML files have valid syntax"
    else
        print_error "Found $error_count YAML syntax errors"
        return 1
    fi
}

# Run actionlint
run_actionlint() {
    print_status "Running actionlint..."
    
    if actionlint -verbose; then
        print_success "actionlint validation passed"
    else
        print_error "actionlint validation failed"
        return 1
    fi
}

# Run shellcheck integration
run_shellcheck() {
    print_status "Running actionlint with shellcheck integration..."
    
    # Check if shellcheck is available
    if command -v shellcheck &> /dev/null; then
        if actionlint -verbose -shellcheck=""; then
            print_success "shellcheck validation passed"
        else
            print_error "shellcheck validation failed"
            return 1
        fi
    else
        print_warning "shellcheck not found, skipping shell script validation"
        print_status "Install shellcheck for better validation: sudo apt-get install shellcheck"
    fi
}

# Check version consistency
check_version_consistency() {
    print_status "Checking version consistency in examples..."
    
    # Find all references to rust-actions-toolkit versions
    version_refs=$(grep -r "rust-actions-toolkit.*@v" examples/ 2>/dev/null || true)
    
    if [ -n "$version_refs" ]; then
        print_status "Found version references:"
        echo "$version_refs"
        
        # Get the latest version from git tags
        latest_version=$(git tag --sort=-version:refname | head -1 2>/dev/null || echo "v2.3.2")
        
        if echo "$version_refs" | grep -v "@$latest_version" | grep -q "@v"; then
            print_warning "Found outdated version references. Consider updating to $latest_version"
            echo "Outdated references:"
            echo "$version_refs" | grep -v "@$latest_version" | grep "@v"
        else
            print_success "All version references are up to date"
        fi
    else
        print_status "No version references found in examples"
    fi
}

# Main function
main() {
    print_status "Starting GitHub Actions lint validation..."
    
    # Check dependencies
    check_actionlint
    check_yq
    
    # Run validations
    validate_yaml_syntax
    run_actionlint
    run_shellcheck
    check_version_consistency
    
    print_success "All GitHub Actions validations completed successfully!"
}

# Run main function
main "$@"
