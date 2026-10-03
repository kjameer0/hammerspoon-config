-- Clipboard history via the vendored ClipboardTool spoon.
-- modifier + config.clipboard.key opens a searchable list of recent copies.
-- Entries marked concealed/transient (password managers) are not recorded.
local M = {}

function M.start(config)
  local opts = config.clipboard
  if not opts then return end

  hs.loadSpoon("ClipboardTool")
  local tool = spoon.ClipboardTool
  tool.hist_size = opts.historySize or 100
  tool.paste_on_select = opts.pasteOnSelect ~= false
  tool.show_copied_alert = false
  tool.show_in_menubar = false
  tool:start()
  M.tool = tool

  M.hotkey = hs.hotkey.bind(config.modifier, opts.key, function()
    tool:toggleClipboard()
  end)
end

return M
