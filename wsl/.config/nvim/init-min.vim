">>---------------------------------------------------------------------<<"
">>> "There are many ways to skin a cat, but only one way to use vim." <<<"
">>---------------------------------------------------------------------<<"

" set rnu " relative line numbers
set termguicolors
set noshowmode " if you are using some statusline, dont show --INSERT--
set vb t_vb= " set visualbell to remove te annoying ping
set belloff=all
set autoread " automatically read a file if it is changed
set hidden

" don't litter
set backupdir=~/.cache/nvim/backup//
set nowritebackup
" use swaps but put them in the following folders
set directory=~/.cache/nvim/swap//
set undofile
set undodir=~/.cache/nvim/undo//

set nowrap " wraps longs lines to screen size
set backspace=2
" set cmdheight=1 " more space for commands

" set to use the default clipboard
set termencoding=utf8
" set ff=dos

set expandtab
filetype plugin indent on

set ts=2 " tabstop - how many columns should the cursor move for one tab
set sw=2 " shiftwidth - how many columns should the text be indented
set mouse=a
set clipboard+=unnamedplus
" set the toggle for "paste" mode
set pastetoggle=<F2>
set signcolumn=yes:1
" autocomplete setup time
set shortmess+=c
set completeopt=menuone,noinsert,noselect
set ignorecase
set infercase


" General oneliners before plugins
" for the tmux conf file compatibility with polyglot
autocmd BufNewFile,BufRead {.,}tmux.*conf.* setfiletype tmux
let g:polyglot_disabled = ['markdown', 'rmarkdown', 'rmd']

" Automatic installation of vimplug :)
let autoload_plug_path = stdpath('data') . '/site/autoload/plug.vim'
if !filereadable(autoload_plug_path)
  silent execute '!curl -fLo ' . autoload_plug_path . '  --create-dirs 
      \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
unlet autoload_plug_path

" plug in the plugins
call plug#begin(stdpath('data') . '\plugged')

" Utilities
" also apt install fzf, ripgrep, bat, exa silversearcher-ag, fd-find
Plug 'moll/vim-bbye' " more sane :bdelete
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } 
Plug 'junegunn/fzf.vim' 
Plug 'junegunn/vim-easy-align'
Plug 'chrisbra/csv.vim' 
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'mbbill/undotree'
Plug 'justinmk/vim-gtfo'
Plug 'lambdalisue/suda.vim'
Plug 'kassio/neoterm'
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
" We recommend updating the parsers on update
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  

" completion and linting
Plug 'sheerun/vim-polyglot'

" Some eyecandy
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-gitgutter'
Plug 'nanotech/jellybeans.vim'

" Documents
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'jceb/vim-orgmode'

call plug#end()

">>--------------------------------------------<<"
">>> "configuration of your life starts here" <<<"
">>--------------------------------------------<<"


">>> "which_key" <<<"
" Define prefix dictionary
" let g:which_key_map =  {}
" buggy floating window
let g:which_key_use_floating_win = 0
" disable the statusline when displaying
autocmd  FileType which_key set laststatus=0 noruler
  \| autocmd BufLeave <buffer> set laststatus=2 ruler
highlight default link WhichKeySeperator healthSuccess


">>> "fzf" <<<"
let g:fzf_layout = { 'window': {
            \ 'relative': 'editor',
            \ 'width': &columns,
            \ 'height': float2nr(round(0.42 * &lines)),
            \ 'yoffset': 1,
            \ 'xoffset': 0,
            \ 'border': 'sharp'
            \ } }

let g:fzf_preview_window = [ 'right:40%', 'ctrl-/' ]
let g:fzf_buffers_jump = 0
let g:fzf_colors = { 
      \ 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'Ignore'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'] }


">>> "visual-multi" <<<"
let g:VM_mouse_mappings = 1
let g:VM_leader = '<leader>m'
" mappings
let g:VM_maps = {}
let g:VM_maps['Add Cursor Down'] = '<M-Down>'
let g:VM_maps['Add Cursor Up'] = '<M-Up>'
let g:VM_maps['Add Cursor At Pos'] = '<M-Enter>'
let g:VM_maps['Mouse Cursor'] = '<M-LeftMouse>'
let g:VM_maps['Mouse Column'] = '<M-RightMouse>'


">>> "Theming" <<<"
set background=dark
let g:material_terminal_italics = 1
let g:jellybeans_use_term_italics = 1
" material themes: 'default' | 'palenight' | 'ocean' | 'lighter' | 'darker'
let g:material_theme_style = 'darker' 
colorscheme jellybeans

highlight Normal guibg = '#151515'
highlight SignColumn guibg = '#151515'
highlight SpellBad guibg = 'none'
highlight SpellBad gui = 'undercurl'
highlight Comment guifg = '#626262'


">>> "neoterm setup" <<<"
" let g:neoterm_default_mod = 'botright'
let g:neoterm_shell = 'zsh'
let g:neoterm_repl_r = 'radian'
let g:neoterm_bracketed_paste = 1
let g:neoterm_autoscroll = 1
let g:neoterm_term_per_tab = 1
let g:neoterm_direct_open_repl = 1
let g:neoterm_keep_term_open = 0
" let g:neoterm_repl_python = ['conda activate', 'ipython --no-autoindent']


">>> "suda" <<<"
" Enable autosudo for root files
let g:suda_smart_edit = 1


">>----------------<<"
">>> "keymapland" <<<"
">>----------------<<"

" >>> "me and me only" <<<"
"
":nunmap can also be used outside of a monastery.

let mapleader="\<space>"
let maplocalleader="\<space>c"
set timeoutlen=700

" Whichkey
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>

" disable ex mode
nnoremap Q <Nop>

" add commands for changing wd on demand
command CwdHere cd %:h
command Cdh cd %:h
nnoremap <silent> <leader>dcd :cd %:h<CR>

" Sending text
" Use ss{text-object} in normal mode
" let g:which_key_map.r = { 'name': '+run' }
" "gv<esc" at the end quarantees that you won't rebound to the end
nmap <leader>rr <Plug>(neoterm-repl-send)<CR>gv<esc>
" nmap <leader>rr :TREPLSendSelection<CR>
nmap <leader>re :TREPLSendFile<CR>
" Send selected contents in visual mode.
xmap <leader>rr <Plug>(neoterm-repl-send)<CR>gv<esc>
" xmap <leader>rr :TREPLSendSelection<CR>
xmap <leader>re :TREPLSendFile<CR>
" Send line in normal.
nmap <leader>rl <Plug>(neoterm-repl-send-line)<CR>gv<esc>

" remap the exit strategy for terminal-mode
tnoremap <C-t><C-t> <C-\><C-n>

" don't rebound after yanking
vmap y ygv<esc>

" paste from previous yank
nnoremap <leader>p "0p
vnoremap <leader>p "0p

" some code navigation sensibilies for vim
noremap <silent> <C-down> }
noremap <silent> <C-up> {
noremap <silent> <C-left> b
noremap <silent> <C-right> e
noremap <silent> <C-j> }
noremap <silent> <C-k> {
inoremap <silent> <C-j> }
inoremap <silent> <C-k> {
noremap <silent> <C-h> b
noremap <silent> <C-l> e
  
" think of buffer not as "b" but as "e" as in ~editor~
" needed when using tmux
nmap <C-e><C-l> :bn<CR>
nmap <C-e><C-h> :bp<CR>
nnoremap <C-e><C-right> :bn<CR>
nnoremap <C-e><C-left> :bp<CR>
" let g:which_key_map.e = { 'name': '+buffer' }
nnoremap <silent> <C-e><C-q> :Bdelete<CR>
nnoremap <silent> <leader>eq :Bdelete<CR>
nnoremap <silent> <leader>bq :Bdelete<CR>
nnoremap <silent> <leader>efq :Bdelete!<CR>
" let g:which_key_map.q = { 'name': '+exit' }
nnoremap <silent> <leader>qq :qa<CR>
nnoremap <silent> <leader>qr :source $MYVIMRC<CR>
nnoremap <silent> <leader>qf :qa!<CR>

" make ctrl+windows work with arrows
nnoremap <silent> <C-w><C-right> :wincmd l<CR>
nnoremap <silent> <C-w><C-left> :wincmd h<CR>
nnoremap <silent> <C-w><C-down> :wincmd j<CR>
nnoremap <silent> <C-w><C-up> :wincmd k<CR>

" buffer mode
nnoremap <silent> <leader>e<right> :bn<CR>
nnoremap <silent> <leader>e<left> :bp<CR>
nnoremap <silent> <leader>el :bn<CR>
nnoremap <silent> <leader>eh :bp<CR>
nnoremap <silent> <leader>eq :Bdelete<CR>
nnoremap <silent> <leader>ez :e $MYVIMRC<CR>

" window mode
" let g:which_key_map.w = { 'name': '+window' }
nnoremap <silent> <leader>w<right> :wincmd l<CR>
nnoremap <silent> <leader>w<left> :wincmd h<CR>
nnoremap <silent> <leader>w<down> :wincmd j<CR>
nnoremap <silent> <leader>w<up> :wincmd k<CR>
nnoremap <silent> <leader>wl :wincmd l<CR>
nnoremap <silent> <leader>wh :wincmd h<CR>
nnoremap <silent> <leader>wj :wincmd j<CR>
nnoremap <silent> <leader>wk :wincmd k<CR>
nnoremap <silent> <leader>wL :wincmd L<CR>
nnoremap <silent> <leader>wH :wincmd H<CR>
nnoremap <silent> <leader>wJ :wincmd J<CR>
nnoremap <silent> <leader>wK :wincmd K<CR>
nnoremap <silent> <leader>w<S-right> :wincmd L<CR>
nnoremap <silent> <leader>w<S-left> :wincmd H<CR>
nnoremap <silent> <leader>w<S-down> :wincmd J<CR>
nnoremap <silent> <leader>w<S-up> :wincmd K<CR>
nnoremap <silent> <leader>wq :close<CR>
nnoremap <silent> <leader>ws :split<CR>
nnoremap <silent> <leader>wv :vsplit<CR>
nnoremap <silent> <leader>w= :wincmd =<CR>
nnoremap <silent> <leader>w< :wincmd <<CR>
nnoremap <silent> <leader>w> :wincmd ><CR>
nnoremap <silent> <leader>w+ :wincmd +<CR>
nnoremap <silent> <leader>w- :wincmd -<CR>
" Might seem harmless but messes up terminal mode leader
" tnoremap <leader>ww <C-w><C-w>

" o as open ~ or / or line somewhere
" use "!" to open temporarly in fullscreen - useful for searching
nnoremap <silent> <leader>ff :Files %:p:h<CR>
nnoremap <silent> <leader>f/ :Files /<CR>
nnoremap <silent> <leader>f~ :Files ~<CR>
nnoremap <silent> <leader>fp :Files<CR>
nnoremap <silent> <leader>fr :History<CR>
nnoremap <silent> <leader>rg :Rg<CR>
nnoremap <silent> <leader>r/ :Rg /<CR>
nnoremap <silent> <leader>r~ :Rg ~<CR>
nnoremap <silent> <leader>rp :Rg $PWD<CR>
" let g:which_key_map.e = { 'name': '+lines' }
nnoremap <silent> <leader>lb :BLines<CR>
nnoremap <silent> <leader>ll :Lines<CR>
" let g:which_key_map.d = { 'name': '+do' }
nnoremap <silent> <leader>dm :Maps<CR>
nnoremap <silent> <leader>dg :Commits<CR>
nnoremap <silent> <leader>ds :w<CR>
noremap <silent> <leader>dcc :Commands<CR>
" general convenience
nnoremap <silent> <leader><space> :Buffers<CR>
nnoremap <silent> <leader>e. :Buffers!<CR>
nnoremap <silent> <leader>u :UndotreeToggle<CR>

" save root files conviniently
" if they are not opened automatically...
" let g:which_key_map.ds = { 'name': '+sudo' }
nnoremap <silent> <leader>sr :SudaRead<CR>
nnoremap <silent> <leader>sw :SudaWrite<CR>

" Other terminal goodness
" navigation shortcuts
nnoremap <silent> <leader>or :RnvimrToggle<CR>
tnoremap <silent> <leader>or <C-\><C-n>:RnvimrToggle<CR>
" let g:which_key_map.o = { 'name': '+open' }
nnoremap <silent> <leader>otv :vertical Topen<CR>
nnoremap <silent> <leader>ots :rightbelow Topen<CR>
nnoremap <silent> <leader>oT :Tnew<CR>
" let g:which_key_map.t = { 'name': '+term' }
nnoremap <silent> <leader>th :Tprevious<CR>
nnoremap <silent> <leader>t<left> Tprevious<CR>
nnoremap <silent> <leader>tl :Tnext<CR>
nnoremap <silent> <leader>t<right> Tnext<CR>


">>> "completions" <<<"
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <Plug>(cr_prev) execute('let g:_prev_line = getline(".")')
inoremap <expr> <Plug>(cr_do) (g:_prev_line == getline('.') ? "\<cr>" : "")
inoremap <expr> <Plug>(cr_post) execute('unlet g:_prev_line')
imap <expr> <CR> (pumvisible() ? "\<Plug>(cr_prev)\<C-Y>\<Plug>(cr_do)\<Plug>(cr_post)" : "\<CR>")
