# Windows-specific environment variables for Nushell

# Set HOME to USERPROFILE for cross-platform compatibility
$env.HOME = $env.USERPROFILE

# Set Claude Code bash path to Git Bash (has cygpath utility)
$env.CLAUDE_CODE_GIT_BASH_PATH = $"($env.USERPROFILE)\\scoop\\apps\\git\\current\\bin\\bash.exe"

# Fix zoxide boolean conversion issue on Windows
if "__zoxide_hooked" in $env {
    if ($env.__zoxide_hooked | describe) == "string" {
        $env.__zoxide_hooked = ($env.__zoxide_hooked == "true")
    }
}

# Add any other Windows-specific environment variables here