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

# ~/.zfunc
# fpath+=~/.zfunc

# Prompt
autoload -Uz compinit promptinit
compinit
promptinit
prompt adam1 ${PROMPT_COLOR:-red}

# Alias
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ls='ls --color=auto'
alias l='ls -lF'
alias ll='ls -AlF'
alias la='ls -AF'
alias grep='grep --color=auto --exclude="*.sw[po]"'
alias less='less -ciRM'

# Color
eval `dircolors -b`

# Stop Ctrl-S
stty stop undef || :

# rbenv
which rbenv 1> /dev/null 2>/dev/null && eval "$(rbenv init -)"

# XXX: following scripts should be run by zlogin.
agent="/dev/shm/.`whoami`-ssh"
if [ -S $agent ]; then
    export SSH_AUTH_SOCK=$agent
else
    eval `ssh-agent -a $agent`
fi
