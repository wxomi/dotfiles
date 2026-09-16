#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " Starting Mac Environment Setup"
echo "========================================"

# 1. Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
    if [[ -t 0 ]]; then
        echo "Please finish the Xcode tools prompt if open, then press Enter to continue."
        read -r
    else
        echo "Non-interactive environment detected, proceeding..."
    fi
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3. Brew bundle (packages & casks)
echo "==> Installing Homebrew packages and apps..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 4. Dotfiles & Shell configs
echo "==> Linking shell configs and dotfiles..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES_DIR/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
ln -sf "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"

# Starship prompt
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

# Herdr config
mkdir -p "$HOME/.config/herdr"
ln -sf "$DOTFILES_DIR/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
if [ -f "$DOTFILES_DIR/config/herdr/plugins.json" ] && [ ! -f "$HOME/.config/herdr/plugins.json" ]; then
    cp "$DOTFILES_DIR/config/herdr/plugins.json" "$HOME/.config/herdr/plugins.json"
fi

# 5. WezTerm + CodexBar setup
echo "==> Setting up WezTerm and CodexBar..."
mkdir -p "$HOME/Workspace/utils"
if [ ! -d "$HOME/Workspace/utils/wezterm-codexbar-setup" ]; then
    git clone https://github.com/wxomi/wezterm-codexbar-setup.git "$HOME/Workspace/utils/wezterm-codexbar-setup"
else
    git -C "$HOME/Workspace/utils/wezterm-codexbar-setup" pull || true
fi
chmod +x "$HOME/Workspace/utils/wezterm-codexbar-setup/setup.sh"
(cd "$HOME/Workspace/utils/wezterm-codexbar-setup" && ./setup.sh)

# 6. Agent skills & skill-link
echo "==> Restoring agent skills..."
mkdir -p "$HOME/.agents"
rsync -a "$DOTFILES_DIR/agents/skills" "$HOME/.agents/"
cp "$DOTFILES_DIR/agents/.skill-lock.json" "$HOME/.agents/.skill-lock.json"
chmod +x "$DOTFILES_DIR/skill-link.sh"
"$DOTFILES_DIR/skill-link.sh" --auto

# 7. Antidote plugin pre-compilation
echo "==> Initializing Antidote zsh plugins..."
if [ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]; then
    zsh -c "source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh && antidote bundle <$HOME/.zsh_plugins.txt >|$HOME/.zsh_plugins.zsh" || true
fi

echo "========================================"
echo " Setup Complete! "
echo " Restart terminal or launch WezTerm."
echo "========================================"
