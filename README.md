# Hammerspoon config

A modular [Hammerspoon](https://www.hammerspoon.org/) setup that reloads itself, built for one-handed navigation around macOS.

## Install

```sh
git clone https://github.com/kjameer0/hammerspoon-config.git ~/.hammerspoon
~/.hammerspoon/install.sh
```

`install.sh` first checks the machine:
- macOS
- Hammerspoon is installed
- the config is at `~/.hammerspoon`
- every app in the keymap is installed
- the iTerm version

It then offers to fix what it can: install Hammerspoon with Homebrew, link `~/.hammerspoon` to the repo, add the shell helpers to your rc file, and start Hammerspoon. It asks before every change. `./install.sh --check` only reports and changes nothing. Rerunning it is safe.

At the end it lists the steps it can't check, mainly allowing Hammerspoon in **System Settings → Privacy & Security → Accessibility**.

To install by hand instead:
1. `brew install --cask hammerspoon`, and clone this repo to `~/.hammerspoon`.
2. Turn on Hammerspoon under Accessibility, as above.
3. Add the shell helpers (for `tabname`), then open a new terminal:
   ```sh
   echo 'source ~/.hammerspoon/shell/hs.sh' >> ~/.zshrc   # or ~/.bashrc
   ```

Optional: put per-machine overrides in `local.lua`, copied from `local.example.lua`.

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

This needs the shell helpers, which `install.sh` sets up. Then `tabname build` sets the current tab's title to `build`. If you run it in a window's first tab, that window also shows up as `build` in the `a` picker. Run `tabname` with no name to clear it.

## Layout

- `install.sh`: checks requirements and sets up a new machine.
- `init.lua`: loads `config.lua`, merges `local.lua` over it, then starts each module. If one module fails to load, an alert appears and the rest still load.
- `config.lua`: the modifier and the table of apps (by bundle ID).
- `modules/reload.lua`: reloads when any `.lua` file is saved. Changes under `.git/` are ignored.
- `modules/apps.lua`: jumps to an app or cycles its windows.
- `shell/hs.sh`: shell helpers to source from your rc file (`tabname`).
- `modules/window_placement.lua`: moves each new window of the apps listed in `config.newWindows` onto the screen under the mouse, centered or at a unit rect.
- `modules/clipboard.lua`: clipboard history, using the bundled `Spoons/ClipboardTool.spoon` (MIT, from the official Hammerspoon Spoons repo). History is saved in Hammerspoon's settings, so it survives restarts. Copies that password managers mark as concealed are skipped. Right-click an entry to delete it.
- `modules/iterm_windows.lua`: picker for named iTerm windows. Each name is stored in the iTerm variable `user.hsName` on the window, so it lasts as long as the window does.
