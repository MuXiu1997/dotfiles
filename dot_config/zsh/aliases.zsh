# { Cd
    alias ..="cd .."
    alias -- -="cd -"
# }

# { Ls
    alias ls="exa --icons --color='always' --time-style=long-iso"
# }

# { Vim
    if type nvim &>/dev/null;
        then alias vim='nvim'
    fi
# }

# { Zsh
    alias zrconf="$EDITOR ~/.zshrc"
    alias zpconf="$EDITOR ~/.zprofile"
    alias zeconf="$EDITOR ~/.zshenv"
# }

# { Chezmoi
    alias cm="chezmoi"
    alias cmmanaged="selected=\$(cm managed | fzf --height 40% --reverse) && echo \${HOME}/\${selected}"
    alias cmedit="selected=\$(cmmanaged) && chezmoi edit \${selected}"
    alias cmra="selected=\$(cmmanaged) && chezmoi add \${selected}"
# }

# { Brew
    alias brewdump="cd;brew bundle dump -f --describe;cd -"
# }
#
# { Lazygit
    alias lg="lazygit"
# }
