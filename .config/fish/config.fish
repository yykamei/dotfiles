if status --is-login
	set --global --export PATH $PATH ~/bin $HOME/.local/bin
end
if not set --query LANG
	set --global LANG en_US.UTF-8
end

# Show full path
set --global fish_prompt_pwd_dir_length 0

# Use vim as main EDITOR
set --global --export EDITOR vim

# SSH settings
set -l agent_sock /tmp/.(whoami)-ssh
if not test -S $agent_sock
	ssh-agent -a $agent_sock 1> /dev/null
end
set --global --export SSH_AUTH_SOCK $agent_sock
