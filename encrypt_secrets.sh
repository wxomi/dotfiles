#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles_secrets.XXXXXX")"
trap 'rm -rf "$STAGING_DIR"' EXIT

echo "========================================="
echo " Encrypting MCP Secrets & ENVs"
echo "========================================="

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

# 3. Encrypt archive with OpenSSL AES-256-CBC PBKDF2
if [ -n "${DOTFILES_SECRET_PASS:-}" ]; then
    tar -czf - -C "$STAGING_DIR" secrets | openssl enc -aes-256-cbc -pbkdf2 -salt -iter 100000 -pass "pass:$DOTFILES_SECRET_PASS" -out "$DOTFILES_DIR/secrets.enc"
else
    echo ""
    echo "Choose a master password to encrypt your secrets."
    echo "You will use this password to decrypt them on your other laptop."
    echo ""
    tar -czf - -C "$STAGING_DIR" secrets | openssl enc -aes-256-cbc -pbkdf2 -salt -iter 100000 -out "$DOTFILES_DIR/secrets.enc"
fi

echo ""
echo "==> Encrypted successfully into $DOTFILES_DIR/secrets.enc"

if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "==> Committing and pushing secrets.enc to GitHub..."
    git -C "$DOTFILES_DIR" add "$DOTFILES_DIR/secrets.enc"
    git -C "$DOTFILES_DIR" commit -m "chore: update encrypted secrets bundle" || true
    git -C "$DOTFILES_DIR" push origin main || true
    echo "==> Pushed encrypted secrets to GitHub!"
fi
