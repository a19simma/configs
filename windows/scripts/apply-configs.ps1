# Powershell
Remove-Item -Path "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force > $null
New-Item -ItemType Junction -Path "$env:USERPROFILE\Documents\PowerShell" -Target "$env:USERPROFILE\Documents\configs\PowerShell" -Force > $null

Remove-Item -Path "$env:USERPROFILE\.wezterm.lua" -Force > $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\.wezterm.lua" -Target "$env:USERPROFILE\Documents\configs\wezterm\.wezterm.lua" -Force > $null

Remove-Item -Path "$env:USERPROFILE\.glaze-wm\config.yaml" -Force > $null
New-Item -ItemType SymbolicLink  -Path "$env:USERPROFILE\.glaze-wm\config.yaml" -Target "$env:USERPROFILE\.glaze-wm\config.yaml" -Force > $null

Remove-Item -Path "$HOME\Appdata\Local\nvim" -Recurse  -Force > $null
New-Item -ItemType Junction  -Path "$HOME\Appdata\Local\nvim" -Target "$env:USERPROFILE\Documents\configs\nvim" -Force > $null



