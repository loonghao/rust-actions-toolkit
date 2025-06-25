#!/bin/bash
# Comprehensive security scanning script
# Usage: security-scan.sh [scan-type] [output-format]

set -euo pipefail

SCAN_TYPE="${1:-all}"
OUTPUT_FORMAT="${2:-text}"

echo "🔒 Running security scan: $SCAN_TYPE"
echo "📄 Output format: $OUTPUT_FORMAT"

# Create reports directory
mkdir -p security-reports

# Function to run cargo audit
run_audit() {
    echo "🔍 Running cargo audit..."
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        cargo audit --json > security-reports/audit.json 2>&1 || true
        echo "📄 Audit report saved to security-reports/audit.json"
    else
        cargo audit | tee security-reports/audit.txt || true
        echo "📄 Audit report saved to security-reports/audit.txt"
    fi
}

# Function to run cargo deny
run_deny() {
    echo "🚫 Running cargo deny..."
    if [[ -f "deny.toml" ]]; then
        cargo deny check 2>&1 | tee security-reports/deny.txt || true
    else
        echo "⚠️  No deny.toml found, creating default configuration..."
        cat > deny.toml << 'EOF'
[graph]
targets = []

[advisories]
db-path = "~/.cargo/advisory-db"
db-urls = ["https://github.com/rustsec/advisory-db"]
vulnerability = "deny"
unmaintained = "warn"
yanked = "warn"
notice = "warn"

[licenses]
unlicensed = "deny"
allow = [
    "MIT",
    "Apache-2.0",
    "Apache-2.0 WITH LLVM-exception",
    "BSD-2-Clause",
    "BSD-3-Clause",
    "ISC",
    "Unicode-DFS-2016",
]
deny = [
    "GPL-2.0",
    "GPL-3.0",
    "AGPL-1.0",
    "AGPL-3.0",
]

[bans]
multiple-versions = "warn"
wildcards = "allow"
highlight = "all"

[sources]
unknown-registry = "warn"
unknown-git = "warn"
allow-registry = ["https://github.com/rust-lang/crates.io-index"]
EOF
        cargo deny check 2>&1 | tee security-reports/deny.txt || true
    fi
    echo "📄 Deny report saved to security-reports/deny.txt"
}

# Function to run cargo geiger
run_geiger() {
    echo "☢️  Running cargo geiger (unsafe code detection)..."
    cargo geiger --format GitHubMarkdown > security-reports/geiger.md 2>&1 || true
    cargo geiger > security-reports/geiger.txt 2>&1 || true
    echo "📄 Geiger reports saved to security-reports/geiger.*"
}

# Function to run cargo outdated
run_outdated() {
    echo "📅 Running cargo outdated..."
    cargo outdated > security-reports/outdated.txt 2>&1 || true
    echo "📄 Outdated report saved to security-reports/outdated.txt"
}

# Function to run license check
run_license_check() {
    echo "📜 Running license check..."
    cargo license > security-reports/licenses.txt 2>&1 || true
    echo "📄 License report saved to security-reports/licenses.txt"
}

# Function to generate dependency tree
run_dependency_tree() {
    echo "🌳 Generating dependency tree..."
    cargo tree > security-reports/dependency-tree.txt 2>&1 || true
    cargo tree --duplicates > security-reports/duplicate-dependencies.txt 2>&1 || true
    echo "📄 Dependency reports saved to security-reports/dependency-*.txt"
}

# Function to run all scans
run_all() {
    echo "🔒 Running comprehensive security scan..."
    run_audit
    run_deny
    run_geiger
    run_outdated
    run_license_check
    run_dependency_tree
}

# Main execution
case "$SCAN_TYPE" in
    "audit")
        run_audit
        ;;
    "deny")
        run_deny
        ;;
    "geiger")
        run_geiger
        ;;
    "outdated")
        run_outdated
        ;;
    "licenses")
        run_license_check
        ;;
    "dependencies")
        run_dependency_tree
        ;;
    "all")
        run_all
        ;;
    *)
        echo "❌ Unknown scan type: $SCAN_TYPE"
        echo "Available scan types: audit, deny, geiger, outdated, licenses, dependencies, all"
        exit 1
        ;;
esac

echo "✅ Security scan completed!"
echo "📁 Reports available in security-reports/ directory:"
ls -la security-reports/
