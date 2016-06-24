# Copyright (C) 2016 Yutaka Kamei
# zlogin

agent="/tmp/.`whoami`-ssh"
if [ -S $agent ]; then
    export SSH_AUTH_SOCK=$agent
else
    eval `ssh-agent -a $agent`
fi
