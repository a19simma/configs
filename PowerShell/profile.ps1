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
