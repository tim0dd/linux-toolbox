#!/bin/bash

usage() {
    echo "Usage: $0 <program_class_name> [keyboard_shortcut]"
    echo "Example: $0 firefox ctrl+l"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

PROGRAM_CLASS_NAME=$1
KEYBOARD_SHORTCUT=${2:-}

# Map window names to launch commands
declare -A launch_commands
launch_commands=(
    ["Navigator.Firefox"]="firefox"
    ["code.Code"]="code"
    # add more mappings here, find window names in 3rd column of wmctrl -lxv
)

# Get the list of window IDs for the given class name
readarray -t WIDS <<< "$(wmctrl -lx | grep "$PROGRAM_CLASS_NAME" | awk '{print $1}')"

if [ "${#WIDS[@]}" -gt 0 ]; then
    # Focus the first window in the list (change logic here for different strategies)
    wmctrl -ia "${WIDS[0]}"
    if [ -n "$KEYBOARD_SHORTCUT" ]; then
        sleep 0.1
        xdotool key --clearmodifiers $KEYBOARD_SHORTCUT
    fi
else
    # Start the program if not found and if a launch command is available
    if [[ ${launch_commands[$PROGRAM_CLASS_NAME]} ]]; then
        ${launch_commands[$PROGRAM_CLASS_NAME]} &
    else
        echo "No launch command found for class name '$PROGRAM_CLASS_NAME'."
    fi
fi