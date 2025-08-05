# Reference: https://github.com/romkatv/powerlevel10k/issues/713#issuecomment-997322170
function prompt_fnm() {
  local fnm_default
  fnm_default=$(fnm list | grep default | awk '{ print $2 }') || return
  local fnm_current=$(fnm current)
  [[ $fnm_default != $fnm_current ]] || return
  p10k segment -b 'magenta' -f 'black' -i 'NODE_ICON' -r -t "$fnm_current"
}

# Replace all occurrences of 'nvm' with 'fnm' in the right prompt elements array using parameter expansion
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/nvm/fnm})