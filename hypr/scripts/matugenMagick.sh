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

set -uo pipefail

# ── Config (override via env if you want) ──────────────────────────────
MATUGEN_CONFIG="${MATUGEN_CONFIG:-$HOME/.config/matugen/matugen.toml}"
MATUGEN_SCHEME="${MATUGEN_SCHEME:-scheme-expressive}"   # tonal-spot|expressive|vibrant|fruit-salad|rainbow|fidelity|content|neutral|monochrome
MATUGEN_CONTRAST="${MATUGEN_CONTRAST:-0.3}"             # -1.0 .. 1.0, higher = punchier
MATUGEN_PREFER="${MATUGEN_PREFER:-saturation}"          # darkness|lightness|saturation|less-saturation|value|closest-to-fallback
                                                          # REQUIRED for non-interactive runs (keybinds/scripts have no TTY,
                                                          # so without --prefer or --source-color-index matugen hangs/fails
                                                          # waiting for an arrow-key prompt)
IMG_DIR="$HOME/.config/rofi/images"
WALL_CACHE_DIR="$HOME/.cache/awww/0.12.1"
FALLBACK_WALLS=(
    "$HOME/.config/wallpapers/wallhaven-poy1zj.png"
    "$HOME/.config/wallpapers/wallpaper.jpg"
)

log() { echo "[matugenMagick] $*"; }
die() { echo "[matugenMagick] ERROR: $*" >&2; notify-send -u critical "MatugenMagick" "❌ $*" 2>/dev/null || true; exit 1; }

# ── Dependency check ────────────────────────────────────────────────────
for bin in matugen magick awww hyprctl; do
    command -v "$bin" >/dev/null 2>&1 || die "required binary '$bin' not found in PATH"
done

# ── Mode flag ────────────────────────────────────────────────────────────
mode="dark"
if [ "${1:-}" == "--light" ]; then
    mode="light"
elif [ "${1:-}" == "--dark" ]; then
    mode="dark"
elif [ -n "${1:-}" ]; then
    log "unrecognized arg '$1', defaulting to --dark"
fi

# ── Locate current wallpaper ─────────────────────────────────────────────
get_current_wallpaper() {
    local wallpaper
    wallpaper=$(awww query 2>/dev/null | grep -oP 'image: \K.*' | head -1)

    if [ -z "$wallpaper" ] && [ -d "$WALL_CACHE_DIR" ]; then
        wallpaper=$(find "$WALL_CACHE_DIR" -type f \
            \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" \) \
            2>/dev/null | head -1)
    fi

    echo "$wallpaper"
}

wallpaper_path=$(get_current_wallpaper)

if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
    for fallback in "${FALLBACK_WALLS[@]}"; do
        if [ -f "$fallback" ]; then
            wallpaper_path="$fallback"
            break
        fi
    done
fi

if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
    wallpaper_path=$(find "$HOME/.config/wallpapers" -type f \
        \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) 2>/dev/null | head -1)
fi

[ -n "$wallpaper_path" ] && [ -f "$wallpaper_path" ] || die "no wallpaper found!"
log "Using wallpaper: $wallpaper_path"
log "Mode: $mode | Scheme: $MATUGEN_SCHEME | Contrast: $MATUGEN_CONTRAST | Prefer: $MATUGEN_PREFER"

# ── Generate colors ──────────────────────────────────────────────────────
# NOTE: --prefer replaces --source-color-index here. Without EITHER flag,
# matugen shows an interactive arrow-key prompt to pick the source color —
# fine in a terminal, but this script has no TTY when run from a keybind,
# so it fails immediately (this was the actual cause of the earlier crash).
# --source-color-index 0 avoided the prompt too, but always grabbed the
# color with the most pixel coverage (often a boring flat area).
# --prefer saturation avoids the prompt AND picks for vibrancy instead.
if ! matugen image "$wallpaper_path" \
        -m "$mode" \
        -c "$MATUGEN_CONFIG" \
        --type "$MATUGEN_SCHEME" \
        --contrast "$MATUGEN_CONTRAST" \
        --prefer "$MATUGEN_PREFER"; then
    die "matugen failed to generate colors"
fi
log "Matugen palette generated."

# ── Reload Hyprland ──────────────────────────────────────────────────────
if [ -f "$HOME/.config/hypr/matugen/matugen-hyprland.conf" ]; then
    hyprctl reload && log "Hyprland reloaded."
fi

# ── GTK theme ────────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.interface gtk-theme "" 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3 2>/dev/null || true

# ── ImageMagick: regenerate rofi's cached wallpaper images ──────────────
mkdir -p "$IMG_DIR"

magick "$wallpaper_path" -resize 1920x1080^ -gravity center -extent 1920x1080 \
    "$IMG_DIR/currentWal.thumb" \
    || log "warning: failed to generate currentWal.thumb"

magick "$wallpaper_path" -resize 1920x1080^ -gravity center -extent 1920x1080 \
    -blur 0x12 "$IMG_DIR/currentWalBlur.thumb" \
    || log "warning: failed to generate currentWalBlur.thumb"

magick "$wallpaper_path" -resize 800x800^ -gravity center -extent 800x800 \
    "$IMG_DIR/currentWal.sqre" \
    || log "warning: failed to generate currentWal.sqre"

magick montage "$wallpaper_path" "$wallpaper_path" "$wallpaper_path" "$wallpaper_path" \
    -tile 2x2 -geometry 960x540+0+0 "$IMG_DIR/currentWalQuad.quad" \
    || log "warning: failed to generate currentWalQuad.quad"

log "Rofi wallpaper cache images regenerated."

# ── Reload swaync ────────────────────────────────────────────────────────
if pidof swaync > /dev/null; then
    swaync-client --reload-config 2>/dev/null || true
    swaync-client --reload-css 2>/dev/null || true
    log "swaync reloaded."
fi

# ── Symlink + rofi refresh ───────────────────────────────────────────────
mkdir -p "$HOME/.local/share"
bg_link="$HOME/.local/share/bg"
# If bg exists as a real directory (not a symlink), `ln -sf` won't replace
# it — it just drops the symlink inside, breaking anything that reads
# ~/.local/share/bg expecting a single image file. Remove it if so.
if [ -d "$bg_link" ] && [ ! -L "$bg_link" ]; then
    log "warning: $bg_link was a plain directory, replacing with a symlink"
    rm -rf "$bg_link"
fi
ln -sf "$wallpaper_path" "$bg_link"

pkill rofi 2>/dev/null || true

# ── Notify ───────────────────────────────────────────────────────────────
notify-send -e -h string:x-canonical-private-synchronous:matugen_notif \
    "MatugenMagick" "✅ Matugen & ImageMagick completed successfully!" \
    -i "$HOME/.local/share/bg" 2>/dev/null || true

log "✅ Done!"
