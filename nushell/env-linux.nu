# Linux-specific environment variables for Nushell

# Add ~/.local/bin to PATH (for uv, uvx, and other user-installed tools)
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local" "bin"))

# Add linuxbrew to PATH
$env.PATH = ($env.PATH | prepend "/home/linuxbrew/.linuxbrew/bin")

# Add PostgreSQL client tools (libpq)
$env.PATH = ($env.PATH | prepend "/home/linuxbrew/.linuxbrew/opt/libpq/bin")

# Setup Azure tools
$env.PATH = ($env.PATH | prepend ($env.HOME + "/.azure-kubectl") | prepend ($env.HOME + "/.azure-kubelogin"))

# Add Go binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join "go" "bin"))

# Add Bun binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".bun" "bin"))

# Add Cargo binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".cargo" "bin"))

# Add .NET tools to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".dotnet" "tools"))

# Generate and load mise configuration
let mise_path = $nu.default-config-dir | path join mise.nu
^mise activate nu | save $mise_path --force
$env.MISE_TRUSTED_CONFIG_PATHS = ($env.HOME | path join "repos")

# WSL Clipboard integration
$env.DISPLAY = ":0"

# .NET HTTPS Development Certificate
$env.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
$env.SSL_CERT_DIR = "/etc/ssl/certs"

# SSH Agent setup via systemd socket activation
$env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"

# Load WSL-specific configuration if running in WSL
if ("/proc/version" | path exists) {
    let proc_version = (open /proc/version)
    if ($proc_version | str contains "WSL") or ($proc_version | str contains "microsoft") {
        try {
            source wsl-env.nu
        }
    }
}
