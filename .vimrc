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
Plug 'scrooloose/syntastic'
call plug#end()

" Display settings
set fileencodings=ucs-bom,utf-8,cp932,euc-jp  " Encoding
set laststatus=2  " Show status line
set statusline=%n:\ %f\ %y%{GetFileInfo()}%m%h%r%=%c%V,%l/%L\ %P
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
"
" Put date time
nnoremap <F5> "=strftime("%c")<CR>P
inoremap <F5> <C-R>=strftime("%c")<CR>
" Copy yanked text into clipboard
nnoremap <F6> yiW:call system("xclip -in -selection clipboard -loops 1", @0)<CR>
vnoremap <F6> y:call system("xclip -in -selection clipboard -loops 1", @0)<CR>

" Color settings
syntax on
colorscheme elflord
set background=dark

" Change Search highlight
highlight Search ctermbg=DarkYellow ctermfg=White

" We want to highlight specific words
highlight MY_HILIGHT term=bold ctermfg=White ctermbg=Magenta
match MY_HILIGHT /\v<FIXME>|<TODO>|<NOTE>/

if has('autocmd')
  " File type plugins
  filetype plugin indent on

  " For editting in mutt
  autocmd BufRead /run/shm/mutt-* setlocal tw=72 fo+=m
  autocmd BufRead /tmp/mutt-* setlocal tw=72 fo+=m

  " Disable recovery in directories which user does not have write
  autocmd BufNewFile,BufReadPre /media/*,/mnt/* setlocal directory=
endif

" plasticboy/vim-markdown
let g:vim_markdown_folding_level = 3

" scrooloose/nerdtree
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = ['\.sw[po]$', '\.pyc$', '\.pyo$']
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" rust-lang/rust.vim
let g:rustfmt_autosave = 1

" scrooloose/syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_python_checkers = ["flake8"]
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
