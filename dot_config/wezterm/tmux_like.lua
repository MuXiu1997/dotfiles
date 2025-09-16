-- ============================================================================
-- WezTerm tmux-like 功能模块
-- ============================================================================

local wezterm = require('wezterm')
local navigation = require('navigation_helpers')

local action = wezterm.action

local M = {}

local repeat_time = 600

local direction_keys = {
  Left = 'h',
  Down = 'j',
  Up = 'k',
  Right = 'l',
}

local modes = {
  tmux = 'tmux_mode',
  tmux_tab_navigation = 'tmux_tab_navigation_mode',
  tmux_pane_navigation = 'tmux_pane_navigation_mode',
  tmux_pane_resize = 'tmux_pane_resize_mode',
}

local function activate_key_table(mode)
  return action.ActivateKeyTable {
    name = mode,
    one_shot = true,
    timeout_milliseconds = repeat_time,
    until_unknown = true,
    prevent_fallback = true,
  }
end

-- 应用 tmux-like 键绑定和功能
function M.apply_to_config(config)
  -- ============================================================================
  -- 主键绑定配置
  -- ============================================================================
  local keys = config.keys or {}
  config.keys = keys
  table.insert(keys, {
    key = 'a',
    mods = 'CTRL',
    action = activate_key_table(modes.tmux),
  })

  -- ============================================================================
  -- Key Tables 配置 (替代 Leader Key)
  -- ============================================================================

  local key_table_tmux = {}
  local key_table_tmux_tab_navigation = {}
  local key_table_tmux_pane_navigation = {}
  local key_table_tmux_pane_resize = {}

  -- 发送 Ctrl+a 到终端 (双击 Ctrl+a)
  table.insert(key_table_tmux, {
    key = 'a',
    mods = 'CTRL',
    action = action.SendKey { key = 'a', mods = 'CTRL', },
  })

  -- 新建标签页
  table.insert(key_table_tmux, {
    key = 'c',
    mods = 'NONE',
    action = action.SpawnTab 'CurrentPaneDomain',
  })

  -- 窗格缩放
  table.insert(key_table_tmux, {
    key = 'z',
    mods = 'NONE',
    action = action.TogglePaneZoomState,
  })

  -- 窗格选择器
  table.insert(key_table_tmux, {
    key = 'q',
    mods = 'NONE',
    action = action.PaneSelect {
      alphabet = '1234567890',
    },
  })

  -- 激活命令面板
  table.insert(key_table_tmux, {
    key = 'p',
    mods = 'NONE',
    action = wezterm.action.ActivateCommandPalette,
  })

  -- 窗格分割
  table.insert(key_table_tmux, {
    key = '-',
    mods = 'NONE',
    action = action.SplitVertical { domain = 'CurrentPaneDomain', },
  })
  table.insert(key_table_tmux, {
    key = '_',
    mods = 'NONE',
    action = action.SplitHorizontal { domain = 'CurrentPaneDomain', },
  })
  table.insert(key_table_tmux, {
    key = '|',
    mods = 'NONE',
    action = action.SplitHorizontal { domain = 'CurrentPaneDomain', },
  })

  -- 标签页导航
  for _, direction in ipairs({ 'Left', 'Right', }) do
    local offset = direction == 'Left' and -1 or 1
    local bind = {
      key = direction_keys[direction],
      mods = 'CTRL',
      action = action.Multiple {
        action.ActivateTabRelative(offset),
        activate_key_table(modes.tmux_tab_navigation),
      },
    }
    table.insert(key_table_tmux, bind)
    table.insert(key_table_tmux_tab_navigation, bind)
  end

  -- 窗格导航
  for _, direction in ipairs({ 'Left', 'Down', 'Up', 'Right', }) do
    local bind = {
      key = direction_keys[direction],
      mods = 'NONE',
      action = action.Multiple {
        navigation.navigate_pane_with_wrap(direction),
        activate_key_table(modes.tmux_pane_navigation),
      },
    }
    table.insert(key_table_tmux, bind)
    table.insert(key_table_tmux_pane_navigation, bind)
  end

  -- 窗格调整大小
  for _, direction in ipairs({ 'Left', 'Down', 'Up', 'Right', }) do
    local bind = {
      key = direction_keys[direction]:upper(),
      mods = 'SHIFT',
      action = action.Multiple {
        action.AdjustPaneSize { direction, 2, },
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

    -- Tmux 模式 key table (替代 leader key)
    -- tmux_mode = {

    --   -- 窗格缩放
    --   {
    --     key = 'z',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.TogglePaneZoomState,
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 关闭窗格
    --   {
    --     key = 'x',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.CloseCurrentPane { confirm = true },
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 标签页管理
    --   {
    --     key = 'c',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.SpawnTab 'CurrentPaneDomain',
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = 'n',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTabRelative(1),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = 'p',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTabRelative(-1),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '&',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.CloseCurrentTab { confirm = true },
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 标签页导航 (Ctrl+hjkl vim 风格) - 支持循环
    --   {
    --     key = 'h',
    --     mods = 'CTRL',
    --     action = action.Multiple{
    --       navigation.navigate_tab_with_wrap('prev'),
    --       action.ActivateKeyTable {
    --         name = 'tmux_mode',
    --         one_shot = true,
    --         timeout_milliseconds = 2000,
    --         until_unknown = true,
    --       },
    --     },
    --   },
    --   {
    --     key = 'l',
    --     mods = 'CTRL',
    --     action = action.Multiple{
    --       navigation.navigate_tab_with_wrap('next'),
    --       action.ActivateKeyTable {
    --         name = 'tmux_mode',
    --         one_shot = true,
    --         timeout_milliseconds = 2000,
    --         until_unknown = true,
    --       },
    --     },
    --   },

    --   -- 标签页重命名
    --   {
    --     key = ',',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.PromptInputLine {
    --         description = 'Enter new name for tab',
    --         action = wezterm.action_callback(function(window, pane, line)
    --           if line then
    --             window:active_tab():set_title(line)
    --           end
    --         end),
    --       },
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 复制模式
    --   {
    --     key = '[',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateCopyMode,
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 粘贴
    --   {
    --     key = ']',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.PasteFrom 'Clipboard',
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 窗格选择模式
    --   {
    --     key = 'q',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.PaneSelect,
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 窗格交换
    --   {
    --     key = '{',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.PaneSelect { mode = 'SwapWithActive' },
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 重新加载配置
    --   {
    --     key = 'r',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ReloadConfiguration,
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 显示启动器
    --   {
    --     key = 't',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ShowLauncher,
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 窗格布局切换
    --   {
    --     key = 'Space',
    --     mods = 'NONE',
    --     action = action.RotatePanes 'Clockwise',
    --   },

    --   -- 数字键快速切换标签页
    --   {
    --     key = '1',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(0),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '2',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(1),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '3',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(2),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '4',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(3),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '5',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(4),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '6',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(5),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '7',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(6),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '8',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(7),
    --       action.PopKeyTable,
    --     },
    --   },
    --   {
    --     key = '9',
    --     mods = 'NONE',
    --     action = action.Multiple{
    --       action.ActivateTab(8),
    --       action.PopKeyTable,
    --     },
    --   },

    --   -- 退出 tmux 模式
    --   {
    --     key = 'Escape',
    --     mods = 'NONE',
    --     action = action.PopKeyTable,
    --   },
    --   {
    --     key = 'q',
    --     mods = 'CTRL',
    --     action = action.PopKeyTable,
    --   },
    -- },
    -- 复制模式键绑定 (Vi 风格)
    copy_mode = {
      { key = 'Tab',        mods = 'NONE',  action = action.CopyMode 'MoveForwardWord', },
      { key = 'Tab',        mods = 'SHIFT', action = action.CopyMode 'MoveBackwardWord', },
      { key = 'Enter',      mods = 'NONE',  action = action.CopyMode 'MoveToStartOfNextLine', },
      { key = 'Escape',     mods = 'NONE',  action = action.CopyMode 'Close', },
      { key = 'Space',      mods = 'NONE',  action = action.CopyMode { SetSelectionMode = 'Cell', }, },
      { key = '$',          mods = 'NONE',  action = action.CopyMode 'MoveToEndOfLineContent', },
      { key = '$',          mods = 'SHIFT', action = action.CopyMode 'MoveToEndOfLineContent', },
      { key = ',',          mods = 'NONE',  action = action.CopyMode 'JumpReverse', },
      { key = '0',          mods = 'NONE',  action = action.CopyMode 'MoveToStartOfLine', },
      { key = ';',          mods = 'NONE',  action = action.CopyMode 'JumpAgain', },
      { key = 'F',          mods = 'NONE',  action = action.CopyMode { JumpBackward = { prev_char = false, }, }, },
      { key = 'F',          mods = 'SHIFT', action = action.CopyMode { JumpBackward = { prev_char = false, }, }, },
      { key = 'G',          mods = 'NONE',  action = action.CopyMode 'MoveToScrollbackBottom', },
      { key = 'G',          mods = 'SHIFT', action = action.CopyMode 'MoveToScrollbackBottom', },
      { key = 'H',          mods = 'NONE',  action = action.CopyMode 'MoveToViewportTop', },
      { key = 'H',          mods = 'SHIFT', action = action.CopyMode 'MoveToViewportTop', },
      { key = 'L',          mods = 'NONE',  action = action.CopyMode 'MoveToViewportBottom', },
      { key = 'L',          mods = 'SHIFT', action = action.CopyMode 'MoveToViewportBottom', },
      { key = 'M',          mods = 'NONE',  action = action.CopyMode 'MoveToViewportMiddle', },
      { key = 'M',          mods = 'SHIFT', action = action.CopyMode 'MoveToViewportMiddle', },
      { key = 'O',          mods = 'NONE',  action = action.CopyMode 'MoveToSelectionOtherEndHoriz', },
      { key = 'O',          mods = 'SHIFT', action = action.CopyMode 'MoveToSelectionOtherEndHoriz', },
      { key = 'T',          mods = 'NONE',  action = action.CopyMode { JumpBackward = { prev_char = true, }, }, },
      { key = 'T',          mods = 'SHIFT', action = action.CopyMode { JumpBackward = { prev_char = true, }, }, },
      { key = 'V',          mods = 'NONE',  action = action.CopyMode { SetSelectionMode = 'Line', }, },
      { key = 'V',          mods = 'SHIFT', action = action.CopyMode { SetSelectionMode = 'Line', }, },
      { key = '^',          mods = 'NONE',  action = action.CopyMode 'MoveToStartOfLineContent', },
      { key = '^',          mods = 'SHIFT', action = action.CopyMode 'MoveToStartOfLineContent', },
      { key = 'b',          mods = 'NONE',  action = action.CopyMode 'MoveBackwardWord', },
      { key = 'b',          mods = 'ALT',   action = action.CopyMode 'MoveBackwardWord', },
      { key = 'b',          mods = 'CTRL',  action = action.CopyMode 'PageUp', },
      { key = 'c',          mods = 'CTRL',  action = action.CopyMode 'Close', },
      { key = 'd',          mods = 'CTRL',  action = action.CopyMode { MoveByPage = (0.5), }, },
      { key = 'e',          mods = 'NONE',  action = action.CopyMode 'MoveForwardWordEnd', },
      { key = 'f',          mods = 'NONE',  action = action.CopyMode { JumpForward = { prev_char = false, }, }, },
      { key = 'f',          mods = 'ALT',   action = action.CopyMode 'MoveForwardWord', },
      { key = 'f',          mods = 'CTRL',  action = action.CopyMode 'PageDown', },
      { key = 'g',          mods = 'NONE',  action = action.CopyMode 'MoveToScrollbackTop', },
      { key = 'g',          mods = 'CTRL',  action = action.CopyMode 'Close', },
      { key = 'h',          mods = 'NONE',  action = action.CopyMode 'MoveLeft', },
      { key = 'j',          mods = 'NONE',  action = action.CopyMode 'MoveDown', },
      { key = 'k',          mods = 'NONE',  action = action.CopyMode 'MoveUp', },
      { key = 'l',          mods = 'NONE',  action = action.CopyMode 'MoveRight', },
      { key = 'm',          mods = 'ALT',   action = action.CopyMode 'MoveToStartOfLineContent', },
      { key = 'o',          mods = 'NONE',  action = action.CopyMode 'MoveToSelectionOtherEnd', },
      { key = 'q',          mods = 'NONE',  action = action.CopyMode 'Close', },
      { key = 't',          mods = 'NONE',  action = action.CopyMode { JumpForward = { prev_char = true, }, }, },
      { key = 'u',          mods = 'CTRL',  action = action.CopyMode { MoveByPage = (-0.5), }, },
      { key = 'v',          mods = 'NONE',  action = action.CopyMode { SetSelectionMode = 'Cell', }, },
      { key = 'v',          mods = 'CTRL',  action = action.CopyMode { SetSelectionMode = 'Block', }, },
      { key = 'w',          mods = 'NONE',  action = action.CopyMode 'MoveForwardWord', },
      { key = 'y',          mods = 'NONE',  action = action.Multiple { action.CopyTo 'ClipboardAndPrimarySelection', action.CopyMode 'Close', }, },
      { key = 'PageUp',     mods = 'NONE',  action = action.CopyMode 'PageUp', },
      { key = 'PageDown',   mods = 'NONE',  action = action.CopyMode 'PageDown', },
      { key = 'LeftArrow',  mods = 'NONE',  action = action.CopyMode 'MoveLeft', },
      { key = 'LeftArrow',  mods = 'ALT',   action = action.CopyMode 'MoveBackwardWord', },
      { key = 'RightArrow', mods = 'NONE',  action = action.CopyMode 'MoveRight', },
      { key = 'RightArrow', mods = 'ALT',   action = action.CopyMode 'MoveForwardWord', },
      { key = 'UpArrow',    mods = 'NONE',  action = action.CopyMode 'MoveUp', },
      { key = 'DownArrow',  mods = 'NONE',  action = action.CopyMode 'MoveDown', },
    },

  }

  -- ============================================================================
  -- 鼠标配置
  -- ============================================================================
  --   config.mouse_bindings = {
  --     -- 右键粘贴
  --     {
  --       event = { Down = { streak = 1, button = 'Right' } },
  --       mods = 'NONE',
  --       action = action.PasteFrom 'Clipboard',
  --     },
  --     -- 中键粘贴
  --     {
  --       event = { Down = { streak = 1, button = 'Middle' } },
  --       mods = 'NONE',
  --       action = action.PasteFrom 'PrimarySelection',
  --     },
  --   }
end

return M
