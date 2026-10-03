-- modifier + key: focus app (launching if needed); if already frontmost,
-- cycle to its next standard window.
local M = { hotkeys = {} }

local function standardWindows(app)
  local wins = {}
  for _, w in ipairs(app:allWindows()) do
    if w:isStandard() then table.insert(wins, w) end
  end
  -- Sort by id so the cycle order is stable regardless of focus history.
  table.sort(wins, function(a, b) return a:id() < b:id() end)
  return wins
end

local function cycleWindows(app)
  local wins = standardWindows(app)
  if #wins < 2 then return end
  local current = hs.window.focusedWindow()
  local currentId = current and current:id()
  for i, w in ipairs(wins) do
    if w:id() == currentId then
      wins[i % #wins + 1]:focus()
      return
    end
  end
  wins[1]:focus()
end

local function jump(bundleID)
  local front = hs.application.frontmostApplication()
  if front and front:bundleID() == bundleID then
    cycleWindows(front)
  else
    hs.application.launchOrFocusByBundleID(bundleID)
  end
end

function M.start(config)
  for _, entry in ipairs(config.apps or {}) do
    local hk = hs.hotkey.bind(config.modifier, entry.key, function()
      jump(entry.bundleID)
    end)
    table.insert(M.hotkeys, hk)
  end
end

return M
