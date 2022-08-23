# { Proxy
    alias p="HTTPS_PROXY=socks5://127.0.0.1:1080 HTTP_PROXY=socks5://127.0.0.1:1080 ALL_PROXY=socks5://127.0.0.1:1080"
# }

# { Cd
    alias ..="cd .."
    alias -- -="cd -"
# }

# { Ls
    if type exa &>/dev/null; then
        alias ls="exa --icons --color='always' --time-style=long-iso"
    fi
# }

# { Vim
    if type nvim &>/dev/null; then
        alias vim='nvim'
    fi
# }

# { Chezmoi
    alias cm="chezmoi"
    alias cms="chezmoi-shortcut"
# }

# { Brew
    alias brewd="brew-dump"
    alias brewu="brew-upgrade"
# }

# { Lazygit
    alias lg="GPG_TTY=\"\$TTY\" lazygit"
# }

# { Tmux
    alias tkill="tmux kill-server"
# }

# { Bw
    alias bwu="export BW_SESSION=\"\$(bw unlock --raw)\""
# }

# { Help
    alias h="help"
# }
