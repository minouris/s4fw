#!/bin/bash

# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Setup script to detect Sims 4 installation and configure the development environment

USER_DRIVE="c"
APP_DRIVE="c"

SIMS4_DOCS_PATH=""
GAME_VERSION="1.116.240.10200"  # Default game version, update as necessary
GAME_VERSION_FILE="GameVersion.txt"

# Prompt user for the drive their Documents folder is on
echo -e "\033[1;36m=== S4FW Setup: Sims 4 Environment Detection ===\033[0m"
read -rp $'\033[1;33mEnter the drive letter where your Documents folder is located (e.g., c, d, e): \033[0m' USER_DRIVE
USER_DRIVE="${USER_DRIVE,,}" # convert to lowercase

USER_DIRS=("/mnt/$USER_DRIVE/Users")
DOC_PATH="Documents/Electronic Arts/The Sims 4/"
APP_PATH=""

# Find all user folders under the possible Windows drives
USER_FOLDERS=()
for base in "${USER_DIRS[@]}"; do
    if [ -d "$base" ]; then
        for user in "$base"/*; do
            [ -d "$user" ] && USER_FOLDERS+=("$user")
        done
    fi
done

# USER_FOLDERS now contains all detected user directories

for folder in "${USER_FOLDERS[@]}"; do
    if [ -d "$folder/$DOC_PATH" ]; then
        SIMS4_DOCS_PATH="$folder/$DOC_PATH"
        break
    fi
done

if [ -n "$SIMS4_DOCS_PATH" ] && [ -f "$SIMS4_DOCS_PATH/$GAME_VERSION_FILE" ]; then
    # Extract version number matching flexible dotted numeric sections
    GAME_VERSION_EXTRACTED=($(grep -a -oE '([0-9]+\.)+[0-9]+' "$SIMS4_DOCS_PATH/$GAME_VERSION_FILE" | head -n 1))
    if [[ -n "$GAME_VERSION_EXTRACTED" ]]; then
        GAME_VERSION="$GAME_VERSION_EXTRACTED"
    else
        echo -e "\033[1;31mCould not extract a valid game version from $GAME_VERSION_FILE, using default: $GAME_VERSION\033[0m"
    fi
else
    echo -e "\033[1;31m$GAME_VERSION_FILE not found in $SIMS4_DOCS_PATH, using default: $GAME_VERSION\033[0m"
fi

# Fix the array syntax - bash doesn't support nested arrays like this
GAME_LAUNCHER_OPTIONS=("EA App:EA:1" "Origin:ORIGIN:2" "Steam:STEAM:3" "Epic Games:EPIC:4" "Other:OTHER:5")
GAME_LAUNCHER_TYPE=""

echo -e "\033[1;36m=== Game Launcher Selection ===\033[0m"
echo -e "\033[1;33mWhat game launcher do you use for The Sims 4?:\033[0m\n"
for option in "${GAME_LAUNCHER_OPTIONS[@]}"; do
    # Split on colon to access elements
    IFS=':' read -ra opt <<< "$option"
    echo -e "  ${opt[2]}) ${opt[0]}"
done
echo -e "\n"
read -rp $'\033[1;33mEnter the number corresponding to your game launcher: \033[0m' GAME_LAUNCHER_SELECTION

GAME_LAUNCHER_TYPE=$(echo "${GAME_LAUNCHER_OPTIONS[GAME_LAUNCHER_SELECTION-1]}" | cut -d':' -f2)
echo -e "\033[1;32mYou selected: $GAME_LAUNCHER_TYPE\033[0m"

if [[ "$GAME_LAUNCHER_TYPE" == "OTHER" ]]; then
    read -rp $'\033[1;33mPlease enter the installation folder of your game: \033[0m' CUSTOM_LAUNCHER
    # Convert Windows path to Unix path if needed
    if [[ "$CUSTOM_LAUNCHER" =~ ^([a-zA-Z]):\\ ]]; then
        drive_letter=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
        unix_path="/mnt/$drive_letter/$(echo "${CUSTOM_LAUNCHER:3}" | tr '\\' '/')"
        APP_PATH="$unix_path"
    else
        APP_PATH="$CUSTOM_LAUNCHER"
    fi
else    
    # Prompt user for the drive their Documents folder is on
    read -rp $'\033[1;33mEnter the drive letter where your Game folder is located (e.g., c, d, e): \033[0m' APP_DRIVE
    APP_DRIVE="${APP_DRIVE,,}" # convert to lowercase
    APP_LEAF="The Sims 4"
    PROGRAM_FILES=("Program Files" "Program Files (x86)")
    # Determine APP_BASE based on launcher
    if [[ "$GAME_LAUNCHER_TYPE" == "EA" ]]; then
        APP_BASE=("EA Games" "Electronic Arts")
    elif [[ "$GAME_LAUNCHER_TYPE" == "ORIGIN" ]]; then
        APP_BASE=("Origin")
    elif [[ "$GAME_LAUNCHER_TYPE" == "EPIC" ]]; then
        APP_BASE=("Epic Games")
    elif [[ "$GAME_LAUNCHER_TYPE" == "STEAM" ]]; then
        APP_BASE=("Steam/steamapps/common")
    else
        APP_BASE=()
    fi

    # Iterate over candidate paths
    for pf in "${PROGRAM_FILES[@]}"; do
        for ab in "${APP_BASE[@]}"; do
            candidate="/mnt/$APP_DRIVE/$pf/$ab/$APP_LEAF"
            if [ -d "$candidate" ]; then
                APP_PATH="$candidate"
                break 2
            fi
        done
    done

    ATTEMPTS=0
    MAX_ATTEMPTS=5
    while [ -z "$APP_PATH" ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        if [ $ATTEMPTS -gt 0 ]; then
            echo -e "\033[1;31mAttempt $((ATTEMPTS+1)) of $MAX_ATTEMPTS.\033[0m"
        fi
        echo -e "\033[1;31mCould not find The Sims 4 installation folder automatically.\033[0m"
        read -rp $'\033[1;33mPlease enter the installation folder of your game: \033[0m' CUSTOM_LAUNCHER
        # Convert Windows path to Unix path if needed
        if [[ "$CUSTOM_LAUNCHER" =~ ^([a-zA-Z]):\\ ]]; then
            drive_letter=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
            unix_path="/mnt/$drive_letter/$(echo "${CUSTOM_LAUNCHER:3}" | tr '\\' '/')"
            APP_PATH="$unix_path"
        else
            APP_PATH="$CUSTOM_LAUNCHER"
        fi
        if [ ! -d "$APP_PATH" ]; then
            echo -e "\033[1;31mPath '$APP_PATH' does not exist or is not a directory.\033[0m"
            APP_PATH=""
        fi
        ATTEMPTS=$((ATTEMPTS+1))
    done

    if [ -z "$APP_PATH" ]; then
        echo -e "\033[1;31mExceeded $MAX_ATTEMPTS attempts. Exiting setup.\033[0m"
        exit 1
    else
        echo -e "\033[1;32mDetected game installation at: $APP_PATH\033[0m"
    fi
fi

EA_LIB_DIR="$APP_PATH/Data/Simulation/Gameplay"
MODS_DIR="$SIMS4_DOCS_PATH/Mods"

# Update devcontainer.json with actual paths
DEVCONTAINER_FILE=".devcontainer/devcontainer.json"
if [ -f "$DEVCONTAINER_FILE" ]; then
    # Escape the paths for sed (handle spaces and special characters)
    EA_LIB_DIR_ESCAPED=$(printf '%s\n' "$EA_LIB_DIR" | sed 's/[[\\.*^$()+?{|]/\\&/g')
    MODS_DIR_ESCAPED=$(printf '%s\n' "$MODS_DIR" | sed 's/[[\\.*^$()+?{|]/\\&/g')
    
    # Replace placeholders with actual paths
    sed -i "s|__SIMS4_EA_ZIPS_PATH__|$EA_LIB_DIR_ESCAPED|g" "$DEVCONTAINER_FILE"
    sed -i "s|__SIMS4_MODS_PATH__|$MODS_DIR_ESCAPED|g" "$DEVCONTAINER_FILE"
    
    echo -e "\033[1;32mUpdated $DEVCONTAINER_FILE with resolved paths:\033[0m"
    echo -e "  \033[1;34mEA Zips:\033[0m $EA_LIB_DIR"
    echo -e "  \033[1;34mMods:\033[0m $MODS_DIR"
else
    echo -e "\033[1;31mWarning: $DEVCONTAINER_FILE not found\033[0m"
fi

AUTHOR_NAME=""
echo -e "\033[1;36m=== Mod Info Configuration ===\033[0m"
read -p $'\033[1;33mEnter your author name: \033[0m' AUTHOR_NAME
MOD_NAME=""
read -p $'\033[1;33mEnter the Mod name: \033[0m' MOD_NAME

# Lowercase and replace spaces with dots
AUTHOR_NAME_FORMATTED=$(echo "$AUTHOR_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')
MOD_NAME_FORMATTED=$(echo "$MOD_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')

# Patch game version, author, and mod name into mod_info.json
MOD_INFO_FILE="mod_info.json"
if [ -f "$MOD_INFO_FILE" ]; then
    # Replace the value of the "gameversion" key with the detected version
    sed -i -E "s/(\"gameversion\"[[:space:]]*:[[:space:]]*\")([^\"]*)\"/\1$GAME_VERSION\"/" "$MOD_INFO_FILE"
    # Replace the value of the "author" key
    sed -i -E "s/(\"author\"[[:space:]]*:[[:space:]]*\")([^\"]*)\"/\1$AUTHOR_NAME_FORMATTED\"/" "$MOD_INFO_FILE"
    # Replace the value of the "modname" key
    sed -i -E "s/(\"name\"[[:space:]]*:[[:space:]]*\")([^\"]*)\"/\1$MOD_NAME_FORMATTED\"/" "$MOD_INFO_FILE"
    echo -e "\033[1;32mPatched $MOD_INFO_FILE with game version: $GAME_VERSION, author: $AUTHOR_NAME_FORMATTED, mod name: $MOD_NAME_FORMATTED\033[0m"
else
    echo -e "\033[1;31mWarning: $MOD_INFO_FILE not found\033[0m"
fi

echo -e "\n\033[1;35m🎉 Setup complete! You may now launch your dev container and start developing your Sims 4 mod. Happy modding! 🚀\033[0m"


