# Windows-specific environment variables for Nushell

# Set Claude Code git-bash path
$env.CLAUDE_CODE_GIT_BASH_PATH = $"($env.USERPROFILE)\\scoop\\shims\\git-bash.exe"

# Fix zoxide boolean conversion issue on Windows
if "__zoxide_hooked" in $env {
    if ($env.__zoxide_hooked | describe) == "string" {
        $env.__zoxide_hooked = ($env.__zoxide_hooked == "true")
    }
}

# Add any other Windows-specific environment variables here