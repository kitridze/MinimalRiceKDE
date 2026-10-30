#!/usr/bin/env bash
# Installs the KDE Plasma edition of the rice dotfiles into $HOME.
#   ./install-kde.sh          safe: keeps your own rice.json (new default saved as rice.json.new)
#   ./install-kde.sh --force  overwrite everything (old files are still backed up)
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
FORCE=0; [ "${1:-}" = "--force" ] && FORCE=1
BK="$HOME/.kde-rice-backup-$(date +%Y%m%d-%H%M%S)"
PRESERVE=" .config/rice/rice.json "
mkdir -p "$BK"

for item in .config/rice .config/spicetify .local/bin/rice .local/bin/rice-settings; do
  [ -e "$HOME/$item" ] && { mkdir -p "$BK/$(dirname "$item")"; cp -a "$HOME/$item" "$BK/$item"; }
  while IFS= read -r -d '' f; do
    rel="${f#"$SRC"/}"; dest="$HOME/$rel"
    mkdir -p "$(dirname "$dest")"
    if [ "$FORCE" = 0 ] && [ -e "$dest" ] && [[ "$PRESERVE" == *" $rel "* ]]; then
      cmp -s "$f" "$dest" || { cp "$f" "$dest.new"; echo "kept yours : ~/$rel (new default saved as ~/$rel.new)"; }
    else
      cp -a "$f" "$dest"
    fi
  done < <(find "$SRC/$item" -type f -print0)
done
chmod +x "$HOME/.local/bin/rice" "$HOME/.local/bin/rice-settings"
# old Hyprland-only templates from a previous install are not used any more
rm -f "$HOME"/.config/rice/templates/{foot.ini,fuzzel.ini,hypr-theme.conf,hyprlock.conf,mako.conf,waybar.css,kdeglobals}

# ~/.local/bin on PATH for the whole Plasma session (KRunner, Konsole, autostart)
mkdir -p "$HOME/.config/plasma-workspace/env"
printf '%s\n' 'export PATH="$HOME/.local/bin:$PATH"' > "$HOME/.config/plasma-workspace/env/rice-path.sh"
export PATH="$HOME/.local/bin:$PATH"

KW=$(command -v kwriteconfig6 || command -v kwriteconfig5 || true)
[ -n "$KW" ] || { echo "kwriteconfig6 not found (package: kconfig). Install it and re-run."; exit 1; }

# --- shortcuts: Super+K -> Konsole, Super+S -> Strawberry --------------------------------------------
"$KW" --file kglobalshortcutsrc --group services --group org.kde.konsole.desktop --key _launch "Meta+K,none,Konsole"
"$KW" --file kglobalshortcutsrc --group services --group org.strawberrymusicplayer.strawberry.desktop --key _launch "Meta+S,none,Strawberry"
for k in 'Meta+K' 'Meta+S'; do
  if grep -n "${k}[,[:space:]]" "$HOME/.config/kglobalshortcutsrc" 2>/dev/null | grep -v -e org.kde.konsole -e strawberry -e '_launch=Meta+[KS],none' >/dev/null 2>&1; then
    echo "note: $k also appears elsewhere in ~/.config/kglobalshortcutsrc; check System Settings > Shortcuts for a conflict."
  fi
done

# --- KRunner as the launcher for everything --------------------------------------------------------
# Tapping the Super key opens KRunner (instead of the Kickoff menu); Alt+Space / Alt+F2 keep working.
"$KW" --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.krunner,/App,,toggleDisplay"
"$KW" --file krunnerrc --group General --key FreeFloating true
"$KW" --file krunnerrc --group General --key ActivateWhenTypingOnDesktop true
"$KW" --file krunnerrc --group Plugins --key shellEnabled true
busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure >/dev/null 2>&1 || true

# --- KRunner launchers (Rice Settings, quick actions, one per theme) --------------------------------
rice desktop-entries

# --- optional: automatic day/night theme switching (only acts if `rice set auto_daynight true`) ----
if command -v systemctl >/dev/null; then
  mkdir -p "$HOME/.config/systemd/user"
  cp "$SRC"/.config/systemd/user/rice-auto.* "$HOME/.config/systemd/user/"
  systemctl --user daemon-reload || true
  systemctl --user enable --now rice-auto.timer || true
fi

rice apply || true
echo
echo "Done. Backup of replaced files: $BK"
echo "Log out and back in once (shortcuts, Super-tap and PATH are read at login)."
echo "Then run 'rice setup' once for Chromium / VS Code / Obsidian / Spotify theming."
