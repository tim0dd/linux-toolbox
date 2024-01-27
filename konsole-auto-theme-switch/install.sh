#!/bin/bash

SET_PS1=false
UPDATE=false
REMOVE=false

KONSOLE_CONFIG="$HOME/.config/konsolerc"
KONSOLE_PROFILE_DIR="$HOME/.local/share/konsole"
BASHRC="$HOME/.bashrc"
DEFAULT_PROFILE=$(grep 'DefaultProfile=' "$KONSOLE_CONFIG" | cut -d'=' -f2)
PROFILE_PATH="$KONSOLE_PROFILE_DIR/$DEFAULT_PROFILE"

LIGHT_THEME="BlackOnWhite"
DARK_THEME="WhiteOnBlack"

CRON_JOB_ID="# KonsoleAutoThemeSwitchID"

parse_time() {
    IFS=':' read -ra time_parts <<<"$1"
    echo "${time_parts[1]} ${time_parts[0]}"
}

remove_existing_cron_jobs() {
    crontab -l | grep -v "$CRON_JOB_ID" | crontab -
}

clean_bashrc() {
    awk '/^# Start KonsoleAutoThemeSwitcher/,/^# End KonsoleAutoThemeSwitcher/ {next} 1' "$BASHRC" >"$BASHRC.tmp" && mv "$BASHRC.tmp" "$BASHRC"
}

add_cron_jobs() {
    light_time=$(parse_time "$1")
    dark_time=$(parse_time "$2")

    light_command="sed -i 's/^ColorScheme=.*/ColorScheme=$LIGHT_THEME/' $PROFILE_PATH"
    dark_command="sed -i 's/^ColorScheme=.*/ColorScheme=$DARK_THEME/' $PROFILE_PATH"

    if $SET_PS1; then
        light_command="$light_command && awk '/^# Start KonsoleAutoThemeSwitcher/,/^# End KonsoleAutoThemeSwitcher/ {next} 1' \"$BASHRC\" >\"$BASHRC.tmp\" && mv \"$BASHRC.tmp\" \"$BASHRC\""
        dark_command="$dark_command && awk '/^# Start KonsoleAutoThemeSwitcher/,/^# End KonsoleAutoThemeSwitcher/ {next} 1' \"$BASHRC\" >\"$BASHRC.tmp\" && mv \"$BASHRC.tmp\" \"$BASHRC\""
        light_command="$light_command && echo -e '\\n# Start KonsoleAutoThemeSwitcher\\nexport PS1=\$LIGHT_PS1\\n# End KonsoleAutoThemeSwitcher' >> $BASHRC"
        dark_command="$dark_command && echo -e '\\n# Start KonsoleAutoThemeSwitcher\\nexport PS1=\$DARK_PS1\\n# End KonsoleAutoThemeSwitcher' >> $BASHRC"
    fi

    (
        crontab -l 2>/dev/null
        echo "$light_time * * * $light_command $CRON_JOB_ID"
    ) | crontab -
    (
        crontab -l 2>/dev/null
        echo "$dark_time * * * $dark_command $CRON_JOB_ID"
    ) | crontab -
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --set_ps1)
        SET_PS1=true
        echo "Enable setting the bash prompt"
        shift
        ;;
    --update)
        UPDATE=true
        LIGHT_START_TIME="$2"
        DARK_START_TIME="$3"
        if [[ -z $LIGHT_START_TIME || -z $DARK_START_TIME ]]; then
            echo "Error: Missing schedule times for light and dark themes."
            echo "Usage: $0 --update <light_start_time> <dark_start_time>"
            exit 1
        fi
        shift 3
        ;;
    --remove)
        REMOVE=true
        shift
        ;;
    *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--update <light_start_time> <dark_start_time>] [--set_ps1] [--remove]"
        exit 1
        ;;
    esac
done

if $UPDATE; then
    remove_existing_cron_jobs
    clean_bashrc
    add_cron_jobs "$LIGHT_START_TIME" "$DARK_START_TIME"
    echo "Cron jobs for theme switching have been updated."
elif $REMOVE; then
    remove_existing_cron_jobs
    clean_bashrc
    echo "Cron jobs for theme switching and added lines in .bashrc have been removed ."
fi
