#!/bin/bash

# Path to your cloned dotfiles
DOTFILES_DIR="/workspaces/.codespaces/.persistedshare/dotfiles"

# Append .zshrc if it exists
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    echo "" >> ~/.zshrc
    echo "# Custom dotfiles from repo" >> ~/.zshrc
    cat "$DOTFILES_DIR/.zshrc" >> ~/.zshrc
    echo "Appended .zshrc"
fi

# Append .bashrc if it exists
if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    echo "" >> ~/.bashrc
    echo "# Custom dotfiles from repo" >> ~/.bashrc
    cat "$DOTFILES_DIR/.bashrc" >> ~/.bashrc
    echo "Appended .bashrc"
fi

if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    cat "$DOTFILES_DIR/.gitconfig" >> ~/.gitconfig
fi
