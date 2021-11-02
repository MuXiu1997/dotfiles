# List Port
pls() {
    local command="lsof -i -nP 2> /dev/null | awk '{if ( 1<NR ) {print}}'"
    local kill_process="echo {} | awk '{print \$2}' | xargs kill -9"
    FZF_DEFAULT_COMMAND=${command} fzf \
        --header 'CTRL-D: Kill Process; CTRL-R: Reload' \
        --bind "ctrl-d:execute-silent(${kill_process})+reload(${command})" \
        --bind "ctrl-r:reload(${command})"
}

frg() {
    INITIAL_QUERY="$@"; \
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"; \
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
      fzf --bind "change:reload:$RG_PREFIX {q} || true" \
          --ansi --disabled --query "$INITIAL_QUERY" \
          --height=50% --layout=reverse \
          --preview="local result={};local filename=\${result%%:*};local other=\${result#*:};local row=\${other%%:*};local start=\$((\$row-5));if [[ \$start < 0 ]];then start=0;fi;bat --theme=Nord --style=\"header,numbers,plain\" -f --paging never -H \${row} -r \${start}:\$((\$start+40)) \${filename}"
}
