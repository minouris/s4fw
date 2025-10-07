#!/bin/bash

# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Package compiled .pyc files into a .ts4script file for distribution

set -e

BUILD_DIR="build"
DIST_DIR="dist"
MOD_INFO_FILE="mod_info.json"

# Check if build directory exists
if [[ ! -d "$BUILD_DIR" ]]; then
    echo "ERROR: Build directory '$BUILD_DIR' not found. Run build.sh first."
    exit 1
fi

# Check if mod_info.json exists
if [[ ! -f "$MOD_INFO_FILE" ]]; then
    echo "ERROR: $MOD_INFO_FILE not found"
    exit 1
fi

# Extract mod info using basic shell tools
author=$(grep -o '"author":[[:space:]]*"[^"]*"' "$MOD_INFO_FILE" | cut -d'"' -f4)
name=$(grep -o '"name":[[:space:]]*"[^"]*"' "$MOD_INFO_FILE" | cut -d'"' -f4)
version=$(grep -o '"version":[[:space:]]*"[^"]*"' "$MOD_INFO_FILE" | cut -d'"' -f4)

if [[ -z "$author" || -z "$name" || -z "$version" ]]; then
    echo "ERROR: Could not extract author, name, or version from $MOD_INFO_FILE"
    echo "Found: author='$author', name='$name', version='$version'"
    exit 1
fi

# Create dist directory
mkdir -p "$DIST_DIR"

# Create filename
filename="${author}-${name}-${version}.ts4script"
output_file="$DIST_DIR/$filename"

echo "Packaging mod: $filename"
echo "  Author: $author"
echo "  Name: $name"
echo "  Version: $version"

# Create the zip file with .ts4script extension
cd "$BUILD_DIR"
zip -r "../$output_file" . -i "*.pyc"
cd ..

echo "Package created: $output_file"
