# { Proxy
    alias p="HTTPS_PROXY=socks5://127.0.0.1:1080 HTTP_PROXY=socks5://127.0.0.1:1080 ALL_PROXY=socks5://127.0.0.1:1080"
# }

# { Cd
    alias ..="cd .."
    alias -- -="cd -"
# }

# { Ls
    alias ls="exa --icons --color='always' --time-style=long-iso"
# }

# { Zsh
    alias zrconf="$EDITOR $ZDOTDIR/.zshrc"
    alias zpconf="$EDITOR $ZDOTDIR/.zprofile"
    alias zeconf="$EDITOR $ZDOTDIR/.zshenv"
# }

# { Vim
    if type nvim &>/dev/null;
        then alias vim='nvim'
    fi
# }

# { Chezmoi
    alias cm="chezmoi"
    alias cmmanaged="selected=\$(cm managed | fzf --height 40% --reverse) && echo \${HOME}/\${selected}"
    alias cmedit="selected=\$(cmmanaged) && chezmoi edit \${selected}"
    alias cmra="selected=\$(cmmanaged) && chezmoi add \${selected}"
# }

# { Brew
    alias brewd="brew-dump"
    alias brewu="brew-upgrade"
# }

# { Lazygit
    alias lg="lazygit"
# }

# { Tmux
    alias tkill="tmux kill-server"
# }

# { Bw
    alias bwu="export BW_SESSION=\"\$(bw unlock --raw)\""
# }
