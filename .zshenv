# Sourced on all zsh invocations (including non-interactive SSH exec used by Heeler)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PATH="$HOME/.local/bin:$PATH"
