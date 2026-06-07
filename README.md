# MASU .config

Personal Hyprland desktop configuration with a pywal-driven color pipeline. Colors follow the wallpaper automatically across Waybar, Rofi, Swaync, Wofi, Dunst, Hyprlock, and related scripts.

**Quick facts**

- **Hardware:** ThinkPad E531 · 1366×768 · Intel Ivy Bridge
- **OS:** Arch Linux
- **Window Manager:** Hyprland
- **Terminal:** Kitty
- **Shell:** Zsh

**Contents**

This repo contains configuration and helper scripts for a themed Hyprland setup.

| Folder | Description |
|--------|-------------|
| `hypr/` | Hyprland config, animations, hyprlock, color pipeline scripts |
| `waybar/` | Status bar configuration (pywal colors) |
| `rofi/` | Rofi themes and palettes |
| `swaync/` | Notification center styling and scripts |
| `kitty/` | Kitty terminal config |
| `matuwall/` | Wallpaper manager config and scripts |
| `wallpapers/` | Example wallpapers used to generate palettes |
| `waybar/themes/` | Waybar theme variants |

## Quick install

1. Clone into `~/.config`

```bash
git clone https://github.com/Maty156/.config.git ~/.config
```

2. Install required packages (Arch example):

```bash
sudo pacman -S hyprland hyprlock waybar rofi kitty dunst swaync wob wofi thunar grim slurp \
  nm-applet blueman pavucontrol python-pywal
```

3. Install AUR packages (examples):

```bash
yay -S hyprpaper awww matuwall ttf-jetbrains-mono-nerd papirus-icon-theme bibata-cursor-theme
```

4. Symlink pywal Rofi colors (optional):

```bash
ln -sf ~/.cache/wal/colors-rofi.rasi ~/.config/rofi/colors-rofi.rasi
```

5. Generate colors from a wallpaper:

```bash
wal -i /path/to/your/wallpaper.jpg
```

6. Start Hyprland.

## Dependencies

- hyprland, hyprlock, hyprpaper, awww, matuwall
- waybar, rofi, swaync, wofi, dunst, wob
- kitty, thunar
- python-pywal, grim, slurp
- nm-applet, blueman, pavucontrol
- JetBrainsMono Nerd Font (recommended)
- Papirus icon theme, Bibata cursor theme

## Color pipeline

When the wallpaper changes via `matuwall` the scripts generate colors and propagate them across the components:

```
matuwall → awww-wrapper.sh → wallpaper-colors.sh
                                    ↓
                               wal -i <wallpaper>
                                    ↓
                     ┌─────────────┼──────────────┐
                  waybar        rofi           swaync
                  wofi          dunst          hyprlock
                  wob           hyprland       SDDM
```

`wal-watcher.sh` can also run in the background to catch wallpaper changes and reapply palettes.

## Monitor

Default configured for `LVDS-1` at `1366x768@60` — change settings in `hypr/hyprland.conf`.

```ini
monitor = LVDS-1, 1366x768@60, 0x0, 1
```

## Screenshots

Screenshots of the setup can be added to `assets/screenshots/` and referenced below. Add PNG or JPG files named clearly (e.g. `waybar.png`, `rofi.png`). Example links (add images to enable):

- [assets/screenshots/waybar.png](assets/screenshots/waybar.png)
- [assets/screenshots/rofi.png](assets/screenshots/rofi.png)
- [assets/screenshots/hypr.png](assets/screenshots/hypr.png)

How to add screenshots:

1. Place images in `assets/screenshots/`.
2. Recommended resolution: 1280×720 (or scaled down).
3. Commit and push; the README will show them automatically.

## Contributing

If you want to contribute adjustments or fixes, open a PR. Configs are opinionated; please test changes locally before proposing.

## License

Share as you like; add a LICENSE file if you want a specific license.

---

If you'd like, I can add placeholder files in `assets/screenshots/` now, or you can upload screenshots and I will insert them into the README for you.
