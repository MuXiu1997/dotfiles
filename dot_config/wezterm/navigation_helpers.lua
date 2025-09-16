local wezterm = require('wezterm')

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

---@enum Direction
local direction = {
  Left = 'Left',
  Right = 'Right',
  Up = 'Up',
  Down = 'Down',
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

---Check if two ranges overlap
---@param start1 number Start position of first range
---@param len1 number Length of first range
---@param start2 number Start position of second range
---@param len2 number Length of second range
---@return boolean overlap True if ranges overlap
local function ranges_overlap(start1, len1, start2, len2)
  return not (start1 + len1 <= start2 or start1 >= start2 + len2)
end

---Check if a pane is a candidate in the given direction
---@param pane_info table Pane information with position and dimensions
---@param current_info table Current pane information
---@param dir Direction Navigation direction
---@return boolean is_candidate True if pane is a valid candidate
local function is_candidate_in_direction(pane_info, current_info, dir)
  if dir == direction.Left then
    -- Left: smaller x-coordinate with overlapping y-coordinate
    return pane_info.left < current_info.left and
        ranges_overlap(pane_info.top, pane_info.height, current_info.top, current_info.height)
  elseif dir == direction.Right then
    -- Right: larger x-coordinate with overlapping y-coordinate
    return pane_info.left > current_info.left and
        ranges_overlap(pane_info.top, pane_info.height, current_info.top, current_info.height)
  elseif dir == direction.Up then
    -- Up: smaller y-coordinate with overlapping x-coordinate
    return pane_info.top < current_info.top and
        ranges_overlap(pane_info.left, pane_info.width, current_info.left, current_info.width)
  elseif dir == direction.Down then
    -- Down: larger y-coordinate with overlapping x-coordinate
    return pane_info.top > current_info.top and
        ranges_overlap(pane_info.left, pane_info.width, current_info.left, current_info.width)
  end
  return false
end

---Calculate distance between two panes based on direction
---@param candidate table Candidate pane information
---@param current_info table Current pane information
---@param dir Direction Navigation direction
---@return number distance Manhattan distance between panes
local function calculate_distance(candidate, current_info, dir)
  if dir == direction.Left or dir == direction.Right then
    local horizontal_dist = math.abs(candidate.left - current_info.left)
    local vertical_dist = math.abs(
      (candidate.top + candidate.height / 2) - (current_info.top + current_info.height / 2)
    )
    return horizontal_dist + vertical_dist
  else
    local vertical_dist = math.abs(candidate.top - current_info.top)
    local horizontal_dist = math.abs(
      (candidate.left + candidate.width / 2) - (current_info.left + current_info.width / 2)
    )
    return vertical_dist + horizontal_dist
  end
end

---Find the closest pane from candidates
---@param candidates table[] List of candidate panes
---@param current_info table Current pane information
---@param dir Direction Navigation direction
---@return table|nil pane The closest pane or nil if no candidates
local function find_closest_pane(candidates, current_info, dir)
  if #candidates == 0 then
    return nil
  end


  local best_candidate = candidates[1]
  ---@cast best_candidate -nil
  local best_distance = calculate_distance(best_candidate, current_info, dir)

  for i = 2, #candidates do
    local distance = calculate_distance(candidates[i], current_info, dir)
    if distance < best_distance then
      best_distance = distance
      best_candidate = candidates[i]
    end
  end

  return best_candidate.pane
end

---Get wrap candidates for cyclic navigation
---@param panes table[] All panes in the tab
---@param current_pane table Current pane object
---@param current_info table Current pane information
---@param dir Direction Navigation direction
---@return table[] wrap_candidates Sorted list of wrap candidates
local function get_wrap_candidates(panes, current_pane, current_info, dir)
  local wrap_candidates = {}

  for _, pane_info in ipairs(panes) do
    if pane_info.pane:pane_id() ~= current_pane:pane_id() then
      local include = false

      if dir == direction.Left or dir == direction.Right then
        -- For horizontal navigation, check vertical overlap
        include = ranges_overlap(pane_info.top, pane_info.height, current_info.top, current_info.height)
      else
        -- For vertical navigation, check horizontal overlap
        include = ranges_overlap(pane_info.left, pane_info.width, current_info.left, current_info.width)
      end

      if include then
        table.insert(wrap_candidates, pane_info)
      end
    end
  end

  -- Sort candidates based on direction
  if dir == direction.Left then
    -- Wrap to rightmost pane
    table.sort(wrap_candidates, function(a, b) return a.left > b.left end)
  elseif dir == direction.Right then
    -- Wrap to leftmost pane
    table.sort(wrap_candidates, function(a, b) return a.left < b.left end)
  elseif dir == direction.Up then
    -- Wrap to bottommost pane
    table.sort(wrap_candidates, function(a, b) return a.top > b.top end)
  elseif dir == direction.Down then
    -- Wrap to topmost pane
    table.sort(wrap_candidates, function(a, b) return a.top < b.top end)
  end

  return wrap_candidates
end

-- ============================================================================
-- Main Navigation Logic
-- ============================================================================

---Get the next pane in the specified direction (with wrapping support)
---@param tab table WezTerm tab object
---@param current_pane table Current pane object
---@param dir Direction Navigation direction
---@return table|nil next_pane The next pane to navigate to, or nil if none found
local function get_next_pane_in_direction(tab, current_pane, dir)
  local panes = tab:panes_with_info()
  local current_info = nil

  -- Find current pane info
  for _, pane_info in ipairs(panes) do
    if pane_info.pane:pane_id() == current_pane:pane_id() then
      current_info = pane_info
      break
    end
  end

  if not current_info then
    return nil
  end

  -- Find direct candidates in the specified direction
  local candidates = {}
  for _, pane_info in ipairs(panes) do
    if pane_info.pane:pane_id() ~= current_pane:pane_id() then
      if is_candidate_in_direction(pane_info, current_info, dir) then
        table.insert(candidates, pane_info)
      end
    end
  end

  -- If direct candidates found, return the closest one
  local closest = find_closest_pane(candidates, current_info, dir)
  if closest then
    return closest
  end

  -- No direct candidates, try wrapping
  local wrap_candidates = get_wrap_candidates(panes, current_pane, current_info, dir)
  if #wrap_candidates > 0 then
    local first_candidate = wrap_candidates[1]
    ---@cast first_candidate -nil
    return first_candidate.pane
  end

  -- No candidates found (single pane case)
  return nil
end

-- ============================================================================
-- Public API
-- ============================================================================

---Navigate to pane with wrapping support
---@param dir Direction Navigation direction ('Left', 'Right', 'Up', or 'Down')
---@return function action_callback WezTerm action callback function
function M.navigate_pane_with_wrap(dir)
  return wezterm.action_callback(function(win, pane)
    local tab = win:active_tab()
    local next_pane = get_next_pane_in_direction(tab, pane, dir)

    if next_pane then
      next_pane:activate()
    end
  end)
end

M.direction = direction

return M
