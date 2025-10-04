#!/bin/bash

INPUT_DIR="$1"
OUTPUT_DIR="$2"
LOGDIR="logs"
CLEAN=0
TRACE=0
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

if [[ -z "$INPUT_DIR" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 [--clean|-c] [--logdir=<dir>|-l <dir>] <input_folder> <output_folder>"
    exit 1
fi

# Parse arguments for --clean or -c
for arg in "$@"; do
    if [[ "$arg" == "--clean" || "$arg" == "-c" ]]; then
        CLEAN=1
        # Remove the flag from positional parameters
        set -- "${@/"$arg"}"
    fi
    if [[ "$arg" == "--trace" || "$arg" == "-t" ]]; then
        TRACE=1
        set -- "${@/"$arg"}"
    fi
done

# Parse arguments for --logdir or -l
for arg in "$@"; do
    if [[ "$arg" == --logdir=* ]]; then
        LOGDIR="${arg#--logdir=}"
        # Remove the flag from positional parameters
        set -- "${@/"$arg"}"
    elif [[ "$arg" == "-l" ]]; then
        shift
        LOGDIR="$1"
        shift
    fi
done

LOGFILE="$LOGDIR/$TIMESTAMP/decompile.log"
ERRLOG="$LOGDIR/$TIMESTAMP/error.log"
TRACELOGDIR="$LOGDIR/$TIMESTAMP/trace"
FAILLIST="$LOGDIR/$TIMESTAMP/fail.log"

# Create the trace log directory
mkdir -p "$TRACELOGDIR"

log_message() {
    local message="$1"
    local logfile="$2"
    local prefix="[$(date '+%Y-%m-%d %H:%M:%S')] "
    echo "$prefix $message" | tee -a "$logfile"
}

record_failure() {
    local pyc_file="$1"
    echo "$pyc_file" >> "$FAILLIST"
}

decompile_file() {
    local pyc_file="$1"
    local output_folder="$2"
    local logfile="$3"
    local errlog="$4"

    local decompilers=("uncompyle6" "decompyle3" "unpyc3")
    local success=0
    local is_original=1

    base_name=$(basename "$pyc_file" .pyc)
    local output_file="$output_folder/$base_name.py"

    # ensure logdir exists (defensive)
    mkdir -p "$(dirname "$errlog")"

    # Compute relative path for trace log filename
    local rel_path="${pyc_file#$INPUT_DIR/}"
    local trace_log_file="$TRACELOGDIR/${rel_path}.log"
    mkdir -p "$(dirname "$trace_log_file")"

    for decompiler in "${decompilers[@]}"; do
        log_message "DECOMPILING: $pyc_file with $decompiler" "$logfile"

        # build and run command, capturing combined stdout+stderr
        if [[ "$decompiler" == "unpyc3" ]]; then
            # correct script name in repo
            cmd=(python3 /opt/unpyc37/unpyc3.py "$pyc_file")
            out="$("${cmd[@]}" 2>&1)"
            # write any stdout output to target file (overwrite)
            printf "%s\n" "$out" > "$output_file" 2>/dev/null || true
            status=$?
        else
            cmd=("$decompiler" -o "$output_folder/" "$pyc_file")
            out="$("${cmd[@]}" 2>&1)"
            status=$?
        fi

        # decide success:
        # - nonzero exit -> fail
        # - OR output file missing/empty -> fail
        # - OR tool emitted known error strings -> fail (treat stderr content as error)
        if [[ $status -eq 0 && -s "$output_file" ]] && ! printf "%s" "$out" | grep -qiE "deparsing stopped|traceback|error"; then
            log_message "SUCCESS: $decompiler: $pyc_file -> $output_file" "$logfile"
            success=1
            break
        else
            log_message "ERROR: $decompiler: $pyc_file" "$errlog"
            # Only write the detailed error trace if TRACE is set
            if [[ $TRACE -eq 1 ]]; then
                # Ensure trace folder exists for this file
                mkdir -p "$(dirname "$trace_log_file")"
                {
                    printf "[%s %s] %s failed with %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$(basename "$pyc_file")" "$decompiler" "exit=$status"
                    printf "%s\n" "$out"
                    printf "\n"
                } >> "$trace_log_file"
            fi
        fi
        if [[ $success -eq 1 && $TRACE -eq 1 ]]; then
            # Clean trace, if it exists, as it's not needed
            rm -f "$trace_log_file"
            trace_log_dir="$(dirname "$trace_log_file")"
            if [[ -d "$trace_log_dir" && ! "$(ls -A "$trace_log_dir")" ]]; then
                rmdir "$trace_log_dir"
            fi
        fi
        is_original=0
    done

    if [[ $success -eq 0 ]]; then
        log_message "FAILED: All decompilers failed for $pyc_file" "$logfile"
        log_message "FAILED: All decompilers failed for $pyc_file" "$errlog"  
        record_failure "$pyc_file"
    fi
}

if [[ $CLEAN -eq 1 ]]; then
    log_message "Cleaning output directory: $OUTPUT_DIR" "$LOGFILE"
    rm -rf "$OUTPUT_DIR"
fi

log_message "Decompilation started at $TIMESTAMP" "$LOGFILE"

# Find all directories in INPUT_DIR containing .pyc files
find "$INPUT_DIR" -type f -name "*.pyc" | while read -r pyc_file; do
    dir_path=$(dirname "$pyc_file")
    # Get relative path from INPUT_DIR
    rel_path="${dir_path#$INPUT_DIR/}"
    # Create corresponding directory in OUTPUT_DIR if it doesn't exist
    if [[ ! -d "$OUTPUT_DIR/$rel_path" ]]; then
        mkdir -p "$OUTPUT_DIR/$rel_path"
        log_message "Created directory: $OUTPUT_DIR/$rel_path" "$LOGFILE"
    fi

    output_folder="$OUTPUT_DIR/$rel_path"
    base_name=$(basename "$pyc_file" .pyc)
    output_file="$output_folder/$base_name.py"
    if [[ ! -f "$output_file" ]]; then
        decompile_file "$pyc_file" "$output_folder" "$LOGFILE" "$ERRLOG"
    fi
done

log_message "Decompilation completed at $(date +%Y-%m-%d_%H-%M-%S)" "$LOGFILE"

