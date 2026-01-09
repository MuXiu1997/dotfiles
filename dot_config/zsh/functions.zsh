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
