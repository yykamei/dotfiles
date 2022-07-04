# Copyright (C) 2016 Yutaka Kamei
# zshrc

# Environmental Variables
export EDITOR=/usr/bin/vim
export WORDCHARS='"*?_-,.[]~=/&;!#$%^(){}<>|'
export PAGER=less
export VIDEO_FORMAT=NTSC # For devede_ng.py
export GOPATH=$HOME/go
export ANDROID_HOME=$HOME/Android/Sdk
export THWACK_EXEC=vim

# PATH settings
PATH=/usr/local/bin:/usr/local/sbin
if [ -d /sbin ]; then
  PATH=$PATH:/sbin
fi
PATH=$PATH:$HOME/.rbenv/bin
PATH=$PATH:$HOME/.local/bin
PATH=$PATH:$HOME/.cabal/bin
PATH=$PATH:$HOME/.node_modules/bin
PATH=$PATH:$HOME/.cargo/bin
PATH=$PATH:$HOME/bin
PATH=$PATH:$GOPATH/bin
PATH=$PATH:$HOME/google-cloud-sdk/bin
PATH=$PATH:$HOME/flutter/bin
PATH=$PATH:$HOME/android-studio/bin
PATH=$PATH:$HOME/.pub-cache/bin
PATH=$PATH:$HOME/.config/composer/vendor/bin
PATH=$PATH:$ANDROID_HOME/emulator
PATH=$PATH:$ANDROID_HOME/tools
PATH=$PATH:$ANDROID_HOME/tools/bin
PATH=$PATH:$ANDROID_HOME/platform-tools
PATH=$PATH:/bin:/usr/bin:/usr/sbin
if which brew 1> /dev/null 2> /dev/null; then
    PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
    PATH="$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH"
fi
export PATH

# Locale settings
unset LANG LC_ALL
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE="C"
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"
test -z "`perl -e exit 2>&1`" || \
    export LANG=C && unset LC_ALL \
                           LC_CTYPE \
                           LC_NUMERIC \
                           LC_TIME \
                           LC_MONETARY \
                           LC_MESSAGES \
                           LC_PAPER \
                           LC_NAME \
                           LC_ADDRESS \
                           LC_TELEPHONE \
                           LC_MEASUREMENT \
                           LC_IDENTIFICATION

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
alias less='less -ciRM'
alias curl='curl -fsSL'
if [ `uname -s` = 'Darwin' ]; then
  alias grep='ggrep --color=auto --exclude="*.sw[po]"'
else
  alias grep='grep --color=auto --exclude="*.sw[po]"'
fi
alias blu='bundle lock --conservative --update'

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

if [ `uname -s` = 'Linux' ]; then
    # XXX: following scripts should be run by zlogin.
    agent="/dev/shm/.`whoami`-ssh"
    if [ -S $agent ]; then
        export SSH_AUTH_SOCK=$agent
    else
        eval `ssh-agent -a $agent`
    fi
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yutaka.kamei/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yutaka.kamei/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/yutaka.kamei/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yutaka.kamei/google-cloud-sdk/completion.zsh.inc'; fi

# The next line updates PATH for Netlify's Git Credential Helper.
test -f '/Users/yutaka.kamei/Library/Preferences/netlify/helper/path.zsh.inc' && source '/Users/yutaka.kamei/Library/Preferences/netlify/helper/path.zsh.inc'
