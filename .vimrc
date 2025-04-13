vim9script

# Skip initialization for vim-tiny
if !1 | finish | endif

# Get file informations for statusline
def g:GetFileInfo(): string
  var ex_status = '[' .. &fileformat .. ']'
  if has('multi_byte') && &fileencoding != ''
    ex_status = ex_status .. '[' .. &fileencoding .. ']'
  endif
  return ex_status
enddef

# Load plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
plug#begin('~/.vim/plugged')
Plug 'justinmk/vim-dirvish'
Plug 'tpope/vim-fugitive'
Plug 'editorconfig/editorconfig-vim'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'hashivim/vim-terraform'
plug#end()

# XXX: Vim hangs when trying to open TypeScript files on macOS.
#      This settings mitigate the problem.
#      See https://vi.stackexchange.com/questions/25086/vim-hangs-when-i-open-a-typescript-file/28721
set regexpengine=2

# Display settings
set fileencodings=ucs-bom,utf-8,cp932,euc-jp # Encoding
set laststatus=2 # Show status line
set statusline=%n:\ %f\ %y%{GetFileInfo()}%m%h%r%=%c%V,%l/%L\ %P
set ruler # Show the cursor position all the time
set number # Show line numbers
set splitbelow
set splitright

# Editting behaviors
set backspace=indent,eol,start
set formatoptions=tcrqmjB

# Tab settings
set autoindent
set tabstop=2
set shiftwidth=2
set expandtab
set smarttab

# Search behavior settings
set nowrapscan
set hlsearch
set incsearch

# Show pair of brackets
set showmatch
set matchpairs+=<:>
set matchtime=2

# Show whitespace characters
set list
set listchars=tab:>-,trail:-,extends:>,precedes:<

# Comply with modeline
set modeline

# Buffer settings
set hidden

# path settings
set path=,,

# Encoding
set encoding=UTF-8
scriptencoding UTF-8

# Key mapping for insert mode (like Bash)
inoremap <C-e> <End>
inoremap <C-a> <Home>
inoremap <C-d> <Del>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-k> <C-O>D

# Key mapping for buffer, args, quickfix and location navigation
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap [B :bfirst<CR>
nnoremap ]B :blast<CR>
nnoremap [a :previous<CR>
nnoremap ]a :next<CR>
nnoremap [A :first<CR>
nnoremap ]A :last<CR>
nnoremap [q :cprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
nnoremap [l :lprevious<CR>
nnoremap ]l :lnext<CR>
nnoremap [L :lfirst<CR>
nnoremap ]L :llast<CR>
nnoremap [t :tabprevious<CR>
nnoremap ]t :tabnext<CR>
nnoremap [T :tabfirst<CR>
nnoremap ]T :tablast<CR>

# Key mapping for some utilities
#
## Window utilities
nnoremap <C-w>N :vnew<CR>
## Put date time
nnoremap <F5> "=strftime("%c")<CR>P
inoremap <F5> <C-R>=strftime("%c")<CR>
## Update shortcuts - I don't use mode-Ex
nnoremap Q :update<CR>

## paste nopaste switch
set pastetoggle=<F2>

# Color settings
syntax on
colorscheme default

# File type plugins
filetype plugin indent on

# Change Tab pages highlight
highlight TabLineFill ctermfg=DarkGray
highlight TabLine ctermfg=Gray
highlight TabLineSel ctermfg=White ctermbg=DarkGreen

# Change Search highlight
highlight Search ctermbg=DarkYellow ctermfg=White

# Highlight specific words
highlight MY_HILIGHT term=bold ctermfg=White ctermbg=DarkBlue
match MY_HILIGHT /\v<FIXME>|<TODO>|<NOTE>/

# justinmk/vim-dirvish
final g:dirvish_relative_paths = 1

# ========= User defined commands =========

## Rename file
command! -nargs=1 -complete=file Rename :file <args> | delete(expand('#'))

## Delete file and delete buffer
command! -nargs=0 Delete delete(expand('%')) | :bdelete
