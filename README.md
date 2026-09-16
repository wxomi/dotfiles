# Dotfiles & Environment Setup

Automated setup for macOS workstation, terminal, AI agents, and skills.

## Quick Install on a New Mac

```bash
# 1. Clone this repository
git clone https://github.com/wxomi/dotfiles.git ~/dotfiles

# 2. Run the bootstrap script
cd ~/dotfiles && ./install.sh
```

## What This Sets Up

1. **Homebrew & Apps**: Everything in [`Brewfile`](./Brewfile) (CLI tools, casks like WezTerm, Herdr, Codex, Raycast, etc.).
2. **WezTerm + CodexBar**: Clones [`wezterm-codexbar-setup`](https://github.com/wxomi/wezterm-codexbar-setup) into `~/Workspace/utils/wezterm-codexbar-setup` and links configurations.
3. **Agent Skills**: Restores `~/.agents/skills` and uses [`skill-link.sh`](./skill-link.sh) to link across all installed agents (Codex, Kiro, Antigravity, Cursor, Devin).
4. **Shell & Prompt**: Antidote plugins, Zsh configuration (`~/.zshrc`), Instahyre aliases (`~/.zshrc-instahyre`), and Starship prompt.
5. **Herdr**: Workspace manager config and keybindings in `~/.config/herdr/config.toml`.
