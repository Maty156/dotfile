#!/usr/bin/env bash
#  ┳┳┓┏┓┏┳┓┳┳┏┓┏┓┳┓  ┳┳┓┏┓┏┓┳┏┓┓┏┓
#  ┃┃┃┣┫ ┃ ┃┃┃┓┣ ┃┃━━┃┃┃┣┫┃┓┃┃ ┃┫
#  ┛ ┗┛┗ ┻ ┗┛┗┛┗┛┛┗  ┛ ┗┛┗┗┛┻┗┛┛┗┛
#
# matugenMagick — MASU color pipeline
# Author: Maty (MASU Cyber Academy) — https://github.com/Maty156
# Generates matugen palettes from the current wallpaper, regenerates the
# ImageMagick-based rofi background cache, and reloads Hyprland + swaync
# so waybar/rofi/kitty/swaync all pick up the new theme automatically.

# Function to get current wallpaper
get_current_wallpaper() {
    local wallpaper=$(awww query 2>/dev/null | grep -oP 'image: \K.*' | head -1)
    if [ -z "$wallpaper" ]; then
        local cache_dir="$HOME/.cache/awww/0.12.1"
        if [ -d "$cache_dir" ]; then
            wallpaper=$(find "$cache_dir" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" 2>/dev/null | head -1)
        fi
    fi
    echo "$wallpaper"
}

wallpaper_path=$(get_current_wallpaper)
if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
    wallpaper_path="$HOME/.config/wallpapers/wallhaven-poy1zj.png"
    if [ ! -f "$wallpaper_path" ]; then
        wallpaper_path="$HOME/.config/wallpapers/wallpaper.jpg"
    fi
    if [ ! -f "$wallpaper_path" ]; then
        wallpaper_path=$(find "$HOME/.config/wallpapers" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | head -1)
    fi
fi

echo "Using wallpaper: $wallpaper_path"
if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
    echo "ERROR: No wallpaper found!"
    exit 1
fi

# Generate colors - auto-pick the most dominant color
if [ "$1" == "--light" ]; then
    matugen image "$wallpaper_path" -m "light" -c ~/.config/matugen/matugen.toml --source-color-index 0
else
    matugen image "$wallpaper_path" -m "dark" -c ~/.config/matugen/matugen.toml --source-color-index 0
fi

# Reload Hyprland
if [ -f ~/.config/hypr/matugen/matugen-hyprland.conf ]; then
    hyprctl reload
    echo "Hyprland reloaded."
fi

# GTK theme is already handled mode-aware by the [templates.gtk3] post_hook
# in matugen.toml (sets color-scheme + adw-gtk3-{{mode}}). Don't touch it
# here — a hardcoded override here was previously stomping it back to the
# light variant on every run, regardless of --dark/--light.

# ImageMagick processing — regenerate rofi's cached wallpaper images
IMG_DIR="$HOME/.config/rofi/images"
mkdir -p "$IMG_DIR"

# Plain resized/cropped copy (used as a non-blurred launcher background)
magick "$wallpaper_path" -resize 1920x1080^ -gravity center -extent 1920x1080 \
    "$IMG_DIR/currentWal.thumb"

# Blurred copy (used by style-2/4/7/8/11 blurred backgrounds)
magick "$wallpaper_path" -resize 1920x1080^ -gravity center -extent 1920x1080 \
    -blur 0x12 "$IMG_DIR/currentWalBlur.thumb"

# Square center-crop (used by style-9)
magick "$wallpaper_path" -resize 800x800^ -gravity center -extent 800x800 \
    "$IMG_DIR/currentWal.sqre"

# 2x2 tiled "quad" mosaic (used by style-5)
magick montage "$wallpaper_path" "$wallpaper_path" "$wallpaper_path" "$wallpaper_path" \
    -tile 2x2 -geometry 960x540+0+0 "$IMG_DIR/currentWalQuad.quad"

echo "Rofi wallpaper cache images regenerated."

# Reload swaync so its colors/CSS pick up the new matugen palette
if pidof swaync > /dev/null; then
    swaync-client --reload-config
    swaync-client --reload-css
    echo "swaync reloaded."
fi

# Create symlink
ln -sf "$wallpaper_path" "$HOME/.local/share/bg"

# Kill rofi to force reload of background images
pkill rofi 2>/dev/null || true

# Send notification
notify-send -e -h string:x-canonical-private-synchronous:matugen_notif "MatugenMagick" "✅ Matugen & ImageMagick completed successfully!" -i "$HOME/.local/share/bg"

echo "✅ Done!"
