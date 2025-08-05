local wezterm = require('wezterm')

local home = os.getenv('HOME')

local function fileExists(filepath)
  local file = io.open(filepath, 'r')
  if file then
    file:close()
    return true
  else
    return false
  end
end

local config = wezterm.config_builder()

config.color_scheme = 'nord'

config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'Symbols Nerd Font Mono',
  'Source Han Sans CN',
})
config.font_size = 16.0

config.line_height = 1.0
config.cell_width = 1.0

config.default_cursor_style = 'BlinkingBar'
config.text_blink_rate = 500

config.enable_tab_bar = false

config.window_background_opacity = 0.8
config.macos_window_background_blur = 25
config.text_background_opacity = 0.9

config.native_macos_fullscreen_mode = false
--config.macos_fullscreen_extend_behind_notch = true

config.default_prog = { 'zsh', '-l' }
if fileExists(home .. '/.local/bin/bootstrap-hotkey') then
  config.default_prog = { home .. '/.local/bin/bootstrap-hotkey' }
end

return config
