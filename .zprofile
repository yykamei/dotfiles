# Copyright (C) 2016 Yutaka Kamei
# zprofile

# Environmental Variables
export LANG=en_US.UTF-8
export C_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=/usr/bin/vim
export WORDCHARS='"*?_-,.[]~=/&;!#$%^(){}<>|'
export PAGER=less
export VIDEO_FORMAT=NTSC # For devede_ng.py
export GOPATH=$HOME/go

# PATH settings
PATH=/bin:/usr/local/bin:/usr/local/sbin
PATH=$PATH:/usr/bin:/usr/sbin
PATH=$PATH:$HOME/bin
PATH=$PATH:$HOME/.local/bin
PATH=$PATH:$HOME/.cabal/bin
PATH=$PATH:$HOME/.node_modules/bin
export PATH=$PATH:$GOPATH/bin

# TERM settings
if [ ${TERM:-none} = "xterm" ]; then
    export TERM=xterm-256color
elif [ ${TERM:-none} = "screen" ]; then
    export TERM=screen-256color
fi
