Import-Module posh-git
Import-Module PSReadLine
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/negligible.omp.json" | Invoke-Expression

Enable-PoshTransientPrompt
 
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView