#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$DOTFILES_DIR/secrets.enc" ]; then
    echo "No secrets.enc found, skipping secret decryption."
    exit 0
fi

if ! command -v age >/dev/null 2>&1; then
    echo "Error: 'age' is not installed. Run: brew install age" >&2
    exit 1
fi

TMP_SECRETS="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles_decrypted.XXXXXX")"
trap 'rm -rf "$TMP_SECRETS"' EXIT

echo "========================================="
echo " Decrypting MCP Secrets & ENVs (age)"
echo "========================================="
echo "Enter your memorable 4-word passphrase:"

age -d "$DOTFILES_DIR/secrets.enc" | tar -xzf - -C "$TMP_SECRETS"

if [ -d "$TMP_SECRETS/secrets" ]; then
    mkdir -p "$HOME/.gemini/config" "$HOME/.cursor" "$HOME/.config/devin" "$HOME/Workspace/config"
    
    if [ -f "$TMP_SECRETS/secrets/gemini_mcp.json" ]; then
        cp -f "$TMP_SECRETS/secrets/gemini_mcp.json" "$HOME/.gemini/config/mcp_config.json"
        echo "  -> Restored Gemini/Antigravity MCP config"
    fi
    
    if [ -f "$TMP_SECRETS/secrets/cursor_mcp.json" ]; then
        cp -f "$TMP_SECRETS/secrets/cursor_mcp.json" "$HOME/.cursor/mcp.json"
        echo "  -> Restored Cursor MCP config"
    fi
    
    if [ -f "$TMP_SECRETS/secrets/devin_mcp.json" ]; then
        cp -f "$TMP_SECRETS/secrets/devin_mcp.json" "$HOME/.config/devin/mcp_config.json"
        echo "  -> Restored Devin MCP config"
    fi
    
    if [ -f "$TMP_SECRETS/secrets/kiro.env" ]; then
        cp -f "$TMP_SECRETS/secrets/kiro.env" "$HOME/Workspace/config/.env"
        echo "  -> Restored Workspace / Kiro .env"
    fi
    
    echo "==> All secrets successfully decrypted and restored!"
fi
