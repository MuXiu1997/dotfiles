r() {
    local temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    trap "rm -f -- ${temp_file}" EXIT
    ranger-zoxide --choosedir "$temp_file" "$@"
    if local choosedir="$(cat -- "$temp_file")" && [ -n "$choosedir" ] && [ "$choosedir" != "$PWD" ]; then
        cd -- "$choosedir"
    fi
}

# List Port
pls() {
    local command="lsof -i -nP 2> /dev/null | awk '{if ( 1<NR ) {print}}'"
    local kill_process="echo {} | awk '{print \$2}' | xargs kill -9"
    FZF_DEFAULT_COMMAND=${command} fzf \
        --header 'CTRL-D: Kill Process; CTRL-R: Reload' \
        --bind "ctrl-d:execute-silent(${kill_process})+reload(${command})" \
        --bind "ctrl-r:reload(${command})"
}
