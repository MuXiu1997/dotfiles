local wezterm = require('wezterm')

local config = wezterm.config_builder()

require('base_config').apply_to_config(config)
require('tmux_like').apply_to_config(config)
require('tmux_nord_status').apply_to_config(config)
require('smart_right_click').apply_to_config(config)
require('command_palette').apply_to_config(config)

return config
