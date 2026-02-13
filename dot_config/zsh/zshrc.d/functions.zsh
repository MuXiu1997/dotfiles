# Function 'r' is a custom command for navigating directories using the ranger file manager and zoxide.
r() {
  local temp_file choosedir
  temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
  trap 'rm -f -- ${temp_file}' EXIT
  ranger-zoxide --choosedir "$temp_file" "$@"
  if choosedir="$(cat -- "$temp_file")" && [ -n "$choosedir" ] && [ "$choosedir" != "$PWD" ]; then
    cd -- "$choosedir" || return
  fi
}

# Function 'help' is a custom command for displaying help information.
help() {
  if type col &>/dev/null && type bat &>/dev/null; then
    "$@" --help | col -bx | bat -pl help
  else
    "$@" --help
  fi
}

# Function 'pls' is a custom command for listing and managing network ports.
pls() {
  local command="lsof -i -nP 2> /dev/null | awk '{if ( 1<NR ) {print}}'"
  local kill_process="echo {} | awk '{print \$2}' | xargs kill -9"
  FZF_DEFAULT_COMMAND=${command} fzf \
    --header 'CTRL-D: Kill Process; CTRL-R: Reload' \
    --bind "ctrl-d:execute-silent(${kill_process})+reload(${command})" \
    --bind "ctrl-r:reload(${command})"
}

# Function 'yp' is a custom command for copying the current directory path for non-terminal apps (e.g., Finder, Slack).
yp() {
  printf '%s' "${PWD}" | pbcopy
}

# Function 'ypt' is a custom command for copying the current directory path for terminal use.
ypt() {
  local q="'\\''"
  printf '%s' "'${PWD//\'/${q}}'" | pbcopy
}

# Function 'cmat' is a custom command for applying chezmoi changes by source path (apply + target-path).
cmat() {
  if [ $# -eq 0 ]; then
    echo "Usage: cmat <path> [path...]" >&2
    return 1
  fi

  for arg in "$@"; do
    local target
    target=$(chezmoi target-path "$arg" 2>/dev/null)
    if [ -n "$target" ]; then
      chezmoi apply "$target"
    else
      echo "Error: '$arg' is not managed by chezmoi" >&2
    fi
  done
}
