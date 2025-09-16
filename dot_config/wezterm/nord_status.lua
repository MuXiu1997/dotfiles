-- ============================================================================
-- WezTerm Nord 状态栏模块
-- 基于 Nord tmux 主题配置
-- ============================================================================

local wezterm = require('wezterm')
local tmux_format_expr = require('tmux_format_expr')
local nord_theme_colors = require('nord_theme_colors')

local M = {}

local left_status_format_expr = tmux_format_expr.define_tmux_format_expr(
  '#[fg=black,bg=blue,bold] #S #[fg=blue,bg=black,nobold,noitalics,nounderscore]'
)
local right_status_format_expr = tmux_format_expr.define_tmux_format_expr(
  '#{prefix_highlight}#[fg=brightblack,bg=black,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] ${NORD_TMUX_STATUS_DATE_FORMAT} #[fg=white,bg=brightblack,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] ${NORD_TMUX_STATUS_TIME_FORMAT} #[fg=cyan,bg=brightblack,nobold,noitalics,nounderscore]#[fg=black,bg=cyan,bold] #H '
)
local tab_title_format_expr = tmux_format_expr.define_tmux_format_expr(
  '#[fg=black,bg=brightblack,nobold,noitalics,nounderscore] #[fg=white,bg=brightblack]#I #[fg=white,bg=brightblack,nobold,noitalics,nounderscore] #[fg=white,bg=brightblack]#W #F #[fg=brightblack,bg=black,nobold,noitalics,nounderscore]'
)
local current_tab_title_format_expr = tmux_format_expr.define_tmux_format_expr(
  '#[fg=black,bg=cyan,nobold,noitalics,nounderscore] #[fg=black,bg=cyan]#I #[fg=black,bg=cyan,nobold,noitalics,nounderscore] #[fg=black,bg=cyan]#W #F #[fg=cyan,bg=black,nobold,noitalics,nounderscore]'
)

-- 应用 Nord 状态栏配置
function M.apply_to_config(config)
  -- 设置状态栏更新间隔
  config.status_update_interval = 250

  -- 配置状态栏事件处理
  wezterm.on('update-status', function(window, pane)
    window:set_left_status(wezterm.format(left_status_format_expr.eval({
      window = window,
    })))
    window:set_right_status(wezterm.format(right_status_format_expr.eval({
      window = window,
    })))
  end)

  -- 配置标签栏事件处理
  wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    if not tab.is_active then
      return tab_title_format_expr.eval({
        tab = tab,
      })
    else
      return current_tab_title_format_expr.eval({
        tab = tab,
      })
    end
  end)

  config.colors = config.colors or {}
  config.colors.tab_bar = config.colors.tab_bar or {}
  config.colors.tab_bar.background = nord_theme_colors.nord1
  config.colors.tab_bar.new_tab = {
    fg_color = nord_theme_colors.nord5,
    bg_color = nord_theme_colors.nord3,
  }
  config.colors.tab_bar.new_tab_hover = {
    fg_color = nord_theme_colors.nord1,
    bg_color = nord_theme_colors.nord8,
  }
end

return M
