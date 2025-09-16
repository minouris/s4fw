#!/bin/bash
set -e
set -o pipefail

PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info[0]}.{sys.version_info[1]}')")
FULL_PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info[0]}.{sys.version_info[1]}.{sys.version_info[2]}')")
MAGIC_TABLE="\
3394 3.7\n\
3400 3.8\n\
3379 3.6\n\
3350 3.5\n\
3320 3.4\n\
3180 3.3\n\
3150 3.2\n\
3091 3.1\n\
3060 3.0\n"

log_event() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "error-$(date +%Y-%m-%d).log"
}

log_command_output() {
    while IFS= read -r line; do
        log_event "$line"
    done
}

get_pyc_version() {
    local pyc_file="$1"
    local magic_hex=$(head -c 2 "$pyc_file" | od -An -t u2 | tr -d ' ')
    local version="unknown"
    local output="Magic number: $magic_hex\n"
    while read line; do
        num=$(echo "$line" | awk '{print $1}')
        ver=$(echo "$line" | awk '{print $2}')
        if [[ "$magic_hex" == "$num" ]]; then
            version="$ver"
            output+="Detected Python version: $ver\n"
            break
        fi
    done <<< "$MAGIC_TABLE"
    if [[ "$version" == "unknown" ]]; then
        output+="Could not match magic number to known Python version."
    fi
    echo -e "$output"
    echo "$version"
}

# Unzip all zips in ea_api into ea_compiled
for zip in ea_api/*.zip; do
    name=$(basename "$zip" .zip)
    mkdir -p "ea_compiled/$name"
    unzip -o "$zip" -d "ea_compiled/$name" || log_event "Failed to unzip $zip"
    # Decompile all .pyc files in this folder
    find "ea_compiled/$name" -type f -name '*.pyc' | while read pyc; do
        outdir="lib/ea/$name"
        mkdir -p "$outdir"
        pyname=$(basename "$pyc" .pyc).py
        outfile="$outdir/$pyname"
        if [ -f "$outfile" ]; then
            log_event "Skipping $pyc (already decompiled)"
            continue
        fi
        # Capture stderr from uncompyle6
        err_output=$(mktemp)
        if ! uncompyle6 -o "$outdir" "$pyc" 2> "$err_output"; then
            log_event "Failed to decompile $pyc (nonzero exit code)"
        fi
        if [ -s "$err_output" ]; then
            log_event "Error output detected for $pyc, retrying with --verify run and --asm for diagnostics"
            cat "$err_output" | log_command_output
            uncompyle6 --verify run --verify syntax "$pyc" 2>&1 | log_command_output
            pyc_ver_output=$(get_pyc_version "$pyc")
            pyc_ver=$(echo "$pyc_ver_output" | tail -n1)
            if [[ "$pyc_ver" == "unknown" ]]; then
                log_event "$pyc_ver_output"
            elif [[ $(echo -e "$pyc_ver\n$PYTHON_VERSION" | sort -V | head -n1) != "$pyc_ver" ]]; then
                log_event "$pyc_ver_output"
                log_event "$pyc was compiled with Python $pyc_ver, which is newer than the current interpreter ($FULL_PYTHON_VERSION)"
            fi
        fi
        rm -f "$err_output"
    done
done

echo "Decompilation complete. See error-$(date +%Y-%m-%d).log for any errors."
