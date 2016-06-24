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

/usr/bin:/usr/sbin:/home/kamei/bin:/home/kamei/.local/bin:/home/kamei/.cabal/bin:/home/kamei/.node_modules/bin:/home/kamei/go/bin
# PATH settings
PATH=/bin:/usr/local/bin:/usr/local/sbin
PATH=$PATH:/usr/bin:/usr/sbin
PATH=$PATH:$HOME/bin
PATH=$PATH:$HOME/.local/bin
PATH=$PATH:$HOME/.cabal/bin
PATH=$PATH:$HOME/.node_modules/bin
export PATH=$PATH:$GOPATH/bin
