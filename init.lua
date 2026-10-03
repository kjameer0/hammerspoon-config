-- Entry point. Loads config (+ optional local overrides), then each module.
-- A module that errors shows an alert but doesn't stop the others loading.

require("hs.ipc") -- enables the `hs` command-line tool

local function safeRequire(name)
  local ok, result = pcall(require, name)
  if not ok then
    print("[init] failed to load " .. name .. ": " .. tostring(result))
    hs.alert.show("⚠️ " .. name .. " failed — see console", 4)
    return nil
  end
  return result
end

-- Shallow-merge local.lua (gitignored, per-machine) over config.lua.
local config = safeRequire("config") or {}
if hs.fs.attributes(hs.configdir .. "/local.lua") then
  for k, v in pairs(safeRequire("local") or {}) do config[k] = v end
end

local modules = { "reload", "apps", "iterm_windows" }
for _, name in ipairs(modules) do
  local mod = safeRequire("modules." .. name)
  if mod and mod.start then
    local ok, err = pcall(mod.start, config)
    if not ok then
      print("[init] " .. name .. ".start failed: " .. tostring(err))
      hs.alert.show("⚠️ " .. name .. " failed to start — see console", 4)
    end
  end
end

hs.alert.show("Config loaded")
