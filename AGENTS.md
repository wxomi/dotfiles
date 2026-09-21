# Agent Setup Instructions

When the user asks you to set up this machine or points you to this dotfiles repository:

1. **Location**: Ensure this repository is at `~/dotfiles`.
2. **Execute**: Run `chmod +x ~/dotfiles/install.sh && ~/dotfiles/install.sh`.
3. **Behavior**: Do not pause for non-critical confirmations. Let the installer run through.
4. **Verification**: After execution, verify:
   - `~/.zshrc` exists and links to `~/dotfiles/.zshrc`
   - `~/.config/herdr/config.toml` exists
   - `~/.wezterm.lua` points to `~/Workspace/utils/wezterm-codexbar-setup/wezterm.lua`
   - `~/.agents/skills` exists and skills are linked across agents via `~/dotfiles/skill-link.sh --auto`
   - If `secrets.enc` exists, prompt user for password or ask if they provided `DOTFILES_SECRET_PASS` to decrypt MCP configs (`~/.gemini/config/mcp_config.json`, `~/.cursor/mcp.json`, `~/.config/devin/mcp_config.json`, `~/Workspace/config/.env`).
5. **Report**: Give the user a clean status check of all installed components.
