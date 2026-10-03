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
    { key = "x", bundleID = "com.microsoft.VSCode",  name = "VS Code" },
  },

  -- modifier + key opens the named iTerm window picker.
  itermWindows = { key = "a" },

  -- Where new windows open, on the screen under the mouse. Either "center"
  -- (keeps the window's size) or a unit rect like { x=0, y=0, w=0.5, h=1 }.
  newWindows = {
    ["com.googlecode.iterm2"] = "center",
  },
}
