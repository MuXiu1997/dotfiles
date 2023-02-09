# { Proxy
  alias p="HTTPS_PROXY=socks5://127.0.0.1:1080 HTTP_PROXY=socks5://127.0.0.1:1080 ALL_PROXY=socks5://127.0.0.1:1080"
# }

# { Cd
  alias ..="cd .."
  alias -- -="cd -"
# }

# { Ls
  # If exa is installed, use it instead of ls
  command_exists exa && alias ls="exa --icons --color='always' --time-style=long-iso"
# }

# { Vim
  # If nvim is installed, use it instead of vim
  command_exists nvim && alias vim='nvim'
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

# { Bitwarden
  alias bwu="export BW_SESSION=\"\$(bw unlock --raw)\""
# }

# { Flyctl
  alias fly="flyctl"
# }

# { Help
  alias h="help"
# }
