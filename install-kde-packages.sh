#!/usr/bin/env bash
# install-kde-packages.sh
# Installs every package and library the KDE rice needs (Arch Linux and Arch-based distros).
# Run it BEFORE ./install-kde.sh. Safe to repeat: already-installed packages are skipped.
#
#   ./install-kde-packages.sh              core + KDE + fonts + apps, then asks about AUR packages
#   ./install-kde-packages.sh --yes        no questions (also installs the AUR packages)
#   ./install-kde-packages.sh --upgrade    full system upgrade first (pacman -Syu); recommended
#   ./install-kde-packages.sh --minimal    only what rice itself needs (no browser/editor/media apps)
#   ./install-kde-packages.sh --extras     also Kvantum (widget styling)
#   ./install-kde-packages.sh --no-aur     skip AUR packages (Monocraft, Spotify, spicetify)
#   ./install-kde-packages.sh --dry-run    print what would run, change nothing
#   ./install-kde-packages.sh --check      only verify that everything is present
set -euo pipefail

# ---------------------------------------------------------------- package lists
# Python runtime and libraries (Pillow = ASCII wallpaper renderer, tk = rice-settings, tomllib is built in)
CORE=(python python-pillow tk xorg-xwayland fontconfig jq xdg-utils libnotify dconf gsettings-desktop-schemas)
# KDE tools the rice calls: kconfig = kwriteconfig6/kreadconfig6, plasma-workspace = plasma-apply-*, KRunner,
# libkscreen = kscreen-doctor; the rest makes Qt and GTK apps follow the colors
KDE=(konsole strawberry kconfig plasma-workspace libkscreen breeze breeze-gtk plasma-integration kio-extras
     kde-gtk-config xdg-desktop-portal-kde xdg-desktop-portal-gtk gnome-themes-extra)
# Fonts: Inter (UI), JetBrainsMono Nerd Font (terminal), Noto (Georgian, emoji)
FONTS=(inter-font ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji)
# Apps that rice themes live (skipped with --minimal)
APPS=(chromium code obsidian mpv gwenview ffmpegthumbs kdegraphics-thumbnailers)
EXTRAS=(kvantum)
# AUR: pixel font, Spotify, spicetify (Spotify theming)
AUR_PKGS=(ttf-monocraft spotify spicetify-cli)

# ---------------------------------------------------------------- options
YES=0; DRY=0; AUR=1; CHECK_ONLY=0; WITH_EXTRAS=0; MINIMAL=0; UPGRADE=0
MISSING=()

say() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
run() { if [ "$DRY" = 1 ]; then printf '+ %s\n' "$*"; else "$@"; fi; }

usage() { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; }

for arg in "$@"; do
  case "$arg" in
    --yes|-y) YES=1 ;;
    --dry-run) DRY=1 ;;
    --no-aur) AUR=0 ;;
    --check) CHECK_ONLY=1 ;;
    --extras) WITH_EXTRAS=1 ;;
    --minimal) MINIMAL=1 ;;
    --upgrade) UPGRADE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $arg (try --help)" ;;
  esac
done

NOCONF=""
if [ "$YES" = 1 ]; then NOCONF="--noconfirm"; fi

# ---------------------------------------------------------------- verification
check() {
  local bad=0 c f
  say "== Checking commands"
  for c in python3 kwriteconfig6 kreadconfig6 plasma-apply-colorscheme plasma-apply-wallpaperimage \
           kscreen-doctor krunner konsole strawberry busctl fc-list notify-send jq; do
    if command -v "$c" >/dev/null 2>&1; then printf '  ok       %s\n' "$c"
    else printf '  MISSING  %s\n' "$c"; bad=1; fi
  done
  say "== Checking Python libraries"
  if python3 -c 'import PIL, tkinter, tomllib' 2>/dev/null; then say "  ok       PIL (Pillow), tkinter, tomllib"
  else say "  MISSING  one of: PIL (python-pillow), tkinter (tk), tomllib (Python 3.11+)"; bad=1; fi
  say "== Checking fonts"
  for f in "Inter" "JetBrainsMono Nerd Font" "Noto Sans Georgian" "Noto Color Emoji"; do
    if fc-list : family 2>/dev/null | grep -qi -- "$f"; then printf '  ok       %s\n' "$f"
    else printf '  MISSING  %s\n' "$f"; bad=1; fi
  done
  if fc-list : family 2>/dev/null | grep -qi 'Monocraft'; then say "  ok       Monocraft (optional pixel font)"
  else say "  optional Monocraft not installed (AUR: ttf-monocraft)"; fi
  say "== Checking session"
  say "  desktop: ${XDG_CURRENT_DESKTOP:-unknown}   session: ${XDG_SESSION_TYPE:-unknown}   (expected: KDE / wayland)"
  return "$bad"
}

if [ "$CHECK_ONLY" = 1 ]; then
  if check; then say "All good."; exit 0; else say "Something is missing: run ./install-kde-packages.sh"; exit 1; fi
fi

# ---------------------------------------------------------------- sanity
[ "$(id -u)" -ne 0 ] || die "run this as your normal user; sudo is called where needed"

if ! command -v pacman >/dev/null 2>&1; then
  cat >&2 <<'EOF'
This script uses pacman (Arch Linux and derivatives such as EndeavourOS or Manjaro).
On another distro, install the equivalents of the package lists at the top of this file:
  Python 3.11+, Pillow, Tk, Konsole, Strawberry, KConfig tools (kwriteconfig6), plasma-workspace,
  libkscreen, Breeze, plasma-integration, xdg-desktop-portal-kde/gtk, jq, libnotify,
  fonts: Inter, JetBrainsMono Nerd Font, Noto Sans (Georgian), Noto Color Emoji.
Then run: ./install-kde-packages.sh --check
EOF
  exit 1
fi

# ---------------------------------------------------------------- install
install_group() {
  local title="$1"; shift
  local ok=() missing=() p
  for p in "$@"; do
    if pacman -Qq "$p" >/dev/null 2>&1; then continue; fi
    if pacman -Si "$p" >/dev/null 2>&1; then ok+=("$p"); else missing+=("$p"); fi
  done
  say "== $title"
  if [ "${#missing[@]}" -gt 0 ]; then
    say "   not found in your repositories (skipped): ${missing[*]}"
    MISSING+=("${missing[@]}")
  fi
  if [ "${#ok[@]}" -eq 0 ]; then say "   nothing to install"; return 0; fi
  say "   installing: ${ok[*]}"
  run sudo pacman -S --needed $NOCONF "${ok[@]}"
}

bootstrap_helper() {
  say "   no AUR helper found: building yay-bin"
  if [ "$DRY" = 1 ]; then say "+ (install git base-devel, clone yay-bin from the AUR, makepkg -si)"; return 0; fi
  sudo pacman -S --needed $NOCONF git base-devel
  local tmp; tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  ( cd "$tmp/yay-bin" && makepkg -si $NOCONF )
  rm -rf "$tmp"
}

install_aur() {
  local helper todo=() p
  say "== AUR packages"
  for p in "${AUR_PKGS[@]}"; do
    if ! pacman -Qq "$p" >/dev/null 2>&1; then todo+=("$p"); fi
  done
  if [ "${#todo[@]}" -eq 0 ]; then say "   nothing to install"; return 0; fi
  if ! command -v yay >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then bootstrap_helper; fi
  helper="$(command -v yay || command -v paru || echo yay)"
  say "   installing with $helper: ${todo[*]}"
  run "$helper" -S --needed $NOCONF "${todo[@]}"
}

if [ "$UPGRADE" = 1 ] || ! compgen -G '/var/lib/pacman/sync/*.db' >/dev/null; then
  say "== Updating the system (pacman -Syu)"
  run sudo pacman -Syu $NOCONF
fi

install_group "Core: Python, Pillow, Tk, utilities" "${CORE[@]}"
install_group "KDE tools and theming support" "${KDE[@]}"
install_group "Fonts" "${FONTS[@]}"
if [ "$MINIMAL" = 0 ]; then install_group "Apps themed by rice" "${APPS[@]}"; fi
if [ "$WITH_EXTRAS" = 1 ]; then install_group "Extras" "${EXTRAS[@]}"; fi

if [ "$AUR" = 1 ] && [ "$MINIMAL" = 0 ]; then
  go="$YES"
  if [ "$YES" = 0 ] && [ -t 0 ]; then
    read -r -p "Install AUR packages (${AUR_PKGS[*]})? They are built from user-submitted recipes; review them. [y/N] " ans || ans=n
    case "$ans" in [yY]*) go=1 ;; esac
  fi
  if [ "$go" = 1 ]; then install_aur; else say "== AUR packages skipped"; fi
fi

run fc-cache -f

# ---------------------------------------------------------------- finish
say
if [ "$DRY" = 1 ]; then say "Dry run: nothing was changed."; exit 0; fi
if [ "${#MISSING[@]}" -gt 0 ]; then
  say "Not found (check names with: pacman -Ss NAME): ${MISSING[*]}"
  say "If a name is simply missing from your mirrors, run: ./install-kde-packages.sh --upgrade"
fi
if check; then
  say
  say "Everything is in place. Next: unzip kde-rice.zip && cd kde-rice && ./install-kde.sh"
else
  say
  say "Some items are missing (see above). Fix them, then re-run: ./install-kde-packages.sh --check"
  exit 1
fi
