" vim::foldmethod=marker:foldmarker={{{,}}}
" {{{ Plug setup
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
" {{{ Snipmate
"Plug 'MarcWeber/vim-addon-mw-utils'
"Plug 'tomtom/tlib_vim'
"Plug 'garbas/vim-snipmate'
"
"" Optional:
"Plug 'honza/vim-snippets'
" }}}

"Plug 'vim-scripts/L9'
"Plug 'vim-scripts/FuzzyFinder'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tomtom/tcomment_vim'
Plug 'kana/vim-smartinput'
Plug 'alvan/vim-closetag', { 'for': ['xml', 'html'] }
Plug 'mattn/emmet-vim', { 'for': ['html', 'html.handlebars'] }
"Plug 'othree/vim-autocomplpop'
Plug 'vim-scripts/dbext.vim', { 'for': 'sql' }
"Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'neoclide/coc.nvim', { 'branch': 'release', 'for': ['javascript', 'python', 'html.handlebars'] }
"Plug 'mustache/vim-mustache-handlebars', { 'for': 'html.handlebars' }
Plug 'maksimr/vim-jsbeautify', { 'for': 'javascript' }

" {{{ Denite.vim
Plug 'Shougo/denite.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
" }}}

"{{{ Markdown
Plug 'godlygeek/tabular', { 'for': 'markdown' }
"Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install', 'for': 'markdown' }
"}}}

"{{{ C++
Plug 'rip-rip/clang_complete', { 'for': 'cpp' }
"}}}

"{{{ PHP
Plug 'ervandew/supertab', { 'for': 'php' }
Plug 'm2mdas/phpcomplete-extended', { 'for': 'php' }
"}}}

call plug#end()
" }}}

" {{{ Standart config
set viminfo='100,<500,s100,h
"Disable mouse support (This was the default setting in previous versions)
set mouse=

"Enable line numbers
set rnu
set nu

"Syntax highlighting and indentation
syntax on 
set bg=dark
filetype plugin on
filetype indent on

set fileformat=unix
set encoding=utf-8
" }}}

autocmd BufNewFile,BufRead * if &syntax == '' | set syntax=plain | endif

"Remove auto wrapping of comments
autocmd FileType * set formatoptions-=c

"{{{ Autocomplete settings
set completeopt+=menuone,noinsert
set completeopt-=menu,preview
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <C-n> pumvisible() ? "\<lt>Down>" : '<C-n>'
"}}}

" {{{ Find related options
"Append all files in the current project to the path so they can be searched with find
set path+=**
"Bar on top displaying available file when tabbing through file with commands like :e and also enables wild globbing with :find
set wildmenu
"Ignore `node_modules` dir because it can slow `find` command a lot
set wildignore+=**/node_modules/**

set incsearch
" }}}

" {{{ Highlight settings
set hlsearch    "highlights search results
hi CursorLine cterm=NONE ctermbg=6 ctermfg=white guibg=darkred guifg=white      "adjust cursor color
set cul         "highlights current line
" }}}

" {{{ Cursor config
"@return pid: String: Parent PID of the given PID
function! GetPPID(pid)
  return system('echo $(ps -o ppid= '. a:pid .')')
endfunction

"@param pid: String: PID of the program
function! GetProgramName(pid)
  return system('echo $(ps -o comm= '. a:pid .')')
endfunction

"Sets different cursor in normal/insert mode
"@TERM_EMU - manially set if in ssh session
"&t_SI - start insert mode
"&t_EI - exit insert mode
if exists('$TERM_EMU')
  let TERM_EMU = $TERM_EMU
else
  if exists("$TMUX") || exists("$TMUX_PANE")
    let tmux_pid = system('echo $(tmux display-message -p "#{client_pid}")')
    let parent_shell_pid = GetPPID(tmux_pid)
  else
    let vim_pid = system('echo $PPID')
    let parent_shell_pid = GetPPID(vim_pid)
  endif

  while (substitute(GetProgramName(parent_shell_pid), '\n', '', '') == "sudo") || (substitute(GetProgramName(parent_shell_pid), '\n', '', '') == "sudoedit") || (substitute(GetProgramName(parent_shell_pid), '\n', '', '') == "bash") || (substitute(GetProgramName(parent_shell_pid), '\n', '', '') == "virsh") || (substitute(GetProgramName(parent_shell_pid), '\n', '', '') == "systemctl") || (substitute(GetProgramName(parent_shell_pid), '\n', '', '') == "sshd")
    let parent_shell_pid = GetPPID(parent_shell_pid)
  endwhile

  let term_emu_pid = parent_shell_pid
  let TERM_EMU = GetProgramName(term_emu_pid)
endif


if (TERM_EMU =~ 'gnome-terminal') || (TERM_EMU =~ 'tilda') || (TERM_EMU =~ 'xfce4-terminal')
  let &t_SI .= "\<Esc>[6 q"
  let &t_EI .= "\<Esc>[2 q"
  if v:version > 704 || v:version == 704 && has('patch687')
    let &t_SR .= "\<Esc>[4 q"
  endif
  " 1 or 0 -> blinking block
  " 2 -> solid block
  " 3 -> blinking underscore
  " 4 -> solid underscore
  " Recent versions of xterm (282 or above) also support
  " 5 -> blinking vertical bar
  " 6 -> solid vertical bar
elseif TERM_EMU =~ 'konsole'
  if exists("$TMUX") || exists("$TMUX_PANE")
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    if v:version > 704 || v:version == 704 && has('patch687')
      let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
    endif
  else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    if v:version > 704 || v:version == 704 && has('patch687')
      let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    endif
    " 0 -> block
    " 1 -> vertical line
    " 2 -> underscore
  endif
endif
" }}}

" {{{ Functions
fun! UpByIndent()
  norm! ^
  let start_col = col(".")
  let col = start_col
  while col >= start_col
    norm! k^
    if getline(".") =~# '^\s*$'
      let col = start_col
    elseif col(".") <= 1
      return
    else
      let col = col(".")
    endif
  endwhile
endfun
" }}}

" {{{ Remaps
let mapleader = "\\"

"no <down> <Nop>
"no <up> <Nop>
"no <left> <Nop>
"no <right> <Nop>
"
"ino <down> <Nop>
"ino <up> <Nop>
"ino <left> <Nop>
"ino <right> <Nop>
"
"vn <down> <Nop>
"vn <up> <Nop>
"vn <left> <Nop>
"vn <right> <Nop>

nn <s-k> <Nop>
nn ; :
nn : ;
nn <c-p> :call UpByIndent()<cr>
nn <Leader>e :Explore<CR>
nn <Leader>f :FufFile<CR>
nn go o<ESC>k
nn gO O<ESC>j
nn <leader>t :tabnew<CR>
nn <leader>w :tabclose<CR>
nn gn :tabnext<CR>
nn gp :tabprev<CR>
"ino <expr> <S-Tab> pumvisible() ? "\<C-n>" : "\<C-x>\<C-o>"
"selection remains after indenting
vn < <gv
vn > >gv
"g+,  move to prev line of same identation
nn g, :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%<' . line('.') . 'l\S', 'be')<CR>
"g+.  move to next line of same identation
nn g. :call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%>' . line('.') . 'l\S', 'e')<CR>
"Same mappings as above but for visual mode
vn g, <Esc>:call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%<' . line('.') . 'l\S', 'be')<CR>m'gv''
vn g. <Esc>:call search('^'. matchstr(getline('.'), '\(^\s*\)') .'\%>' . line('.') . 'l\S', 'e')<CR>m'gv''
" }}}
