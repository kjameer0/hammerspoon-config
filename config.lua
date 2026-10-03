-- Shared defaults. Override per-machine in local.lua (see local.example.lua).
return {
  -- Modifier held for all custom hotkeys.
  modifier = { "ctrl", "shift" },

  -- modifier + r reloads the config manually.
  reloadKey = "r",

  -- modifier + key focuses the app; pressing again cycles its windows.
  -- Find a bundle ID with: osascript -e 'id of app "AppName"'
  apps = {
    { key = "c", bundleID = "com.google.Chrome",    name = "Chrome" },
    { key = "d", bundleID = "com.googlecode.iterm2", name = "iTerm" },
    { key = "s", bundleID = "md.obsidian",           name = "Obsidian" },
  },

  -- modifier + key opens the named iTerm window picker.
  itermWindows = { key = "a" },
}
