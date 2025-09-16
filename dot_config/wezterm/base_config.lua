local wezterm = require('wezterm')

local M = {}

function M.apply_to_config(config)
  config.window_decorations = 'RESIZE' --🇨🇳窗口装饰样式
  config.color_scheme = 'nord' --🇨🇳配色方案

  config.font = wezterm.font_with_fallback({ --🇨🇳字体列表
    'JetBrains Mono',
    'Symbols Nerd Font Mono',
    'Source Han Sans CN',
  })
  config.font_size = 14.0 --🇨🇳字体大小
  config.line_height = 1.0 --🇨🇳行高
  config.cell_width = 1.0 --🇨🇳字符宽度

  config.default_cursor_style = 'BlinkingBar' --🇨🇳光标样式
  config.text_blink_rate = 500 --🇨🇳光标闪烁速率(毫秒)

  config.window_background_opacity = 0.8 --🇨🇳窗口背景透明度
  config.macos_window_background_blur = 25 --🇨🇳macOS窗口背景模糊度
  config.text_background_opacity = 0.9 --🇨🇳文本背景透明度
  config.inactive_pane_hsb = { --🇨🇳非活动窗格亮度
    saturation = 1,
    brightness = 0.6,
  }

  config.native_macos_fullscreen_mode = false --🇨🇳使用原生macOS全屏模式

  config.enable_tab_bar = true --🇨🇳启用标签栏
  config.use_fancy_tab_bar = false --🇨🇳使用花哨标签栏
  config.tab_bar_at_bottom = true --🇨🇳标签栏在底部
  config.hide_tab_bar_if_only_one_tab = false --🇨🇳只有一个标签时隐藏标签栏
  config.tab_max_width = 40 --🇨🇳标签最大宽度

  config.enable_scroll_bar = false --🇨🇳启用滚动条
  config.scrollback_lines = 10000 --🇨🇳历史记录行数
  config.default_prog = { 'zsh', '-l' } --🇨🇳默认程序
end

return M
