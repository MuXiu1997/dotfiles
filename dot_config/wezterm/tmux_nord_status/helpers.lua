local M = {}

-- Append all elements from source table to target table
---@param target table The table to append to
---@param other table The table to append from
---@return table target The modified target table
function M.table_append(target, other)
  for _, elem in ipairs(other) do
    table.insert(target, elem)
  end
  return target
end

-- Trim leading and trailing whitespace from a string
---@param s string The string to trim
---@return string trimmed The trimmed string
function M.trim(s)
  return (string.gsub(s, '^%s*(.-)%s*$', '%1'))
end

-- Check if a string is blank (nil or empty after trimming)
---@param s string|nil The string to check
---@return boolean blank true if the string is nil or empty after trimming
function M.is_blank(s)
  return s == nil or #M.trim(s) == 0
end

-- Check if a Unicode character is a CJK (Chinese, Japanese, Korean) character.
-- CJK characters typically occupy 2 cell widths in monospace terminals.
---@param char number The Unicode code point
---@return boolean true if the character is a CJK character
function M.is_cjk_char(char)
  return (char >= 0x4E00 and char <= 0x9FFF)   -- CJK Unified Ideographs
      or (char >= 0x3400 and char <= 0x4DBF)   -- CJK Unified Ideographs Extension A
      or (char >= 0x20000 and char <= 0x2A6DF) -- CJK Unified Ideographs Extension B
      or (char >= 0xF900 and char <= 0xFAFF)   -- CJK Compatibility Ideographs
      or (char >= 0x2F800 and char <= 0x2FA1F) -- CJK Compatibility Ideographs Supplement
end

-- Get the display width of a Unicode character in monospace terminals
---@param char number The Unicode code point
---@return integer width 2 for CJK characters, 1 for others
function M.get_char_width(char)
  return M.is_cjk_char(char) and 2 or 1
end

-- Calculate the display width of a string (considering UTF-8 characters)
---@param str string The string to measure
---@return integer width The total display width
function M.string_width(str)
  local width = 0
  for _, char in utf8.codes(str) do
    width = width + M.get_char_width(char)
  end
  return width
end

-- Truncate a string to a specified display width
---@param str string The string to truncate
---@param max_width integer The maximum display width
---@return string truncated The truncated string
function M.truncate_string(str, max_width)
  if max_width <= 0 then
    return ''
  end

  local result = ''
  local current_width = 0

  for pos, char in utf8.codes(str) do
    local char_width = M.get_char_width(char)

    if current_width + char_width > max_width then
      break
    end

    result = result .. utf8.char(char)
    current_width = current_width + char_width
  end

  return result
end

return M
