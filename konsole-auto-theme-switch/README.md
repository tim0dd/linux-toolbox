# Konsole Theme Scheduler

## Overview
A simple bash script for autoswitching between light and dark themes in KDE's default terminal Konsole depending on the time of the day. The script registers cronjobs that trigger theme changes at user-chosen times.
The script dynamically reads the user's default Konsole profile and updates the color scheme based on the time. Konsole's built-in `BlackOnWhite` and `WhiteOnBlack` color schemes are assumed to be present.

## Installation
- To set up the theme switching schedule, run:
  ```bash ./install.sh update [light_theme_start_time] [dark_theme_start_time]```
- Replace [light_theme_start_time] and [dark_theme_start_time] with the hours (in 24-hour format `hh:mm`) you want to switch to the light and dark themes, respectively.

## Dependencies
- cron:
    For example cronie. Make sure the service is enabled and started with `sudo systemctl enable --now cronie`
- Bash environment
- Konsole

## Updating previously added cronjobs
Using the installation syntax will automatically delete the previously added cronjobs, then add new ones with the chosen hours.

## Removal
Any previously added cronjobs can be removed by running:
```bash ./install.sh remove```

## Todo
- Add ability to switch bash prompt (PS1)