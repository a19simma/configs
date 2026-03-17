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
# Install core packages first
scoop install git jq just gitleaks starship bat fzf nu komorebi whkd

# Try to install bitwarden-cli separately (often fails)
try {
    scoop install bitwarden-cli
    Write-Host "Installed bitwarden-cli" -ForegroundColor Green
} catch {
    Write-Host "bitwarden-cli installation failed, skipping..." -ForegroundColor Yellow
}

# Install C compiler toolchain
try {
    scoop install mingw
    Write-Host "Installed MinGW C compiler" -ForegroundColor Green
} catch {
    try {
        scoop install llvm
        Write-Host "Installed LLVM/Clang compiler" -ForegroundColor Green
    } catch {
        Write-Host "C compiler installation failed. Install manually if needed." -ForegroundColor Yellow
    }
}

Write-Host "Windows dependencies installed" -ForegroundColor Green
Write-Host ""
Write-Host "Manual installation alternatives if needed:" -ForegroundColor Cyan
Write-Host "  C Compiler: winget install Microsoft.VisualStudio.2022.BuildTools" -ForegroundColor Gray
Write-Host "  Alternative: Download MinGW-w64 from winlibs.com" -ForegroundColor Gray
Write-Host "  Bitwarden: winget install Bitwarden.CLI" -ForegroundColor Gray
