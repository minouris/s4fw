#!/bin/bash

# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Compile all Python files in src/ using a clean environment

set -e

SRC_DIR="src"
BUILD_DIR="build"

# Parse arguments
if [[ "$1" == "--clean" || "$1" == "-c" ]]; then
    rm -rf "$BUILD_DIR/*"
    echo "Build directory cleaned"
    exit 0
fi

# Check if src directory exists
if [[ ! -d "$SRC_DIR" ]]; then
    echo "ERROR: Source directory '$SRC_DIR' not found"
    exit 1
fi

# Clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Find and compile all Python files
find "$SRC_DIR" -name "*.py" -type f | while read py_file; do
    echo "Compiling: $py_file"
    py_dir=$(dirname "$py_file")
    env PYTHONPATH="" python3 -m py_compile "$py_file"
    # Move .pyc file up from __pycache__ and strip version suffix
    base_py=$(basename "$py_file" .py)
    pycache_dir="$py_dir/__pycache__"
    # Find the generated .pyc file (with version suffix)
    pyc_file=$(find "$pycache_dir" -maxdepth 1 -name "${base_py}.*.pyc" | head -n 1)
    if [[ -n "$pyc_file" ]]; then
        target_pyc="$py_dir/${base_py}.pyc"
        mv "$pyc_file" "$target_pyc"
        # Remove __pycache__ if empty
        rmdir --ignore-fail-on-non-empty "$pycache_dir"

        # Compute relative path from SRC_DIR
        rel_dir="${py_dir#$SRC_DIR/}"
        if [[ "$py_dir" == "$SRC_DIR" ]]; then
            rel_dir=""
        fi
        build_target_dir="$BUILD_DIR/$rel_dir"
        mkdir -p "$build_target_dir"
        mv "$target_pyc" "$build_target_dir/"
    fi
done

echo "Compilation completed"
