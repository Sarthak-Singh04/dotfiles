#!/bin/bash
set -e

# Ensure non-interactive apt
export DEBIAN_FRONTEND=noninteractive

# Update package lists
sudo apt-get update

# Install core dependencies
sudo apt-get install -y \
    curl \
    git \
    zsh \
    build-essential \
    libssl-dev \
    pkg-config

# Install Rust
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

# Install Helix
if ! command -v hx &> /dev/null; then
    curl -LO https://github.com/helix-editor/helix/releases/download/24.07/helix-24.07-x86_64-linux.tar.xz
    sudo tar -xf helix-24.07-x86_64-linux.tar.xz -C /usr/local/bin --strip-components=1
    rm helix-24.07-x86_64-linux.tar.xz
fi

# Install Neovim
if ! command -v nvim &> /dev/null; then
    curl -LO https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
    sudo tar -xf nvim-linux64.tar.gz -C /usr/local --strip-components=1
    rm nvim-linux64.tar.gz
fi

# Install Starship
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install Tmux
sudo apt-get install -y tmux

# Install Ghostty (placeholder)
if ! command -v ghostty &> /dev/null; then
    echo "Ghostty not installed. Manual installation required."
fi

# Set Zsh as default shell
if [ ! "$SHELL" = "/bin/zsh" ]; then
    sudo chsh -s /bin/zsh $USER
fi

# Copy dotfiles
DOTFILES_DIR="$HOME/dotfiles"

# Ensure .zshrc exists
touch ~/.zshrc

# Helix
mkdir -p ~/.config/helix
cp -r $DOTFILES_DIR/helix/* ~/.config/helix/ 2>/dev/null || true

# Neovim
mkdir -p ~/.config/nvim
cp -r $DOTFILES_DIR/nvim/* ~/.config/nvim/ 2>/dev/null || true

# Ghostty
mkdir -p ~/.config/ghostty
cp -r $DOTFILES_DIR/ghostty/* ~/.config/ghostty/ 2>/dev/null || true

# Tmux
cp $DOTFILES_DIR/tmux/tmux.conf ~/.tmux.conf 2>/dev/null || true

# Zsh
cp $DOTFILES_DIR/zshrc ~/.zshrc 2>/dev/null || true

# Starship
mkdir -p ~/.config
cp -r $DOTFILES_DIR/starship/* ~/.config/ 2>/dev/null || true

# Configure Starship autocompletion
if ! grep -q "starship init zsh" ~/.zshrc; then
    echo '# Enable Starship prompt' >> ~/.zshrc
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

# Install Zsh completions
sudo apt-get install -y zsh-completions

# Clean up
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo "Setup complete! Run 'zsh' to start your configured shell."
