local wezterm = require('wezterm')
local action = wezterm.action

-- 导入模块
local base_config = require('base_config')
local tmux_like = require('tmux_like')
local nord_status = require('nord_status')
local smart_right_click = require('smart_right_click')

local config = wezterm.config_builder()

-- ============================================================================
-- 应用基础配置
-- ============================================================================
base_config.apply_to_config(config)

-- ============================================================================
-- 应用 tmux-like 键绑定和功能
-- ============================================================================
tmux_like.apply_to_config(config)

-- ============================================================================
-- 应用 Nord 状态栏配置
-- ============================================================================
nord_status.apply_to_config(config)

-- ============================================================================
-- 应用智能右键功能
-- ============================================================================
smart_right_click.apply_to_config(config)

wezterm.on('augment-command-palette', function(window, pane)
  return {
    {
      brief = 'Rename tab',

      action = wezterm.action.PromptInputLine {
        description = 'Enter new name for tab',
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      },
    },
  }
end)

return config
