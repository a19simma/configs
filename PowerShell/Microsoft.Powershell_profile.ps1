Write-Host "💡 To complete setup, run: Bootstrap-Configs" -ForegroundColor Yellow

Import-Module posh-git -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue
Invoke-Expression (&starship init powershell)

# Only set PSStyle if it exists (PowerShell 7+)
if ($PSStyle) {
    $PSStyle.FileInfo.Directory = $PSStyle.Background.FromRgb(0x1f1f28)
}

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Invoke-Expression (& { (zoxide init powershell | Out-String) })

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
