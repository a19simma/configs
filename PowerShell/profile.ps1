Import-Module posh-git
Import-Module PSReadLine
Invoke-Expression (&starship init powershell)

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
