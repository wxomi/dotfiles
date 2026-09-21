# Dotfiles & Workstation Environment Setup

Automated setup for macOS workstation: WezTerm, Herdr, CodexBar, AI agents, skills, and shell dotfiles.

---

## Agent Setup Instructions (Prompt to give an AI Agent)

Copy and send this prompt to your agent (Codex, Antigravity, Devin, Cursor, Claude):

```text
Set up this Mac using my dotfiles repository: https://github.com/wxomi/dotfiles

Instructions:
1. Ensure the repo is cloned at ~/dotfiles (or git clone https://github.com/wxomi/dotfiles.git ~/dotfiles).
2. Run ~/dotfiles/install.sh (or prompt me for secrets password if secrets.enc is present).
3. Confirm all symlinks (~/.zshrc, ~/.config/herdr, ~/.wezterm.lua, ~/.agents/skills) and MCP configs are in place.
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

> **Secrets Decryption:** When `install.sh` runs, it will ask for your memorable 4-word passphrase to decrypt MCP configs and environment variables with `age`.


---

## What This Sets Up

1. **Homebrew & Applications**: Full [`Brewfile`](./Brewfile) containing CLI tools and casks (`wezterm`, `herdr`, `codexbar`, `codex`, `antigravity-cli`, `kiro-cli`, `raycast`, `zed`, etc.).
2. **WezTerm + CodexBar**: Clones [`wezterm-codexbar-setup`](https://github.com/wxomi/wezterm-codexbar-setup) into `~/Workspace/utils/wezterm-codexbar-setup` and creates status bar symlinks.
3. **Agent Skills**: Restores `~/.agents/skills` and runs [`skill-link.sh`](./skill-link.sh) to link skills across all agents.
4. **Shell & Prompt**: Antidote plugins, Zsh config (`~/.zshrc`), Instahyre extensions (`~/.zshrc-instahyre`), and Starship prompt.
5. **Herdr & Full Plugin Suite**: Workspace manager config, keybindings (`config.toml`), and all active plugins:
   - `Session Titles` (`wxomi/herdr-session-titles`): Live session title updater in the agents sidebar.
   - `Herdr Navigator` (`thanhdat77/herdr-navigator`): Fuzzy workspace and session switcher (`prefix+p`).
   - `Current Space Agents`: Focused workspace agent filter.
   - `Auto Title`, `Annotate`, `Memex`, `Reviewr`, `Heeler`.
   - Agent integrations for `devin`, `cursor`, and `antigravity-cli`.
6. **Mercurial (`hg`) & Git**: Complete `~/.hgrc` (extensions, diff tools, aliases), `~/.hgignore` (agent isolation patterns), `~/.gitconfig`, and `~/.gitignore_global`.
7. **Global Agent Guidelines & Codex Rules**: `~/AGENTS.md` (macOS clipboard `pbcopy` guidelines) and `~/.codex/rules/default.rules`.
8. **MCP Servers**: Antigravity, Cursor, and Devin MCP configs (`instahyre-phabricator`, `slack`, `super-productivity`) + automated setup of `super-productivity-mcp`.
9. **SSH & Work Directory**: `~/.ssh/config` (`vps`, `instahyre.com`, `github.com`), `~/Workspace` tree, and `~/Workspace/config/.env` (Kiro SSO).
10. **Zed Editor & Custom Tools**: `~/.config/zed/settings.json` (agent servers, Ayu theme), `~/.config/mise/config.toml`, and custom bin tools (`cfm`, `ox`).
