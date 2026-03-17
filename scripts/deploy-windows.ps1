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

# Require administrator privileges for deployment
if (!(Test-Administrator)) {
    Write-Host "Administrator privileges required for symlink deployment." -ForegroundColor Red
    Write-Host "Restarting with elevated permissions..." -ForegroundColor Yellow
    Start-Process pwsh -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "cd '$PWD'; ./scripts/deploy-windows.ps1" -Verb RunAs -Wait
    return
}

Write-Host "Running with administrator privileges - creating symlinks..." -ForegroundColor Green

# Remove existing configs and create fresh symlinks
$configs = @{
    "$env:LOCALAPPDATA\nvim" = "$(Get-Location)\neovim"
    "$env:USERPROFILE\.config\alacritty" = "$(Get-Location)\alacritty"
    "$env:USERPROFILE\.wezterm.lua" = "$(Get-Location)\wezterm\wezterm.lua"
    "$env:APPDATA\nushell" = "$(Get-Location)\nushell"
    "$env:USERPROFILE\.config\Code" = "$(Get-Location)\vscode"
    "$env:USERPROFILE\.config\opencode" = "$(Get-Location)\opencode"
    "$env:USERPROFILE\.config\k9s" = "$(Get-Location)\k9s"
    "$env:USERPROFILE\komorebi.json" = "$(Get-Location)\komorebi\komorebi.json"
    "$env:USERPROFILE\komorebi.bar.json" = "$(Get-Location)\komorebi\komorebi.bar.json"
    "$env:USERPROFILE\.config\whkdrc" = "$(Get-Location)\komorebi\.config\whkdrc"
}

foreach ($config in $configs.GetEnumerator()) {
    $target = $config.Key
    $source = $config.Value
    
    # Remove existing config (file or directory)
    if (Test-Path -Path $target) {
        Write-Host "Removing existing config: $target" -ForegroundColor Yellow
        Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
    }
    
    # Create symlink
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
        Write-Host "Created symlink: $target -> $source" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create symlink for: $target" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        exit 1
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
