#!/bin/bash

# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Deploy packaged mod to the Sims 4 Mods folder

set -e

DIST_DIR="dist"
MOD_INFO_FILE="mod_info.json"
CONFIG_FILE="s4fw_config.json"

# Check if mod_info.json exists
if [[ ! -f "$MOD_INFO_FILE" ]]; then
    echo "ERROR: $MOD_INFO_FILE not found"
    exit 1
fi

# Extract mod info to build filename
author=$(grep -o '"author":[[:space:]]*"[^"]*"' "$MOD_INFO_FILE" | cut -d'"' -f4)
name=$(grep -o '"name":[[:space:]]*"[^"]*"' "$MOD_INFO_FILE" | cut -d'"' -f4)
version=$(grep -o '"version":[[:space:]]*"[^"]*"' "$MOD_INFO_FILE" | cut -d'"' -f4)

if [[ -z "$author" || -z "$name" || -z "$version" ]]; then
    echo "ERROR: Could not extract author, name, or version from $MOD_INFO_FILE"
    exit 1
fi

# Build expected filename
filename="${author}-${name}-${version}.ts4script"
package_file="$DIST_DIR/$filename"

# Check if package exists
if [[ ! -f "$package_file" ]]; then
    echo "ERROR: Package file not found: $package_file"
    echo "Run package.sh first to create the package"
    exit 1
fi

# Get mods path from config
if [[ -f "$CONFIG_FILE" ]]; then
    mods_path=$(grep -o '"mods_path":[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
else
    mods_path="mods"
fi

echo "Deploying $filename to $mods_path"
cp "$package_file" "$mods_path/"
echo "Deployment completed"
