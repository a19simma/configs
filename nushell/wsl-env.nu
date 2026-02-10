# WSL-specific environment variables for Nushell
# This file is only sourced when running in WSL

# Use Windows Chrome as the default browser
$env.BROWSER = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

# Add Windows Chrome to PATH
$env.PATH = ($env.PATH | prepend "/mnt/c/Program Files/Google/Chrome/Application")

# Create aliases for Chrome commands (without .exe extension)
alias chrome = ^"/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
alias google-chrome = ^"/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

# Additional WSL-specific configurations can go here
