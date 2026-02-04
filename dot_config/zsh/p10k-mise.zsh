# Powerlevel10k segments for mise-managed runtimes

# Helper function to get mise tool version if locally configured
function _get_mise_local_version() {
  local tool="$1"
  # --current: Only show tool versions currently specified in a mise.toml
  # --local: Only show tool versions currently specified in the local mise.toml
  # --silent: Suppress all task output and mise non-error messages
  mise ls --current --silent --local "$tool" 2>/dev/null | awk '{print $2}'
}

# Node.js
function prompt_mise_node() {
  local version=$(_get_mise_local_version "node")
  [[ -n "$version" ]] || return
  p10k segment -b 'magenta' -f 'black' -i 'NODE_ICON' -r -t "$version"
}

# Go
function prompt_mise_go() {
  local version=$(_get_mise_local_version "go")
  [[ -n "$version" ]] || return
  p10k segment -b 'blue' -f 'black' -i 'GO_ICON' -r -t "$version"
}

# Python
function prompt_mise_python() {
  local version=$(_get_mise_local_version "python")
  [[ -n "$version" ]] || return
  p10k segment -b 'blue' -f 'black' -i 'PYTHON_ICON' -r -t "$version"
}

# Java
function prompt_mise_java() {
  local version=$(_get_mise_local_version "java")
  [[ -n "$version" ]] || return
  p10k segment -b 'white' -f 'red' -i 'JAVA_ICON' -r -t "$version"
}

# Replace old runtime elements with mise-based ones in the right prompt
# This handles transitions from nvm, goenv, pyenv, and jenv
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/nvm/mise_node})
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/goenv/mise_go})
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/pyenv/mise_python})
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/jenv/mise_java})
