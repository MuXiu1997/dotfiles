source ~/.vimrc.global

" { Options
    syntax on

    set mouse=a
    set cursorline
    set expandtab
    set hidden
    set updatetime=100
    set shortmess+=c

    set list
    set listchars=tab:--,trail:.
" }

" { Plugins
    call plug#begin(stdpath('data') . '/plugged')
    " Theme
    Plug 'arcticicestudio/nord-vim'
    " Line
    Plug 'itchyny/lightline.vim'

    Plug 'easymotion/vim-easymotion'
    Plug 'tpope/vim-surround'
    Plug 'mg979/vim-visual-multi'
    Plug 'tommcdo/vim-exchange'
    Plug 'machakann/vim-highlightedyank'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'junegunn/vim-easy-align'
    Plug 'jiangmiao/auto-pairs'
    Plug 'mbbill/undotree'
    Plug 'psliwka/vim-smoothie'

    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    call plug#end()
" }

" { Plug 'arcticicestudio/nord-vim'
    colorscheme nord
" }

" { Plug 'itchyny/lightline.vim'
    set noshowmode
    set laststatus=2
    let g:lightline = {
            \ 'colorscheme': 'nord'
          \ }
" }

" { Plug 'easymotion/vim-easymotion'
    let g:EasyMotion_smartcase = 1
    map <TAB><TAB> <Plug>(easymotion-s)
" }

" { Plug 'junegunn/vim-easy-align'
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
" }

" { Plug 'neoclide/coc.nvim'
    let g:coc_global_extensions = ['coc-json', 'coc-vimlsp', 'coc-sh']

    " Use <C-SPACE> to trigger completion.
    if has('nvim')
        inoremap <silent><expr> <C-SPACE> coc#refresh()
    else
        inoremap <silent><expr> <C-@>     coc#refresh()
    endif

    " Make <CR> auto-select the first completion item 
    inoremap <silent><expr> <CR>  pumvisible() ? coc#_select_confirm() : "\<C-G>u\<CR>"
    " Make <TAB> auto-select the first completion item 
    inoremap <silent><expr> <TAB> pumvisible() ? coc#_select_confirm() : "\<C-G>u\<TAB>"

    " Use `F2` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> <F2> <Plug>(coc-diagnostic-next)

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Map function and class text objects
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)
    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)
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

