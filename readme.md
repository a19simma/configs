# Configuration Repository

This repository contains my dotfiles and configurations, managed with GNU Stow for symlink management and Homebrew for cross-platform dependency installation.

Nvim setup is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

## 🚀 One-Command Setup

**Linux/macOS:**
```bash
git clone https://github.com/a19simma/configs ~/repos/configs && source ~/repos/configs/shell/.bashrc && bootstrap-configs
```

**Windows (PowerShell):**
```powershell
git clone https://github.com//a19simma/configs $env:USERPROFILE\repos\configs; . $env:USERPROFILE\repos\configs\PowerShell\Microsoft.PowerShell_profile.ps1; Bootstrap-Configs
```

## Structure

The repository is organized into Stow packages:
- `shell/` - Shell configuration (.zshrc, .bashrc)
- `nushell/` - Nushell configuration (config.nu, env.nu)
- `neovim/` - Neovim configuration 
- `alacritty/` - Alacritty terminal config
- `vscode/` - VS Code settings and profiles
- `tmux/` - Tmux configuration (.tmux.conf)

## Getting Started

### Quick Bootstrap (Recommended)

**Fresh Linux/macOS system:**
```bash
# 1. Clone repository
git clone <your-repo-url> ~/repos/configs

# 2. Source the shell config to get bootstrap function
source ~/repos/configs/shell/.bashrc  # or .zshrc

# 3. Run bootstrap (installs just + all dependencies + deploys configs)
bootstrap-configs
```

**Fresh Windows system:**
```powershell
# 1. Clone repository
git clone <your-repo-url> $env:USERPROFILE\repos\configs

# 2. Import PowerShell profile to get bootstrap function
. $env:USERPROFILE\repos\configs\PowerShell\Microsoft.PowerShell_profile.ps1

# 3. Run bootstrap (installs scoop + just + all dependencies + deploys configs)
Bootstrap-Configs
```

### Manual Installation

**Install Dependencies:**
```bash
# Linux/macOS: Install via Homebrew Bundle
just install-deps

# Windows: Install via Scoop
just install-deps-windows

# Linux only: Install system-level dependencies
just install-system-deps
```

### Deploy Dotfiles

**Linux/macOS (GNU Stow):**
```bash
# Deploy all dotfiles using GNU Stow
just stow-deploy

# Remove dotfiles
just stow-remove
```

**Windows (PowerShell):**
```powershell
# Deploy Windows configurations
just deploy-windows

# Remove Windows configs
just remove-windows
```

### Other Commands
```bash
# Backup existing configs
just backup-configs

# Sync configs from system to repo
just sync-from-local

# Update from kickstart.nvim
just sync-kickstart
``` 
