#!/bin/bash


LOGDIR="logs"
CLEAN=0
TRACE=0
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# TODO: Make sure params can be in any order
#       e.g. decompile2.sh -c -l mylogs infolder outfolder
# TODO: Add argument for passing in a file list of specific .pyc files to process
# TODO: Add option for setting the base of the output folder (e.g. strip leading dirs from input path)

OUTPUT_DIR=""
INPUT_MODE=""
INPUT_DIR=""
IN_FILE_LIST=""
BASE_PATH=""

show_usage() {
    cat << 'EOF'
Usage: decompile2.sh [OPTIONS] --output-dir <dir> {--input-dir <dir>|--in-file-list <file>}

Decompile Python bytecode (.pyc) files to source code (.py) using multiple decompilers.

OPTIONS:
    --input-dir, -d <dir>       Specify input directory containing .pyc files
    --in-file-list, -i <file>   Specify file containing list of .pyc files to process
    --output-dir, -o <dir>      Specify output directory for decompiled .py files
    --base-path, -b <path>      When using --in-file-list, remove this prefix from each input file path to determine its relative output location
    --clean, -c                 Clean output directory before decompiling
    --trace, -t                 Output trace logs for failures (stores detailed error info)
    --logdir, -l <dir>          Specify log directory for decompilation logs (default: logs)
    --help, -h                  Show this help message

EXAMPLES:
    # Decompile all .pyc files in ea_compiled to lib/ea
    decompile2.sh --input-dir ea_compiled --output-dir lib/ea

    # Clean output and decompile with trace logging
    decompile2.sh -c -t --input-dir ea_compiled --output-dir lib/ea

    # Process specific files from a list
    decompile2.sh --in-file-list failed_files.txt --output-dir lib/ea

    # Use custom log directory
    decompile2.sh --logdir my_logs --input-dir ea_compiled --output-dir lib/ea

    # Use base path stripping for file list mode
    # Example: you have the following .pyc files in files.txt:
    #   ea_compiled/foo/bar/baz.pyc
    #   ea_compiled/foo/qux.pyc
    #
    # Run:
    #   decompile2.sh --in-file-list files.txt --output-dir /tmp/lib/ea --base-path ea_compiled
    #
    # Output:
    #   lib/ea/foo/bar/baz.py
    #   lib/ea/foo/qux.py
    decompile2.sh --in-file-list failed_files.txt --base-path ea_compiled --output-dir lib/ea

CONCRETE INPUT/OUTPUT EXAMPLE:

NOTES:
    - Files can also be piped via stdin if no input mode is specified
    - Logs are stored in timestamped subdirectories under the log directory
    - Multiple decompilers are tried in order: pycdc, uncompyle6, decompyle3, unpyc3
    - Use --trace to get detailed error information for failed decompilations

EOF
}


# Parse arguments for input mode
while [[ $# -gt 0 ]]; do
    case "$1" in
        # Show help
        --help|-h)
            show_usage
            exit 0
            ;;
        # Specify input directory for .pyc files
        --input-dir=*)
            INPUT_DIR="${1#--input-dir=}"            
            INPUT_MODE="dir"
            shift
            ;;
        # Specify input directory for .pyc files
        --input-dir|-d)
            INPUT_MODE="dir"
            INPUT_DIR="$2"
            shift 2
            ;;
        --in-file-list|-i)
            # Specify input file list for .pyc files
            INPUT_MODE="filelist"
            IN_FILE_LIST="$2"
            shift 2
            ;;
        --output-dir=*)
            # Specify output directory for decompiled .py files
            OUTPUT_DIR="${1#--output-dir=}"
            shift
            ;;
        --output-dir|-o)
            # Specify output directory for decompiled .py files
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --clean|-c)
            # Clean output directory before decompiling
            CLEAN=1
            shift
            ;;
        --trace|-t)
            # Output trace logs for failures
            TRACE=1
            shift
            ;;
        --logdir=*)
            # Specify log directory for decompilation logs
            LOGDIR="${1#--logdir=}"
            shift
            ;;
        --logdir|-l)        
            # Specify log directory for decompilation logs
            LOGDIR="$2"
            shift 2
            ;;
        --base-path=*)
            BASE_PATH="${1#--base-path=}"
            shift
            ;;
        --base-path|-b)
            BASE_PATH="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            # fallback for positional input_dir (legacy)
            if [[ -z "$INPUT_MODE" && -z "$INPUT_DIR" ]]; then
                INPUT_MODE="dir"
                INPUT_DIR="$1"
                shift
            else
                echo "Unexpected argument: $1"
                echo "Use --help for usage information"
                exit 1
            fi
            ;;
    esac
done

#if [[ -z "$INPUT_MODE" && -z "$INPUT_DIR" && -z "$IN_FILE_LIST" ]]; then
#    echo "Error: Must specify --input-dir or --in-file-list, or pipe in a list of files"
#    echo "Use --help for usage information"
#    exit 1
#fi

if [[ -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 [--clean|-c] [--logdir=<dir>|-l <dir>] [--output-dir=<dir>|-o <dir>] [--base-path=<path>|-b <path>] [--input-dir <dir>|-d <dir>|--in-file-list <file>|-i <file>] [input_folder]"
    echo "Use --help for usage information"
    exit 1
fi

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

    # Can expand this list with cmd line flags if required, and more tools
    local decompilers=("pycdc" "uncompyle6" "decompyle3" "unpyc3")
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
        # TODO: Retry with different flags for the compilers if needed
        if [[ "$decompiler" == "unpyc3" ]]; then
            # correct script name in repo
            cmd=(python3 /opt/unpyc37/unpyc3.py "$pyc_file")
            out="$("${cmd[@]}" 2>&1)"
            # write any stdout output to target file (overwrite)
            printf "%s\n" "$out" > "$output_file" 2>/dev/null || true
            status=$?
        elif [[ "$decompiler" == "pycdc" ]]; then
            # pycdc outputs to file, so use correct syntax
            cmd=(pycdc -o "$output_file" -v 3.7 "$pyc_file")
            out="$("${cmd[@]}" 2>&1)"
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

# Gather .pyc files to process based on input mode
pyc_files=()
if [[ "$INPUT_MODE" == "dir" && -n "$INPUT_DIR" ]]; then
    while IFS= read -r f; do
        pyc_files+=("$f")
    done < <(find "$INPUT_DIR" -type f -name "*.pyc")
elif [[ "$INPUT_MODE" == "filelist" && -n "$IN_FILE_LIST" ]]; then
    while IFS= read -r f; do
        [[ -n "$f" ]] && pyc_files+=("$f")
    done < "$IN_FILE_LIST"
else
    # Read from stdin
    while IFS= read -r f; do
        [[ -n "$f" ]] && pyc_files+=("$f")
    done
fi

for pyc_file in "${pyc_files[@]}"; do
    dir_path=$(dirname "$pyc_file")
    # Get relative path for output
    if [[ -n "$BASE_PATH" ]]; then
        rel_path="${dir_path#${BASE_PATH%/}/}"
    else
        rel_path="${dir_path#$INPUT_DIR/}"
    fi
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

