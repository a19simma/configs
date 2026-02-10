# Launch Chrome with remote debugging for WSL nvim DAP
# Usage: .\Start-ChromeDebug.ps1 [url]
# Default URL: http://localhost:5173

param(
    [string]$Url = "http://localhost:5173"
)

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$userDataDir = "C:\temp\chrome-debug"

Write-Host "Starting Chrome with remote debugging..." -ForegroundColor Green
Write-Host "URL: $Url" -ForegroundColor Cyan
Write-Host "Debug port: 9222" -ForegroundColor Cyan
Write-Host ""
Write-Host "From WSL, you can now attach nvim DAP to this Chrome instance" -ForegroundColor Yellow
Write-Host ""

& $chromePath `
    --remote-debugging-port=9222 `
    --user-data-dir=$userDataDir `
    --no-first-run `
    --no-default-browser-check `
    $Url
