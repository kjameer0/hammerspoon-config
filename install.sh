#!/usr/bin/env bash
# Checks that this machine can run the config, then sets up what's missing.
#   ./install.sh          check, then offer each setup step (asks before changing anything)
#   ./install.sh --check  check only, change nothing
set -u

CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

REPO="$(cd "$(dirname "$0")" && pwd -P)"
TARGET="$HOME/.hammerspoon"
FAILED=0

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$*"; FAILED=$((FAILED+1)); }
ask()  { [ "$CHECK_ONLY" = 0 ] || return 1; read -r -p "    $* [y/N] " a; [ "$a" = y ] || [ "$a" = Y ]; }

# Path of the installed app with this bundle ID, or nothing.
app_path() {
  local p
  p="$(mdfind "kMDItemCFBundleIdentifier == '$1'" 2>/dev/null | grep '\.app$' | grep -v '/\.Trash/' | head -1)"
  [ -n "$p" ] && { echo "$p"; return; }
  for d in /Applications "$HOME/Applications"; do
    for a in "$d"/*.app; do
      [ "$(defaults read "$a/Contents/Info" CFBundleIdentifier 2>/dev/null)" = "$1" ] && { echo "$a"; return; }
    done
  done
}
app_version() { defaults read "$1/Contents/Info" CFBundleShortVersionString 2>/dev/null; }

# True if version $1 >= version $2 (dotted numbers).
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)" = "$2" ]; }

echo "Checking requirements"

# --- macOS ---
if [ "$(uname)" = Darwin ]; then
  ok "macOS $(sw_vers -productVersion)"
else
  fail "This config only runs on macOS"; exit 1
fi

# --- Hammerspoon ---
HS="$(app_path org.hammerspoon.Hammerspoon)"
if [ -n "$HS" ]; then
  ok "Hammerspoon $(app_version "$HS") at $HS"
else
  fail "Hammerspoon is not installed"
  if command -v brew >/dev/null; then
    if ask "Install it with 'brew install --cask hammerspoon'?"; then
      brew install --cask hammerspoon && HS="$(app_path org.hammerspoon.Hammerspoon)"
      [ -n "$HS" ] && { ok "Hammerspoon installed"; FAILED=$((FAILED-1)); }
    fi
  else
    warn "Download it from https://www.hammerspoon.org/ (or install Homebrew, then rerun)"
  fi
fi

# --- Config location: Hammerspoon reads ~/.hammerspoon ---
if [ "$(cd "$TARGET" 2>/dev/null && pwd -P)" = "$REPO" ]; then
  ok "Config is at ~/.hammerspoon"
elif [ ! -e "$TARGET" ]; then
  fail "~/.hammerspoon doesn't exist (this repo is at $REPO)"
  if ask "Link ~/.hammerspoon to $REPO?"; then
    ln -s "$REPO" "$TARGET" && ok "Linked ~/.hammerspoon → $REPO" && FAILED=$((FAILED-1))
  fi
else
  fail "~/.hammerspoon already exists and is a different folder. Move it aside, then rerun"
fi

# --- Apps the hotkeys point at (config.lua plus local.lua overrides) ---
BUNDLE_IDS="$(cat "$REPO/config.lua" "$REPO/local.lua" 2>/dev/null \
  | grep -o 'bundleID *= *"[^"]*"' | sed 's/.*"\(.*\)"/\1/' | sort -u)"
for id in $BUNDLE_IDS; do
  p="$(app_path "$id")"
  if [ -n "$p" ]; then
    ok "$(basename "$p" .app) $(app_version "$p")"
  else
    warn "$id is not installed; its hotkey will launch nothing"
  fi
done

# --- iTerm features used by the picker and tabname ---
ITERM="$(app_path com.googlecode.iterm2)"
if [ -n "$ITERM" ]; then
  v="$(app_version "$ITERM")"
  if version_ge "$v" 3.4; then
    ok "iTerm $v (this config is tested on 3.4+)"
  else
    warn "iTerm $v is older than 3.4, which this config is tested on; the Ctrl+Shift+A picker may not work"
  fi
else
  warn "iTerm isn't installed; the window picker and tabname need it"
fi

if [ "$FAILED" -gt 0 ]; then
  echo; echo "Fix the ✗ items above, then rerun ./install.sh"; exit 1
fi

echo; echo "Setup"

# --- Shell helpers (tabname) ---
case "$(basename "${SHELL:-}")" in
  zsh)  RC="$HOME/.zshrc" ;;
  bash) RC="$HOME/.bashrc" ;;
  *)    RC="" ;;
esac
LINE='source ~/.hammerspoon/shell/hs.sh'
if [ -z "$RC" ]; then
  warn "Unknown shell ${SHELL:-}; add this to your shell's startup file yourself: $LINE"
elif grep -qF 'hammerspoon/shell/hs.sh' "$RC" 2>/dev/null; then
  ok "Shell helpers are sourced in $RC"
else
  warn "Shell helpers (tabname) aren't in $RC"
  if ask "Add '$LINE' to $RC?"; then
    printf '\n# Hammerspoon shell helpers (tabname)\n%s\n' "$LINE" >> "$RC" && ok "Added; open a new terminal to use tabname"
  fi
fi

# --- Hammerspoon running ---
if pgrep -xq Hammerspoon; then
  ok "Hammerspoon is running"
else
  warn "Hammerspoon isn't running"
  if ask "Start it now?"; then open -a "$HS" && ok "Started Hammerspoon"; fi
fi

# --- Things the shell can't check ---
echo
echo "Manual steps (can't be checked from the shell):"
echo "  1. Allow Hammerspoon in System Settings → Privacy & Security → Accessibility."
echo "     Without it, no hotkeys work."
if ask "Open that settings page now?"; then
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
fi
echo "  2. In Hammerspoon's Preferences, turn on 'Launch Hammerspoon at login'."
echo "  3. The first Ctrl+Shift+A asks to let Hammerspoon control iTerm. Allow it."
echo "  4. Optional: iTerm title and badge settings, see README.md."
echo
echo "When it's working you'll see a 'Config loaded' alert. Press Ctrl+Shift+R to reload."
