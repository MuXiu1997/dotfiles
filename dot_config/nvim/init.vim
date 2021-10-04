source ~/.vimrc.global

" { Plugins
    call plug#begin(stdpath('data') . '/plugged')
    " Theme
    Plug 'arcticicestudio/nord-vim'

    Plug 'easymotion/vim-easymotion'
    Plug 'tpope/vim-surround'
    Plug 'mg979/vim-visual-multi'
    Plug 'tommcdo/vim-exchange'
    Plug 'machakann/vim-highlightedyank'
    Plug 'michaeljsmith/vim-indent-object'

    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    call plug#end()
" }

" { Cursor
    if $TERM_PROGRAM =~ "iTerm"
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_SR = "\<Esc>]50;CursorShape=2\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    elseif $TERM_PROGRAM =~ "tmux"
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    endif
" }

colorscheme nord

" { Options
    syntax on

    set mouse=a
    set cursorline
    set expandtab
    set list
    set listchars=tab:--,trail:.

    let g:EasyMotion_smartcase = 1
" }

" { Coc.nvim
    set hidden
    " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
    " delays and poor user experience.
    set updatetime=100

    " Don't pass messages to |ins-completion-menu|.
    set shortmess+=c

    let g:coc_global_extensions = ['coc-json', 'coc-vimlsp', 'coc-sh']

    " Use tab for trigger completion with characters ahead and navigate.
    " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
    " other plugin before putting this into your config.
    inoremap <silent><expr> <TAB>
          \ pumvisible() ? "\<C-n>" :
          \ <SID>check_back_space() ? "\<TAB>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Use <c-space> to trigger completion.
    if has('nvim')
        inoremap <silent><expr> <c-space> coc#refresh()
    else
        inoremap <silent><expr> <c-@> coc#refresh()
    endif

    " Make <CR> auto-select the first completion item and notify coc.nvim to
    " format on enter, <cr> could be remapped by other vim plugin
    inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    " Use `F2` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> <F2> <Plug>(coc-diagnostic-next)
" }

map <TAB><TAB> <Plug>(easymotion-s)
