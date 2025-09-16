local wezterm = require('wezterm')

local M = {}

-- Smart Right-Click Copy/Paste Functionality
-- When text is selected: Copy the selected content and clear the selection
-- When no text is selected: Paste content from clipboard
local function smart_right_click_handler()
  return wezterm.action_callback(function(window, pane)
    local has_selection = window:get_selection_text_for_pane(pane) ~= ''

    if has_selection then
      -- Has selected text: Copy to clipboard and clear selection
      window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
      window:perform_action(wezterm.action.ClearSelection, pane)
    else
      -- No selected text: Paste from clipboard
      window:perform_action(wezterm.action({
        PasteFrom = 'Clipboard',
      }), pane)
    end
  end)
end

function M.apply_to_config(config)
  config.mouse_bindings = config.mouse_bindings or {}
  table.insert(config.mouse_bindings, {
    event = { Down = { streak = 1, button = 'Right', }, },
    mods = 'NONE',
    action = smart_right_click_handler(),
  })
end

return M
