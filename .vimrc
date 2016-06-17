" Copyright (C) 2016 Yutaka Kamei

" Skip initialization for vim-tiny
if !1 | finish | endif

" Get file informations for statusline
function! GetFileInfo()
  let ex_status = '[' . &fileformat . ']'
  if has('multi_byte') && &fileencoding != ''
    let ex_status = ex_status . '[' . &fileencoding . ']'
  endif
  return ex_status
endfunction

" Load plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'vim-scripts/ifdef-highlighting'
Plug 'Align'
Plug 'vim-scripts/matchit.zip'
Plug 'plasticboy/vim-markdown'
Plug 'elzr/vim-json'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
call plug#end()

" Display settings
set fileencodings=ucs-bom,utf-8,cp932,euc-jp  " Encoding
set laststatus=2  " Show status line
set statusline=%n:\ %F\ %y%{GetFileInfo()}%m%h%r%=%c%V,%l/%L\ %P
set ruler  " Show the cursor position all the time
set number  " Show line numbers

" Editting behaviors
set backspace=indent,eol,start
set formatoptions=tcrqmj

" Tab settings
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab

" Search behavior settings
set nowrapscan
set hlsearch
set incsearch
set noignorecase
set magic

" Show pair of brackets
set showmatch
set matchpairs+=<:>
set matchtime=2

" Show whitespace characters
set list
set listchars=tab:>-,trail:-,extends:>,precedes:<

" We comply with modeline
set modeline

" Buffer settings
set hidden

" path settings
set path=,,

" Key mapping for insert mode (like Bash)
inoremap <C-e> <End>
inoremap <C-a> <Home>
inoremap <C-d> <Del>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-k> <C-O>D

" Key mapping for buffer, args, quickfix and location navigation
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

" Key mapping for some utilities
inoremap <F5> <C-R>=strftime("%c")<CR>

" Color settings
syntax on
colorscheme elflord
set background=dark

" We want to highlight specific words
highlight MY_HILIGHT ctermfg=Black ctermbg=Yellow
match MY_HILIGHT /\v<FIXME>|<TODO>|<NOTE>/

if has('autocmd')
  " File type plugins
  filetype plugin indent on

  " For editting in mutt
  autocmd BufRead /run/shm/mutt-* setlocal tw=72 fo+=m
  autocmd BufRead /tmp/mutt-* setlocal tw=72 fo+=m

  " Disable recovery in directories which user does not have write
  autocmd BufNewFile,BufReadPre /media/*,/mnt/* setlocal directory=

  " Specific file extensions indentation
  autocmd! FileType html setlocal shiftwidth=2 tabstop=2
  autocmd! FileType htmldjango setlocal shiftwidth=2 tabstop=2
  autocmd! FileType xml setlocal shiftwidth=2 tabstop=2
  autocmd! FileType css setlocal shiftwidth=2 tabstop=2
  autocmd! FileType javascript setlocal shiftwidth=2 tabstop=2
  autocmd! FileType json setlocal shiftwidth=2 tabstop=2
  autocmd! FileType less setlocal shiftwidth=2 tabstop=2
  autocmd! FileType yaml setlocal shiftwidth=2 tabstop=2
  autocmd! FileType vim setlocal shiftwidth=2 tabstop=2
endif

" NERD tree
if has('autocmd')
  let g:NERDTreeShowHidden = 1
  let g:NERDTreeIgnore     = ['\.sw[po]$']
  let g:loaded_netrw       = 1
  let g:loaded_netrwPlugin = 1
  autocmd VimEnter * if exists(":NERDTree") | execute 'NERDTree' | endif
endif
