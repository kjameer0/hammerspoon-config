# Hammerspoon config

A modular [Hammerspoon](https://www.hammerspoon.org/) setup that reloads itself, built for one-handed navigation around macOS.

## Install

1. Install Hammerspoon: `brew install --cask hammerspoon`
2. Clone this repo to `~/.hammerspoon`.
3. Turn on Hammerspoon in **System Settings → Privacy & Security → Accessibility**.
4. Add the shell helpers (for `tabname`) to your shell's startup file, then open a new terminal:
   ```sh
   echo 'source ~/.hammerspoon/shell/hs.sh' >> ~/.zshrc   # or ~/.bashrc
   ```
5. Optional: put per-machine overrides in `local.lua`, copied from `local.example.lua`.

## Keymap

All shortcuts use the modifier set in `config.lua` (default **Ctrl+Shift**).

| Key | Action |
|-----|--------|
| `c` | Chrome |
| `d` | iTerm |
| `s` | Obsidian |
| `x` | VS Code |
| `a` | Named iTerm windows: pick one, or type a new name to create it |
| `z` | Clipboard history: search recent copies, Enter pastes |
| `r` | Reload config |

Pressing an app's key when that app is already in front moves to its next window.

The first time you use `a`, macOS asks whether Hammerspoon may control iTerm (Automation permission). Allow it.

To show each window's name in its title bar, turn on both **Session Name** and **Job Name** in iTerm under **Settings → Profiles → (your profile) → General → Title**. Named windows then show titles like `notes (vim)`. To also show the name as a large label inside the window, set **Badge** to `\(user.hsName)`.

### Renaming from the shell

This needs the shell helpers from install step 4. Then `tabname build` sets the current tab's title to `build`. If you run it in a window's first tab, that window also shows up as `build` in the `a` picker. Run `tabname` with no name to clear it.

## Layout

- `init.lua`: loads `config.lua`, merges `local.lua` over it, then starts each module. If one module fails to load, an alert appears and the rest still load.
- `config.lua`: the modifier and the table of apps (by bundle ID).
- `modules/reload.lua`: reloads when any `.lua` file is saved. Changes under `.git/` are ignored.
- `modules/apps.lua`: jumps to an app or cycles its windows.
- `shell/hs.sh`: shell helpers to source from your rc file (`tabname`).
- `modules/window_placement.lua`: moves each new window of the apps listed in `config.newWindows` onto the screen under the mouse, centered or at a unit rect.
- `modules/clipboard.lua`: clipboard history, using the bundled `Spoons/ClipboardTool.spoon` (MIT, from the official Hammerspoon Spoons repo). History is saved in Hammerspoon's settings, so it survives restarts. Copies that password managers mark as concealed are skipped. Right-click an entry to delete it.
- `modules/iterm_windows.lua`: picker for named iTerm windows. Each name is stored in the iTerm variable `user.hsName` on the window, so it lasts as long as the window does.
