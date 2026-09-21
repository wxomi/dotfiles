#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " Starting Complete Mac Environment Setup"
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

# 3. Brew bundle (all CLI tools, GUI casks, and runtimes)
echo "==> Installing Homebrew packages, casks, and runtimes..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 4. Workspace Directory Hierarchy
echo "==> Creating Workspace directory structure..."
mkdir -p "$HOME/Workspace"/{config,utils,learning,media,misc,personal,raw,code/work/instahyre}

# 5. Core Dotfiles & Shell Configs
echo "==> Linking shell configs and core dotfiles..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES_DIR/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
ln -sf "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.hgrc" "$HOME/.hgrc"
ln -sf "$DOTFILES_DIR/.hgignore" "$HOME/.hgignore"
ln -sf "$DOTFILES_DIR/home-AGENTS.md" "$HOME/AGENTS.md"

# SSH Config
mkdir -p "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ]; then
    cp "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
fi

# Custom CLI binaries (cfm, ox, etc.)
mkdir -p "$HOME/.local/bin"
if [ -d "$DOTFILES_DIR/bin" ]; then
    cp -f "$DOTFILES_DIR/bin/"* "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/"*
fi

# Starship prompt
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

# Mise configuration
mkdir -p "$HOME/.config/mise"
if [ -f "$DOTFILES_DIR/config/mise/config.toml" ]; then
    ln -sf "$DOTFILES_DIR/config/mise/config.toml" "$HOME/.config/mise/config.toml"
fi

# Zed Editor configuration
mkdir -p "$HOME/.config/zed"
if [ -f "$DOTFILES_DIR/config/zed/settings.json" ]; then
    ln -sf "$DOTFILES_DIR/config/zed/settings.json" "$HOME/.config/zed/settings.json"
fi

# 6. WezTerm + CodexBar Setup
echo "==> Setting up WezTerm and CodexBar..."
mkdir -p "$HOME/Workspace/utils"
if [ ! -d "$HOME/Workspace/utils/wezterm-codexbar-setup" ]; then
    git clone https://github.com/wxomi/wezterm-codexbar-setup.git "$HOME/Workspace/utils/wezterm-codexbar-setup"
else
    git -C "$HOME/Workspace/utils/wezterm-codexbar-setup" pull || true
fi
chmod +x "$HOME/Workspace/utils/wezterm-codexbar-setup/setup.sh"
(cd "$HOME/Workspace/utils/wezterm-codexbar-setup" && ./setup.sh)

# 7. Herdr & Custom Plugins Suite
echo "==> Setting up Herdr, plugins, and integrations..."
mkdir -p "$HOME/.config/herdr"
ln -sf "$DOTFILES_DIR/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# Restore Herdr plugin configs
mkdir -p "$HOME/.config/herdr/plugins/config"
if [ -d "$DOTFILES_DIR/config/herdr/plugins-config" ]; then
    cp -R "$DOTFILES_DIR/config/herdr/plugins-config/"* "$HOME/.config/herdr/plugins/config/" 2>/dev/null || true
fi

# Local plugins in ~/.local/share
mkdir -p "$HOME/.local/share"
if [ -d "$DOTFILES_DIR/herdr-local/herdr-navigator" ]; then
    cp -R "$DOTFILES_DIR/herdr-local/herdr-navigator" "$HOME/.local/share/"
fi
if [ -d "$DOTFILES_DIR/herdr-local/herdr-space-agents" ]; then
    cp -R "$DOTFILES_DIR/herdr-local/herdr-space-agents" "$HOME/.local/share/"
fi
if [ -d "$DOTFILES_DIR/herdr-local/herdr-pets" ]; then
    cp -R "$DOTFILES_DIR/herdr-local/herdr-pets" "$HOME/.local/share/"
fi

# Clone Session Titles (wxomi/herdr-session-titles)
if [ ! -d "$HOME/.local/share/herdr-session-titles" ]; then
    echo "==> Cloning Session Titles plugin..."
    git clone https://github.com/wxomi/herdr-session-titles.git "$HOME/.local/share/herdr-session-titles"
else
    git -C "$HOME/.local/share/herdr-session-titles" pull || true
fi

# Clone Heeler plugin
if [ ! -d "$HOME/.config/herdr/plugins/github/heeler" ]; then
    echo "==> Cloning Heeler plugin..."
    mkdir -p "$HOME/.config/herdr/plugins/github/heeler"
    git clone https://github.com/ZingerLittleBee/Heeler.git "$HOME/.config/herdr/plugins/github/heeler" || true
    if [ -d "$HOME/.config/herdr/plugins/github/heeler/plugin" ] && command -v npm >/dev/null 2>&1; then
        (cd "$HOME/.config/herdr/plugins/github/heeler/plugin" && npm ci) || true
    fi
fi

# Link all local plugins in Herdr
if command -v herdr >/dev/null 2>&1; then
    echo "==> Linking Herdr plugins..."
    herdr plugin link "$HOME/.local/share/herdr-session-titles" 2>/dev/null || true
    herdr plugin link "$HOME/.local/share/herdr-navigator" 2>/dev/null || true
    herdr plugin link "$HOME/.local/share/herdr-space-agents" --disabled 2>/dev/null || true
    if [ -d "$HOME/.config/herdr/plugins/github/heeler/plugin" ]; then
        herdr plugin link "$HOME/.config/herdr/plugins/github/heeler/plugin" 2>/dev/null || true
    fi

    # Install GitHub plugins via Herdr plugin manager
    echo "==> Installing GitHub Herdr plugins..."
    herdr plugin install plannotator/herdr-annotate/lite --yes 2>/dev/null || true
    herdr plugin install kryptamine/herdr-auto-title --yes 2>/dev/null || true
    herdr plugin install nicosuave/memex --yes 2>/dev/null || true
    herdr plugin install persiyanov/herdr-reviewr --yes 2>/dev/null || true

    # Install agent integrations for Herdr
    echo "==> Installing Herdr agent integrations..."
    herdr integration install devin 2>/dev/null || true
    herdr integration install cursor 2>/dev/null || true
    herdr integration install antigravity-cli 2>/dev/null || true
fi

# 8. Codex Rules & Configurations
echo "==> Configuring Codex rules..."
mkdir -p "$HOME/.codex/rules"
ln -sf "$DOTFILES_DIR/codex/default.rules" "$HOME/.codex/rules/default.rules"

# 9. Super Productivity MCP Server
echo "==> Setting up Super Productivity MCP..."
mkdir -p "$HOME/.local/share"
if [ ! -d "$HOME/.local/share/super-productivity-mcp" ]; then
    git clone https://github.com/b0x42/Super-Productivity-MCP.git "$HOME/.local/share/super-productivity-mcp"
fi
if command -v npm >/dev/null 2>&1 && [ -d "$HOME/.local/share/super-productivity-mcp" ]; then
    (cd "$HOME/.local/share/super-productivity-mcp" && npm install && npm run build) 2>/dev/null || true
fi

# 10. Decrypt & Restore MCP Secrets & ENVs (AES-256)
if [ -f "$DOTFILES_DIR/secrets.enc" ]; then
    chmod +x "$DOTFILES_DIR/decrypt_secrets.sh"
    "$DOTFILES_DIR/decrypt_secrets.sh"
fi

# 11. Agent skills & skill-link
echo "==> Restoring agent skills..."
mkdir -p "$HOME/.agents"
rsync -a "$DOTFILES_DIR/agents/skills" "$HOME/.agents/"
cp "$DOTFILES_DIR/agents/.skill-lock.json" "$HOME/.agents/.skill-lock.json"
chmod +x "$DOTFILES_DIR/skill-link.sh"
"$DOTFILES_DIR/skill-link.sh" --auto

# 12. Antidote plugin pre-compilation
echo "==> Initializing Antidote zsh plugins..."
if [ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]; then
    zsh -c "source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh && antidote bundle <$HOME/.zsh_plugins.txt >|$HOME/.zsh_plugins.zsh" || true
fi

echo "========================================"
echo " Setup Complete! "
echo " Restart terminal or launch WezTerm."
echo "========================================"
