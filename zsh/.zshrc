# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
# Path to your oh-my-zsh installation.
source ~/.zsh/zsh-completions/zsh-completions.plugin.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
fpath=(path/to/zsh-completions/src $fpath)
autoload -Uz compinit
compinit

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY_TIME
DISABLE_LS_COLORS=true

unsetopt beep
unsetopt autocd
# go
export PATH=/usr/local/go/bin:$PATH
export GOPATH=$HOME/go
export GOCACHE=$HOME/.cache/go-build
export PATH=$PATH:$GOPATH/bin
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# webinstalls
export PATH=/root/.local/bin:$PATH

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Bitwarden CLI setup for API keys
alias setup-claude='export BW_SESSION=$(bw unlock --raw) && export AVANTE_ANTHROPIC_API_KEY=$(bw get password "Anthropic API Key")'
alias setup-gemini='export BW_SESSION=$(bw unlock --raw) && export AVANTE_GEMINI_API_KEY=$(bw get password "Gemini API Key")'
alias setup-tavily='export BW_SESSION=$(bw unlock --raw) && export TAVILY_API_KEY=$(bw get password "Tavily API Key")'
alias setup-morph='export BW_SESSION=$(bw unlock --raw) && export MORPH_API_KEY=$(bw get password "Morph API Key")'
alias setup-all-keys='export BW_SESSION=$(bw unlock --raw) && export ANTHROPIC_API_KEY=$(bw get password "Anthropic API Key") && export GEMINI_API_KEY=$(bw get password "Gemini API Key") && export TAVILY_API_KEY=$(bw get password "Tavily API Key") && export MORPH_API_KEY=$(bw get password "Morph API Key")'

# Vault setup from Bitwarden
alias setup-vault='export BW_SESSION=$(bw unlock --raw) && export VAULT_TOKEN=$(bw get password "vault-init.json" | jq -r ".root_token")'

# Tmux aliases
alias t='tmux'
alias tclear='tmux kill-window -a'
# Enhanced tmux development session with optional name parameter
unalias tdev 2>/dev/null
tdev() {
  local session_name="${1:-$(basename "$PWD")}"
  
  # Create new session with first window
  tmux new-session -d -s "$session_name" -c "$PWD"
  tmux send-keys -t "$session_name" "nvim ." Enter
  
  # Create additional windows
  tmux new-window -t "$session_name" -c "$PWD"
  tmux send-keys -t "$session_name" "opencode ." Enter
  
  tmux new-window -t "$session_name" -c "$PWD"
  
  tmux new-window -t "$session_name" -c "$PWD" 
  tmux send-keys -t "$session_name" "claude" Enter
  
  tmux new-window -t "$session_name" -c "$PWD"
  tmux send-keys -t "$session_name" "lazygit" Enter
  
  # Select first window and switch to session
  tmux select-window -t "$session_name":1
  
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session_name"
  else
    tmux attach-session -t "$session_name"
  fi
}

# Enhanced fuzzy tmux session management
tm() {
  local session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --prompt="Select session: ")
  if [ -n "$session" ]; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session"
    else
      tmux attach -t "$session"
    fi
  fi
}

# Fuzzy tmux session selector with preview
tmp() {
  local session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (created #{session_created_string})" 2>/dev/null | \
    fzf --prompt="Select session: " \
        --preview="tmux list-windows -t {1} -F '#{window_index}: #{window_name} #{window_active}'" \
        --preview-window=right:40% | \
    cut -d: -f1)
  if [ -n "$session" ]; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session"
    else
      tmux attach -t "$session"
    fi
  fi
}

# Kill tmux session with fzf selector
tk() {
  local session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --prompt="Kill session: ")
  if [ -n "$session" ]; then
    tmux kill-session -t "$session"
    echo "Killed session: $session"
  fi
}

# Update Go to latest version
update-go() {
  echo "Fetching latest Go version..."
  local latest=$(curl -s https://go.dev/VERSION?m=text)
  local current=$(go version 2>/dev/null | awk '{print $3}' || echo "none")
  
  if [ "$current" = "$latest" ]; then
    echo "Go is already up to date: $current"
    return
  fi
  
  echo "Current: $current, Latest: $latest"
  echo "Downloading and installing $latest..."
  
  # Download and install
  cd /tmp
  wget -q "https://go.dev/dl/${latest}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "${latest}.linux-amd64.tar.gz"
  rm "${latest}.linux-amd64.tar.gz"
  
  echo "Go updated to $latest"
  echo "Please restart your shell or run: source ~/.zshrc"
}

# User command keybinds - using Meh key (Ctrl+Alt+Shift) as prefix to avoid tmux conflicts
bindkey -s '^[[1;8m' 'tm\n'

