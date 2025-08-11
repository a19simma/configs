# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

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
export PATH=/usr/local/go/bin:/usr/bin/go/bin:$PATH
export GOPATH=/usr/bin/go
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# webinstalls
export PATH=/root/.local/bin:$PATH

eval "$(starship init zsh)"
export PATH=$PATH

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

