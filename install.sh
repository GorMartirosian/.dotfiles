#!/usr/bin/env bash

# Ensure ~/.local/bin exists
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir "$HOME/.local/bin"
fi

# Symlink files
ln -sfn ~/.dotfiles/.bashrc ~/.bashrc
ln -sfn ~/.dotfiles/.vimrc ~/.vimrc
ln -sfn ~/.dotfiles/.local/bin/ql-https ~/.local/bin/ql-https

# Symlink directories
ln -sfn ~/.dotfiles/.emacs.d ~/.emacs.d
