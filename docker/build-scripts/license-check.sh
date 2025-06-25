#!/bin/bash
# License checking and compliance script
# Usage: license-check.sh [output-format] [allowed-licenses-file]

set -euo pipefail

OUTPUT_FORMAT="${1:-text}"
ALLOWED_LICENSES_FILE="${2:-}"

echo "📜 Running license compliance check"
echo "📄 Output format: $OUTPUT_FORMAT"

# Create reports directory
mkdir -p security-reports

# Install cargo-license if not available
if ! command -v cargo-license >/dev/null 2>&1; then
    echo "📦 Installing cargo-license..."
    cargo install cargo-license --locked
fi

# Default allowed licenses (permissive open source licenses)
DEFAULT_ALLOWED_LICENSES=(
    "MIT"
    "Apache-2.0"
    "Apache-2.0 WITH LLVM-exception"
    "BSD-2-Clause"
    "BSD-3-Clause"
    "ISC"
    "Unicode-DFS-2016"
    "Unlicense"
    "0BSD"
    "CC0-1.0"
)

# Default denied licenses (copyleft and proprietary)
DEFAULT_DENIED_LICENSES=(
    "GPL-2.0"
    "GPL-3.0"
    "LGPL-2.1"
    "LGPL-3.0"
    "AGPL-1.0"
    "AGPL-3.0"
    "EUPL-1.2"
    "OSL-3.0"
    "EPL-1.0"
    "EPL-2.0"
    "MPL-2.0"
    "CDDL-1.0"
    "CDDL-1.1"
)

# Load custom allowed licenses if file provided
if [[ -n "$ALLOWED_LICENSES_FILE" && -f "$ALLOWED_LICENSES_FILE" ]]; then
    echo "📋 Loading allowed licenses from: $ALLOWED_LICENSES_FILE"
    mapfile -t ALLOWED_LICENSES < "$ALLOWED_LICENSES_FILE"
else
    ALLOWED_LICENSES=("${DEFAULT_ALLOWED_LICENSES[@]}")
fi

# Generate license report
echo "🔄 Generating license report..."

case "$OUTPUT_FORMAT" in
    "json")
        cargo license --json > "security-reports/licenses.json"
        echo "📄 JSON license report saved to security-reports/licenses.json"
        ;;
    "csv")
        cargo license --tsv > "security-reports/licenses.tsv"
        echo "📄 TSV license report saved to security-reports/licenses.tsv"
        ;;
    "text"|*)
        cargo license > "security-reports/licenses.txt"
        echo "📄 Text license report saved to security-reports/licenses.txt"
        ;;
esac

# Analyze licenses for compliance
echo "🔍 Analyzing license compliance..."

# Get unique licenses
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    FOUND_LICENSES=($(jq -r '.[].license' "security-reports/licenses.json" | sort -u))
else
    FOUND_LICENSES=($(cargo license | tail -n +2 | awk '{print $NF}' | sort -u))
fi

echo "📋 Found licenses:"
printf '%s\n' "${FOUND_LICENSES[@]}"

# Check for denied licenses
DENIED_FOUND=()
for license in "${FOUND_LICENSES[@]}"; do
    for denied in "${DEFAULT_DENIED_LICENSES[@]}"; do
        if [[ "$license" == "$denied" ]]; then
            DENIED_FOUND+=("$license")
        fi
    done
done

# Check for unknown licenses
UNKNOWN_LICENSES=()
for license in "${FOUND_LICENSES[@]}"; do
    found_in_allowed=false
    for allowed in "${ALLOWED_LICENSES[@]}"; do
        if [[ "$license" == "$allowed" ]]; then
            found_in_allowed=true
            break
        fi
    done
    
    if [[ "$found_in_allowed" == false ]]; then
        # Check if it's in denied list
        found_in_denied=false
        for denied in "${DEFAULT_DENIED_LICENSES[@]}"; do
            if [[ "$license" == "$denied" ]]; then
                found_in_denied=true
                break
            fi
        done
        
        if [[ "$found_in_denied" == false ]]; then
            UNKNOWN_LICENSES+=("$license")
        fi
    fi
done

# Generate compliance report
{
    echo "# License Compliance Report"
    echo "Generated on: $(date)"
    echo ""
    
    echo "## Summary"
    echo "- Total unique licenses: ${#FOUND_LICENSES[@]}"
    echo "- Allowed licenses found: $((${#FOUND_LICENSES[@]} - ${#DENIED_FOUND[@]} - ${#UNKNOWN_LICENSES[@]}))"
    echo "- Denied licenses found: ${#DENIED_FOUND[@]}"
    echo "- Unknown licenses found: ${#UNKNOWN_LICENSES[@]}"
    echo ""
    
    if [[ ${#DENIED_FOUND[@]} -gt 0 ]]; then
        echo "## ❌ Denied Licenses Found"
        printf '- %s\n' "${DENIED_FOUND[@]}"
        echo ""
    fi
    
    if [[ ${#UNKNOWN_LICENSES[@]} -gt 0 ]]; then
        echo "## ⚠️  Unknown Licenses Found"
        printf '- %s\n' "${UNKNOWN_LICENSES[@]}"
        echo ""
    fi
    
    echo "## ✅ All Found Licenses"
    printf '- %s\n' "${FOUND_LICENSES[@]}"
    echo ""
    
    echo "## Allowed Licenses Policy"
    printf '- %s\n' "${ALLOWED_LICENSES[@]}"
    echo ""
    
    echo "## Denied Licenses Policy"
    printf '- %s\n' "${DEFAULT_DENIED_LICENSES[@]}"
    
} > "security-reports/license-compliance.md"

echo "📄 License compliance report saved to security-reports/license-compliance.md"

# Exit with error if denied licenses found
if [[ ${#DENIED_FOUND[@]} -gt 0 ]]; then
    echo "❌ License compliance check FAILED!"
    echo "Found denied licenses: ${DENIED_FOUND[*]}"
    exit 1
elif [[ ${#UNKNOWN_LICENSES[@]} -gt 0 ]]; then
    echo "⚠️  License compliance check completed with warnings"
    echo "Found unknown licenses: ${UNKNOWN_LICENSES[*]}"
    echo "Please review these licenses manually"
else
    echo "✅ License compliance check PASSED!"
    echo "All licenses are in the allowed list"
fi

echo "📁 License reports available in security-reports/ directory"
