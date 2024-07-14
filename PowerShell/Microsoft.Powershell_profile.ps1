Import-Module posh-git
Import-Module PSReadLine
Invoke-Expression (&starship init powershell)
$PSStyle.FileInfo.Directory = $PSStyle.Background.FromRgb(0x1f1f28)

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Invoke-Expression (& { (zoxide init powershell | Out-String) })
