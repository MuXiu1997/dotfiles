local wezterm = require('wezterm')

local M = {}

function M.apply_to_config(config)
  wezterm.on('augment-command-palette', function(window, pane)
    return {
      {
        brief = 'Rename Tab',
        action = wezterm.action.PromptInputLine {
          description = 'Enter new name for tab',
          action = wezterm.action_callback(function(win, _, line)
            if line then
              win:active_tab():set_title(line)
            end
          end),
        },
      },
      {
        brief = 'Set Tab to Directory Name',
        action = wezterm.action_callback(function(win, p)
          local cwd = p:get_current_working_dir()
          if cwd then
            local cwd_path = cwd.file_path or cwd.path or tostring(cwd)
            local basename = cwd_path:match('([^/]+)/?$')
            if basename and basename ~= '' then
              win:active_tab():set_title(basename)
            end
          end
        end),
      },
    }
  end)
end

return M
