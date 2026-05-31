#!/bin/bash
# wal-watcher.sh — MASU Hyprland
# Watches awww for wallpaper changes and runs the full pywal color pipeline

LAST_WALL=""
SCRIPTS="$HOME/.config/hypr/scripts"

apply_colors() {
    local wall="$1"

    # Generate pywal palette
    wal -i "$wall" -n -q

    # Distribute color files
    [[ -f ~/.cache/wal/colors-waybar.css    ]] && cp ~/.cache/wal/colors-waybar.css    ~/.config/waybar/colors.css
    [[ -f ~/.cache/wal/colors-wofi.css      ]] && cp ~/.cache/wal/colors-wofi.css      ~/.config/wofi/style.css
    [[ -f ~/.cache/wal/colors.css           ]] && cp ~/.cache/wal/colors.css           ~/.config/swaync/colors.css
    [[ -f ~/.cache/wal/wob.ini              ]] && cp ~/.cache/wal/wob.ini              ~/.config/wob/wob.ini
    [[ -f ~/.cache/wal/dunstrc              ]] && cp ~/.cache/wal/dunstrc              ~/.config/dunst/dunstrc
    [[ -f ~/.cache/wal/hyprland-colors.conf ]] && cp ~/.cache/wal/hyprland-colors.conf ~/.config/hypr/hyprland-colors.conf

    # Update hyprlock background
    bash "$SCRIPTS/hyprlock_wall.sh" "$wall"

    # Update SDDM
    sudo cp "$wall" /usr/share/sddm/themes/catppuccin/backgrounds/current-wall.jpg 2>/dev/null
    bash "$SCRIPTS/sddm-colors.sh"

    # Reload Hyprland colors only (no full reload — avoids visual flash)
    hyprctl keyword source ~/.config/hypr/hyprland-colors.conf 2>/dev/null

    # Restart dunst
    pkill -x dunst 2>/dev/null
    dunst &

    # Recreate wob pipe
    pkill -x wob 2>/dev/null
    rm -f /tmp/wobpipe
    mkfifo /tmp/wobpipe
    tail -f /tmp/wobpipe | wob -c ~/.config/wob/wob.ini &

    # Restart swaync cleanly
    pkill -x swaync 2>/dev/null
    sleep 0.5
    swaync &
    sleep 0.6
    swaync-client -R -rs 2>/dev/null || true
    swaync-client -df 2>/dev/null || true

    # Reload waybar (soft restart)
    pkill -x waybar 2>/dev/null
    sleep 0.3
    waybar &
}

while true; do
    CURRENT=$(awww query --json 2>/dev/null | grep -o '"path":"[^"]*"' | head -1 | cut -d'"' -f4)

    # Fallback: try plain text format
    if [[ -z "$CURRENT" ]]; then
        CURRENT=$(awww query 2>/dev/null | grep -oP '(?<=image: ).*' | head -1)
    fi

    if [[ -n "$CURRENT" && "$CURRENT" != "$LAST_WALL" && -f "$CURRENT" ]]; then
        echo "[wal-watcher] Wallpaper changed: $CURRENT"
        LAST_WALL="$CURRENT"
        apply_colors "$CURRENT"
    fi

    sleep 1
done
