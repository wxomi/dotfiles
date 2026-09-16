#!/bin/bash
# skill-link.sh — symlink skills from ~/.agents/skills/ to the agents you use
#
# Usage:
#   skill-link.sh <skill-name>   Link one skill
#   skill-link.sh --auto         Link any skills not yet linked (silent)
#
# Note: Devin reads ~/.agents/skills/ directly, so it's NOT listed here.
# Symlinking to ~/.config/devin/skills/ causes duplicates.

set -euo pipefail

SOURCE="$HOME/.agents/skills"
AGENT_DIRS=(
    "$HOME/.kiro/skills"
    "$HOME/.codex/skills"
    "$HOME/.gemini/antigravity-cli/skills"
    "$HOME/.cursor/skills"
)

link_one() {
    local skill="$1" src="$SOURCE/$1"
    [ ! -d "$src" ] && return 1
    local count=0
    for dir in "${AGENT_DIRS[@]}"; do
        mkdir -p "$dir" 2>/dev/null || true
        local target="$dir/$skill"
        [ -L "$target" ] && continue
        [ -d "$target" ] && continue
        ln -s "$src" "$target"
        count=$((count + 1))
    done
    [ "$count" -gt 0 ] && echo "Linked '$skill' to $count agent(s)"
}

case "${1:-}" in
    --auto)
        for d in "$SOURCE"/*/; do
            name=$(basename "$d")
            [[ "$name" == .* ]] && continue
            link_one "$name" || true
        done
        ;;
    "")
        echo "Usage: skill-link.sh <skill-name>"
        exit 1
        ;;
    *)
        link_one "$1"
        ;;
esac
