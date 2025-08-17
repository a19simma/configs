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
    stow -t ~ shell neovim alacritty vscode nushell tmux wezterm
    @echo "✅ Dotfiles deployed successfully"

# Remove dotfiles using GNU Stow
stow-remove:
    @echo "Removing dotfiles with GNU Stow..."
    stow -t ~ -D shell neovim alacritty vscode nushell tmux wezterm
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
    stow -t ~ shell neovim alacritty vscode nushell tmux wezterm
    @echo "✅ Symlinks fixed and dotfiles deployed"

# Deploy configs on Windows (PowerShell/cmd)
deploy-windows:
    #!pwsh
    Write-Host "Deploying Windows configurations..."
    
    # Create .config directory if it doesn't exist
    if (!(Test-Path -Path "$env:USERPROFILE\.config")) {
        New-Item -ItemType Directory -Path "$env:USERPROFILE\.config" -Force
    }

    
    # Function to test if running as administrator
    function Test-Administrator {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    
    # Function to restart script with admin privileges
    function Request-AdminElevation {
        if (!(Test-Administrator)) {
            Write-Host "Requesting administrator privileges for symlink creation..." -ForegroundColor Yellow
            Write-Host "   This allows creating symlinks instead of copying files." -ForegroundColor Gray
            
            $currentScript = $MyInvocation.MyCommand.Path
            if (!$currentScript) {
                # If running from justfile, restart the deploy command with admin
                Start-Process pwsh -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "cd '$PWD'; just deploy-windows" -Verb RunAs -Wait
                return $true
            }
        }
        return $false
    }
    
    # Check if we should request elevation for symlinks
    $shouldElevate = $false
    $configsToCheck = @(
        "$env:USERPROFILE\.config\nvim",
        "$env:USERPROFILE\.config\alacritty", 
        "$env:USERPROFILE\.wezterm.lua"
    )
    
    foreach ($config in $configsToCheck) {
        if (!(Test-Path -Path $config)) {
            $shouldElevate = $true
            break
        }
    }
    
    # If we need to create symlinks and we're not admin, ask for elevation
    if ($shouldElevate -and !(Test-Administrator)) {
        $choice = Read-Host "Create symlinks (requires admin) or copy files? [S]ymlinks/[C]opy (default: Copy)"
        if ($choice -eq "S" -or $choice -eq "s") {
            if (Request-AdminElevation) {
                return  # Exit this instance as the elevated one will take over
            }
        }
        Write-Host "Proceeding with file copying (no admin required)..." -ForegroundColor Yellow
    }
    
    $useSymlinks = Test-Administrator
    
    # Create nvim config
    if (!(Test-Path -Path "$env:USERPROFILE\.config\nvim")) {
        if ($useSymlinks) {
            try {
                New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\nvim" -Target "$(Get-Location)\neovim\.config\nvim" -Force
                Write-Host "Created nvim symlink" -ForegroundColor Green
            } catch {
                Write-Host "Symlink creation failed, copying instead..." -ForegroundColor Yellow
                Copy-Item -Path "$(Get-Location)\neovim\.config\nvim" -Destination "$env:USERPROFILE\.config\nvim" -Recurse -Force
                Write-Host "Copied nvim config" -ForegroundColor Green
            }
        } else {
            Copy-Item -Path "$(Get-Location)\neovim\.config\nvim" -Destination "$env:USERPROFILE\.config\nvim" -Recurse -Force
            Write-Host "Copied nvim config" -ForegroundColor Green
        }
    }
    
    # Create alacritty config
    if (!(Test-Path -Path "$env:USERPROFILE\.config\alacritty")) {
        if ($useSymlinks) {
            try {
                New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\alacritty" -Target "$(Get-Location)\alacritty\.config\alacritty" -Force
                Write-Host "Created alacritty symlink" -ForegroundColor Green
            } catch {
                Write-Host "Symlink creation failed, copying instead..." -ForegroundColor Yellow
                Copy-Item -Path "$(Get-Location)\alacritty\.config\alacritty" -Destination "$env:USERPROFILE\.config\alacritty" -Recurse -Force
                Write-Host "Copied alacritty config" -ForegroundColor Green
            }
        } else {
            Copy-Item -Path "$(Get-Location)\alacritty\.config\alacritty" -Destination "$env:USERPROFILE\.config\alacritty" -Recurse -Force
            Write-Host "Copied alacritty config" -ForegroundColor Green
        }
    }
    
    # Create wezterm config
    if (!(Test-Path -Path "$env:USERPROFILE\.wezterm.lua")) {
        if ($useSymlinks) {
            try {
                New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.wezterm.lua" -Target "$(Get-Location)\wezterm\.config\wezterm\wezterm.lua" -Force
                Write-Host "Created wezterm symlink" -ForegroundColor Green
            } catch {
                Write-Host "Symlink creation failed, copying instead..." -ForegroundColor Yellow
                Copy-Item -Path "$(Get-Location)\wezterm\.config\wezterm\wezterm.lua" -Destination "$env:USERPROFILE\.wezterm.lua" -Force
                Write-Host "Copied wezterm config" -ForegroundColor Green
            }
        } else {
            Copy-Item -Path "$(Get-Location)\wezterm\.config\wezterm\wezterm.lua" -Destination "$env:USERPROFILE\.wezterm.lua" -Force
            Write-Host "Copied wezterm config" -ForegroundColor Green
        }
    }

    
    # Fix existing PowerShell profiles first to stop errors
    $profileDir = Split-Path $PROFILE -Parent
    if (Test-Path -Path "$profileDir\profile.ps1") {
        # Quick fix for existing profile.ps1 to stop errors
        (Get-Content "$profileDir\profile.ps1") -replace '\$PSStyle\.FileInfo\.Directory = \$PSStyle\.Background\.FromRgb\(0x1f1f28\)', 'if ($PSStyle -and $PSStyle.FileInfo -and $PSStyle.Background) { try { $PSStyle.FileInfo.Directory = $PSStyle.Background.FromRgb(0x1f1f28) } catch { } }' | Set-Content "$profileDir\profile.ps1"
        Write-Host "Fixed existing profile.ps1" -ForegroundColor Green
    }
    
    if (Test-Path -Path "$PROFILE") {
        # Quick fix for existing Microsoft.PowerShell_profile.ps1 to stop errors
        (Get-Content "$PROFILE") -replace '\$PSStyle\.FileInfo\.Directory = \$PSStyle\.Background\.FromRgb\(0x1f1f28\)', 'if ($PSStyle -and $PSStyle.FileInfo -and $PSStyle.Background) { try { $PSStyle.FileInfo.Directory = $PSStyle.Background.FromRgb(0x1f1f28) } catch { } }' | Set-Content "$PROFILE"
        Write-Host "Fixed existing Microsoft.PowerShell_profile.ps1" -ForegroundColor Green
    }
    
    # Copy PowerShell profiles (create directories if needed)
    if (Test-Path -Path ".\PowerShell\Microsoft.PowerShell_profile.ps1") {
        # Create PowerShell profile directory if it doesn't exist
        if (!(Test-Path -Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force
            Write-Host "Created PowerShell profile directory" -ForegroundColor Green
        }
        
        Copy-Item -Path ".\PowerShell\Microsoft.PowerShell_profile.ps1" -Destination "$PROFILE" -Force
        Write-Host "Copied PowerShell profile" -ForegroundColor Green
    }
    
    if (Test-Path -Path ".\PowerShell\profile.ps1") {
        Copy-Item -Path ".\PowerShell\profile.ps1" -Destination "$(Split-Path $PROFILE)\profile.ps1" -Force
        Write-Host "Copied PowerShell profile.ps1" -ForegroundColor Green
    }
    
    Write-Host "Windows configs deployed successfully" -ForegroundColor Green

# Remove Windows configs
remove-windows:
    #!pwsh
    Write-Host "Removing Windows configurations..."
    
    # Remove symlinks
    if (Test-Path -Path "$env:USERPROFILE\.config\nvim") {
        Remove-Item -Path "$env:USERPROFILE\.config\nvim" -Force -Recurse
    }
    
    if (Test-Path -Path "$env:USERPROFILE\.config\alacritty") {
        Remove-Item -Path "$env:USERPROFILE\.config\alacritty" -Force -Recurse
    }
    
    # Remove wezterm config
    if (Test-Path -Path "$env:USERPROFILE\.wezterm.lua") {
        Remove-Item -Path "$env:USERPROFILE\.wezterm.lua" -Force
    }
    
    # Remove PowerShell profiles
    if (Test-Path -Path "$PROFILE") {
        Remove-Item -Path "$PROFILE" -Force
    }
    
    if (Test-Path -Path "$(Split-Path $PROFILE)\profile.ps1") {
        Remove-Item -Path "$(Split-Path $PROFILE)\profile.ps1" -Force
    }
    
    Write-Host "Windows configs removed successfully" -ForegroundColor Green

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
    #!pwsh
    Write-Host "Installing dependencies with Scoop..."
    
    # Install Scoop if not present
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing Scoop...'
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    }
    
    # Add extras bucket if not present
    if (!(scoop bucket list | Select-String -Pattern 'extras' -Quiet)) {
        scoop bucket add extras
    }
    
    # Change to home directory to avoid bucket confusion
    Set-Location $env:USERPROFILE
    
    # Install packages (try nushell with --skip to continue if it fails)
    scoop install git jq just bitwarden-cli gitleaks starship bat fzf nu gcc
    
    Write-Host "Windows dependencies installed" -ForegroundColor Green

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

# Run GitHub Actions locally using act
test-ci:
    @echo "Running GitHub Actions locally with act..."
    @if ! command -v act >/dev/null 2>&1; then \
        echo "Installing act..."; \
        if command -v brew >/dev/null 2>&1; then \
            brew install act; \
        else \
            curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash; \
        fi; \
    fi
    @echo "Running CI workflow..."
    act -j lint-and-test

# Run specific CI job locally
test-ci-job job:
    @echo "Running GitHub Actions job: {{job}}"
    @if ! command -v act >/dev/null 2>&1; then \
        echo "❌ act not installed. Run: just test-ci"; \
        exit 1; \
    fi
    act -j {{job}}

# List available CI jobs
list-ci-jobs:
    @echo "Available GitHub Actions jobs:"
    @if [ -f ".github/workflows/ci.yml" ]; then \
        grep "^  [a-zA-Z].*:$" .github/workflows/ci.yml | sed 's/:$//' | sed 's/^  /  - /'; \
    else \
        echo "❌ No CI workflow found at .github/workflows/ci.yml"; \
    fi
