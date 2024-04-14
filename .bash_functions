#!/bin/bash

# Echo path, separated by \n
path() {
	echo $PATH | sed "s/:/\n/g"
}

# cd then ls.
# The beauty of this command is that if called without arguments, it equals a raw ls.
cl() {
	cd "$1" && ls
}

# cd then la.
ca() {
	cd "$1" && ls -A
}

# Real directory name of symlink
# realdir() {
#     if [ "$#" -lt 1 ]; then
#         echo "Usage: realdir <file>"
#         return 1
#     fi
#
#     dirname $(realpath $(command -v "$1"))
# }

# Create and go to a temporary directory.
tmp() {
	cd $(mktemp -d)
}

# Duplicate file or directory and add a counter at the end.
# If called with 2 parameters, it's equivalent to cp -r.
dupe() {
	if [ "$#" -lt 1 ]; then
		echo "Usage: dupe <path> [<target>]"
		return 1
	fi

	path="$1"
	if [ ! -e "$path" ]; then
		echo "dupe: $path not found"
		return 1
	fi

	if [ "$#" -ge 2 ]; then
		path_duped="$2"
	else
		counter=1
		while [ -e "${path}_$counter" ]; do
			counter=$((counter + 1))
		done
		path_duped="${path}_$counter"
	fi

	cp -r "$path" "$path_duped" && echo "Duplicated $path -> $path_duped"
}

# trash-cli aliases
bin() {
	if [ "$1" == "list" ]; then
		trash-list
	elif [ "$1" == "empty" ]; then
		trash-empty
	elif [ "$1" == "restore"]; then
		trash-restore "$2"
	else
		echo "Command not recognized"
		return 1
	fi
}

# Look up in sdcv
# Dependency: apt sdcv
see() {
	query="$*"
	# The sed command adds 4 spaces before each line
	sdcv -n --color "$query" | sed "s/^/    /" | less -R
}

# Search on jisho.org
# Dependency: npm jisho-cli
miru() {
	query="$*"
	jisho-cli -c always -r "$query" | less -R
}
