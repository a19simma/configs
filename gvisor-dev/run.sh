#!/usr/bin/env nu
# Script to build and run a gvisor-isolated development container

let SCRIPT_DIR = ($env.CURRENT_FILE | path dirname)
let IMAGE_NAME = "gvisor-dev:latest"

# Simple logging functions
def log_info [msg: string] {
    print $"[INFO] ($msg)"
}

def log_warn [msg: string] {
    print $"[WARN] ($msg)"
}

def log_error [msg: string] {
    print $"[ERROR] ($msg)"
}

# Check if gvisor is installed
def check_gvisor [] {
    if (which runsc | is-empty) {
        log_warn "gvisor (runsc) not found. Installing..."
        install_gvisor
    } else {
        let version = (runsc --version 2>/dev/null | get 0 | str trim)
        log_info $"gvisor already installed: ($version)"
    }
}

# Install gvisor
def install_gvisor [] {
    let arch = match ($nu.os-info.arch) {
        "x86_64" => "x86_64"
        "aarch64" => "aarch64"
        _ => {
            log_error $"Unsupported architecture: ($nu.os-info.arch)"
            exit 1
        }
    }

    # Download from gvisor releases page
    let tmp_dir = (mktemp -d)
    
    log_info "Downloading gvisor runsc..."
    
    cd $tmp_dir
    
    # Try different version if latest doesn't work
    let version = "20240506.0"
    let url = $"https://storage.googleapis.com/gvisor/releases/($version)/($arch)/runsc"
    let url_shim = $"https://storage.googleapis.com/gvisor/releases/($version)/($arch)/containerd-shim-runsc-v2"

    curl -fsSL $url -o runsc
    curl -fsSL $url_shim -o containerd-shim-runsc-v2
    
    chmod +x runsc containerd-shim-runsc-v2

    # Install to system locations (requires sudo)
    sudo install -m 755 runsc /usr/local/bin/runsc
    sudo install -m 755 containerd-shim-runsc-v2 /usr/local/bin/containerd-shim-runsc-v2

    cd /
    rm -rf $tmp_dir

    log_info "gvisor installed successfully"
}

# Register gvisor with docker
def register_gvisor_docker [] {
    let docker_info = (docker info 2>/dev/null)
    if not ($docker_info | is-empty) and ($docker_info | str contains "runsc") {
        log_info "gvisor already registered with docker"
        return
    }

    log_info "Registering gvisor with docker..."

    sudo mkdir -p /etc/docker

    if not (/etc/docker/daemon.json | path exists) {
        let config = {
            runtimes: {
                runsc: {
                    path: "/usr/local/bin/runsc",
                    runtimeArgs: [
                        "--host-uds=all"
                        "--platform=linux"
                        "--enable-sleep-pid"
                    ]
                }
            }
        }
        sudo tee /etc/docker/daemon.json < (($config | to json -r) | into string) > null
    }

    log_info "Restarting docker daemon..."
    try {
        sudo systemctl restart docker
    } catch {
        try {
            sudo service docker restart
        } catch {
            log_warn "Could not restart docker. You may need to restart docker manually."
        }
    }

    sleep 2sec

    log_info "gvisor registered with docker"
}

# Build the docker image
def build_image [] {
    log_info $"Building docker image: ($IMAGE_NAME)"

    # Get absolute paths
    let parent_dir = ($SCRIPT_DIR | path join "..")
    let dockerfile_path = ($SCRIPT_DIR | path join "Dockerfile")
    
    # Copy mise.toml if exists
    let mise_path = ($parent_dir | path join "mise.toml")
    if ($mise_path | path exists) {
        cp $mise_path ($SCRIPT_DIR | path join "mise.toml")
    }

    # Build from parent directory to access configs
    docker build -t $IMAGE_NAME -f $dockerfile_path $parent_dir

    log_info "Image built successfully"
}

# Run the container
def run_container [workdir: string, container_name: string] {
    # Check if container with same name is already running
    let containers = (docker ps -a --format "{{.Names}}" | split row "\n")
    if ($containers | any {|c| $c == $container_name}) {
        let running = (docker ps --format "{{.Names}}" | split row "\n")
        if ($running | any {|c| $c == $container_name}) {
            log_info $"Container '($container_name)' is already running."
            log_info $"To attach, run: docker exec -it ($container_name) nu"
            return
        } else {
            log_info $"Removing stopped container '($container_name)'..."
            docker rm $container_name 2>/dev/null
        }
    }

    log_info "Starting gvisor-isolated container..."
    log_info $"Working directory: ($workdir)"

    let uid = (id -u)
    let gid = (id -g)

    # Run container
    let runtime = if (which runsc | is-empty) { "runc" } else { "runsc" }
    
    # Run in detached mode and show attach command
    let container_id = (^docker run -d --name $container_name --runtime $runtime --hostname gvisor-dev -w $workdir -v $"($workdir):($workdir)" -v /tmp:/tmp -v /dev:/dev -e $"HOST_UID=($uid)" -e $"HOST_GID=($gid)" -e TERM=xterm-256color $IMAGE_NAME /entrypoint.sh | str trim)
    
    log_info $"Container started: ($container_id)"
    log_info $"Attach with: docker exec -it ($container_name) nu"
}

# Run the script - skip gvisor for testing
let build_only = false
let use_gvisor = false

# Get current directory for workdir (must be after script starts)
let workdir = (pwd)
let dir_name = ($workdir | path basename)
let CONTAINER_NAME = $"dev-($dir_name)"

if $use_gvisor {
    check_gvisor
    register_gvisor_docker
}

build_image

if $build_only {
    log_info "Build complete. Run without --build-only to start the container."
    exit 0
}

run_container $workdir $CONTAINER_NAME
