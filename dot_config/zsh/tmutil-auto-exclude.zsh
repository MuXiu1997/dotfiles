# Automatically add node_modules and Python virtual environment directories to Time Machine exclusion list
# Check for these directories when entering a directory, and exclude them if they exist

# Function to check and add directories to Time Machine exclusion list
__tmutil_auto_exclude() {
  local current_dir="$PWD"

  local _color_gray="\033[90m"
  local _color_red="\033[31m"
  local _color_reset="\033[0m"

  # Check for node_modules directory
  if [[ -d "$current_dir/node_modules" ]]; then
    local node_modules_path="$current_dir/node_modules"
    # Check if already in exclusion list
    local exclusion_status=$(tmutil isexcluded "$node_modules_path" 2>/dev/null)
    if [[ "$exclusion_status" == *"[Excluded]"* ]]; then
      # Already excluded, no need to add again
      :
    else
      echo "${_color_gray}Adding node_modules to Time Machine exclusion list: $node_modules_path${_color_reset}"
      tmutil addexclusion "$node_modules_path" 2>/dev/null || {
        echo "${_color_red}❌ Failed to add node_modules to exclusion list, may require admin privileges${_color_reset}"
      }
    fi
  fi

  # Check for Python virtual environment directories
  local venv_dirs=("venv" ".venv")
  for venv_dir in "${venv_dirs[@]}"; do
    local venv_path="$current_dir/$venv_dir"
    if [[ -d "$venv_path" ]]; then
      # Check if it's a valid Python virtual environment (has bin/python or Scripts/python.exe)
      if [[ -f "$venv_path/bin/python" ]] || [[ -f "$venv_path/bin/python3" ]] || [[ -f "$venv_path/Scripts/python.exe" ]]; then
        # Check if already in exclusion list
        local exclusion_status=$(tmutil isexcluded "$venv_path" 2>/dev/null)
        if [[ "$exclusion_status" == *"[Excluded]"* ]]; then
          # Already excluded, no need to add again
          :
        else
          echo "${_color_gray}Adding Python virtual environment to Time Machine exclusion list: $venv_path${_color_reset}"
          tmutil addexclusion "$venv_path" 2>/dev/null || {
            echo "${_color_red}❌ Failed to add $venv_dir to exclusion list, may require admin privileges${_color_reset}"
          }
        fi
      fi
    fi
  done
}

# Use chpwd hook to run check every time directory is changed
autoload -U add-zsh-hook
add-zsh-hook chpwd __tmutil_auto_exclude

# Also run check when script is loaded (for current directory)
__tmutil_auto_exclude
