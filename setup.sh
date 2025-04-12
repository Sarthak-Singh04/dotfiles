#!/bin/bash
set -e

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

# Install Helix (if not provided by devcontainer feature)
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

# Install Ghostty
if ! command -v ghostty &> /dev/null; then
    # Note: Ghostty may require building from source or a custom installer.
    # Adjust this based on official Ghostty installation instructions.
    # Placeholder: Assuming a binary or package becomes available.
    echo "Ghostty installation not automated. Please provide installation steps."
    # Example (if available via apt or similar in the future):
    # sudo apt-get install -y ghostty
    # For now, we’ll ensure the config is copied, and you can install Ghostty manually if needed.
fi

# Set Zsh as default shell
if [ ! "$SHELL" = "/bin/zsh" ]; then
    chsh -s /bin/zsh
fi

# Copy dotfiles to appropriate locations
DOTFILES_DIR="/workspaces/dotfiles" # DevPod mounts workspace here

# Helix
mkdir -p ~/.config/helix
cp -r $DOTFILES_DIR/helix/* ~/.config/helix/

# Neovim
mkdir -p ~/.config/nvim
cp -r $DOTFILES_DIR/nvim/* ~/.config/nvim/

# Ghostty
mkdir -p ~/.config/ghostty
cp -r $DOTFILES_DIR/ghostty/* ~/.config/ghostty/

# Tmux
cp $DOTFILES_DIR/tmux/tmux.conf ~/.tmux.conf

# Zsh
cp $DOTFILES_DIR/zshrc ~/.zshrc

# Starship
mkdir -p ~/.config
cp -r $DOTFILES_DIR/starship/* ~/.config/

# Configure Starship autocompletion for Zsh
if ! grep -q "starship completions zsh" ~/.zshrc; then
    echo '# Enable Starship autocompletion' >> ~/.zshrc
    echo 'source <(starship completions zsh)' >> ~/.zshrc
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

# Clean up
sudo apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Setup complete! Run 'zsh' to start your configured shell."
