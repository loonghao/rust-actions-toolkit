#!/bin/bash
# Software Bill of Materials (SBOM) generation script
# Usage: generate-sbom.sh [format] [output-file]

set -euo pipefail

FORMAT="${1:-json}"
OUTPUT_FILE="${2:-sbom.$FORMAT}"

echo "📋 Generating Software Bill of Materials (SBOM)"
echo "📄 Format: $FORMAT"
echo "📁 Output: $OUTPUT_FILE"

# Create reports directory
mkdir -p security-reports

# Check if cargo-cyclonedx is available
if ! command -v cargo-cyclonedx >/dev/null 2>&1; then
    echo "📦 Installing cargo-cyclonedx..."
    cargo install cargo-cyclonedx --locked
fi

# Generate SBOM based on format
case "$FORMAT" in
    "json")
        echo "🔄 Generating CycloneDX JSON SBOM..."
        cargo cyclonedx --format json --output-file "security-reports/$OUTPUT_FILE"
        ;;
    "xml")
        echo "🔄 Generating CycloneDX XML SBOM..."
        cargo cyclonedx --format xml --output-file "security-reports/$OUTPUT_FILE"
        ;;
    "spdx")
        echo "🔄 Generating SPDX SBOM..."
        # Note: This requires additional tooling
        if command -v spdx-tools >/dev/null 2>&1; then
            cargo cyclonedx --format json --output-file "security-reports/temp-cyclonedx.json"
            # Convert CycloneDX to SPDX (if converter available)
            echo "⚠️  SPDX conversion not implemented yet, generating CycloneDX JSON instead"
            mv "security-reports/temp-cyclonedx.json" "security-reports/$OUTPUT_FILE"
        else
            echo "⚠️  SPDX tools not available, generating CycloneDX JSON instead"
            cargo cyclonedx --format json --output-file "security-reports/$OUTPUT_FILE"
        fi
        ;;
    *)
        echo "❌ Unsupported format: $FORMAT"
        echo "Supported formats: json, xml, spdx"
        exit 1
        ;;
esac

# Verify SBOM was generated
if [[ -f "security-reports/$OUTPUT_FILE" ]]; then
    echo "✅ SBOM generated successfully: security-reports/$OUTPUT_FILE"
    
    # Show SBOM summary
    echo "📊 SBOM Summary:"
    case "$FORMAT" in
        "json")
            if command -v jq >/dev/null 2>&1; then
                echo "📦 Components: $(jq '.components | length' "security-reports/$OUTPUT_FILE")"
                echo "🏷️  Metadata:"
                jq -r '.metadata.component | "  Name: \(.name)", "  Version: \(.version)", "  Type: \(.type)"' "security-reports/$OUTPUT_FILE"
            else
                echo "📄 File size: $(du -h "security-reports/$OUTPUT_FILE" | cut -f1)"
            fi
            ;;
        "xml")
            echo "📄 File size: $(du -h "security-reports/$OUTPUT_FILE" | cut -f1)"
            if command -v xmllint >/dev/null 2>&1; then
                echo "📦 Components: $(xmllint --xpath "count(//component)" "security-reports/$OUTPUT_FILE" 2>/dev/null || echo "N/A")"
            fi
            ;;
    esac
else
    echo "❌ Failed to generate SBOM"
    exit 1
fi

# Generate additional dependency information
echo "🔄 Generating additional dependency information..."

# Cargo tree output
cargo tree --format "{p} {l}" > "security-reports/dependency-tree.txt"

# License summary
if command -v cargo-license >/dev/null 2>&1; then
    cargo license --json > "security-reports/licenses.json"
    cargo license > "security-reports/licenses.txt"
else
    echo "⚠️  cargo-license not available, skipping license summary"
fi

# Dependency graph in DOT format
cargo tree --format "{p}" --prefix none | sort -u > "security-reports/dependencies-list.txt"

echo "📁 Generated files in security-reports/:"
ls -la security-reports/

echo "✅ SBOM generation completed!"
