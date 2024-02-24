#!/bin/bash

abort() {
	echo
	echo "Abort."
	exit 1
}

# When the user sends an interrupt signal (Ctrl+C),
# abort the script instead of skipping current command.
trap abort INT

copy_dotfiles() {
	echo -n "Copying core dotfiles... "
	cp -r ./.bashrc ./.bash ./.gitconfig ./.vimrc ~/
	echo "Done."

	# Xmodmap and imwheel for Ubuntu.
	read -p "Copy Linux input configurations? (y/n) " response

	# Accept Y/y
	if [[ "$response" =~ ^[Yy]$ ]]; then
		cp ./.Xmodmap ./.imwheelrc ~/
		echo "Done."
	fi
}

setup() {
	echo "Updating apt..."
	sudo apt update && sudo apt upgrade -y

	# Download Node.js from source.
	# See https://askubuntu.com/a/83290
	read -p "Download the latest version of Node.js? (y/n)" response

	if [[ "$response" =~ ^[Yy]$ ]]; then
		curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
		sudo apt-get install -y nodejs
	fi

	# Download vim-plug and install plugins.
	# See https://github.com/junegunn/vim-plug/wiki/tutorial
	echo "Downloading vim-plug..."
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	# Enter vim, run :PlugInstall and immediately quit
	vim -c PlugInstall -c qa!

	# Compile YouCompleteMe. This may take a long time, so an option is offered to skip.
	# See https://github.com/ycm-core/YouCompleteMe/blob/master/README.md#linux-64-bit
	read -p "Compile YouCompleteMe automatically? (y/n) " response

	if [[ "$response" =~ ^[Yy]$ ]]; then
		echo "Setting up YouCompleteMe..."

		# Install CMake, Vim and Python
		sudo apt install build-essential cmake vim-nox python3-dev

		# Install mono-complete, go, node, java, and npm
		sudo mkdir -p /etc/apt/keyrings
		curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
		echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_current.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
		sudo apt install mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm

		# Compile YCM
		echo "Compiling YouCompleteMe..."
		cd ~/.vim/plugged/YouCompleteMe
		python3 install.py --all
	fi
}

echo "Enter a number."
echo "1: Use dotfiles in this repo to replace dotfiles on this machine"
echo "2: Run first-time setup on this machine"
echo "Anything else: Do nothing"
read -p "Your choice (1/2): " response

case $response in
	1)
		copy_dotfiles
		;;
	2)
		copy_dotfiles
		setup
		;;
	*)
		abort
		;;
esac

echo "Completed."
exit 0
