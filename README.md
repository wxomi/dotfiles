# Dotfiles & Workstation Environment Setup

Automated setup for macOS workstation: WezTerm, Herdr, CodexBar, AI agents, skills, and shell dotfiles.

---

## Agent Setup Instructions (Prompt to give an AI Agent)

Copy and send this prompt to your agent (Codex, Antigravity, Devin, Cursor, Claude):

```text
Set up this Mac using my dotfiles repository: https://github.com/wxomi/dotfiles

Instructions:
1. Ensure the repo is cloned at ~/dotfiles (or git clone https://github.com/wxomi/dotfiles.git ~/dotfiles).
2. Run ~/dotfiles/install.sh.
3. Confirm all symlinks (~/.zshrc, ~/.config/herdr, ~/.wezterm.lua, ~/.agents/skills) are in place and working.
```

---

## Agent Self-Execution Guide

If you are an AI agent reading this repository:

1. **Verify or clone**: Ensure this repository is located at `~/dotfiles`.
2. **Execute installer**: Run `~/dotfiles/install.sh`.
3. **Verify components**:
   - Homebrew and CLI binaries (`wezterm`, `herdr`, `codexbar`, `starship`, etc.)
   - Shell dotfiles (`~/.zshrc`, `~/.zsh_plugins.txt`, `~/.zshenv`)
   - WezTerm & CodexBar (`~/.wezterm.lua`, `~/Workspace/utils/wezterm-codexbar-setup`)
   - Herdr configuration (`~/.config/herdr/config.toml`)
   - Skills linked across agents (`~/.agents/skills`, `~/.codex/skills`, `~/.kiro/skills`, etc.)
4. **Report completion**: Tell the user setup is complete and advise them to restart terminal or launch WezTerm.

---

## Manual Install on a New Mac

```bash
# 1. Clone repository
git clone https://github.com/wxomi/dotfiles.git ~/dotfiles

# 2. Run bootstrap script
cd ~/dotfiles && ./install.sh
```

---

## What This Sets Up

1. **Homebrew & Applications**: Full [`Brewfile`](./Brewfile) containing CLI tools and casks (`wezterm`, `herdr`, `codexbar`, `codex`, `antigravity-cli`, `kiro-cli`, `raycast`, `zed`, etc.).
2. **WezTerm + CodexBar**: Clones [`wezterm-codexbar-setup`](https://github.com/wxomi/wezterm-codexbar-setup) into `~/Workspace/utils/wezterm-codexbar-setup` and creates status bar symlinks.
3. **Agent Skills**: Restores `~/.agents/skills` and runs [`skill-link.sh`](./skill-link.sh) to link skills across all agents.
4. **Shell & Prompt**: Antidote plugins, Zsh config (`~/.zshrc`), Instahyre extensions (`~/.zshrc-instahyre`), and Starship prompt.
5. **Herdr**: Workspace manager config and keybindings in `~/.config/herdr/config.toml`.
