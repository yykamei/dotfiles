# Copyright (C) 2016 Yutaka Kamei
# zprofile

# Environmental Variables
export EDITOR=/usr/bin/vim
export WORDCHARS='"*?_-,.[]~=/&;!#$%^(){}<>|'
export PAGER=less
export VIDEO_FORMAT=NTSC # For devede_ng.py
export GOPATH=$HOME/go
export GEM_HOME=$HOME/.gem

# PATH settings
PATH=/bin:/usr/local/bin:/usr/local/sbin
PATH=$PATH:/usr/bin:/usr/sbin
PATH=$PATH:$HOME/bin
PATH=$PATH:$HOME/.local/bin
PATH=$PATH:$HOME/.cabal/bin
PATH=$PATH:$HOME/.node_modules/bin
PATH=$PATH:$HOME/.cargo/bin
PATH=$PATH:$GOPATH/bin
PATH=$PATH:$GEM_HOME/bin
export PATH

# Locale settings
unset LANG LC_ALL
export LC_CTYPE="ja_JP.UTF-8"
export LC_NUMERIC="ja_JP.UTF-8"
export LC_TIME="ja_JP.UTF-8"
export LC_COLLATE="C"
export LC_MONETARY="ja_JP.UTF-8"
export LC_MESSAGES="ja_JP.UTF-8"
export LC_PAPER="ja_JP.UTF-8"
export LC_NAME="ja_JP.UTF-8"
export LC_ADDRESS="ja_JP.UTF-8"
export LC_TELEPHONE="ja_JP.UTF-8"
export LC_MEASUREMENT="ja_JP.UTF-8"
export LC_IDENTIFICATION="ja_JP.UTF-8"
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
