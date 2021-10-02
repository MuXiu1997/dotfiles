# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"


# { Default
    export FZF_COMPLETION_TRIGGER='\'

    FZF_DEFAULT_FILE_PREVIEW='--preview "
    [[ $(file --mime {}) =~ binary ]] && if [[ -d {} ]] ;then lsd -1 --icon never --color always {}; else echo {} is a binary file;fi ||
    (bat --theme=Nord --style=numbers --color=always {} ) 2> /dev/null | head -500
    "'
    FZF_DEFAULT_COLOR='
    --color fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C,fg+:#D8DEE9,bg+:#434C5E,hl+:#A3BE8C
    --color pointer:#BF616A,info:#4C566A,spinner:#4C566A,header:#4C566A,prompt:#81A1C1,marker:#EBCB8B
    '

    export FZF_DEFAULT_COMMAND='fd --color=always --follow --exclude .git --exclude node_modules'

    export FZF_DEFAULT_OPTS="
    ${FZF_DEFAULT_COLOR}
    "
# }

# { CTRL-T
    temp_fzf_ctrl_t_type_file="$(mktemp -t fzf_ctrl_t_type.XXXXXXXXXX)"
    temp_fzf_ctrl_t_hidden_file="$(mktemp -t fzf_ctrl_t_hidden.XXXXXXXXXX)"
    fzf_ctrl_t_files_command="echo \"f\" > ${temp_fzf_ctrl_t_type_file}"
    fzf_ctrl_t_directories_command="echo \"d\" > ${temp_fzf_ctrl_t_type_file}"
    fzf_ctrl_t_init_hidden_command="echo \"\" > ${temp_fzf_ctrl_t_hidden_file}"
    fzf_ctrl_t_toggle_hidden_command="if [[ \$(cat -- \"${temp_fzf_ctrl_t_hidden_file}\") == \"\" ]];then echo \"h\" > ${temp_fzf_ctrl_t_hidden_file};else echo \"\" > ${temp_fzf_ctrl_t_hidden_file};fi"
    fzf_ctrl_t_base_command="
        local args=(\"-H\" \"--type\" \"f\" \"--color=always\" \"--follow\" \"--exclude\" \".git\" \"--exclude\" \"node_modules\" \"--exclude\" \"Library\" \"--exclude\" \"Applications\" \"--exclude\" \"System\" \"--exclude\" \"*备份\"); \
        if [[ \$(cat -- \"${temp_fzf_ctrl_t_hidden_file}\") == \"\" ]]; \
        then args[1]=\"\"; \
        else args[1]=\"-H\"; \
        fi; \
        if [[ \$(cat -- \"${temp_fzf_ctrl_t_type_file}\") == \"d\" ]]; \
        then args[3]=\"d\"; \
        else args[3]=\"f\"; \
        fi; \
        fd \${args}
    "
    export FZF_CTRL_T_COMMAND="${fzf_ctrl_t_files_command};${fzf_ctrl_t_init_hidden_command};${fzf_ctrl_t_base_command}"
    export FZF_CTRL_T_OPTS="
    --height '80%'
    --border
    --ansi
    --prompt 'Files> '
    --header 'CTRL-D: Directories / CTRL-F: Files / CTRL-SPACE: Toggle Hidden'
    --bind 'ctrl-f:change-prompt(Files> )+reload#${fzf_ctrl_t_files_command};${fzf_ctrl_t_base_command}#'
    --bind 'ctrl-d:change-prompt(Directories> )+reload#${fzf_ctrl_t_directories_command};${fzf_ctrl_t_base_command}#'
    --bind 'ctrl-space:+reload#${fzf_ctrl_t_toggle_hidden_command};${fzf_ctrl_t_base_command}#'
    ${FZF_DEFAULT_FILE_PREVIEW}
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
