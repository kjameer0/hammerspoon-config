-- Auto-reload when a .lua file in the config dir changes (ignores .git/).
local M = {}

local function isLuaChange(paths)
  for _, path in ipairs(paths) do
    if path:sub(-4) == ".lua" and not path:find("/%.git/") then
      return true
    end
  end
  return false
end

function M.start(config)
  -- Debounce: editors often write several events per save.
  M.timer = hs.timer.delayed.new(0.3, hs.reload)
  M.watcher = hs.pathwatcher.new(hs.configdir, function(paths)
    if isLuaChange(paths) then M.timer:start() end
  end):start()

  M.hotkey = hs.hotkey.bind(config.modifier, config.reloadKey, hs.reload)
end

return M
