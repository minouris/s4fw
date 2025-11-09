#!/bin/bash

# Repository: https://github.com/minouris/s4fw
#
# Project: S4FW
# Author: Ciara Norrish (@minouris)
# License: MIT (see LICENSE.md)
#
# Description: Universal setup script for Windows (WSL) and Linux hosts running Sims 4

SIMS4_DOCS_PATH=""
GAME_VERSION="1.116.240.10200"  # Default game version, update as necessary
GAME_VERSION_FILE="GameVersion.txt"

echo -e "\033[1;36m=== S4FW Universal Setup: Sims 4 Environment Detection ===\033[0m"

# Detect platform
PLATFORM=""
if [[ -d "/mnt/c" ]]; then
    PLATFORM="WSL"
    echo -e "\033[1;32mDetected platform: Windows Subsystem for Linux (WSL)\033[0m"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="LINUX"
    echo -e "\033[1;32mDetected platform: Native Linux\033[0m"
else
    echo -e "\033[1;31mUnsupported platform: $OSTYPE\033[0m"
    exit 1
fi

# Platform-specific setup
if [[ "$PLATFORM" == "WSL" ]]; then
    # WSL setup - original setup.sh logic
    USER_DRIVE="c"
    APP_DRIVE="c"
    
    # Prompt user for the drive their Documents folder is on
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
    
    for folder in "${USER_FOLDERS[@]}"; do
        if [ -d "$folder/$DOC_PATH" ]; then
            SIMS4_DOCS_PATH="$folder/$DOC_PATH"
            break
        fi
    done
    
    # Game launcher selection for WSL
    GAME_LAUNCHER_OPTIONS=("EA App:EA:1" "Origin:ORIGIN:2" "Steam:STEAM:3" "Epic Games:EPIC:4" "Other:OTHER:5")
    GAME_LAUNCHER_TYPE=""
    
    echo -e "\033[1;36m=== Game Launcher Selection ===\033[0m"
    echo -e "\033[1;33mWhat game launcher do you use for The Sims 4?:\033[0m\n"
    for option in "${GAME_LAUNCHER_OPTIONS[@]}"; do
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
        # Prompt user for the drive their Game folder is on
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

elif [[ "$PLATFORM" == "LINUX" ]]; then
    # Linux Steam Proton setup
    STEAM_PATHS=(
        "$HOME/.steam/steam"
        "$HOME/.local/share/Steam"
        "/usr/share/steam"
        "/opt/steam"
    )
    
    STEAM_ROOT=""
    for path in "${STEAM_PATHS[@]}"; do
        if [ -d "$path" ]; then
            STEAM_ROOT="$path"
            echo -e "\033[1;32mFound Steam at: $STEAM_ROOT\033[0m"
            break
        fi
    done
    
    if [ -z "$STEAM_ROOT" ]; then
        echo -e "\033[1;31mCould not find Steam installation automatically.\033[0m"
        read -rp $'\033[1;33mPlease enter your Steam installation path: \033[0m' CUSTOM_STEAM_PATH
        if [ -d "$CUSTOM_STEAM_PATH" ]; then
            STEAM_ROOT="$CUSTOM_STEAM_PATH"
        else
            echo -e "\033[1;31mInvalid Steam path. Exiting.\033[0m"
            exit 1
        fi
    fi
    
    # Find Steam user directories
    STEAM_USERDATA="$STEAM_ROOT/userdata"
    if [ ! -d "$STEAM_USERDATA" ]; then
        echo -e "\033[1;31mCould not find Steam userdata directory at $STEAM_USERDATA\033[0m"
        exit 1
    fi
    
    # List available Steam user IDs
    STEAM_USERS=($(ls -1 "$STEAM_USERDATA" | grep -E '^[0-9]+$'))
    if [ ${#STEAM_USERS[@]} -eq 0 ]; then
        echo -e "\033[1;31mNo Steam users found in $STEAM_USERDATA\033[0m"
        exit 1
    elif [ ${#STEAM_USERS[@]} -eq 1 ]; then
        STEAM_USER_ID="${STEAM_USERS[0]}"
        echo -e "\033[1;32mUsing Steam user ID: $STEAM_USER_ID\033[0m"
    else
        echo -e "\033[1;33mMultiple Steam users found:\033[0m"
        for i in "${!STEAM_USERS[@]}"; do
            echo "  $((i+1))) ${STEAM_USERS[i]}"
        done
        read -rp $'\033[1;33mSelect Steam user (1-'"${#STEAM_USERS[@]}"$'): \033[0m' USER_CHOICE
        if [[ "$USER_CHOICE" =~ ^[0-9]+$ ]] && [ "$USER_CHOICE" -ge 1 ] && [ "$USER_CHOICE" -le "${#STEAM_USERS[@]}" ]; then
            STEAM_USER_ID="${STEAM_USERS[$((USER_CHOICE-1))]}"
            echo -e "\033[1;32mSelected Steam user ID: $STEAM_USER_ID\033[0m"
        else
            echo -e "\033[1;31mInvalid selection. Exiting.\033[0m"
            exit 1
        fi
    fi
    
    # Find Proton prefix for Sims 4
    SIMS4_APPID="1222670"
    COMPATDATA_PATH="$STEAM_ROOT/steamapps/compatdata/$SIMS4_APPID"
    
    if [ ! -d "$COMPATDATA_PATH" ]; then
        echo -e "\033[1;31mCould not find Sims 4 Proton prefix at $COMPATDATA_PATH\033[0m"
        echo -e "\033[1;33mMake sure you have launched The Sims 4 at least once through Steam.\033[0m"
        read -rp $'\033[1;33mPlease enter the path to your Sims 4 Proton prefix: \033[0m' CUSTOM_COMPATDATA
        if [ -d "$CUSTOM_COMPATDATA" ]; then
            COMPATDATA_PATH="$CUSTOM_COMPATDATA"
        else
            echo -e "\033[1;31mInvalid path. Exiting.\033[0m"
            exit 1
        fi
    fi
    
    echo -e "\033[1;32mFound Sims 4 Proton prefix at: $COMPATDATA_PATH\033[0m"
    
    # Look for Documents folder in the Proton prefix
    PROTON_DRIVE_C="$COMPATDATA_PATH/pfx/drive_c"
    PROTON_USERS_DIR="$PROTON_DRIVE_C/users"
    PROTON_USER_DIRS=("$PROTON_USERS_DIR/steamuser" "$PROTON_USERS_DIR"/*/)
    DOC_PATH="Documents/Electronic Arts/The Sims 4"
    
    for user_dir in "${PROTON_USER_DIRS[@]}"; do
        if [ -d "$user_dir/$DOC_PATH" ]; then
            SIMS4_DOCS_PATH="$user_dir/$DOC_PATH"
            echo -e "\033[1;32mFound Sims 4 Documents at: $SIMS4_DOCS_PATH\033[0m"
            break
        fi
    done
    
    if [ -z "$SIMS4_DOCS_PATH" ]; then
        echo -e "\033[1;31mCould not find Sims 4 Documents folder automatically.\033[0m"
        read -rp $'\033[1;33mPlease enter the path to your Sims 4 Documents folder: \033[0m' CUSTOM_DOCS_PATH
        if [ -d "$CUSTOM_DOCS_PATH" ]; then
            SIMS4_DOCS_PATH="$CUSTOM_DOCS_PATH"
        else
            echo -e "\033[1;31mInvalid path. Exiting.\033[0m"
            exit 1
        fi
    fi
    
    # Find Sims 4 installation directory
    STEAM_APPS_PATHS=(
        "$STEAM_ROOT/steamapps/common/The Sims 4"
        "$HOME/.local/share/Steam/steamapps/common/The Sims 4"
    )
    
    # Check for additional library folders
    LIBRARYFOLDERS_VDF="$STEAM_ROOT/steamapps/libraryfolders.vdf"
    if [ -f "$LIBRARYFOLDERS_VDF" ]; then
        while IFS= read -r line; do
            if [[ $line =~ \"path\"[[:space:]]*\"([^\"]+)\" ]]; then
                library_path="${BASH_REMATCH[1]}"
                STEAM_APPS_PATHS+=("$library_path/steamapps/common/The Sims 4")
            fi
        done < "$LIBRARYFOLDERS_VDF"
    fi
    
    APP_PATH=""
    for path in "${STEAM_APPS_PATHS[@]}"; do
        if [ -d "$path" ]; then
            APP_PATH="$path"
            echo -e "\033[1;32mFound Sims 4 installation at: $APP_PATH\033[0m"
            break
        fi
    done
    
    if [ -z "$APP_PATH" ]; then
        echo -e "\033[1;31mCould not find Sims 4 installation automatically.\033[0m"
        read -rp $'\033[1;33mPlease enter the path to your Sims 4 installation: \033[0m' CUSTOM_APP_PATH
        if [ -d "$CUSTOM_APP_PATH" ]; then
            APP_PATH="$CUSTOM_APP_PATH"
        else
            echo -e "\033[1;31mInvalid path. Exiting.\033[0m"
            exit 1
        fi
    fi
fi

# Common setup for both platforms
if [ -n "$SIMS4_DOCS_PATH" ] && [ -f "$SIMS4_DOCS_PATH/$GAME_VERSION_FILE" ]; then
    GAME_VERSION_EXTRACTED=$(grep -a -oE '([0-9]+\.)+[0-9]+' "$SIMS4_DOCS_PATH/$GAME_VERSION_FILE" | head -n 1)
    if [[ -n "$GAME_VERSION_EXTRACTED" ]]; then
        GAME_VERSION="$GAME_VERSION_EXTRACTED"
        echo -e "\033[1;32mDetected game version: $GAME_VERSION\033[0m"
    else
        echo -e "\033[1;31mCould not extract a valid game version from $GAME_VERSION_FILE, using default: $GAME_VERSION\033[0m"
    fi
else
    echo -e "\033[1;31m$GAME_VERSION_FILE not found in $SIMS4_DOCS_PATH, using default: $GAME_VERSION\033[0m"
fi

EA_LIB_DIR="$APP_PATH/Data/Simulation/Gameplay"
MODS_DIR="$SIMS4_DOCS_PATH/Mods"

# Verify paths exist
if [ ! -d "$EA_LIB_DIR" ]; then
    echo -e "\033[1;31mWarning: EA library directory not found at $EA_LIB_DIR\033[0m"
fi
if [ ! -d "$MODS_DIR" ]; then
    echo -e "\033[1;31mWarning: Mods directory not found at $MODS_DIR\033[0m"
    echo -e "\033[1;33mThis is normal if you haven't created any mods yet.\033[0m"
fi

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

# Mod Info Configuration (common for both platforms)
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

# Platform-specific completion messages
if [[ "$PLATFORM" == "LINUX" ]]; then
    echo -e "\n\033[1;35m🎉 Setup complete! You may now launch your dev container and start developing your Sims 4 mod. Happy modding! 🚀\033[0m"
    echo -e "\033[1;36mNote: Make sure to launch The Sims 4 through Steam at least once to ensure all Proton files are properly initialized.\033[0m"
else
    echo -e "\n\033[1;35m🎉 Setup complete! You may now launch your dev container and start developing your Sims 4 mod. Happy modding! 🚀\033[0m"
fi
