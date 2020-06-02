# Copyright (C) 2016 Yutaka Kamei
# zshrc

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt AUTO_PUSHD
unsetopt EXTENDED_HISTORY
unsetopt CLOBBER
unsetopt BEEP

# Select emacs mode
bindkey -e

# ~/.zfunc
# fpath+=~/.zfunc

# Completion
autoload -Uz compinit
compinit

# Alias
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ls='ls --color=auto --group-directories-first'
alias l='ls -lF'
alias ll='ls -alF'
alias la='ls -aF'
alias grep='grep --color=auto --exclude="*.sw[po]"'
alias less='less -ciRM'
alias CAPS='xdotool key Caps_Lock'

# Color
eval `dircolors -b`

# Stop Ctrl-S
stty stop undef || :

# if exa(1) exist
which exa 1> /dev/null 2> /dev/null && \
    alias ls='exa --group-directories-first'

# starship to initialize the prompt
which starship 1> /dev/null 2> /dev/null && eval "$(starship init zsh)"

# rbenv
which rbenv 1> /dev/null 2> /dev/null && eval "$(rbenv init -)"

# pyenv
which pyenv 1> /dev/null 2> /dev/null && eval "$(pyenv init -)"

# XXX: following scripts should be run by zlogin.
agent="/dev/shm/.`whoami`-ssh"
if [ -S $agent ]; then
    export SSH_AUTH_SOCK=$agent
else
    eval `ssh-agent -a $agent`
fi
