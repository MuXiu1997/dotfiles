-- ============================================================================
-- WezTerm 导航功能模块
-- ============================================================================

local wezterm = require('wezterm')
local action = wezterm.action

local M = {}

-- ============================================================================
-- 循环窗格导航功能
-- ============================================================================

-- 获取指定方向上的下一个窗格（支持循环）
local function get_next_pane_in_direction(tab, current_pane, direction)
  local panes = tab:panes_with_info()
  local current_info = nil

  -- 找到当前窗格的信息
  for _, pane_info in ipairs(panes) do
    if pane_info.pane:pane_id() == current_pane:pane_id() then
      current_info = pane_info
      break
    end
  end

  if not current_info then
    return nil
  end

  local candidates = {}

  -- 根据方向筛选候选窗格
  for _, pane_info in ipairs(panes) do
    if pane_info.pane:pane_id() ~= current_pane:pane_id() then
      local is_candidate = false

      if direction == 'Left' then
        -- 左侧：x坐标更小，y坐标有重叠
        is_candidate = pane_info.left < current_info.left and
            not (pane_info.top + pane_info.height <= current_info.top or
              pane_info.top >= current_info.top + current_info.height)
      elseif direction == 'Right' then
        -- 右侧：x坐标更大，y坐标有重叠
        is_candidate = pane_info.left > current_info.left and
            not (pane_info.top + pane_info.height <= current_info.top or
              pane_info.top >= current_info.top + current_info.height)
      elseif direction == 'Up' then
        -- 上方：y坐标更小，x坐标有重叠
        is_candidate = pane_info.top < current_info.top and
            not (pane_info.left + pane_info.width <= current_info.left or
              pane_info.left >= current_info.left + current_info.width)
      elseif direction == 'Down' then
        -- 下方：y坐标更大，x坐标有重叠
        is_candidate = pane_info.top > current_info.top and
            not (pane_info.left + pane_info.width <= current_info.left or
              pane_info.left >= current_info.left + current_info.width)
      end

      if is_candidate then
        table.insert(candidates, pane_info)
      end
    end
  end

  -- 如果找到候选窗格，选择最近的一个
  if #candidates > 0 then
    local best_candidate = candidates[1]
    local best_distance = math.huge

    for _, candidate in ipairs(candidates) do
      local distance
      if direction == 'Left' or direction == 'Right' then
        distance = math.abs(candidate.left - current_info.left) +
            math.abs((candidate.top + candidate.height / 2) - (current_info.top + current_info.height / 2))
      else
        distance = math.abs(candidate.top - current_info.top) +
            math.abs((candidate.left + candidate.width / 2) - (current_info.left + current_info.width / 2))
      end

      if distance < best_distance then
        best_distance = distance
        best_candidate = candidate
      end
    end

    return best_candidate.pane
  end

  -- 如果没有找到候选窗格，实现循环逻辑
  local wrap_candidates = {}

  if direction == 'Left' then
    -- 循环到最右侧的窗格
    for _, pane_info in ipairs(panes) do
      if pane_info.pane:pane_id() ~= current_pane:pane_id() and
          not (pane_info.top + pane_info.height <= current_info.top or
            pane_info.top >= current_info.top + current_info.height) then
        table.insert(wrap_candidates, pane_info)
      end
    end
    -- 选择最右侧的
    table.sort(wrap_candidates, function(a, b) return a.left > b.left end)
  elseif direction == 'Right' then
    -- 循环到最左侧的窗格
    for _, pane_info in ipairs(panes) do
      if pane_info.pane:pane_id() ~= current_pane:pane_id() and
          not (pane_info.top + pane_info.height <= current_info.top or
            pane_info.top >= current_info.top + current_info.height) then
        table.insert(wrap_candidates, pane_info)
      end
    end
    -- 选择最左侧的
    table.sort(wrap_candidates, function(a, b) return a.left < b.left end)
  elseif direction == 'Up' then
    -- 循环到最下方的窗格
    for _, pane_info in ipairs(panes) do
      if pane_info.pane:pane_id() ~= current_pane:pane_id() and
          not (pane_info.left + pane_info.width <= current_info.left or
            pane_info.left >= current_info.left + current_info.width) then
        table.insert(wrap_candidates, pane_info)
      end
    end
    -- 选择最下方的
    table.sort(wrap_candidates, function(a, b) return a.top > b.top end)
  elseif direction == 'Down' then
    -- 循环到最上方的窗格
    for _, pane_info in ipairs(panes) do
      if pane_info.pane:pane_id() ~= current_pane:pane_id() and
          not (pane_info.left + pane_info.width <= current_info.left or
            pane_info.left >= current_info.left + current_info.width) then
        table.insert(wrap_candidates, pane_info)
      end
    end
    -- 选择最上方的
    table.sort(wrap_candidates, function(a, b) return a.top < b.top end)
  end

  if #wrap_candidates > 0 then
    return wrap_candidates[1].pane
  end

  -- 如果还是没有找到，返回nil（只有一个窗格的情况）
  return nil
end

-- 循环窗格导航函数
function M.navigate_pane_with_wrap(direction)
  return wezterm.action_callback(function(win, pane)
    local tab = win:active_tab()
    local next_pane = get_next_pane_in_direction(tab, pane, direction)

    if next_pane then
      next_pane:activate()
    end
  end)
end

return M
