-- ============================================================================
-- WezTerm 智能右键功能模块
-- ============================================================================

local wezterm = require('wezterm')
local action = wezterm.action

local M = {}

-- ============================================================================
-- 智能右键复制粘贴功能
-- ============================================================================

-- 智能右键处理函数
-- 当有选中文本时：复制选中内容并清空选择
-- 当没有选中文本时：粘贴剪贴板内容
local function smart_right_click_handler()
  return wezterm.action_callback(function(window, pane)
    local has_selection = window:get_selection_text_for_pane(pane) ~= ''

    if has_selection then
      -- 有选中文本：复制到剪贴板并清空选择
      window:perform_action(action.CopyTo('ClipboardAndPrimarySelection'), pane)
      window:perform_action(action.ClearSelection, pane)
    else
      -- 没有选中文本：从剪贴板粘贴
      window:perform_action(action({
        PasteFrom = 'Clipboard',
      }), pane)
    end
  end)
end

-- 应用智能右键配置到 wezterm 配置
function M.apply_to_config(config)
  -- 确保 mouse_bindings 表存在
  if not config.mouse_bindings then
    config.mouse_bindings = {}
  end

  -- 添加智能右键绑定
  table.insert(config.mouse_bindings, {
    event = { Down = { streak = 1, button = 'Right', }, },
    mods = 'NONE',
    action = smart_right_click_handler(),
  })
end

return M
