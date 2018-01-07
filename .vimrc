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
Plug 'Align'
Plug 'vim-scripts/matchit.zip'
Plug 'justinmk/vim-dirvish'
Plug 'szw/vim-tags'
Plug 'scrooloose/syntastic'
Plug 'nginx.vim'
Plug 'kannokanno/previm', {'for': ['markdown']}
Plug 'elzr/vim-json', {'for': ['json']}
Plug 'rust-lang/rust.vim', {'for': ['rust']}
Plug 'racer-rust/vim-racer', {'for': ['rust']}
Plug 'fatih/vim-go', {'for': ['go']}
Plug 'slim-template/vim-slim', {'for': ['slim']}
Plug 'kchmck/vim-coffee-script', {'for': ['coffee']}
Plug 'mtscout6/syntastic-local-eslint.vim', {'for': ['javascript']}
Plug 'alessioalex/syntastic-local-tslint.vim', {'for': ['typescript']}
Plug 'othree/yajs.vim', {'for': ['javascript']}
Plug 'tfnico/vim-gradle', {'for': ['groovy']}
Plug 'dart-lang/dart-vim-plugin', {'for': ['dart']}
Plug 'tell-k/vim-autopep8', {'for': ['python']}
Plug 'digitaltoad/vim-pug'
Plug 'wavded/vim-stylus'
Plug 'posva/vim-vue'
Plug 'mxw/vim-jsx'
Plug 'tpope/vim-fugitive'
Plug 'cespare/vim-toml'
Plug 'leafgarland/typescript-vim'
Plug 'udalov/kotlin-vim'
call plug#end()

" Display settings
set fileencodings=ucs-bom,utf-8,cp932,euc-jp  " Encoding
set laststatus=2  " Show status line
set statusline=%n:\ %f\ %y%{GetFileInfo()}%m%h%r%=%c%V,%l/%L\ %P
set ruler  " Show the cursor position all the time
set number  " Show line numbers
set splitbelow
set splitright

" Editting behaviors
set backspace=indent,eol,start
set formatoptions=tcrqmjB

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

" Encoding
set encoding=UTF-8
scriptencoding UTF-8

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
nnoremap [t :tabprevious<CR>
nnoremap ]t :tabnext<CR>
nnoremap [T :tabfirst<CR>
nnoremap ]T :tablast<CR>

" Key mapping for some utilities
"
"" Window utilities
nnoremap <C-w>N :vnew<CR>
"" Put date time
nnoremap <F5> "=strftime("%c")<CR>P
inoremap <F5> <C-R>=strftime("%c")<CR>
"" Update shortcuts - I don't use mode-Ex
nnoremap Q :update<CR>

"" paste nopaste switch
set pastetoggle=<F2>

" Color settings
syntax on
colorscheme elflord
set background=dark

" File type plugins
filetype plugin indent on

" Change Tab pages highlight
highlight TabLineFill ctermfg=DarkGray
highlight TabLine ctermfg=Gray
highlight TabLineSel ctermfg=White ctermbg=DarkGreen

" Change Search highlight
highlight Search ctermbg=DarkYellow ctermfg=White

" We want to highlight specific words
highlight MY_HILIGHT term=bold ctermfg=White ctermbg=DarkBlue
match MY_HILIGHT /\v<FIXME>|<TODO>|<NOTE>/

if has('autocmd')
  " For editting in mutt
  autocmd BufRead /run/shm/mutt-* setlocal tw=36 fo+=m
  autocmd BufRead /tmp/mutt-* setlocal tw=36 fo+=m

  " Disable recovery in directories which user does not have write
  autocmd BufNewFile,BufReadPre /media/*,/mnt/* setlocal directory=
endif

" kannokanno/previm
let g:previm_open_cmd = 'chromium -incognito'

" rust-lang/rust.vim
let g:rustfmt_autosave = 1
let g:rustfmt_fail_silently = 1

" scrooloose/syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_python_checkers = ['python', 'flake8']
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_ruby_rubocop_args = '--force-exclusion --display-cop-names'
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_java_checkers=['javac']
let g:syntastic_java_javac_config_file_enabled = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_dart_checkers = ['dartanalyzer']
let g:syntastic_dart_dartanalyzer_args = ['--lints']
let g:syntastic_typescript_checkers = ['tslint']
let g:syntastic_typescript_tslint_args = ['--project', '.']
let g:syntastic_scss_checkers = ['scss_lint']
let g:syntastic_scss_scss_lint_args = ['--exclude-linter', 'PropertySortOrder']
nnoremap <silent> gs :SyntasticToggleMode<CR>

" 'szw/vim-tags'
let g:vim_tags_ignore_files = []
if has('autocmd')
  autocmd BufNewFile,BufRead * let g:vim_tags_main_file = 'tags.' . &filetype
  autocmd BufNewFile,BufRead * let g:vim_tags_project_tags_command = '{CTAGS} -R --fields=+l --languages=' . &filetype . ' {OPTIONS} {DIRECTORY} 2>/dev/null'
end

" fatih/vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"

" tell-k/vim-autopep8
if has('autocmd')
  autocmd FileType python set equalprg=autopep8\ -
end
let g:autopep8_max_line_length=120
let g:autopep8_disable_show_diff=1
