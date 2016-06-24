# Copyright (C) 2016 Yutaka Kamei
# zshrc

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt AUTO_PUSHD
unsetopt EXTENDED_HISTORY
unsetopt CLOBBER
unsetopt BEEP

# Select emacs mode
bindkey -e

# Prompt
autoload -Uz compinit promptinit
compinit
promptinit
prompt adam1 ${PROMPT_COLOR:-red}

# Alias
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias ls="ls --color=auto"
alias l="ls -lF"
alias ll="ls -AlF"
alias la="ls -AF"
alias grep='grep --color=auto'
alias less='less -ciRM'

## Color
eval `dircolors -b`

## Stop Ctrl-S
stty stop undef
