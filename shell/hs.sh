# Shell helpers for this Hammerspoon config. Works in zsh and bash.
# Source from your shell rc:  source ~/.hammerspoon/shell/hs.sh

# tabname <name>: set this iTerm session's title and its picker name.
# With no argument, clears both.
# - OSC 1 sets the session name shown in the tab/title bar.
# - OSC 1337 SetUserVar sets user.hsName (base64), which the Ctrl+Shift+A
#   picker reads from each window's first tab.
tabname() {
  local name="$*"
  printf '\033]1;%s\007' "$name"
  printf '\033]1337;SetUserVar=hsName=%s\007' "$(printf '%s' "$name" | base64 | tr -d '\n')"
}
