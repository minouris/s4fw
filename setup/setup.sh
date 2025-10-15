#!/bin/bash

# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Setup script to detect Sims 4 installation and configure the development environment

S4FW_USER_DRIVE="c"
S4FW_APP_DRIVE="c"

S4FW_SIMS4_DOCS_PATH=""
S4FW_GAME_VERSION="1.116.240.10200"  # Default game version, update as necessary
S4FW_GAME_VERSION_FILE="GameVersion.txt"

# Prompt user for the drive their Documents folder is on
echo -e "\033[1;36m=== S4FW Setup: Sims 4 Environment Detection ===\033[0m"
read -rp $'\033[1;33mEnter the drive letter where your Documents folder is located (e.g., c, d, e): \033[0m' S4FW_USER_DRIVE
S4FW_USER_DRIVE="${S4FW_USER_DRIVE,,}" # convert to lowercase

S4FW_USER_DIRS=("/mnt/$S4FW_USER_DRIVE/Users")
DOC_PATH="Documents/Electronic Arts/The Sims 4/"
S4FW_APP_PATH=""

# Find all user folders under the possible Windows drives
S4FW_USER_FOLDERS=()
for base in "${S4FW_USER_DIRS[@]}"; do
    if [ -d "$base" ]; then
        for user in "$base"/*; do
            [ -d "$user" ] && S4FW_USER_FOLDERS+=("$user")
        done
    fi
done

# S4FW_USER_FOLDERS now contains all detected user directories

for folder in "${S4FW_USER_FOLDERS[@]}"; do
    if [ -d "$folder/$DOC_PATH" ]; then
        S4FW_SIMS4_DOCS_PATH="$folder/$DOC_PATH"
        break
    fi
done

if [ -n "$S4FW_SIMS4_DOCS_PATH" ] && [ -f "$S4FW_SIMS4_DOCS_PATH/$S4FW_GAME_VERSION_FILE" ]; then
    # Extract version number matching flexible dotted numeric sections
    S4FW_GAME_VERSION_EXTRACTED=($(grep -a -oE '([0-9]+\.)+[0-9]+' "$S4FW_SIMS4_DOCS_PATH/$S4FW_GAME_VERSION_FILE" | head -n 1))
    if [[ -n "$S4FW_GAME_VERSION_EXTRACTED" ]]; then
        S4FW_GAME_VERSION="$S4FW_GAME_VERSION_EXTRACTED"
    else
        echo -e "\033[1;31mCould not extract a valid game version from $S4FW_GAME_VERSION_FILE, using default: $S4FW_GAME_VERSION\033[0m"
    fi
else
    echo -e "\033[1;31m$S4FW_GAME_VERSION_FILE not found in $S4FW_SIMS4_DOCS_PATH, using default: $S4FW_GAME_VERSION\033[0m"
fi

S4FW_GAME_LAUNCHER_OPTIONS=("EA App:EA:1" "Origin:ORIGIN:2" "Steam:STEAM:3" "Epic Games:EPIC:4" "Other:OTHER:5")
S4FW_GAME_LAUNCHER_TYPE=""

echo -e "\033[1;36m=== Game Launcher Selection ===\033[0m"
echo -e "\033[1;33mWhat game launcher do you use for The Sims 4?:\033[0m\n"
for option in "${S4FW_GAME_LAUNCHER_OPTIONS[@]}"; do
    # Split on colon to access elements
    IFS=':' read -ra opt <<< "$option"
    echo -e "  ${opt[2]}) ${opt[0]}"
done
echo -e "\n"
read -rp $'\033[1;33mEnter the number corresponding to your game launcher: \033[0m' S4FW_GAME_LAUNCHER_SELECTION

S4FW_GAME_LAUNCHER_TYPE=$(echo "${S4FW_GAME_LAUNCHER_OPTIONS[S4FW_GAME_LAUNCHER_SELECTION-1]}" | cut -d':' -f2)
echo -e "\033[1;32mYou selected: $S4FW_GAME_LAUNCHER_TYPE\033[0m"

if [[ "$S4FW_GAME_LAUNCHER_TYPE" == "OTHER" ]]; then
    read -rp $'\033[1;33mPlease enter the installation folder of your game: \033[0m' S4FW_CUSTOM_LAUNCHER
    # Convert Windows path to Unix path if needed
    if [[ "$S4FW_CUSTOM_LAUNCHER" =~ ^([a-zA-Z]):\\ ]]; then
        drive_letter=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
        unix_path="/mnt/$drive_letter/$(echo "${S4FW_CUSTOM_LAUNCHER:3}" | tr '\\' '/')"
        S4FW_APP_PATH="$unix_path"
    else
        S4FW_APP_PATH="$S4FW_CUSTOM_LAUNCHER"
    fi
else    
    # Prompt user for the drive their Documents folder is on
    read -rp $'\033[1;33mEnter the drive letter where your Game folder is located (e.g., c, d, e): \033[0m' S4FW_APP_DRIVE
    S4FW_APP_DRIVE="${S4FW_APP_DRIVE,,}" # convert to lowercase
    APP_LEAF="The Sims 4"
    PROGRAM_FILES=("Program Files" "Program Files (x86)")
    # Determine APP_BASE based on launcher
    if [[ "$S4FW_GAME_LAUNCHER_TYPE" == "EA" ]]; then
        APP_BASE=("EA Games" "Electronic Arts")
    elif [[ "$S4FW_GAME_LAUNCHER_TYPE" == "ORIGIN" ]]; then
        APP_BASE=("Origin")
    elif [[ "$S4FW_GAME_LAUNCHER_TYPE" == "EPIC" ]]; then
        APP_BASE=("Epic Games")
    elif [[ "$S4FW_GAME_LAUNCHER_TYPE" == "STEAM" ]]; then
        APP_BASE=("Steam/steamapps/common")
    else
        APP_BASE=()
    fi

    # Iterate over candidate paths
    for pf in "${PROGRAM_FILES[@]}"; do
        for ab in "${APP_BASE[@]}"; do
            candidate="/mnt/$S4FW_APP_DRIVE/$pf/$ab/$APP_LEAF"
            if [ -d "$candidate" ]; then
                S4FW_APP_PATH="$candidate"
                break 2
            fi
        done
    done

    ATTEMPTS=0
    MAX_ATTEMPTS=5
    while [ -z "$S4FW_APP_PATH" ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        if [ $ATTEMPTS -gt 0 ]; then
            echo -e "\033[1;31mAttempt $((ATTEMPTS+1)) of $MAX_ATTEMPTS.\033[0m"
        fi
        echo -e "\033[1;31mCould not find The Sims 4 installation folder automatically.\033[0m"
        read -rp $'\033[1;33mPlease enter the installation folder of your game: \033[0m' S4FW_CUSTOM_LAUNCHER
        # Convert Windows path to Unix path if needed
        if [[ "$S4FW_CUSTOM_LAUNCHER" =~ ^([a-zA-Z]):\\ ]]; then
            drive_letter=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
            unix_path="/mnt/$drive_letter/$(echo "${S4FW_CUSTOM_LAUNCHER:3}" | tr '\\' '/')"
            S4FW_APP_PATH="$unix_path"
        else
            S4FW_APP_PATH="$S4FW_CUSTOM_LAUNCHER"
        fi
        if [ ! -d "$S4FW_APP_PATH" ]; then
            echo -e "\033[1;31mPath '$S4FW_APP_PATH' does not exist or is not a directory.\033[0m"
            S4FW_APP_PATH=""
        fi
        ATTEMPTS=$((ATTEMPTS+1))
    done

    if [ -z "$S4FW_APP_PATH" ]; then
        echo -e "\033[1;31mExceeded $MAX_ATTEMPTS attempts. Exiting setup.\033[0m"
        exit 1
    else
        echo -e "\033[1;32mDetected game installation at: $S4FW_APP_PATH\033[0m"
    fi
fi

S4FW_AUTHOR_NAME_UNFORMATTED=""
echo -e "\033[1;36m=== Mod Info Configuration ===\033[0m"
read -p $'\033[1;33mEnter your author name: \033[0m' S4FW_AUTHOR_NAME_UNFORMATTED
S4FW_MOD_NAME_UNFORMATTED=""
read -p $'\033[1;33mEnter the Mod name: \033[0m' S4FW_MOD_NAME_UNFORMATTED

# Lowercase and replace spaces with dots
S4FW_AUTHOR_NAME=$(echo "$S4FW_AUTHOR_NAME_UNFORMATTED" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')
S4FW_MOD_NAME=$(echo "$S4FW_MOD_NAME_UNFORMATTED" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')

# --- Template file processing from simple JSON ---

TEMPLATE_JSON="setup/template_files.json"

S4FW_EA_LIB_DIR="$S4FW_APP_PATH/Data/Simulation/Gameplay"
S4FW_MODS_DIR="$S4FW_SIMS4_DOCS_PATH/Mods"
S4FW_INCLUDE_DEVCONTAINER=1
S4FW_TEMPLATES=setup/.templates

# Export all variables used in template_files.json for envsubst
export S4FW_EA_LIB_DIR
export S4FW_MODS_DIR
export S4FW_INCLUDE_DEVCONTAINER
export S4FW_TEMPLATES
export S4FW_AUTHOR_NAME
export S4FW_MOD_NAME
export S4FW_GAME_VERSION

if [ ! -f "$TEMPLATE_JSON" ]; then
  echo "Template JSON file '$TEMPLATE_JSON' not found."
else
  # Use envsubst to expand all ${VARNAME} and $VARNAME placeholders
  template_json_expanded="$(envsubst < "$TEMPLATE_JSON")"
  echo "$template_json_expanded" > setup/templates_expanded.json
  # Remove newlines for easier parsing, then split on '},{'
  json_entries=$(echo "$template_json_expanded" | tr -d '\n' | awk '{
    gsub(/\}\s*,\s*\{/, "}\n{");
    print;
  }')
  while IFS= read -r entry; do
    # Extract fields using grep/sed
    input=$(echo "$entry" | sed -n 's/.*"input"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    target_dir=$(echo "$entry" | sed -n 's/.*"target_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    target_name=$(echo "$entry" | sed -n 's/.*"target_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    condition=$(echo "$entry" | sed -n 's/.*"condition"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    # Only process if condition is empty or "1", "true" (case-insensitive)
    cond_lc=$(echo "$condition" | tr '[:upper:]' '[:lower:]')
    if [[ -z "$cond_lc" || "$cond_lc" == "1" || "$cond_lc" == "true" ]]; then
      out_name="$target_name"
      [[ -z "$out_name" ]] && out_name="$(basename "$input")"
      out_dir="$target_dir"
      mkdir -p "$out_dir"
      cp "$input" "$out_dir/$out_name"
      # Parse values object
      values=$(echo "$entry" | sed -n 's/.*"values"[[:space:]]*:[[:space:]]*{\([^}]*\)}.*/\1/p')
      if [[ -n "$values" ]]; then
        echo "$values" | tr ',' '\n' | while IFS=: read -r k v; do
          key=$(echo "$k" | sed 's/[[:space:]]*"//g')
          # Trim whitespace from val
          val=$(echo "$v" | sed 's/[[:space:]]*"//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
          val_escaped=$(printf '%s\n' "$val" | sed 's/[\/&]/\\&/g')
          sed -i "s|$key|$val_escaped|g" "$out_dir/$out_name"
        done
      fi
      echo "Processed template: $input -> $out_dir/$out_name"
    fi
  done <<< "$json_entries"
fi

echo -e "\n\033[1;35m🎉 Setup complete! You may now launch your dev container and start developing your Sims 4 mod. Happy modding! 🚀\033[0m"


