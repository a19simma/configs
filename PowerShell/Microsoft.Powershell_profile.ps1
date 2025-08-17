Write-Host "💡 To complete setup, run: Bootstrap-Configs" -ForegroundColor Yellow

# Safe import with error handling
try { Import-Module posh-git -ErrorAction SilentlyContinue } catch { }
try { Import-Module PSReadLine -ErrorAction SilentlyContinue } catch { }

# Only initialize starship if available
if (Get-Command starship -ErrorAction SilentlyContinue) {
    try { Invoke-Expression (&starship init powershell) } catch { }
}

# Only set PSStyle if it exists (PowerShell 7+)
if ($PSStyle -and $PSStyle.FileInfo -and $PSStyle.Background) {
    try {
        $PSStyle.FileInfo.Directory = $PSStyle.Background.FromRgb(0x1f1f28)
    } catch {
        # Silently ignore if PSStyle doesn't support this operation
    }
}

# Safe PSReadLine configuration
try {
    Set-PSReadLineOption -EditMode Windows -ErrorAction SilentlyContinue
    Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
} catch {
    # Silently ignore PSReadLine errors
}

# Only initialize zoxide if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    try { Invoke-Expression (& { (zoxide init powershell | Out-String) }) } catch { }
}

# Bootstrap function for fresh Windows systems
function Bootstrap-Configs {
    Write-Host "🚀 Bootstrapping configuration management..." -ForegroundColor Cyan
    
    # Check if just is installed, if not install via scoop
    if (!(Get-Command just -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop and just..." -ForegroundColor Yellow
        if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        }
        scoop install just
    }
    
    # Navigate to configs and run bootstrap
    if (Test-Path "$env:USERPROFILE\repos\configs") {
        Set-Location "$env:USERPROFILE\repos\configs"
        just bootstrap-windows
    } else {
        Write-Host "❌ ~/repos/configs not found. Please clone the repository first:" -ForegroundColor Red
        Write-Host "git clone <your-repo-url> $env:USERPROFILE\repos\configs" -ForegroundColor Yellow
    }
}
