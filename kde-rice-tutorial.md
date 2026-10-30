# Hyprland rice on KDE Plasma: tutorial

This tutorial walks you through installing the KDE edition of your rice (`kde-rice.zip`), using it day to day, and fixing the usual problems.

**What you get**

- Your 57 themes, 7 ASCII backgrounds, the `rice` command and the `rice-settings` app, now driving Plasma instead of Hyprland.
- `Super+K` opens Konsole, `Super+S` opens Strawberry.
- Tapping `Super` opens KRunner, and KRunner can also run `rice-settings`, switch themes and change backgrounds.

**Assumptions:** Plasma 6 on Wayland, and Arch package names. On another distro, translate the package names; everything else is the same.

> **Honesty note.** The generated files and command sequences were tested against a fake home with stubbed KDE tools. They were not run on a live Plasma session, so the shortcut and Super-tap steps are the first things to verify (section 4).

---

## 1. Install

### 1.1 Packages

```bash
sudo pacman -S --needed python python-pillow tk konsole strawberry kconfig plasma-workspace libkscreen \
  inter-font ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
```

| Package | Why |
|---|---|
| `python`, `python-pillow`, `tk` | the `rice` script, the ASCII wallpaper renderer, the `rice-settings` window |
| `kconfig` | `kwriteconfig6` / `kreadconfig6`, used to change KDE settings one key at a time |
| `plasma-workspace` | `plasma-apply-colorscheme`, `plasma-apply-wallpaperimage`, KRunner |
| `libkscreen` | `kscreen-doctor`, used to detect your screen size (QHD etc.) |
| fonts | Inter (UI), JetBrainsMono Nerd Font (terminal), Noto (Georgian, emoji) |

Optional, only if you want the pixel font: `yay -S ttf-monocraft`.

### 1.2 Run the installer

```bash
unzip kde-rice.zip && cd kde-rice
./install-kde.sh
```

The installer:

1. Backs up what it replaces to `~/.kde-rice-backup-<date>`.
2. Copies `rice`, `rice-settings`, the themes, templates and backgrounds into `~/.local/bin` and `~/.config/rice`.
3. Keeps your own `rice.json` if you already have one (the new default is saved as `rice.json.new`). Use `./install-kde.sh --force` to overwrite everything.
4. Adds `~/.local/bin` to PATH for the whole Plasma session.
5. Sets the shortcuts and KRunner options (section 3).
6. Creates the KRunner launchers (section 5).
7. Enables a small timer for automatic day/night switching. It does nothing until you turn that on.
8. Runs `rice apply` once.

### 1.3 Log out and back in

Shortcuts, the Super-tap setting and the new PATH are read at login. This is the safe way; do it once.

### 1.4 One-time app setup

```bash
rice setup
```

This prepares Chromium, VS Code, Obsidian and Spotify so they follow every theme change. It prints any `sudo` line it cannot run itself. Before running it:

- Start VS Code, Obsidian (open your vault) and Spotify (log in) once, then close them.
- For Chromium: `sudo mkdir -p /etc/chromium/policies/managed && sudo chown $USER /etc/chromium/policies/managed`
- For Spotify (AUR package): `sudo chmod a+wr /opt/spotify -R && sudo chmod a+wr /opt/spotify/Apps -R`

`rice setup` is safe to repeat.

---

## 2. What changes when you switch a theme

`rice theme NAME` now updates:

| Item | How |
|---|---|
| Plasma colors (windows, views, buttons, selection, tooltips) | a generated color scheme named `Rice-<theme>`, applied with `plasma-apply-colorscheme` |
| Titlebar colors | the `[WM]` section of that scheme |
| Fonts | UI font and monospace font written into KDE's font settings |
| Icons | `breeze` or `breeze-dark` to match light/dark |
| Konsole | a `Rice` profile and color scheme, set as the default profile |
| Wallpaper | your ASCII background, rendered in the theme's colors at your screen size |
| Chromium, VS Code, Obsidian, Spotify, mpv | same mechanisms as in the Hyprland version |

KDE's own `kdeglobals` file is never overwritten as a whole, only individual keys are changed, so the rest of your Plasma setup stays intact.

Already-open Konsole windows keep their old profile; new windows get the new one.

---

## 3. Keyboard shortcuts and KRunner

| Keys | Action |
|---|---|
| `Super+K` | Konsole |
| `Super+S` | Strawberry (a second press raises the running window, as Strawberry is single-instance) |
| tap `Super` | KRunner |
| `Alt+Space`, `Alt+F2` | KRunner (Plasma defaults, still active) |

### 3.1 Verify (do this first)

1. Press `Super+K`: Konsole should open.
2. Press `Super+S`: Strawberry should open.
3. Tap `Super`: KRunner should appear in the middle of the screen.

If one of them does nothing, see section 7.

### 3.2 Change a shortcut later

System Settings → Keyboard → Shortcuts. Search for "Konsole" or "Strawberry" and set a new key. Or re-run the one-line commands the installer uses, for example:

```bash
kwriteconfig6 --file kglobalshortcutsrc --group services --group org.kde.konsole.desktop \
  --key _launch "Meta+Return,none,Konsole"
```

Then log out and back in.

### 3.3 Want `Super+D` for KRunner, like in Hyprland?

Plasma uses `Super+D` for "Peek at Desktop". Clear it in System Settings → Shortcuts, then set KRunner's shortcut (System Settings → Search → KRunner) to `Super+D`.

---

## 4. Using KRunner for everything

Open KRunner (tap `Super`) and type:

| Type | Result |
|---|---|
| `rice settings` | opens the settings app |
| `rice theme mint` (or just `mint`) | switches to the mint theme |
| `rice toggle` | day ↔ night sibling of your current theme |
| `rice next background`, `previous`, `random`, `main` | change the ASCII wallpaper |
| `rice eyecare on` / `off` | KDE Night Light |
| any app name, a calculation, a file | KRunner's normal job |

These are real launchers in `~/.local/share/applications` named `rice-*.desktop`: one for the settings app, one for each quick action, and one per theme (65 in total). After you add a theme file, recreate them:

```bash
rice desktop-entries
```

They may also show up under Settings in the application menu. If that bothers you, you can ignore it, since you use KRunner.

The "Command Line" KRunner plugin is enabled too, so typing a command such as `rice bg set megumin` also works.

---

## 5. The settings app

Open it with KRunner (`rice settings`) or run `rice-settings`.

| Tab | What it does on KDE |
|---|---|
| **Look** | theme, day/night themes, auto switching, animation speed preset, main background, Konsole opacity, window blur and strength |
| **Eyecare** | on/off, warmth in kelvin (1000-6500), schedule; handled by KDE Night Light |
| **Background art** | fit, softness, edge fade and ink strength per ASCII background |
| **Fonts** | UI, monospace and pixel fonts, size, terminal and ASCII-art font |
| **Apps** | extra Obsidian vault, auto-apply Spotify, plus **Set up apps** and **Refresh apps only** buttons |

Press **Apply** to save and regenerate. **Day / Night** and **Next background** act immediately.

The Layout and Bar tabs from the Hyprland version were removed because they controlled gaps, borders, rounding and Waybar, which do not exist in Plasma.

The window is a Tk app and runs through XWayland, so text can look slightly soft on fractional scaling. It is a utility window, not something you keep open.

---

## 6. Everyday commands

```bash
rice list themes                  # all 57
rice theme green-muted-night      # switch now
rice toggle                       # day <-> night, same color family
rice bg next | prev | random | main
rice bg set megumin               # a specific one
rice bg opts megumin '{"soften": 3}'   # tweak the art
rice eyecare on | off | temp 3500
rice anim snappy                  # animation speed preset
rice set auto_daynight true       # switch by clock (day 07:00, night 19:00)
rice apply apps                   # refresh only the apps
rice apply desktop                # refresh only wallpaper, blur, animation, eyecare
```

### Settings you may want in `~/.config/rice/rice.json`

| Setting | Meaning |
|---|---|
| `"screen_size": "2560x1440"` | use this if the wallpaper has the wrong resolution (auto-detect uses `kscreen-doctor`) |
| `"kde_icons": "auto"` | `auto` = breeze / breeze-dark; a theme name such as `"Papirus-Dark"`; or `""` to leave your icons alone |
| `"kde_fonts": false` | do not touch KDE fonts |
| `"opacity_active": 0.9` | Konsole opacity |
| `"blur": true`, `"blur_size": 6` | KWin blur, strength 1-15 (only visible with translucency) |

After editing the file by hand, run `rice apply`.

### How the old settings map

| Hyprland setting | On KDE |
|---|---|
| `opacity_active` | Konsole background opacity |
| `blur`, `blur_size` | KWin blur effect |
| animation preset | KDE animation speed (`off` = disabled, `snappy` = faster, `smooth` = normal) |
| `eyecare*` | KDE Night Light; the schedule is stored in KWin, so no background loop is needed |

Rice does not touch blur, animation speed or Night Light until you move them away from the defaults, so your own Plasma settings are safe. If you switch one back to default, rice resets it once and then leaves it alone again.

---

## 7. Troubleshooting

| Symptom | Fix |
|---|---|
| `Super+K` / `Super+S` do nothing | Log out and back in. Then check System Settings → Shortcuts for a conflict (the installer warns about duplicates it can see). Optional shortcut: `systemctl --user restart plasma-kglobalaccel.service`, but a re-login is the reliable way. |
| Tapping `Super` still opens the Kickoff menu | Check `kreadconfig6 --file kwinrc --group ModifierOnlyShortcuts --key Meta`. It should print `org.kde.krunner,/App,,toggleDisplay`. Then run `busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure` or re-login. |
| KRunner does not find "rice settings" | Run `rice desktop-entries` (it refreshes KDE's application cache), then try again. |
| `rice: command not found` in KRunner or a launcher | PATH is read at login; log out and in. Launchers use absolute paths, so they work even before that. |
| Wallpaper did not change | `plasma-apply-wallpaperimage` comes from `plasma-workspace`. Run `rice setup kde` to see which tool is missing. |
| Wallpaper is blurry or the wrong size | Set `"screen_size"` in `rice.json`, then `rice bg set NAME`. For sharper art: `rice ascii IMAGE --cols 320 --name megumin320`. |
| Colors did not change in an open app | Qt apps re-read colors live in most cases. Close and reopen the app if one stays on the old colors. |
| Konsole looks unchanged | Open a new Konsole window; it should use the `Rice` profile. If not, Settings → Manage Profiles → set `Rice` as default. |
| GTK apps do not match | Plasma's desktop portal passes dark/light to GTK apps. Install `xdg-desktop-portal-kde` and `kde-gtk-config` if missing. |
| Spotify did not change | Restart Spotify. After a Spotify update, run `rice setup spotify`. |
| Night Light does not react | System Settings → Display → Night Light should show your values after `rice eyecare on`. |
| `rice-settings` fails to start | Needs `tk` and XWayland (default on Plasma Wayland). Run it from a terminal to see the error. |

---

## 8. What does not carry over from Hyprland

No exact KDE equivalent exists for:

- Gaps between windows, colored borders, rounded corners and shadows per window.
- Per-window inactive opacity.
- Dwindle tiling and Hyprland's slide/popin animation styles.
- The Waybar pills (including the loud battery pill).

Closest options, as far as I know:

- **Rounding and widget styling:** Klassy or Kvantum (check the current packages for your distro).
- **Tiling:** Plasma's built-in tiling (`Meta+T`), or Krohnkite / Polonium.
- **Bar:** a floating, translucent panel. `rice-panel.js` in the zip adds one (workspaces, clock, tray). It is an untested sketch. Run it with:

  ```bash
  busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell evaluateScript s "$(cat rice-panel.js)"
  ```

  It creates a new panel and does not remove your existing one. Delete the old one yourself in Edit Mode, then set the new panel's Opacity to Translucent. For CPU and RAM, add "System Monitor Sensor" widgets from Add Widgets.

---

## 9. Undo

- Restore your files from `~/.kde-rice-backup-<date>`.
- Reset the color scheme in System Settings → Colors & Themes → Colors.
- Remove the shortcuts you do not want in System Settings → Shortcuts.
- Make Super open the normal menu again:
  `kwriteconfig6 --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu"`
  then reconfigure KWin or log out and in.
- Stop the day/night timer: `systemctl --user disable --now rice-auto.timer`.
