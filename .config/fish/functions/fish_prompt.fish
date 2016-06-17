function fish_prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

	echo -s (set_color -b $fish_color_host) "$USER" @ "$__fish_prompt_hostname" \
		    (set_color normal) ' ' \
		    (set_color $fish_color_cwd) (prompt_pwd)
	echo -n -s (set_color normal) ' $ '
end
