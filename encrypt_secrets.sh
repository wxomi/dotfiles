#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_SUFFIX="$(uname -s | tr 'A-Z' 'a-z')"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles_secrets.XXXXXX")"
trap 'rm -rf "$STAGING_DIR"' EXIT

echo "========================================="
echo " Encrypting Secrets & ENVs (age scrypt)"
echo "========================================="

if ! command -v age >/dev/null 2>&1; then
    echo "Error: 'age' is not installed. Run: brew install age" >&2
    exit 1
fi

mkdir -p "$STAGING_DIR/secrets"

# 0. Seed the staging dir from the existing bundle so the OTHER machine's
#    per-OS configs survive this run. Without this, encrypting on macOS
#    would drop the Linux variants and vice versa.
if [ -f "$DOTFILES_DIR/secrets.enc" ]; then
    echo "Enter the existing passphrase (keeps the other machine's configs):"
    if ! age -d "$DOTFILES_DIR/secrets.enc" | tar -xzf - -C "$STAGING_DIR"; then
        echo "Error: could not decrypt the existing secrets.enc." >&2
        echo "Aborting so the other machine's configs are not silently dropped." >&2
        exit 1
    fi
fi

# 1. Collect this machine's MCP configs
if [ -f "$HOME/.gemini/config/mcp_config.json" ]; then
    echo "  -> Found Gemini/Antigravity MCP config"
    cp "$HOME/.gemini/config/mcp_config.json" "$STAGING_DIR/secrets/gemini_mcp.${OS_SUFFIX}.json"
fi

if [ -f "$HOME/.cursor/mcp.json" ]; then
    echo "  -> Found Cursor MCP config"
    cp "$HOME/.cursor/mcp.json" "$STAGING_DIR/secrets/cursor_mcp.${OS_SUFFIX}.json"
fi

if [ -f "$HOME/.config/devin/mcp_config.json" ]; then
    echo "  -> Found Devin MCP config"
    cp "$HOME/.config/devin/mcp_config.json" "$STAGING_DIR/secrets/devin_mcp.${OS_SUFFIX}.json"
fi

# 2. Collect Workspace / Kiro ENVs
if [ -f "$HOME/Workspace/config/.env" ]; then
    echo "  -> Found Workspace / Kiro .env"
    cp "$HOME/Workspace/config/.env" "$STAGING_DIR/secrets/kiro.env"
fi

# 3. Encrypt archive with age scrypt passphrase
echo ""
echo "Type your memorable 4-word passphrase when prompted."
echo "You will use these 4 words to decrypt on your other laptop."
echo ""
tar -czf - -C "$STAGING_DIR" secrets | age -p -o "$DOTFILES_DIR/secrets.enc"

echo ""
echo "==> Encrypted successfully into $DOTFILES_DIR/secrets.enc"

if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "==> Committing and pushing secrets.enc to GitHub..."
    git -C "$DOTFILES_DIR" add "$DOTFILES_DIR/secrets.enc" "$DOTFILES_DIR/Brewfile" "$DOTFILES_DIR/encrypt_secrets.sh" "$DOTFILES_DIR/decrypt_secrets.sh" "$DOTFILES_DIR/README.md"
    git -C "$DOTFILES_DIR" commit -m "chore: use age scrypt passphrase encryption for public repo safety" || true
    git -C "$DOTFILES_DIR" push origin main || true
    echo "==> Pushed encrypted secrets to GitHub!"
fi
