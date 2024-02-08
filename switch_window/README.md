# Switch Window

## Overview

A ChatGPT-generated script that I use via a custom shortcut in KDE to switch windows. My use-case is mainly for switching to firefox and then immediately putting the cursor into the adress bar. Only tested in an archlinux system with KDE.

## Usage

`./bash switch_window.sh <program_name> <keyboard_shortcut>`

The `<keyboard_shortcut>` argument is optional.

Example for firefox:

` ./bash switch_window.sh firefox ctrl+l`

The script will attempt to grep the first entry with `<program_name>` (case-insensitive) from the list of windows and switch to it. If it isn't present, it will try to launch the program via a hard-coded mapping (so far, only includes vscode and firefox). It will perform the keyboard shortcut, if present, 100ms afterwards (only if the program was running already, not if a new instance was launched).

## Dependencies

- `xdotool`
- `wmctrl`
