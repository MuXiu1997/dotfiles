enable-fzf-tab

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' single-group color header
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' prefix ''

zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  popup-pad 100 5
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-flags --preview-window=down:3:wrap

