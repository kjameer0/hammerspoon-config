# Hammerspoon config

A modular [Hammerspoon](https://www.hammerspoon.org/) setup that reloads itself, built for one-handed navigation around macOS.

## Install

1. Install Hammerspoon: `brew install --cask hammerspoon`
2. Clone this repo to `~/.hammerspoon`.
3. Turn on Hammerspoon in **System Settings → Privacy & Security → Accessibility**.
4. Optional: put per-machine overrides in `local.lua`, copied from `local.example.lua`.

## Keymap

All shortcuts use the modifier set in `config.lua` (default **Ctrl+Shift**).

| Key | Action |
|-----|--------|
| `c` | Chrome |
| `d` | iTerm |
| `s` | Obsidian |
| `a` | Named iTerm windows: pick one, or type a new name to create it |
| `r` | Reload config |

Pressing an app's key when that app is already in front moves to its next window.

The first time you use `a`, macOS asks whether Hammerspoon may control iTerm (Automation permission). Allow it.

To show each window's name on the window itself, set the badge in iTerm: **Preferences → Profiles → (your profile) → General → Badge** = `\(user.hsName)`. Windows without a name don't get a badge.

## Layout

- `init.lua`: loads `config.lua`, merges `local.lua` over it, then starts each module. If one module fails to load, an alert appears and the rest still load.
- `config.lua`: the modifier and the table of apps (by bundle ID).
- `modules/reload.lua`: reloads when any `.lua` file is saved. Changes under `.git/` are ignored.
- `modules/apps.lua`: jumps to an app or cycles its windows.
- `modules/iterm_windows.lua`: picker for named iTerm windows. Each name is stored in the iTerm variable `user.hsName` on the window, so it lasts as long as the window does.
