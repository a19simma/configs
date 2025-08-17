# Safe import with error handling
try { Import-Module posh-git -ErrorAction SilentlyContinue } catch { }
try { Import-Module PSReadLine -ErrorAction SilentlyContinue } catch { }

# Only initialize starship if available
if (Get-Command starship -ErrorAction SilentlyContinue) {
    try { Invoke-Expression (&starship init powershell) } catch { }
}

# Only set PSStyle if it exists (PowerShell 7+)
if ($PSStyle -and $PSStyle.FileInfo -and $PSStyle.Background) {
    try {
        $PSStyle.FileInfo.Directory = $PSStyle.Background.FromRgb(0x1f1f28)
    } catch {
        # Silently ignore if PSStyle doesn't support this operation
    }
}

# Safe PSReadLine configuration
try {
    Set-PSReadLineOption -EditMode Windows -ErrorAction SilentlyContinue
    Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
} catch {
    # Silently ignore PSReadLine errors
}

# Only initialize zoxide if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    try { Invoke-Expression (& { (zoxide init powershell | Out-String) }) } catch { }
}
