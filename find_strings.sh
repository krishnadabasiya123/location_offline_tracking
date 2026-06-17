#!/bin/bash

# Target directory
TARGET="/Users/harshilpindoriya/scripts"

# Check if directory exists
if [ ! -d "$TARGET" ]; then
    echo "Error: Directory $TARGET does not exist."
    exit 1
fi

echo "Extracting all strings from: $TARGET"
echo "=========================================================="

# Search for strings inside double quotes " " and single quotes ' '
# We exclude common hidden or large folders to keep results clean
grep -roE "\"([^\\\"]|\\.)*\"|'([^\\']|\\.)*'" "$TARGET" \
    --exclude-dir={.git,node_modules,vendor,dist,build}

echo "=========================================================="
echo "Done."
