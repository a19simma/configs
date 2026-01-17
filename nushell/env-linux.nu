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

# Add .NET tools to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".dotnet" "tools"))

# Generate and load mise configuration
let mise_path = $nu.default-config-dir | path join mise.nu
#^mise activate nu | save $mise_path --force

# WSL Clipboard integration
$env.DISPLAY = ":0"

# SSH Agent setup (from https://www.nushell.sh/cookbook/ssh_agent.html)
# This prevents starting multiple ssh-agent processes
do --env {
    let ssh_agent_file = (
        $nu.temp-path | path join $"ssh-agent-(whoami).nuon"
    )

    if ($ssh_agent_file | path exists) {
        let ssh_agent_env = open ($ssh_agent_file)
        if ($"/proc/($ssh_agent_env.SSH_AGENT_PID)" | path exists) {
            load-env $ssh_agent_env
            return
        } else {
            rm $ssh_agent_file
        }
    }

    let ssh_agent_env = ^ssh-agent -c
        | lines
        | first 2
        | parse "setenv {name} {value};"
        | transpose --header-row
        | into record
    load-env $ssh_agent_env
    $ssh_agent_env | save --force $ssh_agent_file
}
