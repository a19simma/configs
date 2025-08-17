# Sync files from kickstart.nvim
sync-kickstart:
    @TMP_DIR=$(mktemp -d) && git clone https://github.com/nvim-lua/kickstart.nvim.git "$TMP_DIR" && cp -r "$TMP_DIR"/* neovim/.config/nvim/ && rm -rf "$TMP_DIR"

# Backup local config files
backup-configs:
    @echo "Backing up local configs..."
    @if [ -f ~/.bashrc ]; then cp ~/.bashrc ~/.bashrc.bak; fi
    @if [ -f ~/.zshrc ]; then cp ~/.zshrc ~/.zshrc.bak; fi
    @if [ -d ~/.config ]; then cp -R ~/.config ~/.config.bak; fi
    @echo "✅ Configs backed up to ~/.bashrc.bak, ~/.zshrc.bak and ~/.config.bak"

# Deploy dotfiles using GNU Stow
stow-deploy:
    @echo "Deploying dotfiles with GNU Stow..."
    stow -t ~ shell neovim alacritty vscode nushell tmux
    @echo "✅ Dotfiles deployed successfully"

# Remove dotfiles using GNU Stow
stow-remove:
    @echo "Removing dotfiles with GNU Stow..."
    stow -t ~ -D shell neovim alacritty vscode nushell tmux
    @echo "✅ Dotfiles removed successfully"

# Fix existing symlinks and files that block stow
fix-symlinks:
    @echo "Fixing existing symlinks and backing up conflicting files..."
    # Remove or backup existing symlinks
    @if [ -L ~/.config/nvim ]; then rm ~/.config/nvim; fi
    @if [ -L ~/.zshrc ]; then rm ~/.zshrc; fi
    @if [ -L ~/.bashrc ]; then rm ~/.bashrc; fi
    @if [ -L ~/.config/nushell ]; then rm ~/.config/nushell; fi
    @if [ -L ~/.tmux.conf ]; then rm ~/.tmux.conf; fi
    # Backup existing files that would conflict with stow
    @if [ -f ~/.bashrc ] && [ ! -L ~/.bashrc ]; then mv ~/.bashrc ~/.bashrc.backup; fi
    @if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then mv ~/.zshrc ~/.zshrc.backup; fi
    @if [ -f ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ]; then mv ~/.tmux.conf ~/.tmux.conf.backup; fi
    @if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then mv ~/.config/nvim ~/.config/nvim.backup; fi
    @if [ -d ~/.config/nushell ] && [ ! -L ~/.config/nushell ]; then mv ~/.config/nushell ~/.config/nushell.backup; fi
    @if [ -d ~/.config/alacritty ] && [ ! -L ~/.config/alacritty ]; then mv ~/.config/alacritty ~/.config/alacritty.backup; fi
    @if [ -d ~/.config/Code ] && [ ! -L ~/.config/Code ]; then mv ~/.config/Code ~/.config/Code.backup; fi
    # Deploy with stow
    stow -t ~ shell neovim alacritty vscode nushell tmux
    @echo "✅ Symlinks fixed and dotfiles deployed"

# Deploy configs on Windows (PowerShell/cmd)
deploy-windows:
    @echo "Deploying Windows configurations..."
    @powershell -Command "if (!(Test-Path -Path $env:USERPROFILE\\.config)) { New-Item -ItemType Directory -Path $env:USERPROFILE\\.config -Force }"
    @powershell -Command "if (!(Test-Path -Path $env:USERPROFILE\\.config\\nvim)) { New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\\.config\\nvim -Target $(Get-Location)\\neovim\\.config\\nvim -Force }"
    @powershell -Command "if (!(Test-Path -Path $env:USERPROFILE\\.config\\alacritty)) { New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\\.config\\alacritty -Target $(Get-Location)\\alacritty\\.config\\alacritty -Force }"
    @powershell -Command "Copy-Item -Path .\\PowerShell\\Microsoft.PowerShell_profile.ps1 -Destination $PROFILE -Force"
    @powershell -Command "Copy-Item -Path .\\PowerShell\\profile.ps1 -Destination $(Split-Path $PROFILE)\\profile.ps1 -Force"
    @echo "✅ Windows configs deployed successfully"

# Remove Windows configs
remove-windows:
    @echo "Removing Windows configurations..."
    @powershell -Command "if (Test-Path -Path $env:USERPROFILE\\.config\\nvim) { Remove-Item -Path $env:USERPROFILE\\.config\\nvim -Force -Recurse }"
    @powershell -Command "if (Test-Path -Path $env:USERPROFILE\\.config\\alacritty) { Remove-Item -Path $env:USERPROFILE\\.config\\alacritty -Force -Recurse }"
    @powershell -Command "if (Test-Path -Path $PROFILE) { Remove-Item -Path $PROFILE -Force }"
    @powershell -Command "if (Test-Path -Path $(Split-Path $PROFILE)\\profile.ps1) { Remove-Item -Path $(Split-Path $PROFILE)\\profile.ps1 -Force }"
    @echo "✅ Windows configs removed successfully"

# Hello 
# Setup Bitwarden CLI
setup-bitwarden:
    @echo "Setting up Bitwarden CLI..."
    @echo "1. Login to Bitwarden:"
    bw login
    @echo "2. Unlock vault and set session:"
    @echo "Run: export BW_SESSION=\$$(bw unlock --raw)"

# Create Anthropic API key in Bitwarden
create-anthropic-api-key:
    @./scripts/create-anthropic-key.sh

# Create Gemini API key in Bitwarden
create-gemini-api-key:
    @./scripts/create-gemini-key.sh

# Create Tavily API key in Bitwarden
create-tavily-api-key:
    @./scripts/create-tavily-key.sh

# Create Morph API key in Bitwarden
create-morph-api-key:
    @./scripts/create-morph-key.sh

# Copy local files to repo (sync from system to repo)
sync-from-local:
    @echo "Syncing configs from local system to repo..."
    cp ~/.zshrc ./shell/.zshrc
    cp -R ~/.config/nvim ./neovim/.config/
    cp -R ~/.config/alacritty ./alacritty/.config/
    cp -R ~/.config/Code/User/* ./vscode/.config/Code/User/
    @echo "✅ Local configs synced to repo"

# Install all dependencies using Homebrew Bundle
install-deps:
    @echo "Installing dependencies with Homebrew Bundle..."
    brew bundle
    @echo "✅ All dependencies installed"

# Install system-level dependencies (Linux)
install-system-deps:
    @echo "Installing system-level dependencies..."
    @if command -v apt >/dev/null 2>&1; then \
        sudo apt update && sudo apt install -y nfs-common ca-certificates curl gnupg lsb-release apt-transport-https; \
    elif command -v yum >/dev/null 2>&1; then \
        sudo yum install -y nfs-utils ca-certificates curl gnupg2; \
    else \
        echo "⚠️  Please install system dependencies manually for your distribution"; \
    fi
    @echo "✅ System dependencies installed"

# Install dependencies on Windows using Scoop
install-deps-windows:
    @echo "Installing dependencies with Scoop..."
    @powershell -Command "if (!(Get-Command scoop -ErrorAction SilentlyContinue)) { Write-Host 'Installing Scoop...'; Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh') }"
    @powershell -Command "scoop bucket add extras"
    @powershell -Command "scoop install git curl jq just bitwarden-cli gitleaks starship stow nushell bat"
    @echo "✅ Windows dependencies installed"

# Bootstrap fresh Unix/Linux/macOS system
bootstrap-unix:
    @echo "🚀 Bootstrapping fresh Unix system..."
    @echo "Installing Homebrew..."
    @if ! command -v brew >/dev/null 2>&1; then \
        /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
    fi
    @echo "Installing dependencies..."
    just install-deps
    just install-system-deps
    @echo "Deploying configurations..."
    just fix-symlinks
    @echo "Setting default shell to nushell..."
    @if command -v nu >/dev/null 2>&1; then \
        sudo chsh -s "$(which nu)" "$(whoami)"; \
        echo "✅ Default shell set to nushell"; \
    else \
        echo "⚠️  nushell not found in PATH, skipping shell change"; \
    fi
    @echo "✅ Bootstrap complete!"

# Bootstrap fresh Windows system
bootstrap-windows:
    @echo "🚀 Bootstrapping fresh Windows system..."
    just install-deps-windows
    just deploy-windows
    @echo "✅ Bootstrap complete!"

# Security checks using GitLeaks
check-secrets:
    @if command -v gitleaks >/dev/null 2>&1; then \
        echo "Running GitLeaks scan..."; \
        gitleaks detect --config .gitleaks.toml --verbose; \
    else \
        echo "❌ GitLeaks not installed. Run: just install-deps"; \
        exit 1; \
    fi

# Help system - with optional parameter
help topic="":
    #!/bin/bash
    cd help
    if [ -n "{{topic}}" ]; then
        if [ -f "{{topic}}.txt" ]; then
            cat "{{topic}}.txt"
        else
            echo "Help topic '{{topic}}' not found"
            echo "Available topics:"
            ls *.txt | sed 's/.txt$//' | sed 's/^/  - /'
        fi
    elif command -v fzf >/dev/null 2>&1; then
        selected=$(ls *.txt | sed 's/.txt$//' | fzf --prompt="Select help topic: ")
        if [ -n "$selected" ]; then
            cat "$selected.txt"
        else
            echo "No help topic selected"
        fi
    else
        echo "Available help topics:"
        ls *.txt | sed 's/.txt$//' | sed 's/^/  - /'
        echo "Usage: just help [topic] or install fzf for interactive selection"
    fi
