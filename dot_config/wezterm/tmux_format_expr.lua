local wezterm = require('wezterm')
local nord_theme_colors = require('nord_theme_colors')
-- -- Nord Theme
-- ---@enum nord_theme
-- local nord_theme = {
--   -- Polar Night
--   nord0 = '#2e3440',
--   nord1 = '#3b4252',
--   nord2 = '#434c5e',
--   nord3 = '#4c566a',

--   -- Snow Storm
--   nord4 = '#d8dee9',
--   nord5 = '#e5e9f0',
--   nord6 = '#eceff4',

--   -- Frost
--   nord7 = '#8fbcbb',
--   nord8 = '#88c0d0',
--   nord9 = '#81a1c1',
--   nord10 = '#5e81ac',

--   -- Aurora
--   nord11 = '#bf616a',
--   nord12 = '#d08770',
--   nord13 = '#ebcb8b',
--   nord14 = '#a3be8c',
--   nord15 = '#b48ead',
-- }

-- local colors = {
--   black = nord_theme.nord1,
--   red = nord_theme.nord11,
--   green = nord_theme.nord14,
--   yellow = nord_theme.nord13,
--   blue = nord_theme.nord9,
--   magenta = nord_theme.nord15,
--   cyan = nord_theme.nord8,
--   white = nord_theme.nord5,

--   black_bright = nord_theme.nord3,
--   red_bright = nord_theme.nord11,
--   green_bright = nord_theme.nord14,
--   yellow_bright = nord_theme.nord13,
--   blue_bright = nord_theme.nord9,
--   magenta_bright = nord_theme.nord15,
--   cyan_bright = nord_theme.nord7,
--   white_bright = nord_theme.nord6,
-- }

-- local icons = {
--   left_hard_divider = utf8.char(0xE0B0),
--   right_hard_divider = utf8.char(0xE0B2),
--   left_soft_divider = utf8.char(0xE0B1),
--   right_soft_divider = utf8.char(0xE0B3),
-- }

-- Format time and date
---@return string
local function format_date()
  return wezterm.strftime('%Y-%m-%d')
end

---@return string
local function format_time()
  return wezterm.strftime('%H:%M:%S')
end

-- Get hostname
local function get_hostname()
  return wezterm.hostname() or 'localhost'
end

-- Get session name (using workspace name)
local function get_session_name(window)
  return window:active_workspace() or 'main'
end

-- Get current tab information
local function get_tab_info(window)
  local tab = window:active_tab()
  local tab_index = 0
  local tab_count = 0

  -- Get all tabs
  for i, t in ipairs(window:mux_window():tabs()) do
    tab_count = tab_count + 1
    if t:tab_id() == tab.tab_id then
      tab_index = i
    end
  end

  local title = tab:get_title()
  if title == '' or title == nil then
    title = 'zsh'
  end

  return {
    index = tab_index,
    count = tab_count,
    title = title,
    is_zoomed = tab:get_size().is_zoomed or false,
  }
end

local function table_append(table1, table2)
  for _, elem in ipairs(table2) do
    table.insert(table1, elem)
  end
  return table1
end

local color_map = {
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

-- 解析颜色名称到实际颜色值
local function parse_color(color_name)
  if not color_name or color_name == '' then
    return nil
  end

  -- 直接返回十六进制颜色
  if color_name:match('^#[0-9a-fA-F]+$') then
    return color_name
  end

  -- 映射颜色名称到实际颜色值

  return color_map[color_name:lower()] or color_name
end

-- 样式缓存
local style_cache = {}

-- 解析 tmux 样式的格式字符串并返回 wezterm element 数组
-- 参数：
--   style: 样式字符串，格式如 "fg=white,bg=brightblack,nobold,noitalics,nounderscore"
-- 返回：wezterm format element 数组
local function parse_tmux_style(style)
  if not style or style == '' then
    return {}
  end

  -- 检查缓存
  if style_cache[style] then
    return style_cache[style]
  end

  local elements = {}

  -- 解析样式参数
  local fg_color = nil
  local bg_color = nil
  local is_bold = false
  local is_italic = false
  local underline_style = 'None'

  -- 分割样式字符串
  for param in style:gmatch('[^,]+') do
    param = param:gsub('^%s*(.-)%s*$', '%1') -- 去除首尾空格

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

  -- 构建 wezterm format elements
  -- 设置前景色
  if fg_color and fg_color ~= '' then -- luacheck: ignore
    table.insert(elements, { Foreground = { Color = fg_color, }, })
  end

  -- 设置背景色
  if bg_color and bg_color ~= '' then -- luacheck: ignore
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

  -- 存储到缓存
  style_cache[style] = elements
  return elements
end

local function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

local function tab_flags(tab_info)
  local flags = '-'
  if tab_info.is_active then
    flags = '*'
  end
  if tab_info.active_pane.is_zoomed then
    flags = flags .. 'Z'
  end
  return flags
end

-- Token 类型枚举
local TokenType = {
  TEXT = 'TEXT',           -- 普通文本
  STYLE = 'STYLE',         -- 样式定义 #[...]
  VARIABLE = 'VARIABLE',   -- tmux 变量 #S, #I, #W 等
  CONDITION = 'CONDITION', -- 条件表达式 #{...}
  LITERAL = 'LITERAL',     -- 字面量 ${...}
}

-- Token 结构
local function create_token(type, value, raw)
  return {
    type = type,
    value = value,
    raw = raw or value,
  }
end

-- tmux 变量映射函数
local tmux_variables = {
  ['S'] = function(ctx) return get_session_name(ctx.window) end,
  ['H'] = function(ctx) return get_hostname() end,
  ['I'] = function(ctx) return tostring(ctx.tab and ctx.tab.tab_index or 0) end,
  ['W'] = function(ctx) return ctx.tab and tab_title(ctx.tab) or 'zsh' end,
  ['F'] = function(ctx) return ctx.tab and tab_flags(ctx.tab) or '-' end,
}

-- 环境变量和特殊变量映射
local special_variables = {
  ['NORD_TMUX_STATUS_DATE_FORMAT'] = function(ctx) return format_date() end,
  ['NORD_TMUX_STATUS_TIME_FORMAT'] = function(ctx) return format_time() end,
  ['prefix_highlight'] = function(ctx)
    -- 检查是否在特殊按键模式中
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

-- Token 解析器
local function tokenize_tmux_format(format_str)
  local tokens = {}
  local i = 1
  local len = #format_str

  while i <= len do
    local char = format_str:sub(i, i)

    if char == '#' then
      -- 检查样式定义 #[...]
      if i + 1 <= len and format_str:sub(i + 1, i + 1) == '[' then
        local start = i
        local bracket_count = 0
        local j = i + 1

        -- 查找匹配的右括号
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
          table.insert(tokens, create_token(TokenType.STYLE, style_content, format_str:sub(start, j)))
          i = j + 1
        else
          -- 未匹配的括号，作为普通文本处理
          table.insert(tokens, create_token(TokenType.TEXT, char))
          i = i + 1
        end

        -- 检查条件表达式 #{...}
      elseif i + 1 <= len and format_str:sub(i + 1, i + 1) == '{' then
        local start = i
        local brace_count = 0
        local j = i + 1

        -- 查找匹配的右大括号
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
          table.insert(tokens, create_token(TokenType.CONDITION, condition_content, format_str:sub(start, j)))
          i = j + 1
        else
          -- 未匹配的大括号，作为普通文本处理
          table.insert(tokens, create_token(TokenType.TEXT, char))
          i = i + 1
        end

        -- 检查 tmux 变量 #S, #I, #W 等
      elseif i + 1 <= len then
        local var_char = format_str:sub(i + 1, i + 1)
        if tmux_variables[var_char] then
          table.insert(tokens, create_token(TokenType.VARIABLE, var_char, format_str:sub(i, i + 1)))
          i = i + 2
        else
          -- 不是已知变量，作为普通文本处理
          table.insert(tokens, create_token(TokenType.TEXT, char))
          i = i + 1
        end
      else
        -- # 在字符串末尾，作为普通文本处理
        table.insert(tokens, create_token(TokenType.TEXT, char))
        i = i + 1
      end
    elseif char == '$' then
      -- 检查字面量 ${...}
      if i + 1 <= len and format_str:sub(i + 1, i + 1) == '{' then
        local start = i
        local brace_count = 0
        local j = i + 1

        -- 查找匹配的右大括号
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
          table.insert(tokens, create_token(TokenType.LITERAL, literal_content, format_str:sub(start, j)))
          i = j + 1
        else
          -- 未匹配的大括号，作为普通文本处理
          table.insert(tokens, create_token(TokenType.TEXT, char))
          i = i + 1
        end
      else
        -- 不是字面量语法，作为普通文本处理
        table.insert(tokens, create_token(TokenType.TEXT, char))
        i = i + 1
      end
    else
      -- 普通字符，收集连续的文本
      local start = i
      while i <= len and format_str:sub(i, i) ~= '#' and format_str:sub(i, i) ~= '$' do
        i = i + 1
      end
      local text = format_str:sub(start, i - 1)
      if #text > 0 then
        table.insert(tokens, create_token(TokenType.TEXT, text))
      end
    end
  end

  return tokens
end

-- 操作符类：处理不同类型的 token
local Operation = {}
Operation.__index = Operation

function Operation.new(type, value)
  local self = setmetatable({}, Operation)
  self.type = type
  self.value = value
  return self
end

function Operation:eval(ctx)
  if self.type == TokenType.TEXT then
    return { Text = self.value, }
  elseif self.type == TokenType.STYLE then
    -- 样式操作符不直接返回元素，而是设置样式状态
    return parse_tmux_style(self.value)
  elseif self.type == TokenType.VARIABLE then
    local var_func = tmux_variables[self.value]
    if var_func then
      local text = var_func(ctx)
      return { Text = text, }
    end
    return { Text = '#' .. self.value, }
  elseif self.type == TokenType.CONDITION then
    local var_func = special_variables[self.value]
    if var_func then
      local text = var_func(ctx)
      return { Text = text, }
    end
    return { Text = '#{' .. self.value .. '}', }
  elseif self.type == TokenType.LITERAL then
    local var_func = special_variables[self.value]
    if var_func then
      local text = var_func(ctx)
      return { Text = text, }
    end
    return { Text = '${' .. self.value .. '}', }
  end

  return { Text = '', }
end

-- 重新实现 define_tmux_format_expr 函数
local function define_tmux_format_expr(expr_str)
  local tokens = tokenize_tmux_format(expr_str)
  local ops = {}

  -- 将 tokens 转换为操作符
  for _, token in ipairs(tokens) do
    table.insert(ops, Operation.new(token.type, token.value))
  end

  local expr = {}
  expr.eval = function(ctx)
    local elements = {}
    local current_style = {}

    for _, op in ipairs(ops) do
      if op.type == TokenType.STYLE then
        -- 样式操作符：解析样式并应用到后续文本
        local style_elements = parse_tmux_style(op.value)
        if #style_elements > 0 then
          table_append(elements, style_elements)
        end
      else
        -- 其他操作符：生成文本元素
        local op_elements = op:eval(ctx)
        if op_elements.Text and op_elements.Text ~= '' then
          table.insert(elements, op_elements)
        end
      end
    end

    return elements
  end

  return expr
end

local M = {}
M.define_tmux_format_expr = define_tmux_format_expr
return M
