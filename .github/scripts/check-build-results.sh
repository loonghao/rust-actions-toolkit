#!/bin/bash
set -euo pipefail

# Script to check build results and determine release readiness
# Usage: ./check-build-results.sh <platforms> <build-results-json>

PLATFORMS="${1:?Platforms list is required}"
BUILD_RESULTS="${2:-}"

echo "🔍 Checking build results for platforms: $PLATFORMS"

SUCCESS_COUNT=0
TOTAL_COUNT=0
FAILED_PLATFORMS=()
SUCCESS_PLATFORMS=()

# Parse platforms and count expected builds
IFS=',' read -ra PLATFORM_ARRAY <<< "$PLATFORMS"
for platform in "${PLATFORM_ARRAY[@]}"; do
    platform=$(echo "$platform" | xargs)  # trim whitespace
    
    case "$platform" in
        "linux")
            TOTAL_COUNT=$((TOTAL_COUNT + 1))
            echo "📋 Expected: Linux x86_64"
            ;;
        "macos")
            TOTAL_COUNT=$((TOTAL_COUNT + 2))  # x86_64 + aarch64
            echo "📋 Expected: macOS x86_64, macOS aarch64"
            ;;
        "windows")
            TOTAL_COUNT=$((TOTAL_COUNT + 1))
            echo "📋 Expected: Windows x86_64"
            ;;
        *)
            echo "⚠️ Warning: Unknown platform '$platform'"
            ;;
    esac
done

echo "📊 Total expected builds: $TOTAL_COUNT"

# Check artifacts directory to see what was actually built
if [ -d "artifacts" ]; then
    echo "📦 Checking available artifacts..."
    
    # Count successful artifacts
    for artifact in artifacts/*/; do
        if [ -d "$artifact" ] && [ "$(ls -A "$artifact")" ]; then
            artifact_name=$(basename "$artifact")
            echo "✅ Found artifact: $artifact_name"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            SUCCESS_PLATFORMS+=("$artifact_name")
        fi
    done
    
    # List any missing expected artifacts
    for platform in "${PLATFORM_ARRAY[@]}"; do
        platform=$(echo "$platform" | xargs)
        
        case "$platform" in
            "linux")
                if [ ! -d "artifacts/linux-x86_64" ] || [ ! "$(ls -A "artifacts/linux-x86_64" 2>/dev/null)" ]; then
                    FAILED_PLATFORMS+=("linux-x86_64")
                fi
                ;;
            "macos")
                if [ ! -d "artifacts/macos-x86_64" ] || [ ! "$(ls -A "artifacts/macos-x86_64" 2>/dev/null)" ]; then
                    FAILED_PLATFORMS+=("macos-x86_64")
                fi
                if [ ! -d "artifacts/macos-aarch64" ] || [ ! "$(ls -A "artifacts/macos-aarch64" 2>/dev/null)" ]; then
                    FAILED_PLATFORMS+=("macos-aarch64")
                fi
                ;;
            "windows")
                if [ ! -d "artifacts/windows-x86_64" ] || [ ! "$(ls -A "artifacts/windows-x86_64" 2>/dev/null)" ]; then
                    FAILED_PLATFORMS+=("windows-x86_64")
                fi
                ;;
        esac
    done
else
    echo "❌ No artifacts directory found"
fi

# Report results
echo ""
echo "📊 Build Results Summary:"
echo "✅ Successful builds: $SUCCESS_COUNT/$TOTAL_COUNT"

if [ ${#SUCCESS_PLATFORMS[@]} -gt 0 ]; then
    echo "✅ Successful platforms:"
    for platform in "${SUCCESS_PLATFORMS[@]}"; do
        echo "  - $platform"
    done
fi

if [ ${#FAILED_PLATFORMS[@]} -gt 0 ]; then
    echo "❌ Failed platforms:"
    for platform in "${FAILED_PLATFORMS[@]}"; do
        echo "  - $platform"
    done
fi

# Output for GitHub Actions
echo "success-count=$SUCCESS_COUNT" >> "$GITHUB_OUTPUT"
echo "total-count=$TOTAL_COUNT" >> "$GITHUB_OUTPUT"
echo "success-rate=$((SUCCESS_COUNT * 100 / TOTAL_COUNT))%" >> "$GITHUB_OUTPUT"

# Determine if we can proceed with release
if [ $SUCCESS_COUNT -eq 0 ]; then
    echo ""
    echo "❌ No successful builds - cannot create release"
    exit 1
elif [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    echo ""
    echo "🎉 All builds successful - ready for release!"
    echo "can-release=true" >> "$GITHUB_OUTPUT"
else
    echo ""
    echo "⚠️ Partial success - will create release with available artifacts"
    echo "can-release=true" >> "$GITHUB_OUTPUT"
fi
