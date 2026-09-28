#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_SUFFIX="$(uname -s | tr 'A-Z' 'a-z')"

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

restore_config() {
    # restore_config <basename> <destination> <label>
    # Prefers <basename>.<os>.json so macOS and Linux each get their own
    # absolute paths. Falls back to <basename>.json for bundles written
    # before per-OS variants existed.
    local src="$TMP_SECRETS/secrets/$1.${OS_SUFFIX}.json"
    [ -f "$src" ] || src="$TMP_SECRETS/secrets/$1.json"
    [ -f "$src" ] || return 0
    cp -f "$src" "$2"
    echo "  -> Restored $3 MCP config (${src##*/})"
}

if [ -d "$TMP_SECRETS/secrets" ]; then
    mkdir -p "$HOME/.gemini/config" "$HOME/.cursor" "$HOME/.config/devin" "$HOME/Workspace/config"

    restore_config gemini_mcp "$HOME/.gemini/config/mcp_config.json" "Gemini/Antigravity"
    restore_config cursor_mcp "$HOME/.cursor/mcp.json" "Cursor"
    restore_config devin_mcp "$HOME/.config/devin/mcp_config.json" "Devin"

    if [ -f "$TMP_SECRETS/secrets/kiro.env" ]; then
        cp -f "$TMP_SECRETS/secrets/kiro.env" "$HOME/Workspace/config/.env"
        echo "  -> Restored Workspace / Kiro .env"
    fi

    echo "==> All secrets successfully decrypted and restored!"
fi
