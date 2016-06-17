if status --is-login
	set PATH $PATH ~/bin
end
if set --quqery LANG
	set --global LANG en_US.UTF-8
end
set --global fish_prompt_pwd_dir_length 0
set --global --export EDITOR vim

