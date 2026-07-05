# Credits

This rice (MASU Hyprland setup) is built on top of, and heavily customized
from, several community Hyprland/dotfiles projects. Full credit to the
original authors — the file headers throughout this repo keep their
copyright notices intact.

## Sources

- **[JaKooLit/Hyprland-Dots](https://github.com/JaKooLit)** — base scripts
  for wallpaper/audio/network helpers (`airplaneMode.sh`, `sounds.sh`,
  `cliphist.sh`, `Weather.sh` / `Weather.py`) and several animation presets.
- **[HyDE Project (prasanthrangan/hyprdots)](https://github.com/prasanthrangan/hyprdots)** —
  rofi launcher styles and applets.
- **[ML4W / mylinuxforwork/dotfiles](https://github.com/mylinuxforwork/dotfiles)** —
  a set of animation presets.
- **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)** —
  animation preset.
- **[gh0stzk](https://github.com/gh0stzk)** — original `wallSelect.sh`
  (GPL-3.0), modified here to use the `awww` fork and trigger the MASU
  color pipeline.
- **Mahaveer ([mahaveergurjar](https://github.com/mahaveergurjar))** and
  **Itz-Abhishek-Tiwari** — additional animation presets.
- **Vince Liuice / Tsu Jan (KvAdapta)** — `matugen.kvconfig` base.
- **[wttr.in](https://github.com/chubin/wttr.in)** and
  [Surendrajat's gist](https://gist.github.com/Surendrajat/ff3876fd2166dd86fb71180f4e9342d7) —
  weather data source used by `Weather.sh` / `Weather.py`.
- **[trygveaa/kitty-kitten-search](https://github.com/trygveaa/kitty-kitten-search)** —
  kitty search kitten.

The `hypr/modules/animations/` folder is a curated collection of presets
pulled from several of the above projects — see each file's own header for
its specific origin.

## MASU customizations

Original work by Maty ([Maty156](https://github.com/Maty156), MASU Cyber
Academy) on top of the above, including:

- `matugenMagick.sh` — full matugen + ImageMagick color pipeline (palette
  generation, rofi background cache regeneration, Hyprland reload, and
  automatic swaync CSS/config reload).
- `wallSelect.sh` — ported from swww to the `awww` fork and wired into the
  matugen pipeline above.
- Integration of matugen-based dynamic theming across waybar, rofi, kitty,
  hyprlock, and swaync into a single automated chain.
- Hyprland 0.55.4 compatibility fixes (windowrules/layerrules Lua syntax
  migration, deprecated option cleanup).

If you're the author of something in here and want a credit fixed, updated,
or removed, please open an issue.
