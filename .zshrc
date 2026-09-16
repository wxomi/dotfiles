
# Kiro CLI pre block. Keep at the top of this file.
# Skip inside herdr — kiro-cli-term creates a nested PTY that breaks agent detection.
[[ -z "${HERDR_ENV:-}" ]] && [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# --- Antidote (plugin manager) ---
# zsh 5.9 on macOS: compdump uses `mv -f -u` which BSD mv doesn't support
# -C skips the dump security check (and the mv -u call), using cache instead
autoload -Uz compinit && compinit -C
antidote_dir=/opt/homebrew/opt/antidote/share/antidote
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  source ${antidote_dir}/antidote.zsh
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"

# --- Tool activation ---
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# --- fzf (keybindings + completion) ---
source <(fzf --zsh)

# --- Sourced configs ---
source ~/dotfiles/.zshrc-instahyre

# --- Functions ---
# Skills — npx skills wrapper that auto-links to all 5 agents after add/init
skills() {
    command npx skills "$@"
    # After add or init, auto-link any new skills to all agents
    if [[ "$1" == "add" || "$1" == "init" ]]; then
        ~/dotfiles/skill-link.sh --auto 2>/dev/null
    fi
}

# yazi — change cwd on quit
function yy() {
    local tmp="$(mktemp -t yazi-cwd)"
    command yazi --cwd-file="$tmp"
    local cwd="$(cat -- "$tmp")"
    rm -f -- "$tmp"
    if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
        cd -- "$cwd"
    fi
}

# --- Aliases ---
# hg-share wrappers (run from instahyre devel repo root)
alias hgscreate='cd /Users/wxomi/Workspace/code/work/instahyre/devel && ./scripts/hg-share.sh create'
alias hgsremove='cd /Users/wxomi/Workspace/code/work/instahyre/devel && ./scripts/hg-share.sh remove'
alias hgslist='cd /Users/wxomi/Workspace/code/work/instahyre/devel && ./scripts/hg-share.sh list'

# YouTube background audio (default Claude FM; pass any URL)
#   cfm / cfmstop / cfmvol +|-|50 / cfmmute
#   WezTerm: Ctrl-a ] vol up · Ctrl-a [ vol down · Ctrl-a m mute
alias cfm='claudefm start'
alias cfmstop='claudefm stop'
alias cfmtoggle='claudefm toggle'
alias cfmstatus='claudefm status'
alias cfmvol='claudefm vol'
alias cfmmute='claudefm mute'

# --- fzf-tab (must load after compinit, before syntax-highlighting) ---
source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh


export DEVIN_PERMISSION_MODE="bypass"

# Kiro CLI post block. Keep at the bottom of this file.
# Skip inside herdr — kiro-cli-term creates a nested PTY that breaks agent detection.
[[ -z "${HERDR_ENV:-}" ]] && [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
