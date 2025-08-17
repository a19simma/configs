# ~/.bashrc: executed by bash(1) for non-login shells.

echo "💡 To complete setup, run: bootstrap-configs"

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "$(dircolors)"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
/usr/bin/keychain -q --nogui $HOME/.ssh/keys/main-key
source $HOME/.keychain/DESKTOP-T8RC9SH-sh

# go
export PATH=/usr/local/go/bin:/usr/bin/go/bin:$PATH
export GOPATH=/usr/bin/go
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# webinstalls
export PATH=/root/.local/bin:$PATH

bind 'set bell-style none'

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(starship init bash)"

# Bootstrap function for fresh systems (installs just first)
bootstrap-configs() {
    echo "🚀 Bootstrapping configuration management..."
    
    # Install just if not present
    if ! command -v just >/dev/null 2>&1; then
        echo "Installing just..."
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Navigate to configs and run bootstrap
    if [ -d ~/repos/configs ]; then
        cd ~/repos/configs && just bootstrap-unix
    else
        echo "❌ ~/repos/configs not found. Please clone the repository first:"
        echo "git clone <your-repo-url> ~/repos/configs"
    fi
}

# Configuration management aliases (work from any directory)
alias install-deps='(cd ~/repos/configs && just install-deps)'
alias deploy-configs='(cd ~/repos/configs && just stow-deploy)'
alias remove-configs='(cd ~/repos/configs && just stow-remove)'
alias fix-symlinks='(cd ~/repos/configs && just fix-symlinks)'
alias help='(cd ~/repos/configs && just help)'

