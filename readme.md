# Arch Linux + KDE Plasma: the rice, ported from Hyprland

*The same `rice` manager, 57 themes and ASCII backgrounds as the Hyprland guide, now driving a Plasma 6 desktop.*

**Conventions.** `$` is a normal-user prompt, `#` is root (or prefix with `sudo`). Paths starting with `~` are inside your home folder. The files arrive as `kde-rice.zip` plus `install-kde-packages.sh` (the package script from section 1.2). **Chapter numbers match the Hyprland guide**: chapter 6 is theme switching in both, chapter 14 is app theming in both. Where a Hyprland chapter has no KDE equivalent, the first line of the chapter says so.

**What you get**

- Your 57 themes, 7 ASCII backgrounds, the `rice` command and the `rice-settings` app, now driving Plasma instead of Hyprland.
- Every theme switch changes Plasma colors, fonts, icons, the Konsole profile and the wallpaper; Chromium, VS Code, Obsidian, Spotify and mpv follow.
- `Super+K` opens Konsole, `Super+S` opens Strawberry, tapping `Super` opens KRunner. KRunner also runs the settings app, theme switches, background changes and eyecare.
- Eyecare through KDE Night Light, with the same warmth guide as before.
- No Waybar pills, window gaps, colored borders or Hyprland tiling. See 15.2 for the closest substitutes.

> **Honesty note.** The generated files and command sequences were tested against a fake home with stubbed KDE tools. They were not run on a live Plasma session, so the shortcut and tap-`Super` steps in 5.1 are the first things to verify. Option names used here (`screen_size`, `kde_icons`, `kde_fonts`, `rice desktop-entries`, `rice setup kde`) come from the KDE edition's own notes; if one behaves differently, `rice help` on your machine is authoritative. Package names are Arch's; confirm with `pacman -Ss`.

---

## 1. Installation

Assumes **Arch Linux with Plasma 6 on Wayland**. On another distro, translate the package names; everything else is the same.

### 1.1 Get a Plasma session

Follow Hyprland guide chapter 1.1 to 1.4 (USB, `archinstall`, first boot) with these differences:

| Menu entry | Hyprland guide | KDE |
| --- | --- | --- |
| Profile → Type | Desktop → Hyprland | **Desktop → KDE Plasma** |
| Greeter | `ly` or `sddm`, pick Hyprland (uwsm) | `sddm`, pick **Plasma (Wayland)** |
| Additional packages | the long Hyprland list | none needed; section 1.2 installs everything |

Audio (pipewire), NetworkManager, zram and systemd-boot stay as in the Hyprland guide.

### 1.2 Install all packages and libraries

One script installs everything the rice needs: Python and Pillow (the ASCII renderer), Tk (the settings window), the KDE command-line tools, theming bridges, fonts, the themed apps and the AUR extras.

```bash
$ chmod +x install-kde-packages.sh
$ ./install-kde-packages.sh --upgrade
```

| Group | Packages | Why |
| --- | --- | --- |
| Core | `python python-pillow tk xorg-xwayland fontconfig jq xdg-utils libnotify dconf gsettings-desktop-schemas` | the `rice` script, wallpaper renderer, `rice-settings` window (Tk runs through XWayland), notifications, GTK color-scheme setting |
| KDE | `konsole strawberry kconfig plasma-workspace libkscreen breeze breeze-gtk plasma-integration kio-extras kde-gtk-config xdg-desktop-portal-kde xdg-desktop-portal-gtk gnome-themes-extra` | `kwriteconfig6` / `kreadconfig6` (kconfig); `plasma-apply-colorscheme`, `plasma-apply-wallpaperimage` and KRunner (plasma-workspace); `kscreen-doctor` for your screen size (libkscreen); widget style, icons and GTK bridging |
| Fonts | `inter-font ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji` | Inter (UI), JetBrainsMono Nerd Font (terminal), Noto (Georgian, emoji) |
| Apps | `chromium code obsidian mpv gwenview ffmpegthumbs kdegraphics-thumbnailers` | the apps rice themes live |
| AUR | `ttf-monocraft spotify spicetify-cli` | pixel font, Spotify and its theming |

Options:

- `--upgrade` runs a full `pacman -Syu` first. Recommended, because Arch does not support partial upgrades.
- `--minimal` installs only what `rice` itself needs (no browser, editor or media apps, no AUR).
- `--no-aur` skips the AUR group. Without `--yes`, the script asks before touching the AUR, and builds `yay-bin` if you have no AUR helper.
- `--extras` adds Kvantum. `--yes` answers every question. `--dry-run` prints what would run.
- `--check` changes nothing and verifies that every command, the Python libraries (Pillow, Tk, `tomllib`) and the fonts are present. Run it any time something misbehaves.

The script skips packages that are already installed and reports any name your mirrors do not have instead of aborting. If you prefer to do it by hand:

```bash
$ sudo pacman -S --needed python python-pillow tk xorg-xwayland fontconfig jq xdg-utils libnotify dconf gsettings-desktop-schemas konsole strawberry kconfig plasma-workspace libkscreen breeze breeze-gtk plasma-integration kio-extras kde-gtk-config xdg-desktop-portal-kde xdg-desktop-portal-gtk gnome-themes-extra inter-font ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji chromium code obsidian mpv gwenview ffmpegthumbs kdegraphics-thumbnailers
$ yay -S --needed ttf-monocraft spotify spicetify-cli
$ fc-cache -f
```

The pixel font is optional; if `ttf-monocraft` is not found, see Hyprland guide 1.5.

### 1.3 Install the rice

```bash
$ unzip kde-rice.zip && cd kde-rice
$ ./install-kde.sh
```

The installer:

1. Backs up what it replaces to `~/.kde-rice-backup-<date>`.
2. Copies `rice`, `rice-settings`, the themes, templates and backgrounds into `~/.local/bin` and `~/.config/rice`.
3. Keeps your own `rice.json` if you have one (the new default is saved as `rice.json.new`). Use `./install-kde.sh --force` to overwrite everything.
4. Adds `~/.local/bin` to PATH for the whole Plasma session.
5. Sets the shortcuts and KRunner options (chapter 5).
6. Creates the KRunner launchers (5.4).
7. Enables a small timer for automatic day/night switching. It does nothing until you turn auto switching on.
8. Runs `rice apply` once.

### 1.4 Log out and back in

Shortcuts, the tap-`Super` setting and the new PATH are read at login. Do it once; it is the reliable way.

### 1.5 One-time app setup

```bash
$ rice setup
```

This prepares Chromium, VS Code, Obsidian and Spotify so they follow every theme change, and prints any `sudo` line it cannot run itself. Before running it, start VS Code, Obsidian (open your vault) and Spotify (log in) once, then close them, and run the two permission lines from 14.1. `rice setup` is safe to repeat.

### 1.6 Coming from the Hyprland version

The installer's safe mode keeps your `~/.config/rice/rice.json`, so fonts, themes, backgrounds and eyecare settings carry over. Hyprland-only keys (gaps, border size, rounding, shadows, bar layout, inactive opacity) have no effect on Plasma and can stay. Note that the installer replaces `~/.local/bin/rice` and `rice-settings` with the KDE editions (the old ones are in the backup folder), so a Hyprland session on the same account would call the KDE script. Use one edition per account, or restore the backup before logging into Hyprland.

---

## 2. Wi-Fi

No changes. Plasma uses NetworkManager, so the live-USB steps (2.1 to 2.3) and the `nmcli` commands in 2.4 of the Hyprland guide apply as written. Day to day, use the network applet in the system tray instead of the bar's click-to-`nmtui`.

---

## 3. Laptop power

The TLP and NetworkManager power files are unchanged; install them as in Hyprland guide 1.6:

```bash
$ sudo install -Dm644 etc/tlp.d/10-rice.conf /etc/tlp.d/10-rice.conf
$ sudo install -Dm644 etc/NetworkManager/conf.d/wifi-powersave.conf /etc/NetworkManager/conf.d/wifi-powersave.conf
$ sudo tlp start && sudo systemctl restart NetworkManager
```

What replaces the Hyprland pieces:

| Hyprland | Plasma |
| --- | --- |
| `hypridle` (dim, lock, screen off, suspend) | System Settings → Energy Saving and Screen Locking. To match the old timers: dim 2.5 min, lock 5 min, screen off 5.5 min, suspend 15 min. |
| `hyprlock` | Plasma's own lock screen (not themed by rice) |
| `misc:vfr`, blur and shadows off | KWin handles redraws. Translucency and blur cost GPU; rice leaves blur off by default. |
| no `power-profiles-daemon` | Same rule. Plasma's power-profile slider needs that daemon, so with TLP it is simply absent. |

---

## 4. Dotfile structure

The layout mirrors the Hyprland dotfiles (confirm with `unzip -l kde-rice.zip`):

```text
kde-rice/
├── install-kde.sh                   copies everything into $HOME
├── rice-panel.js                    optional panel sketch (chapter 8)
├── .local/bin/
│   ├── rice                         the manager (themes, backgrounds, animation, eyecare)
│   └── rice-settings                Tk settings GUI
└── .config/rice/
    ├── rice.json                    YOUR settings
    ├── themes/*.toml                one file = one theme
    ├── backgrounds/*.txt            one file = one ASCII background
    └── templates/*                  one template per app
```

**How it flows.** `rice apply` reads `rice.json`, the active theme and the templates, then writes or sets:

| Generated item | Used by |
| --- | --- |
| color scheme `Rice-<theme>` (applied with `plasma-apply-colorscheme`) | Plasma, all Qt/KDE apps, titlebars (its `[WM]` section) |
| single keys in `~/.config/kdeglobals` (UI and monospace font, icon theme) | Plasma and Qt apps; the file is never overwritten as a whole |
| Konsole profile and color scheme `Rice`, set as default | Konsole |
| ASCII wallpaper PNG in `~/.cache/rice/bg/` (`plasma-apply-wallpaperimage`) | desktop |
| `~/.local/share/applications/rice-*.desktop` | KRunner launchers (5.4) |
| Chromium policy, VS Code `settings.json`, Obsidian snippet, spicetify `color.ini`, `mpv.conf` | same mechanisms as Hyprland chapter 14 |
| user timer `rice-auto.timer` | automatic day/night switching |

**Never edit generated files**; edit `rice.json`, a theme or a template, then run `rice apply`. Template variables and suffixes (`{{bg.hex}}`, `{{bg.rgb}}`) work as in the Hyprland guide.

---

## 5. Hotkeys and KRunner

`Super` is the Windows key.

| Keys | Action | Hyprland equivalent |
| --- | --- | --- |
| `Super+K` | Konsole | `Super+Return` |
| `Super+S` | Strawberry (a second press raises the running window) | `Super+S` opened the settings app |
| tap `Super` | KRunner | `Super+D` (fuzzel) |
| `Alt+Space`, `Alt+F2` | KRunner (Plasma defaults, still active) | none |
| settings app | KRunner: `rice settings` | `Super+S` |

Window management keys (close, fullscreen, workspaces, move/resize) are Plasma's own; see System Settings → Shortcuts.

### 5.1 Verify (do this first)

1. Press `Super+K`: Konsole should open.
2. Press `Super+S`: Strawberry should open.
3. Tap `Super`: KRunner should appear in the middle of the screen.

If one does nothing, see 15.1.

### 5.2 Change a shortcut later

System Settings → Keyboard → Shortcuts, search for Konsole or Strawberry and set a new key. Or re-run the command the installer uses, then log out and in:

```bash
$ kwriteconfig6 --file kglobalshortcutsrc --group services --group org.kde.konsole.desktop --key _launch 'Meta+Return,none,Konsole'
```

### 5.3 Want `Super+D` for KRunner, like in Hyprland?

Plasma uses `Super+D` for Peek at Desktop. Clear it in System Settings → Shortcuts, then set KRunner's shortcut (System Settings → Search → KRunner) to `Super+D`.

### 5.4 Using KRunner for everything

Open KRunner and type:

| Type in KRunner | CLI equivalent | Result |
| --- | --- | --- |
| `rice settings` | `rice-settings` | opens the settings app |
| `rice theme mint` (or just `mint`) | `rice theme mint` | switches theme |
| `rice toggle` | `rice toggle` | day and night sibling of the current theme |
| `rice next background`, `previous`, `random`, `main` | `rice bg next`, `prev`, `random`, `main` | changes the ASCII wallpaper |
| `rice eyecare on` / `off` | `rice eyecare on` / `off` | KDE Night Light |
| an app name, a calculation, a file |  | KRunner's normal job |

These are real launchers named `rice-*.desktop` in `~/.local/share/applications`: one for the settings app, one per quick action and one per theme (65 in total). After adding a theme file, recreate them with `rice desktop-entries`. They may also show up under Settings in the application menu; you can ignore that. The Command Line KRunner plugin is enabled too, so typing `rice bg set megumin` also works.

---

## 6. Theme switching

Same commands as Hyprland chapter 6:

```bash
$ rice list themes            # 57 names
$ rice theme mint             # switch now
$ rice theme next             # cycle (CLI only)
$ rice toggle                 # day <-> night, same color family
```

`rice theme NAME` now also reapplies the Plasma color scheme, titlebar colors, fonts, icons (`breeze` or `breeze-dark` to match light and dark), the Konsole profile and the wallpaper. Already-open Konsole windows keep their old profile; new windows get the new one.

**Day / night.** `day_theme` and `night_theme` in `rice.json` are the two sides of the toggle (defaults `sakura` and `lavender-night`). The 48 color themes are named `COLOR-VARIATION-day` / `COLOR-VARIATION-night` (blue, red, green, yellow, pink, purple, orange, brown × pastel, muted, vivid), and `rice toggle` moves to the sibling of the same color and variation. The 9 originals use the `day_theme` / `night_theme` pair.

**Automatic switching.** `rice set auto_daynight true` (day from 07:00, night from 19:00; `day_start` and `night_start` change that). On KDE a user timer does the checking instead of the Hyprland autostart loop. A manual choice sticks until the next sunrise or sunset boundary.

**Adding a theme = adding one file.** Copy any file in `~/.config/rice/themes/`, change the colors (all 14 keys are required: `mode`, `bg`, `bg_alt`, `surface`, `fg`, `fg_dim`, `accent`, `accent_alt`, `border`, `red`, `green`, `yellow`, `blue`, `on_accent`), then:

```bash
$ rice theme mynewtheme
$ rice desktop-entries        # so KRunner finds it
```

---

## 7. Background switching

Backgrounds are plain `.txt` files in `~/.config/rice/backgrounds/`. `rice` renders the chosen one to a screen-sized PNG in the theme's colors and sets it with `plasma-apply-wallpaperimage`. Renders are cached in `~/.cache/rice/bg/`, so switching is instant after the first time per theme.

| Command | KRunner phrase | Hyprland hotkey (not set on KDE) |
| --- | --- | --- |
| `rice bg main` | `rice main background` | `Super+Alt+M` |
| `rice bg next` / `prev` | `rice next background` / `previous` | `Super+Alt+→` / `←` |
| `rice bg random` | `rice random background` | `Super+Alt+R` |
| `rice bg set NAME` | `rice bg set NAME` |  |
| `rice bg list` |  |  |

Want the old hotkeys back? System Settings → Keyboard → Shortcuts → Add New → Command or Script, with the command from the first column.

**Screen size.** It is detected with `kscreen-doctor`. If the wallpaper has the wrong resolution, set `screen_size` to `2560x1440` (or yours) in `rice.json`, then run `rice bg set NAME`.

### 7.1 Filling the screen and soft edges

Each background can carry options in `~/.config/rice/backgrounds/NAME.toml`, or use the settings app's Background art tab, or `rice bg opts NAME '{"soften": 3}'`:

| Option | Values | Meaning |
| --- | --- | --- |
| `fit` | `contain` / `cover` | `contain` shows the art at `scale`% of the screen; `cover` stretches it to fill the display exactly |
| `scale` | 20-100 | size in `contain` mode |
| `soften` | 0-10 | 0 crisp glyphs, about 2 soft edges but still ASCII, 4+ smooth and image-like |
| `feather` | 0-50 (%) | fades the outer border into the background color |
| `strength` | 0-1 | how strongly the ink color shows; lower is calmer |

For finer detail, convert the original image with more columns:

```bash
$ rice ascii ~/Pictures/megumin.png --cols 320 --name megumin320
$ rice bg set megumin320
```

| `--cols` | Character size on QHD | Look |
| --- | --- | --- |
| 213 | about 12 px | chunky, retro |
| 320 | about 8 px | good balance (default) |
| 426 | about 6 px | fine detail, slower first render |

Options `--invert`, `--gamma` and `--aspect` work as in Hyprland chapter 7.

---

## 8. Panel (replaces Waybar)

There is no Waybar on Plasma, so the bar module system (`rice bar`, left/center/right modules, the loud battery pill) is gone. Use Plasma's own panel:

- **Hide / show** (was `Super+B`): panel Edit Mode → Visibility → Auto Hide.
- **Workspaces, clock, tray, battery, keyboard layout, volume:** all standard panel widgets.
- **CPU, RAM, temperature:** add System Monitor Sensor widgets from Add Widgets.
- **Floating translucent look:** `rice-panel.js` in the zip creates a new panel with workspaces, clock and tray. It is an **untested sketch**:

```bash
$ busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell evaluateScript s "$(cat rice-panel.js)"
```

It adds a new panel and does not remove your existing one. Delete the old one yourself in Edit Mode, then set the new panel's Opacity to Translucent.

---

## 9. Animations

Hyprland's animation presets map to KDE's global animation speed:

| Preset | On KDE |
| --- | --- |
| `off` | animations disabled |
| `snappy` | faster animations |
| `smooth` (default) | normal speed |
| `eco`, `minimal` | not covered by the KDE notes; try `rice anim eco` and check System Settings → Workspace Behavior → General Behavior |

```bash
$ rice anim snappy
```

Rice does not touch animation speed until you move it away from the default. If you switch back to the default, rice resets it once and then leaves it alone. Slide and popin styles are Hyprland-only.

---

## 10. Fonts

Same table and commands as Hyprland chapter 10: Inter for UI, JetBrainsMono Nerd Font for the terminal and ASCII art, Noto Sans Georgian and Noto Color Emoji as fallbacks, Monocraft (AUR) as the optional pixel font.

```bash
$ rice set font_ui 'Inter'
$ rice set font_mono 'JetBrainsMono Nerd Font'
$ rice set font_size 12
$ fc-list : family | sort -u        # exact family names
```

On KDE the UI and monospace fonts are also written into Plasma's font settings, key by key. Set `kde_fonts` to `false` to stop rice touching them. The lock-screen clock font from the Hyprland guide does not apply.

---

## 11. Keyboard layouts (English / Russian / Georgian)

Plasma manages layouts itself: System Settings → Keyboard → Layouts → enable Configure layouts, add English (US), Russian and Georgian, and set a shortcut under Main shortcuts (`Alt+Shift` matches the Hyprland setup). The panel's Keyboard Layout widget replaces the bar's `ge`/`ru`/`us` indicator. The command-line equivalent, then log out and in:

```bash
$ kwriteconfig6 --file kxkbrc --group Layout --key Use true
$ kwriteconfig6 --file kxkbrc --group Layout --key LayoutList 'us,ru,ge'
$ kwriteconfig6 --file kxkbrc --group Layout --key Options 'grp:alt_shift_toggle'
```

Georgian needs `noto-fonts` (installed by the package script).

---

## 12. Changing visuals

Most things are one-line settings in `~/.config/rice/rice.json`, or in the settings app, or `rice set KEY VALUE`. After editing the file by hand, run `rice apply`.

| Want | Setting | Notes |
| --- | --- | --- |
| Konsole opacity | `opacity_active` | `0.5` to `1.0`; was window opacity on Hyprland |
| Blur | `blur` (`true` / `false`), `blur_size` 1-15 | KWin blur; only visible with translucency; costs GPU |
| Icons | `kde_icons` | `auto` = breeze / breeze-dark; a theme name such as `Papirus-Dark`; empty to leave your icons alone |
| KDE fonts | `kde_fonts` | `false` = do not touch them |
| Screen size | `screen_size` | e.g. `2560x1440` if auto-detect is wrong |
| Colors | the theme `.toml` | edit `accent`, `bg`, etc. |

Rice leaves blur, animation speed and Night Light alone until you move them away from the defaults, so your own Plasma settings are safe.

### Eyecare mode (warm screen)

Handled by **KDE Night Light**. The schedule is stored in KWin, so no background loop is needed. It is independent of the day/night theme.

| Setting | Meaning |
| --- | --- |
| `eyecare` | manual on/off |
| `eyecare_temp` | kelvin, 1000-6500 (Night Light's range). Lower is warmer. |
| `eyecare_schedule` | if `true`, the schedule decides |
| `eyecare_start`, `eyecare_end` | schedule hours (24h); may wrap midnight, default 20 to 7 |

Warmth guide: `6500` neutral, `4500` mild, `4000` default, `3500` strong, `3000` very warm, `2500` candle-like. CLI: `rice eyecare on|off`, `rice eyecare temp 3500`. System Settings → Display → Night Light should show your values.

---

## 13. The settings app

Open it with KRunner (`rice settings`) or run `rice-settings` (`Super+S` is Strawberry on KDE). It needs `tk` and XWayland (default on Plasma Wayland), so text can look slightly soft on fractional scaling; it is a utility window, not a daily driver.

| Tab | What it does on KDE |
| --- | --- |
| **Look** | theme, day/night themes, auto switching, animation preset, main background, Konsole opacity, window blur and strength |
| **Eyecare** | on/off, warmth in kelvin, schedule |
| **Background art** | fit, softness, edge fade and ink strength per background |
| **Fonts** | UI, monospace and pixel fonts, size, terminal and ASCII-art font |
| **Apps** | extra Obsidian vault, auto-apply Spotify, **Set up apps** and **Refresh apps only** buttons |

**Apply** saves and regenerates; **Day / Night** and **Next background** act immediately. The **Layout** and **Bar modules** tabs from the Hyprland version were removed because gaps, borders, rounding and Waybar do not exist in Plasma. Everything the app does is `rice set-many '{...}'`, so it can be scripted.

---

## 14. App theming (Plasma, Konsole, Chromium, VS Code, Spotify, Obsidian, media apps)

Goal: change the theme once and all of these follow. `rice apply` does the work on every theme change; the one-time part is `rice setup`.

### 14.1 One-time setup

```bash
$ sudo mkdir -p /etc/chromium/policies/managed && sudo chown $USER /etc/chromium/policies/managed
$ sudo chmod a+wr /opt/spotify -R && sudo chmod a+wr /opt/spotify/Apps -R
$ # start VS Code, Obsidian (open your vault) and Spotify (log in) once, then close them
$ rice setup
```

`rice setup` is safe to repeat and tells you which `sudo` lines are still missing. Individual steps: `rice setup chromium|vscode|obsidian|spotify|portal|kde`. The settings app's **Set up apps** button does the same.

### 14.2 What happens per app

| App | Mechanism | Live? |
| --- | --- | --- |
| **Plasma and Qt apps** | color scheme `Rice-<theme>`, fonts and icons set key by key | Yes, in most apps; reopen one that keeps old colors |
| **Konsole** | `Rice` profile and color scheme as default | New windows only |
| **VS Code** | colors, token colors and your monospace font merged into `settings.json` (comments in it are removed; a backup is saved the first time) | Yes |
| **Obsidian** | snippet `rice.css` written into every vault and enabled | Yes (restart once the first time) |
| **Chromium** | managed policy sets the theme color and dark/light; Chromium shows Managed by your organization | Yes |
| **Spotify** | spicetify regenerates `color.ini` and applies it | Restart Spotify; after a Spotify update run `rice setup spotify` |
| **mpv** | background and on-screen text colors in `mpv.conf` | Next start |
| **GTK apps** | dark/light passed through the desktop portal | Yes |

GTK apps not matching? Make sure `xdg-desktop-portal-kde` and `kde-gtk-config` are installed (the package script does this).

### 14.3 Recommended media apps

Gwenview (images), mpv (video, hardware decoding) and Strawberry (music) are installed by the package script, follow the Qt theme automatically, and are the same picks as Hyprland chapter 14.4. Set defaults:

```bash
$ xdg-mime default org.kde.gwenview.desktop image/png image/jpeg image/webp image/gif image/avif
$ xdg-mime default mpv.desktop video/mp4 video/x-matroska video/webm video/quicktime
$ xdg-mime default org.strawberrymusicplayer.strawberry.desktop audio/mpeg audio/flac audio/ogg audio/x-wav
```

### 14.4 Updating only some targets

```bash
$ rice apply apps              # Plasma/Qt, Konsole, VS Code, Obsidian, Chromium, Spotify, mpv, GTK
$ rice apply desktop           # only wallpaper, blur, animation, eyecare
$ rice apply vscode obsidian   # just those two
$ rice theme mint apps         # switch theme but refresh only the apps
$ rice list targets            # all valid target names
```

---

## 15. Troubleshooting, limits, tuning and undo

### 15.1 Troubleshooting

| Symptom | Fix |
| --- | --- |
| `Super+K` / `Super+S` do nothing | Log out and back in, then check System Settings → Shortcuts for a conflict. `systemctl --user restart plasma-kglobalaccel.service` can work, but a re-login is the reliable way. |
| Tapping `Super` still opens Kickoff | `kreadconfig6 --file kwinrc --group ModifierOnlyShortcuts --key Meta` should print `org.kde.krunner,/App,,toggleDisplay`. Then `busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure` or re-login. |
| KRunner does not find `rice settings` | `rice desktop-entries` (refreshes KDE's application cache), then try again. |
| `rice: command not found` in a launcher | PATH is read at login; log out and in. Launchers use absolute paths, so they work before that. |
| Wallpaper did not change | `plasma-apply-wallpaperimage` comes from `plasma-workspace`. Run `./install-kde-packages.sh --check` and `rice setup kde`. |
| Wallpaper blurry or wrong size | Set `screen_size`, then `rice bg set NAME`. Sharper art: `rice ascii IMAGE --cols 320 --name megumin320`. |
| Colors did not change in an open app | Close and reopen it. |
| Konsole looks unchanged | Open a new window; if still wrong, Settings → Manage Profiles → set `Rice` as default. |
| Spotify did not change | Restart it; after an update run `rice setup spotify`. |
| Night Light does not react | System Settings → Display → Night Light should show your values after `rice eyecare on`. |
| `rice-settings` fails to start | Needs `tk` and XWayland. Run it from a terminal to see the error, or run `./install-kde-packages.sh --check`. |

### 15.2 What does not carry over from Hyprland

No exact KDE equivalent exists for window gaps, colored borders, rounded corners and shadows per window, per-window inactive opacity, dwindle tiling, Hyprland's slide and popin animation styles, and the Waybar pills (including the loud battery pill).

Closest options, as far as I know:

- **Rounding and widget styling:** Klassy (AUR) or Kvantum (`--extras`); check current package names.
- **Tiling:** Plasma's built-in tiling (`Meta+T`), or Krohnkite / Polonium.
- **Bar:** chapter 8.

### 15.3 Battery wins

Same order as Hyprland chapter 15: screen brightness, fewer Chromium tabs, no blur, TLP in place, suspend on idle (3), the pure `black` theme on OLED, `off` or `snappy` animations, `powertop` tunables.

### 15.4 Undo

- Restore your files from `~/.kde-rice-backup-<date>`.
- Reset the color scheme: System Settings → Colors & Themes → Colors.
- Remove shortcuts you do not want: System Settings → Shortcuts.
- Make `Super` open the normal menu again:

```bash
$ kwriteconfig6 --file kwinrc --group ModifierOnlyShortcuts --key Meta 'org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu'
```

then reconfigure KWin or log out and in.

- Stop the day/night timer: `systemctl --user disable --now rice-auto.timer`.

---

## Appendix: what ships where

Unlike the Hyprland guide, this guide does not reprint every file. They live in the delivered files:

| File | Contents |
| --- | --- |
| `install-kde-packages.sh` | every package and library (section 1.2); `--check` verifies them |
| `kde-rice.zip` → `install-kde.sh` | the rice installer (1.3) |
| `kde-rice.zip` → `.local/bin/rice`, `rice-settings` | the manager and the Tk settings app |
| `kde-rice.zip` → `.config/rice/` | `rice.json`, the 57 themes, 7 backgrounds, templates |
| `kde-rice.zip` → `rice-panel.js` | optional panel sketch (chapter 8) |

The theme color table is identical to the Hyprland guide's appendix, because the `.toml` files are unchanged.
