#!/bin/sh
set -e

if [ -d "/target" ]; then
    echo "========================================"
    echo "Antigravity CLI (agy) Multi-Platform Bundle"
    echo "========================================"
    echo "Target volume detected: /target"
    echo "Copying all binaries to your local machine..."
    
    # -p preserves file modes (executable permissions)
    cp -Rp /dist/* /target/
    
    echo "Done! The following directories have been created in your local path:"
    ls -l /target
    echo "========================================"
else
    echo "========================================"
    echo "Antigravity CLI (agy) Multi-Platform Bundle"
    echo "========================================"
    echo "This Docker image bundles the agy binary for all supported platforms:"
    echo "  - macOS (Intel 64-bit):   /dist/darwin-amd64/agy"
    echo "  - macOS (Apple Silicon):  /dist/darwin-arm64/agy"
    echo "  - Linux (Intel 64-bit):   /dist/linux-amd64/agy"
    echo "  - Linux (ARM 64-bit):     /dist/linux-arm64/agy"
    echo "  - Windows (64-bit):       /dist/windows-amd64/agy.exe"
    echo ""
    echo "To extract the binaries to your current directory, run:"
    echo "  docker run --rm -v \$(pwd):/target <image_name>"
    echo "========================================"
fi
