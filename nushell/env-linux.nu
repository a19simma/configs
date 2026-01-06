# Linux-specific environment variables for Nushell

# Add ~/.local/bin to PATH (for uv, uvx, and other user-installed tools)
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local" "bin"))

# Add linuxbrew to PATH
$env.PATH = ($env.PATH | prepend "/home/linuxbrew/.linuxbrew/bin")

# Add PostgreSQL client tools (libpq)
$env.PATH = ($env.PATH | prepend "/home/linuxbrew/.linuxbrew/opt/libpq/bin")

# Setup Volta
$env.VOLTA_HOME = ($env.HOME | path join ".volta")
$env.PATH = ($env.PATH | prepend ($env.VOLTA_HOME | path join "bin"))

# Setup Azure tools
$env.PATH = ($env.PATH | prepend ($env.HOME + "/.azure-kubectl") | prepend ($env.HOME + "/.azure-kubelogin"))

# Add Go binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join "go" "bin"))

# Add Bun binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".bun" "bin"))

# Add Cargo binaries to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".cargo" "bin"))

# Generate and load mise configuration
let mise_path = $nu.default-config-dir | path join mise.nu
#^mise activate nu | save $mise_path --force

# WSL Clipboard integration
$env.DISPLAY = ":0"
