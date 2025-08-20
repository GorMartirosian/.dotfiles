#!/usr/bin/env bash

# Symlink files
ln -sf ~/.dotfiles/.bashrc ~/.bashrc
ln -sf ~/.dotfiles/.vimrc ~/.vimrc
ln -sf ~/.dotfiles/.local/bin/ql-https ~/.local/bin/ql-https

# Symlink directories
ln -sfn ~/.dotfiles/.emacs.d ~/.emacs.d
