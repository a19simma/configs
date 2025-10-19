# Powershell
$RepoPath = (Get-Item .).FullName
Remove-Item -Path "$env:USERPROFILE\Documents\PowerShell" -Recurse -Force 2> $null
New-Item -ItemType Junction -Path "$env:USERPROFILE\Documents\PowerShell" -Target "$RepoPath\PowerShell" -Force > $null

Remove-Item -Path "$env:USERPROFILE\.wezterm.lua" -Force 2> $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\.wezterm.lua" -Target "$RepoPath\wezterm\.wezterm.lua" -Force > $null

Remove-Item -Path "$env:USERPROFILE\AppData\Roaming\alacritty" -Force 2> $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\AppData\Roaming\alacritty" -Target "$RepoPath\alacritty" -Force > $null

Remove-Item -Path "$env:USERPROFILE\.ideavimrc" -Force 2> $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\.ideavimrc" -Target "$RepoPath\intellij\.ideavimrc" -Force > $null

Remove-Item -Path "$env:USERPROFILE\AppData\Roaming\Code\User\settings.json" -Force > $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\AppData\Roaming\Code\User\settings.json" -Target "$RepoPath\vscode\settings.json" -Force > $null

Remove-Item -Path "$env:USERPROFILE\.glaze-wm\config.yaml" -Force 2> $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\.glaze-wm\config.yaml" -Target "$RepoPath\glaze-wm\config.yaml" -Force > $null

Remove-Item -Path "$HOME\Appdata\Local\nvim-data" -Recurse  -Force 2> $null
Remove-Item -Path "$HOME\Appdata\Local\nvim" -Recurse  -Force > $null
New-Item -ItemType Junction  -Path "$HOME\Appdata\Local\nvim" -Target "$RepoPath\nvim" -Force > $null
