# Copyright (C) 2016 Yutaka Kamei

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups:ignorespace

# for setting history length see HISTSIZE and
# HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=100000

# check the window size after each command and,
# if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias ls="ls --color=auto"
alias l="ls -lF"
alias ll="ls -AlF"
alias la="ls -AF"

PS1='\e[42m\u@\h\e[0m \w\n $ '
