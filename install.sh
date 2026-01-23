#!/bin/bash

echo "Installing dotfiles..."

sudo chsh -s /bin/zsh $(whoami)

# Append .zshrc if it exists
if [ -f ".zshrc" ]; then
    echo "" >> ~/.zshrc
    echo "# Custom dotfiles from repo" >> ~/.zshrc
    cat .zshrc >> ~/.zshrc
    echo "✓ Appended .zshrc"
fi

# Append .bashrc if it exists
if [ -f ".bashrc" ]; then
    echo "" >> ~/.bashrc
    echo "# Custom dotfiles from repo" >> ~/.bashrc
    cat .bashrc >> ~/.bashrc
    echo "✓ Appended .bashrc"
fi

# Append .gitconfig if it exists
if [ -f ".gitconfig" ]; then
    echo "" >> ~/.gitconfig
    echo "# Custom dotfiles from repo" >> ~/.gitconfig
    cat .gitconfig >> ~/.gitconfig
    echo "✓ Appended .gitconfig"
fi

# Install .claude folder for Claude Code
if [ -d ".claude" ]; then
    mkdir -p ~/.claude
    cp -r .claude/* ~/.claude/
    echo "✓ Installed .claude folder"
fi

echo "Dotfiles installation complete!"
