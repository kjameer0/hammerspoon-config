-- modifier + key: picker over named iTerm windows. Pick one to focus it, or
-- type a new name to create a window with that name.
-- The name is stored in the iTerm user variable `user.hsName` on the window's
-- first session, so it lives exactly as long as the window does.
local M = {}

local ITERM = 'application id "com.googlecode.iterm2"'

local function quote(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

local function run(script)
  local ok, result, err = hs.osascript.applescript(script)
  if not ok then
    print("[iterm_windows] AppleScript failed: " .. hs.inspect(err))
    hs.alert.show("⚠️ iTerm AppleScript failed — see console", 3)
    return nil
  end
  return result
end

-- Returns { {id=…, name=…}, … } for every window that has a name.
local function listNamed()
  local result = run(([[
    tell %s
      set out to {}
      repeat with w in windows
        tell current session of first tab of w to set n to variable named "user.hsName"
        if n is not missing value and n is not "" then set end of out to {id of w, n}
      end repeat
      return out
    end tell]]):format(ITERM))
  local windows = {}
  for _, pair in ipairs(result or {}) do
    table.insert(windows, { id = pair[1], name = pair[2] })
  end
  return windows
end

local function focus(id)
  run(([[
    tell %s
      select window id %d
      activate
    end tell]]):format(ITERM, id))
end

-- iTerm ignores AppleScript-set session names in the title, so the new
-- window's shell sets its own title (OSC 1) and then execs the login shell.
-- The title's Session Name + Job components then show e.g. "notes (vim)".
-- iTerm splits this string itself: single quotes pass through literally, but
-- nested double quotes and backslashes don't, so the script is single-quoted
-- and the name is passed as $1.
local function titleCommand(name)
  local safe = name:gsub("[^%w%s%-_.]", "") -- keep shell/printf-safe chars
  return ([[/bin/zsh -c 'printf "\033]1;%%s\007" "$1"; exec $SHELL -l' _ '%s']]):format(safe)
end

local function create(name)
  run(([[
    tell %s
      set w to (create window with default profile command %s)
      tell current session of w to set variable named "user.hsName" to %s
      activate
    end tell]]):format(ITERM, quote(titleCommand(name)), quote(name)))
end

local function buildChoices(query)
  local q = (query or ""):lower()
  local choices, exact = {}, false
  for _, w in ipairs(M.windows) do
    local lname = w.name:lower()
    if lname == q then exact = true end
    if q == "" or lname:find(q, 1, true) then
      table.insert(choices, { text = w.name, id = w.id })
    end
  end
  if q ~= "" and not exact then
    table.insert(choices, { text = "＋ New window: " .. query, create = query })
  end
  return choices
end

local function onChoice(choice)
  if not choice then return end
  if choice.create then create(choice.create) else focus(choice.id) end
end

function M.start(config)
  M.windows = {}
  M.chooser = hs.chooser.new(onChoice)
  M.chooser:placeholderText("iTerm window: pick or type a new name")
  M.chooser:queryChangedCallback(function(query)
    M.chooser:choices(buildChoices(query))
  end)

  M.hotkey = hs.hotkey.bind(config.modifier, config.itermWindows.key, function()
    M.windows = listNamed()
    M.chooser:query("")
    M.chooser:choices(buildChoices(""))
    M.chooser:show()
  end)
end

return M
