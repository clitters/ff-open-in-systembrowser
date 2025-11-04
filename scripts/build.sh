#!/bin/bash
# Build script for ff-open-in-systembrowser Firefox addon

set -e

echo "Building Firefox addon..."

# Ensure we're in the project root
cd "$(dirname "$0")/.."

# Check if icons exist
if [ ! -f "src/icons/icon-48.png" ] || [ ! -f "src/icons/icon-96.png" ]; then
    echo "Warning: Icon files not found in src/icons/"
    echo "Please add icon-48.png and icon-96.png to src/icons/"
fi

# Check if node_modules exists, if not run npm install
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Clean previous build artifacts
echo "Cleaning previous builds..."
rm -rf dist/

# Build the extension
echo "Running web-ext build..."
npm run build

echo "Build complete! XPI file is in dist/"
ls -lh dist/*.xpi
