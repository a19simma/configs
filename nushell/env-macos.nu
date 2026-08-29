# macOS-specific environment variables for Nushell

# Add ~/.local/bin to PATH (for uv, uvx, and other user-installed tools)
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local" "bin"))

# Add krew (kubectl plugin manager) to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".krew" "bin"))

# Add Homebrew (Apple Silicon prefix) to PATH
$env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")

# Add PostgreSQL client tools (libpq) — only present if `brew install libpq`
$env.PATH = ($env.PATH | prepend "/opt/homebrew/opt/libpq/bin")

# Add Go binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join "go" "bin"))

# Add Bun binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".bun" "bin"))

# Add Cargo binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".cargo" "bin"))

# Add .NET tools to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".dotnet" "tools"))

# Generate and load mise configuration (only regenerate if missing)
let mise_path = $nu.default-config-dir | path join mise.nu
if not ($mise_path | path exists) {
    ^mise activate nu | save $mise_path --force
}
$env.MISE_TRUSTED_CONFIG_PATHS = ($env.HOME | path join "repos")

# CA bundle. macOS ships a single PEM; there is no hashed SSL_CERT_DIR,
# so SSL_CERT_DIR is deliberately left unset.
$env.SSL_CERT_FILE = "/etc/ssl/cert.pem"

# No SSH_AUTH_SOCK override: launchd already provides the agent socket.
# No DISPLAY: not an X11 host.
