if type "atuin" &>/dev/null; then
  fzf-history-widget() {
    local selected atuin_cmd atuin_cmd_cwd

    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null

    atuin_cmd="atuin history list --format=\"{time} {command}\" --print0 --reverse false"
    atuin_cmd_cwd="$atuin_cmd --cwd"
    selected="$(eval $atuin_cmd |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "
        -n3..,..
        --bind 'ctrl-r:toggle-sort'
        --bind 'ctrl-space:toggle-preview'
        --bind 'ctrl-d:reload($atuin_cmd_cwd)'
        --bind 'ctrl-a:reload($atuin_cmd)'
        --wrap-sign '\t↳ '
        --highlight-line
        --header 'CTRL-R: 切换排序 | CTRL-D: 当前目录 | CTRL-A: 全部历史'
        --preview 'echo {3..} | bat --theme=Nord -l sh --style=plain --color=always'
        --preview-window down:3:wrap
        --query=${(qqq)LBUFFER}
        --read0
        --accept-nth '{3..}'
        +s
        +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"

    local ret=$?
    if [ -n "$selected" ]; then
      LBUFFER="$selected"
    fi
    zle reset-prompt
    return $ret
  }
fi
