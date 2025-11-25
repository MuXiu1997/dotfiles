# { Key bindings
  file_readable_then_source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
# }

# { Default
    export FZF_DEFAULT_COLOR='
    --color fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C,fg+:#D8DEE9,bg+:#434C5E,hl+:#A3BE8C
    --color pointer:#BF616A,info:#4C566A,spinner:#4C566A,header:#4C566A,prompt:#81A1C1,marker:#EBCB8B
    '

    export FZF_DEFAULT_OPTS="
    --bind=tab:down,btab:up,change:top,ctrl-space:toggle
    --cycle
    ${FZF_DEFAULT_COLOR}
    "
# }

# { CTRL-R
    export FZF_CTRL_R_OPTS="
    --height '50%'
    --sort
    --ansi
    --preview 'echo {2..} | bat --theme=Nord -l sh --style=plain --style=numbers --color=always'
    --preview-window down:3:wrap
    --bind 'ctrl-space:toggle-preview'
    "
# }
