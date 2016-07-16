# Copyright (C) 2016 Yutaka Kamei
# zprofile

# Environmental Variables
export EDITOR=/usr/bin/vim
export WORDCHARS='"*?_-,.[]~=/&;!#$%^(){}<>|'
export PAGER=less
export VIDEO_FORMAT=NTSC # For devede_ng.py
export GOPATH=$HOME/go

# PATH settings
PATH=/usr/local/bin:/usr/local/sbin
PATH=$PATH:$HOME/.rbenv/bin
PATH=$PATH:$HOME/.local/bin
PATH=$PATH:$HOME/.cabal/bin
PATH=$PATH:$HOME/.node_modules/bin
PATH=$PATH:$HOME/.cargo/bin
PATH=$PATH:$HOME/bin
PATH=$PATH:$GOPATH/bin
PATH=$PATH:/bin:/usr/bin:/usr/sbin
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

# TERM settings
if [ ${TERM:-none} = "xterm" ]; then
    export TERM=xterm-256color
elif [ ${TERM:-none} = "screen" ]; then
    export TERM=screen-256color
fi
