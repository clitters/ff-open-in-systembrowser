#!/bin/bash
# Package script for creating distributable XPI

set -e

echo "Packaging Firefox addon..."

# Ensure we're in the project root
cd "$(dirname "$0")/.."

# Get version from manifest.json
VERSION=$(grep -oP '"version":\s*"\K[^"]+' src/manifest.json)
echo "Version: $VERSION"

# Create dist directory if it doesn't exist
mkdir -p dist

# Create the XPI file
OUTPUT_FILE="dist/ff-open-in-systembrowser-${VERSION}.xpi"

echo "Creating XPI archive..."
cd src
zip -r "../${OUTPUT_FILE}" \
    manifest.json \
    background.js \
    content.js \
    icons/ \
    -x "*.DS_Store" "*.gitkeep"
cd ..

echo "Package created: ${OUTPUT_FILE}"
ls -lh "${OUTPUT_FILE}"

# Calculate SHA256 checksum
if command -v sha256sum &> /dev/null; then
    echo "SHA256 checksum:"
    sha256sum "${OUTPUT_FILE}"
elif command -v shasum &> /dev/null; then
    echo "SHA256 checksum:"
    shasum -a 256 "${OUTPUT_FILE}"
fi
