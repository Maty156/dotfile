#!/bin/bash
# awww-wrapper.sh — MASU Hyprland
# Intercepts matuwall awww calls, passes to real awww,
# then triggers the pywal color pipeline in the background.

REAL_AWW=/usr/bin/awww
WALLPAPER="${@: -1}"

# Pass all args to real awww first
"$REAL_AWW" "$@"

# Trigger color pipeline only if last arg looks like a file path
[[ -f "$WALLPAPER" ]] && bash ~/.config/hypr/scripts/wallpaper-colors.sh "$WALLPAPER" &
