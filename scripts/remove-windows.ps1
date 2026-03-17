Write-Host "Removing Windows configurations..."

# Remove symlinks
if (Test-Path -Path "$env:LOCALAPPDATA\nvim") {
    Remove-Item -Path "$env:LOCALAPPDATA\nvim" -Force -Recurse
}

if (Test-Path -Path "$env:USERPROFILE\.config\alacritty") {
    Remove-Item -Path "$env:USERPROFILE\.config\alacritty" -Force -Recurse
}

# Remove wezterm config
if (Test-Path -Path "$env:USERPROFILE\.wezterm.lua") {
    Remove-Item -Path "$env:USERPROFILE\.wezterm.lua" -Force
}

# Remove nushell config
if (Test-Path -Path "$env:APPDATA\nushell") {
    Remove-Item -Path "$env:APPDATA\nushell" -Force -Recurse
}

# Remove vscode config
if (Test-Path -Path "$env:USERPROFILE\.config\Code") {
    Remove-Item -Path "$env:USERPROFILE\.config\Code" -Force -Recurse
}

# Remove opencode config
if (Test-Path -Path "$env:USERPROFILE\.config\opencode") {
    Remove-Item -Path "$env:USERPROFILE\.config\opencode" -Force -Recurse
}

# Remove Claude Code symlinks to OpenCode
if (Test-Path -Path "$env:USERPROFILE\.claude\CLAUDE.md") {
    Remove-Item -Path "$env:USERPROFILE\.claude\CLAUDE.md" -Force
}
if (Test-Path -Path "$env:USERPROFILE\.claude\agents") {
    Remove-Item -Path "$env:USERPROFILE\.claude\agents" -Force -Recurse
}
if (Test-Path -Path "$env:USERPROFILE\.claude\commands") {
    Remove-Item -Path "$env:USERPROFILE\.claude\commands" -Force -Recurse
}

# Remove komorebi configs
if (Test-Path -Path "$env:USERPROFILE\komorebi.json") {
    Remove-Item -Path "$env:USERPROFILE\komorebi.json" -Force
}

if (Test-Path -Path "$env:USERPROFILE\komorebi.bar.json") {
    Remove-Item -Path "$env:USERPROFILE\komorebi.bar.json" -Force
}

if (Test-Path -Path "$env:USERPROFILE\.config\whkdrc") {
    Remove-Item -Path "$env:USERPROFILE\.config\whkdrc" -Force
}

# Remove PowerShell profiles
if (Test-Path -Path "$PROFILE") {
    Remove-Item -Path "$PROFILE" -Force
}

if (Test-Path -Path "$(Split-Path $PROFILE)\profile.ps1") {
    Remove-Item -Path "$(Split-Path $PROFILE)\profile.ps1" -Force
}

Write-Host "Windows configs removed successfully" -ForegroundColor Green
