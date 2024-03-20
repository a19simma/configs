# Powershell
Remove-Item -Path "$env:USERPROFILE\Documents\PowerShell" -Recurse -Force > $null
New-Item -ItemType Junction -Path "$env:USERPROFILE\Documents\PowerShell" -Target "$env:USERPROFILE\Documents\configs\PowerShell" -Force > $null

Remove-Item -Path "$env:USERPROFILE\.wezterm.lua" -Force > $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\.wezterm.lua" -Target "$env:USERPROFILE\Documents\configs\wezterm\.wezterm.lua" -Force > $null

Remove-Item -Path "$env:USERPROFILE\.ideavimrc" -Force > $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\.ideavimrc" -Target "$env:USERPROFILE\Documents\configs\intellij\.ideavimrc" -Force > $null

Remove-Item -Path "$env:USERPROFILE\.glaze-wm\config.yaml" -Force > $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\.glaze-wm\config.yaml" -Target "$env:USERPROFILE\Documents\configs\glaze-wm\config.yaml" -Force > $null

Remove-Item -Path "$HOME\Appdata\Local\nvim-data" -Recurse  -Force > $null
Remove-Item -Path "$HOME\Appdata\Local\nvim" -Recurse  -Force > $null
New-Item -ItemType Junction  -Path "$HOME\Appdata\Local\nvim" -Target "$env:USERPROFILE\Documents\configs\nvim" -Force > $null



