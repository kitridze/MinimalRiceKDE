# Rice on KDE Plasma 6

Install (Arch names; adapt for your distro):

    sudo pacman -S --needed python python-pillow tk konsole strawberry kconfig plasma-workspace libkscreen \
      inter-font ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
    unzip kde-rice.zip && cd kde-rice && ./install-kde.sh
    # log out and back in, then once:  rice setup

Your 57 themes, 7 ASCII backgrounds, `rice` commands and `rice-settings` all still work. `rice theme NAME` now
changes: Plasma color scheme, fonts, icons, titlebar colors, Konsole profile + colors, wallpaper, and Chromium /
VS Code / Obsidian / Spotify / mpv as before.

Keys: Super+K Konsole, Super+S Strawberry, tap Super = KRunner (Alt+Space and Alt+F2 too).
KRunner finds: "rice settings", "rice theme mint", "rice toggle", "rice next background", "rice eyecare on" ...
(`rice desktop-entries` recreates these after you add a theme.)

Mapping of old settings:
  opacity_active -> Konsole opacity        blur / blur_size -> KWin blur (needs translucent Konsole)
  animation preset -> KDE animation speed  eyecare* -> KDE Night Light (schedule handled by KWin)
  rice does not touch blur / animation speed / Night Light until you change them from the defaults.
Settings you can add to rice.json: "screen_size": "2560x1440" (if auto-detect is wrong),
  "kde_icons": "auto" | "Papirus-Dark" | "" (leave icons alone),  "kde_fonts": false (leave fonts alone).

No Plasma equivalent: Hyprland gaps, borders, rounding, shadows, per-window inactive opacity, dwindle tiling,
slide/popin animation styles, the Waybar pills. Closest: Klassy or Kvantum for rounding/styles, Plasma tiling
(Meta+T) or Krohnkite, a floating translucent panel (optional rice-panel.js).
