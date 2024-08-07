# { Cd
  alias ..="cd .."
  alias -- -="cd -"
# }

# { Ls
  # If eza/exa is installed, use it instead of ls
  command_exists exa && alias ls="exa --icons --color='always' --time-style=long-iso"
  command_exists eza && alias ls="eza --icons --color='always' --time-style=long-iso"
# }

# { Vim
  # If nvim is installed, use it instead of vim
  command_exists nvim && alias vim='nvim'
# }

# { Chezmoi
  alias cm="chezmoi"
  alias j-chezmoi="just \${XDG_CONFIG_HOME}/justfiles/chezmoi/"
# }

# { Brew
  alias j-brew="just \${XDG_CONFIG_HOME}/justfiles/brew/"
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

# { Just
  alias j="just"
# }

# { Help
  alias h="help"
# }

# { Docker
  alias dk="docker"
  alias dkc="docker compose"
# }

# { Proxy
  alias p="HTTPS_PROXY=socks5://127.0.0.1:1080 HTTP_PROXY=socks5://127.0.0.1:1080 ALL_PROXY=socks5://127.0.0.1:1080"
# }
