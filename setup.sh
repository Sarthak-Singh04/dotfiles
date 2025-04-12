#!/bin/bash
set -euo pipefail

# Determine the root directory of your repository (dotfiles)
DOTFILES_ROOT="$(cd "$(dirname "$0")" && pwd)"
echo "Using dotfiles root: ${DOTFILES_ROOT}"

# Function to create a symlink after backing up an existing file if needed
link_file() {
    local src="$1"
    local dest="$2"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing file $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    if [ -L "$dest" ]; then
        rm -f "$dest"
    fi
    ln -s "$src" "$dest"
    echo "Symlinked $src to $dest"
}

echo "Starting dotfiles setup..."

### Helix Configurations ###
echo "Setting up Helix configuration..."
# Create Helix configuration directory if it doesn't exist
mkdir -p ~/.config/helix
link_file "${DOTFILES_ROOT}/helix/config.toml" ~/.config/helix/config.toml
link_file "${DOTFILES_ROOT}/helix/languages.toml" ~/.config/helix/languages.toml

### Neovim Configuration ###
if [ -d "${DOTFILES_ROOT}/nvim" ]; then
    echo "Setting up Neovim configuration..."
    mkdir -p ~/.config/nvim
    # Remove any existing nvim symlink or directory
    rm -rf ~/.config/nvim
    ln -s "${DOTFILES_ROOT}/nvim" ~/.config/nvim
    echo "Neovim configuration symlinked."
else
    echo "Neovim configuration folder not found in the repository."
fi

### tmux Configuration ###
if [ -f "${DOTFILES_ROOT}/tmux/.tmux.conf" ]; then
    echo "Setting up tmux configuration..."
    link_file "${DOTFILES_ROOT}/tmux/.tmux.conf" ~/.tmux.conf
else
    echo "tmux configuration file (.tmux.conf) not found in the repository/tmux folder."
fi

### Starship Configuration ###
if [ -f "${DOTFILES_ROOT}/starship/starship.toml" ]; then
    echo "Setting up Starship configuration..."
    mkdir -p ~/.config
    link_file "${DOTFILES_ROOT}/starship/starship.toml" ~/.config/starship.toml
else
    echo "Starship configuration file (starship.toml) not found in the repository/starship folder."
fi

### Ghostty Configuration ###
if [ -d "${DOTFILES_ROOT}/ghostty" ]; then
    echo "Setting up Ghostty configuration..."
    mkdir -p ~/.config/ghostty
    # Here we copy the files instead of linking (adjust as needed)
    cp -r "${DOTFILES_ROOT}/ghostty/"* ~/.config/ghostty/
    echo "Ghostty configuration copied."
else
    echo "Ghostty configuration folder not found in the repository."
fi

### Bash Configuration (Optional) ###
# If you have custom bash configurations inside a 'bash' folder in your dotfiles:
if [ -f "${DOTFILES_ROOT}/bash/.bashrc" ]; then
    echo "Setting up bash configuration..."
    # Optionally, source a custom bash config file from .bashrc
    if ! grep -q "source ~/.bash_custom" ~/.bashrc; then
        echo "source ~/.bash_custom" >> ~/.bashrc
        echo "Added source for ~/.bash_custom in ~/.bashrc"
    fi
    cp "${DOTFILES_ROOT}/bash/.bashrc" ~/.bash_custom
else
    echo "No custom bash configuration file found."
fi

echo "Dotfiles setup complete."
