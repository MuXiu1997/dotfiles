local wezterm = require('wezterm')
local nord_theme_colors = require('tmux_nord_status.nord_theme_colors')
local helpers = require('tmux_nord_status.helpers')

-- ============================================================================
-- Type Definitions
-- ============================================================================

---@class WeztermElement
---@alias WeztermElements WeztermElement[]

---@alias Token { type: TokenType, value: string, raw: string }

---@class FormatContext
---@field window any The wezterm window object
---@field tab table|nil The tab information
---@field max_width number|nil The maximum width for rendering

---@enum ColorName
local color = {
  black = nord_theme_colors.nord1,
  red = nord_theme_colors.nord11,
  green = nord_theme_colors.nord14,
  yellow = nord_theme_colors.nord13,
  blue = nord_theme_colors.nord9,
  magenta = nord_theme_colors.nord15,
  cyan = nord_theme_colors.nord8,
  white = nord_theme_colors.nord5,
  brightblack = nord_theme_colors.nord3,
  brightred = nord_theme_colors.nord11,
  brightgreen = nord_theme_colors.nord14,
  brightyellow = nord_theme_colors.nord13,
  brightblue = nord_theme_colors.nord9,
  brightmagenta = nord_theme_colors.nord15,
  brightcyan = nord_theme_colors.nord7,
  brightwhite = nord_theme_colors.nord6,
}

---@enum TokenType
local token_type = {
  TEXT = 'TEXT',           -- Plain text
  STYLE = 'STYLE',         -- Style definition #[...]
  VARIABLE = 'VARIABLE',   -- tmux variables like #S, #I, #W
  CONDITION = 'CONDITION', -- Conditional expression #{...}
  LITERAL = 'LITERAL',     -- Literal ${...}
}

-- ============================================================================
-- Style Parsing
-- ============================================================================

---@type table<string, WeztermElements|nil>
local style_cache = {}

-- Parse color name to actual color value
---@param color_name string|nil The color name or hex value
---@return string|nil color The resolved color value or nil
local function parse_color(color_name)
  if helpers.is_blank(color_name) then
    return nil
  end

  ---@cast color_name -nil
  -- Return hex color directly
  if color_name:match('^#[0-9a-fA-F]+$') then
    return color_name
  end

  -- Map color name to actual color value
  return color[color_name:lower()] or color_name
end

-- Parse tmux style format string and return wezterm format element array
-- Example: "fg=white,bg=brightblack,nobold,noitalics,nounderscore"
---@param style_str string The style string to parse
---@return WeztermElements elements Array of wezterm format elements
local function parse_tmux_style(style_str)
  if helpers.is_blank(style_str) then
    return {}
  end

  -- Check cache
  local cached_elements = style_cache[style_str]
  if cached_elements then
    return cached_elements
  end

  ---@type WeztermElements
  local elements = {}

  -- Parse style parameters
  local fg_color = nil
  local bg_color = nil
  local is_bold = false
  local is_italic = false
  local underline_style = 'None'

  -- Split style string
  for param in style_str:gmatch('[^,]+') do
    param = helpers.trim(param)

    if param:match('^fg=') then
      fg_color = parse_color(param:match('^fg=(.+)'))
    elseif param:match('^bg=') then
      bg_color = parse_color(param:match('^bg=(.+)'))
    elseif param == 'bold' then
      is_bold = true
    elseif param == 'nobold' then
      is_bold = false
    elseif param == 'italics' then
      is_italic = true
    elseif param == 'noitalics' then
      is_italic = false
    elseif param == 'underscore' then
      underline_style = 'Single'
    elseif param == 'nounderscore' then
      underline_style = 'None'
    end
  end

  -- Build wezterm format elements
  -- Set foreground color
  if not helpers.is_blank(fg_color) then
    table.insert(elements, { Foreground = { Color = fg_color, }, })
  end

  -- Set background color
  if not helpers.is_blank(bg_color) then
    table.insert(elements, { Background = { Color = bg_color, }, })
  end

  if is_bold then
    table.insert(elements, { Attribute = { Intensity = 'Bold', }, })
  end

  if is_italic then
    table.insert(elements, { Attribute = { Italic = true, }, })
  end

  if underline_style ~= 'None' then
    table.insert(elements, { Attribute = { Underline = underline_style, }, })
  end

  -- Store to cache
  style_cache[style_str] = elements
  return elements
end

-- ============================================================================
-- Variable Mapping
-- ============================================================================

-- tmux variable mapping functions
---@type table<string, (fun(ctx: FormatContext): string)|nil>
local tmux_variables = {
  ['S'] = function(ctx)
    -- Get session name (using workspace name)
    return ctx.window:active_workspace() or 'main'
  end,
  ['H'] = function()
    -- Get hostname
    return wezterm.hostname() or 'localhost'
  end,
  ['I'] = function(ctx)
    -- Get tab index
    return tostring(ctx.tab and ctx.tab.tab_index or 0)
  end,
  ['W'] = function(ctx)
    -- Get tab title
    if not ctx.tab then
      return 'zsh'
    end

    -- Calculate the maximum available width for the title
    -- Format: " #I  #W #F "
    -- #I: tab index (1-2 chars)
    -- #W: tab title (variable)
    -- #F: flags (1-2 chars, like "*" or "*Z")
    -- Spaces and separators: about 5 chars
    -- Conservative estimate: reserve 10 chars for other elements
    ---@type number
    local available_width = 16
    if ctx.max_width and ctx.max_width > 0 then
      available_width = ctx.max_width - 10
    end

    -- If the tab title is explicitly set, use that
    local title = ctx.tab.tab_title
    if helpers.is_blank(title) then
      -- Otherwise, use the title from the active pane
      title = ctx.tab.active_pane.title
    end
    -- Truncate title if max width is specified
    if available_width > 0 then
      title = helpers.truncate_string(title, available_width)
    end
    return title
  end,
  ['F'] = function(ctx)
    -- Get tab flags
    if not ctx.tab then
      return '-'
    end

    local flags = '-'
    if ctx.tab.is_active then
      flags = '*'
    end
    if ctx.tab.active_pane.is_zoomed then
      flags = flags .. 'Z'
    end
    return flags
  end,
}

-- Environment and special variable mapping
---@type table<string, (fun(ctx: FormatContext): string)|nil>
local special_variables = {
  ['NORD_TMUX_STATUS_DATE_FORMAT'] = function()
    -- Format date
    return wezterm.strftime('%Y-%m-%d')
  end,
  ['NORD_TMUX_STATUS_TIME_FORMAT'] = function()
    -- Format time
    return wezterm.strftime('%H:%M:%S')
  end,
  ['prefix_highlight'] = function(ctx)
    -- Check if in special key mode
    local key_table = ctx.window:active_key_table()
    if key_table then
      local mode_text = ''
      if key_table == 'tmux_mode' then
        mode_text = ' TMUX '
      elseif key_table == 'copy_mode' then
        mode_text = ' COPY '
      else
        mode_text = ' ' .. string.upper(key_table) .. ' '
      end
      return mode_text
    end
    return ''
  end,
}

-- ============================================================================
-- Tokenizer
-- ============================================================================

-- Create a token
---@param type TokenType The token type
---@param value string The token value
---@param raw string|nil The raw string representation
---@return Token token The created token
local function create_token(type, value, raw)
  return {
    type = type,
    value = value,
    raw = raw or value,
  }
end

-- Tokenize the tmux format string
---@param format_str string The tmux format string to tokenize
---@return Token[] tokens The tokens array
local function tokenize_tmux_format(format_str)
  ---@type Token[]
  local tokens = {}
  local i = 1
  local len = #format_str

  while i <= len do
    local char = format_str:sub(i, i)

    if char == '#' then
      -- Check for style definition #[...]
      if i + 1 <= len and format_str:sub(i + 1, i + 1) == '[' then
        local start = i
        local bracket_count = 0
        local j = i + 1

        -- Find matching right bracket
        while j <= len do
          local c = format_str:sub(j, j)
          if c == '[' then
            bracket_count = bracket_count + 1
          elseif c == ']' then
            bracket_count = bracket_count - 1
            if bracket_count == 0 then
              break
            end
          end
          j = j + 1
        end

        if j <= len then
          local style_content = format_str:sub(i + 2, j - 1)
          table.insert(tokens, create_token(token_type.STYLE, style_content, format_str:sub(start, j)))
          i = j + 1
        else
          -- Unmatched bracket, treat as plain text
          table.insert(tokens, create_token(token_type.TEXT, char))
          i = i + 1
        end

        -- Check for conditional expression #{...}
      elseif i + 1 <= len and format_str:sub(i + 1, i + 1) == '{' then
        local start = i
        local brace_count = 0
        local j = i + 1

        -- Find matching right brace
        while j <= len do
          local c = format_str:sub(j, j)
          if c == '{' then
            brace_count = brace_count + 1
          elseif c == '}' then
            brace_count = brace_count - 1
            if brace_count == 0 then
              break
            end
          end
          j = j + 1
        end

        if j <= len then
          local condition_content = format_str:sub(i + 2, j - 1)
          table.insert(tokens, create_token(token_type.CONDITION, condition_content, format_str:sub(start, j)))
          i = j + 1
        else
          -- Unmatched brace, treat as plain text
          table.insert(tokens, create_token(token_type.TEXT, char))
          i = i + 1
        end

        -- Check for tmux variables like #S, #I, #W
      elseif i + 1 <= len then
        local var_char = format_str:sub(i + 1, i + 1)
        if tmux_variables[var_char] then
          table.insert(tokens, create_token(token_type.VARIABLE, var_char, format_str:sub(i, i + 1)))
          i = i + 2
        else
          -- Not a known variable, treat as plain text
          table.insert(tokens, create_token(token_type.TEXT, char))
          i = i + 1
        end
      else
        -- # at end of string, treat as plain text
        table.insert(tokens, create_token(token_type.TEXT, char))
        i = i + 1
      end
    elseif char == '$' then
      -- Check for literal ${...}
      if i + 1 <= len and format_str:sub(i + 1, i + 1) == '{' then
        local start = i
        local brace_count = 0
        local j = i + 1

        -- Find matching right brace
        while j <= len do
          local c = format_str:sub(j, j)
          if c == '{' then
            brace_count = brace_count + 1
          elseif c == '}' then
            brace_count = brace_count - 1
            if brace_count == 0 then
              break
            end
          end
          j = j + 1
        end

        if j <= len then
          local literal_content = format_str:sub(i + 2, j - 1)
          table.insert(tokens, create_token(token_type.LITERAL, literal_content, format_str:sub(start, j)))
          i = j + 1
        else
          -- Unmatched brace, treat as plain text
          table.insert(tokens, create_token(token_type.TEXT, char))
          i = i + 1
        end
      else
        -- Not literal syntax, treat as plain text
        table.insert(tokens, create_token(token_type.TEXT, char))
        i = i + 1
      end
    else
      -- Plain character, collect consecutive text
      local start = i
      while i <= len and format_str:sub(i, i) ~= '#' and format_str:sub(i, i) ~= '$' do
        i = i + 1
      end
      local text = format_str:sub(start, i - 1)
      if #text > 0 then
        table.insert(tokens, create_token(token_type.TEXT, text))
      end
    end
  end

  return tokens
end

-- ============================================================================
-- Operation Class
-- ============================================================================

-- Operation class: handles different types of tokens
---@class Operation
---@field type TokenType The operation type
---@field value string The operation value
local Operation = {}
Operation.__index = Operation

function Operation.new(type, value)
  local self = setmetatable({}, Operation)
  self.type = type
  self.value = value
  return self
end

-- Evaluate the operation with the given context
---@param ctx FormatContext The evaluation context
---@return WeztermElements elements Array of wezterm format elements
function Operation:eval(ctx)
  if self.type == token_type.TEXT then
    return { { Text = self.value, }, }
  elseif self.type == token_type.STYLE then
    -- Style operator returns style elements array
    return parse_tmux_style(self.value)
  elseif self.type == token_type.VARIABLE then
    local var_func = tmux_variables[self.value]
    if var_func then
      local text = var_func(ctx)
      return { { Text = text, }, }
    end
    return { { Text = '#' .. self.value, }, }
  elseif self.type == token_type.CONDITION then
    local var_func = special_variables[self.value]
    if var_func then
      local text = var_func(ctx)
      return { { Text = text, }, }
    end
    return { { Text = '#{' .. self.value .. '}', }, }
  elseif self.type == token_type.LITERAL then
    local var_func = special_variables[self.value]
    if var_func then
      local text = var_func(ctx)
      return { { Text = text, }, }
    end
    return { { Text = '${' .. self.value .. '}', }, }
  end

  return { { Text = '', }, }
end

-- ============================================================================
-- Public API
-- ============================================================================

local M = {}

-- Define a tmux format expression that can be evaluated with context
---@param expr_str string The tmux format string to parse
---@return table expr An expression object with an eval method
function M.define_tmux_format_expr(expr_str)
  local tokens = tokenize_tmux_format(expr_str)
  ---@type Operation[]
  local ops = {}

  -- Convert tokens to operators
  for _, token in ipairs(tokens) do
    table.insert(ops, Operation.new(token.type, token.value))
  end

  local expr = {}

  -- Evaluate the expression with the given context
  ---@param ctx FormatContext The evaluation context
  ---@return WeztermElements elements Array of wezterm format elements
  function expr.eval(ctx)
    ---@type WeztermElements
    local elements = {}

    for _, op in ipairs(ops) do
      local op_elements = op:eval(ctx)
      if #op_elements > 0 then
        helpers.table_append(elements, op_elements)
      end
    end

    return elements
  end

  return expr
end

return M
