#!/bin/bash
# wallpaper-colors.sh — MASU Hyprland
# Applies full pywal color pipeline for a given wallpaper path.
# Called by awww-wrapper.sh on manual wallpaper set.

WALLPAPER="$1"
[[ -f "$WALLPAPER" ]] || exit 1

SCRIPTS="$HOME/.config/hypr/scripts"

wal -i "$WALLPAPER" -n -q

[[ -f ~/.cache/wal/colors-waybar.css    ]] && cp ~/.cache/wal/colors-waybar.css    ~/.config/waybar/colors.css
[[ -f ~/.cache/wal/colors-wofi.css      ]] && cp ~/.cache/wal/colors-wofi.css      ~/.config/wofi/style.css
[[ -f ~/.cache/wal/wob.ini              ]] && cp ~/.cache/wal/wob.ini              ~/.config/wob/wob.ini
[[ -f ~/.cache/wal/dunstrc              ]] && cp ~/.cache/wal/dunstrc              ~/.config/dunst/dunstrc
[[ -f ~/.cache/wal/hyprland-colors.conf ]] && cp ~/.cache/wal/hyprland-colors.conf ~/.config/hypr/hyprland-colors.conf

bash "$SCRIPTS/hyprlock_wall.sh" "$WALLPAPER"
sudo cp "$WALLPAPER" /usr/share/sddm/themes/catppuccin/backgrounds/current-wall.jpg 2>/dev/null
bash "$SCRIPTS/sddm-colors.sh"

# Reload Hyprland border colors without full restart
hyprctl keyword source ~/.config/hypr/hyprland-colors.conf 2>/dev/null

pkill -x dunst 2>/dev/null; dunst &

pkill -x wob 2>/dev/null
rm -f /tmp/wobpipe && mkfifo /tmp/wobpipe
tail -f /tmp/wobpipe | wob -c ~/.config/wob/wob.ini &

pkill -x waybar 2>/dev/null
sleep 0.3
waybar &
