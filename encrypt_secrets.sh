#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles_secrets.XXXXXX")"
trap 'rm -rf "$STAGING_DIR"' EXIT

echo "========================================="
echo " Encrypting Secrets & ENVs with age"
echo "========================================="

if ! command -v age >/dev/null 2>&1; then
    echo "Error: 'age' is not installed. Run: brew install age" >&2
    exit 1
fi

RECIPIENTS_FILE="$DOTFILES_DIR/recipients.txt"
if [ ! -f "$RECIPIENTS_FILE" ]; then
    echo "Error: recipients.txt not found in $DOTFILES_DIR" >&2
    exit 1
fi

mkdir -p "$STAGING_DIR/secrets"

# 1. Collect MCP configs
if [ -f "$HOME/.gemini/config/mcp_config.json" ]; then
    echo "  -> Found Gemini/Antigravity MCP config"
    cp "$HOME/.gemini/config/mcp_config.json" "$STAGING_DIR/secrets/gemini_mcp.json"
fi

if [ -f "$HOME/.cursor/mcp.json" ]; then
    echo "  -> Found Cursor MCP config"
    cp "$HOME/.cursor/mcp.json" "$STAGING_DIR/secrets/cursor_mcp.json"
fi

if [ -f "$HOME/.config/devin/mcp_config.json" ]; then
    echo "  -> Found Devin MCP config"
    cp "$HOME/.config/devin/mcp_config.json" "$STAGING_DIR/secrets/devin_mcp.json"
fi

# 2. Collect Workspace / Kiro ENVs
if [ -f "$HOME/Workspace/config/.env" ]; then
    echo "  -> Found Workspace / Kiro .env"
    cp "$HOME/Workspace/config/.env" "$STAGING_DIR/secrets/kiro.env"
fi

# 3. Encrypt archive with age using recipients list
echo "  -> Encrypting archive using age recipients..."
tar -czf - -C "$STAGING_DIR" secrets | age -R "$RECIPIENTS_FILE" -o "$DOTFILES_DIR/secrets.enc"

echo ""
echo "==> Encrypted successfully into $DOTFILES_DIR/secrets.enc"

if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "==> Committing and pushing secrets.enc to GitHub..."
    git -C "$DOTFILES_DIR" add "$DOTFILES_DIR/secrets.enc" "$RECIPIENTS_FILE" "$DOTFILES_DIR/Brewfile" "$DOTFILES_DIR/encrypt_secrets.sh" "$DOTFILES_DIR/decrypt_secrets.sh"
    git -C "$DOTFILES_DIR" commit -m "chore: upgrade secrets encryption to age asymmetric keys" || true
    git -C "$DOTFILES_DIR" push origin main || true
    echo "==> Pushed encrypted secrets to GitHub!"
fi
