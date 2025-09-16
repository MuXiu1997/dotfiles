local wezterm = require('wezterm')
local navigation = require('navigation_helpers')

local M = {}

local repeat_time = 600

local direction = navigation.direction

local direction_keys = {
  [direction.Left] = 'h',
  [direction.Down] = 'j',
  [direction.Up] = 'k',
  [direction.Right] = 'l',
}

---@enum Mode
local modes = {
  tmux = 'tmux_mode',
  tmux_tab_navigation = 'tmux_tab_navigation_mode',
  tmux_pane_navigation = 'tmux_pane_navigation_mode',
  tmux_pane_resize = 'tmux_pane_resize_mode',
}

local function activate_key_table(mode)
  return wezterm.action.ActivateKeyTable {
    name = mode,
    one_shot = true,
    timeout_milliseconds = repeat_time,
    until_unknown = true,
    prevent_fallback = true,
  }
end

function M.apply_to_config(config)
  -- Main key bindings configuration
  local keys = config.keys or {}
  config.keys = keys
  table.insert(keys, {
    key = 'a',
    mods = 'CTRL',
    action = activate_key_table(modes.tmux),
  })

  -- Key tables configuration (replaces leader key)
  local key_table_tmux = {}
  local key_table_tmux_tab_navigation = {}
  local key_table_tmux_pane_navigation = {}
  local key_table_tmux_pane_resize = {}

  -- Send Ctrl+a to terminal 🇨🇳发送 Ctrl+a 到终端（双击 Ctrl+a）
  table.insert(key_table_tmux, {
    key = 'a',
    mods = 'CTRL',
    action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
  })

  -- Create new tab 🇨🇳新建标签页
  table.insert(key_table_tmux, {
    key = 'c',
    mods = 'NONE',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  })

  -- Toggle pane zoom 🇨🇳窗格缩放
  table.insert(key_table_tmux, {
    key = 'z',
    mods = 'NONE',
    action = wezterm.action.TogglePaneZoomState,
  })

  -- Pane selector 🇨🇳窗格选择器
  table.insert(key_table_tmux, {
    key = 'q',
    mods = 'NONE',
    action = wezterm.action.PaneSelect {
      alphabet = '1234567890',
    },
  })

  -- Activate command palette 🇨🇳激活命令面板
  table.insert(key_table_tmux, {
    key = 'p',
    mods = 'NONE',
    action = wezterm.action.ActivateCommandPalette,
  })

  -- Split pane vertically 🇨🇳垂直分割窗格
  table.insert(key_table_tmux, {
    key = '-',
    mods = 'NONE',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  })
  -- Split pane horizontally 🇨🇳水平分割窗格
  table.insert(key_table_tmux, {
    key = '_',
    mods = 'NONE',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  })
  table.insert(key_table_tmux, {
    key = '|',
    mods = 'NONE',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  })

  -- Tab navigation 🇨🇳标签页导航
  for _, dir in ipairs({ direction.Left, direction.Right }) do
    local offset = dir == direction.Left and -1 or 1
    local bind = {
      key = direction_keys[dir],
      mods = 'CTRL',
      action = wezterm.action.Multiple {
        wezterm.action.ActivateTabRelative(offset),
        activate_key_table(modes.tmux_tab_navigation),
      },
    }
    table.insert(key_table_tmux, bind)
    table.insert(key_table_tmux_tab_navigation, bind)
  end

  -- Pane navigation 🇨🇳窗格导航
  for _, dir in ipairs({ direction.Left, direction.Down, direction.Up, direction.Right }) do
    local bind = {
      key = direction_keys[dir],
      mods = 'NONE',
      action = wezterm.action.Multiple {
        navigation.navigate_pane_with_wrap(dir),
        activate_key_table(modes.tmux_pane_navigation),
      },
    }
    table.insert(key_table_tmux, bind)
    table.insert(key_table_tmux_pane_navigation, bind)
  end

  -- Pane resize 🇨🇳窗格调整大小
  for _, dir in ipairs({ direction.Left, direction.Down, direction.Up, direction.Right }) do
    local bind = {
      key = direction_keys[dir]:upper(),
      mods = 'SHIFT',
      action = wezterm.action.Multiple {
        wezterm.action.AdjustPaneSize { dir, 2 },
        activate_key_table(modes.tmux_pane_resize),
      },
    }
    table.insert(key_table_tmux, bind)
    table.insert(key_table_tmux_pane_resize, bind)
  end


  config.key_tables = {
    [modes.tmux] = key_table_tmux,
    [modes.tmux_tab_navigation] = key_table_tmux_tab_navigation,
    [modes.tmux_pane_navigation] = key_table_tmux_pane_navigation,
    [modes.tmux_pane_resize] = key_table_tmux_pane_resize,
  }
end

return M
