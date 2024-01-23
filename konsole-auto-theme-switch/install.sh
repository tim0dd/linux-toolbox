#!/bin/bash

# Paths
KONSOLE_CONFIG="$HOME/.config/konsolerc"
KONSOLE_PROFILE_DIR="$HOME/.local/share/konsole"

# Color schemes
LIGHT_THEME="BlackOnWhite"
DARK_THEME="WhiteOnBlack"

# Unique identifier for our cron jobs
CRON_JOB_ID="# KonsoleAutoThemeSwitchID"

# Extract the default profile name
DEFAULT_PROFILE=$(grep 'DefaultProfile=' "$KONSOLE_CONFIG" | cut -d'=' -f2)

# Construct the profile path
PROFILE_PATH="$KONSOLE_PROFILE_DIR/$DEFAULT_PROFILE"
# Function to parse time input (hour:minute) into cron format
parse_time() {
    IFS=':' read -ra TIME_PARTS <<< "$1"
    echo "${TIME_PARTS[1]} ${TIME_PARTS[0]}"
}

# Function to remove existing cron jobs for our script
remove_existing_cron_jobs() {
    crontab -l | grep -v "$CRON_JOB_ID" | crontab -
}

# Function to add new cron jobs
add_cron_jobs() {
    light_time=$(parse_time "$1")
    dark_time=$(parse_time "$2")

    light_command="sed -i 's/^ColorScheme=.*/ColorScheme=$LIGHT_THEME/' $PROFILE_PATH"
    dark_command="sed -i 's/^ColorScheme=.*/ColorScheme=$DARK_THEME/' $PROFILE_PATH"

    (crontab -l 2>/dev/null; echo "$light_time * * * $light_command $CRON_JOB_ID") | crontab -
    (crontab -l 2>/dev/null; echo "$dark_time * * * $dark_command $CRON_JOB_ID") | crontab -
}

# Main execution based on command line argument
case "$1" in
    update)
        if [[ -n $2 && -n $3 ]]; then
            remove_existing_cron_jobs
            add_cron_jobs "$2" "$3"
            echo "Cron jobs for theme switching have been updated."
        else
            echo "Error: Missing schedule times for light and dark themes."
            echo "Usage: $0 update [light_time] [dark_time]"
            echo "Time format: hour:minute (e.g., 7:30, 19:00)"
            exit 1
        fi
        ;;
    remove)
        remove_existing_cron_jobs
        echo "Cron jobs for theme switching have been removed."
        ;;
    *)
        echo "Usage: $0 [update [light_time] [dark_time]|remove]"
        echo "Time format: hour:minute (e.g., 7:30, 19:00)"
        exit 1
        ;;
esac