# We use /usr/share/fish/functions/ls.fish

function l --description 'List contents of directory using long format'
	ls -lF $argv
end
