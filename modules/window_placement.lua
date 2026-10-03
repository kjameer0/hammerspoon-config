-- Places newly created windows of chosen apps on the screen under the mouse.
-- config.newWindows maps a bundle ID to a placement:
--   "center"                     keep the window's size, center it
--   { x=0, y=0, w=0.5, h=1 }     unit rect (fractions of the screen)
local M = {}

local function place(win, placement)
  local screen = hs.mouse.getCurrentScreen() or win:screen()
  if placement == "center" then
    win:centerOnScreen(screen, true, 0)
  elseif type(placement) == "table" then
    win:move(placement, screen, true, 0)
  end
end

function M.start(config)
  local rules = config.newWindows or {}
  if next(rules) == nil then return end

  M.filter = hs.window.filter.new(function(win)
    local app = win:application()
    return win:isStandard() and app ~= nil and rules[app:bundleID()] ~= nil
  end)
  M.filter:subscribe(hs.window.filter.windowCreated, function(win)
    place(win, rules[win:application():bundleID()])
  end)
end

return M
