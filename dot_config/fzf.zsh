# { Key bindings
  [[ ! -f "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] || source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
# }

# { Default
    export FZF_COMPLETION_TRIGGER='\'

    export FZF_DEFAULT_COLOR='
    --color fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C,fg+:#D8DEE9,bg+:#434C5E,hl+:#A3BE8C
    --color pointer:#BF616A,info:#4C566A,spinner:#4C566A,header:#4C566A,prompt:#81A1C1,marker:#EBCB8B
    '

    export FZF_DEFAULT_OPTS="
    --bind=tab:down,btab:up,change:top,ctrl-space:toggle
    --cycle
    ${FZF_DEFAULT_COLOR}
    "

    __fzf_funtions="cat $HOME/.config/fzf.zsh | grep -E '^####' | cut -c5-"
# }

# { CTRL-T
    export temp_fzf_ctrl_t_type_file="$(mktemp -t fzf_ctrl_t_type.XXXXXXXXXX)"
    export temp_fzf_ctrl_t_hidden_file="$(mktemp -t fzf_ctrl_t_hidden.XXXXXXXXXX)"

    function __clear_temp_fzf_ctrl_files() {
        rm -f -- $temp_fzf_ctrl_t_type_file
        rm -f -- $temp_fzf_ctrl_t_hidden_file
    }
    typeset -ag zshexit_functions;
    if [[ -z "${zshexit_functions[(r)__clear_temp_fzf_ctrl_files]+1}" ]]; then
      zshexit_functions=( __clear_temp_fzf_ctrl_files ${zshexit_functions[@]} )
    fi

    export FZF_CTRL_T_COMMAND="$__fzf_funtions | zsh -s _fzf_ctrl_t_command 0 \"$temp_fzf_ctrl_t_type_file\" \"$temp_fzf_ctrl_t_hidden_file\""
    export FZF_CTRL_T_OPTS="
    --height '80%'
    --border
    --ansi
    --prompt 'Files> '
    --header 'CTRL-D: Directories / CTRL-F: Files / CTRL-SPACE: Toggle Hidden'
    --bind 'ctrl-f:change-prompt(Files> )+reload($__fzf_funtions | zsh -s _fzf_ctrl_t_command 1 \"$temp_fzf_ctrl_t_type_file\" \"$temp_fzf_ctrl_t_hidden_file\")'
    --bind 'ctrl-d:change-prompt(Directories> )+reload($__fzf_funtions | zsh -s _fzf_ctrl_t_command 2 \"$temp_fzf_ctrl_t_type_file\" \"$temp_fzf_ctrl_t_hidden_file\")'
    --bind 'ctrl-space:+reload($__fzf_funtions | zsh -s _fzf_ctrl_t_command 3 \"$temp_fzf_ctrl_t_type_file\" \"$temp_fzf_ctrl_t_hidden_file\")'
    --preview '$__fzf_funtions | sh -s _file_preview {}'
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

unset __fzf_funtions

####set -e
####
####_file_preview() {
####    filepath="$1"
####    if [[ $(file --mime "$filepath") =~ binary ]]; then
####        if [[ -d "$filepath" ]]; then
####            exec exa -1 --color=always "$filepath"
####        else
####            echo ""$filepath" is a binary file"
####        fi
####    else
####        exec bat --theme=Nord --style=numbers --color=always "$filepath" 2> /dev/null | head -500
####    fi
####}
####
####_fzf_ctrl_t_command() {
####    temp_type_file="$2"
####    temp_hidden_file="$3"
####
####    case $1 in
####        0)
####            echo "f" > $temp_type_file
####            echo "" > $temp_hidden_file
####        ;;
####        1)
####            echo "f" > $temp_type_file
####        ;;
####        2)
####            echo "d" > $temp_type_file
####        ;;
####        3)
####            if [[ "$(cat -- $temp_hidden_file)" == "" ]]; then
####                echo "h" > $temp_hidden_file
####            else
####                echo "" > $temp_hidden_file
####            fi
####        ;;
####    esac
####
####    fd_args=("-H" "--type" "f" "--color=always" "--follow" "--exclude" ".git" "--exclude" "node_modules" "--exclude" "Library" "--exclude" "Applications" "--exclude" "System" "--exclude" "*备份")
####    if [[ "$(cat -- $temp_hidden_file)" == "" ]]; then
####        fd_args[1]=""
####    fi
####    if [[ "$(cat -- $temp_type_file)" == "d" ]]; then
####        fd_args[3]="d"
####    fi
####    exec fd $fd_args
####}
####
####"$@"

