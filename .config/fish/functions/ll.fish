# We use /usr/share/fish/functions/ls.fish

function ll --description 'List contents of directory using long format'
	ls -lAF $argv
end
