# Nushell Environment Configuration
# This file is loaded before config.nu

# Basic environment variables
$env.EDITOR = "nvim"
$env.CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1"

# Load OS-specific environment variables
if $nu.os-info.name == "windows" {
    try {
        source env-windows.nu
    }
} else {
    try {
        source env-linux.nu
    }
}

# Starship prompt
$env.STARSHIP_SHELL = "nu"

# Create starship and zoxide init files if they don't exist
if not ("~/.cache/starship/init.nu" | path expand | path exists) {
    mkdir ~/.cache/starship
    starship init nu | save -f ~/.cache/starship/init.nu
}

# Initialize zoxide
zoxide init nushell | save -f ~/.zoxide.nu

# Configuration management commands (work from any directory)
def --env install-deps [] {
    cd ~/repos/configs; just install-deps
}

def --env deploy-configs [] {
    cd ~/repos/configs; just stow-deploy
}

def --env fix-symlinks [] {
    cd ~/repos/configs; just fix-symlinks
}

def --env setup-ssh [] {
    cd ~/repos/configs; just setup-ssh-server
}

def configs-help [] {
    cd ~/repos/configs; just help
}

# Git worktree navigation with fzf
def --env gwt [] {
    let worktrees = (git worktree list --porcelain
        | lines
        | where $it starts-with "worktree"
        | each { |line| $line | str replace "worktree " "" })

    let selected = ($worktrees | str join "\n" | fzf --prompt="Select worktree: ")

    if ($selected | is-not-empty) {
        cd $selected
    }
}

# Tmux session management
def ta [] {
    let sessions = (tmux list-sessions -F "#{session_name}" | lines)

    if ($sessions | is-empty) {
        print "No tmux sessions found"
        return
    }

    let selected = ($sessions | str join "\n" | fzf --prompt="Select tmux session: ")

    if ($selected | is-not-empty) {
        tmux attach-session -t $selected
    }
}

def td [session_name?: string] {
    let name = if ($session_name | is-empty) { "dev" } else { $session_name }
    let current_dir = $env.PWD

    # Create new session with first window (plain shell)
    tmux new-session -d -s $name -c $current_dir -n "shell"

    # Window 2: nvim
    tmux new-window -t $"($name):1" -n "nvim" -c $current_dir
    tmux send-keys -t $"($name):1" "nvim" Enter

    # Window 3: lazygit
    tmux new-window -t $"($name):2" -n "lazygit" -c $current_dir
    tmux send-keys -t $"($name):2" "lazygit" Enter

    # Window 4: claude code
    tmux new-window -t $"($name):3" -n "claude1" -c $current_dir
    tmux send-keys -t $"($name):3" "claude" Enter

    # Window 5: claude code
    tmux new-window -t $"($name):4" -n "claude2" -c $current_dir
    tmux send-keys -t $"($name):4" "claude" Enter

    # Select first window and attach
    tmux select-window -t $"($name):0"
    tmux attach-session -t $name
}

# Kubectl fzf functions for pod operations
def kpods [] {
    kubectl get pods -o wide | fzf --header-lines=1
}

def kexec [] {
    let pod = (kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select pod to exec into: ")
    if ($pod | is-not-empty) {
        kubectl exec -it $pod -- /bin/bash
    }
}

def klogs [] {
    let pod = (kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select pod for logs: ")
    if ($pod | is-not-empty) {
        # Use bat for syntax highlighting and less for pagination
        if (which bat | is-not-empty) {
            kubectl logs -f $pod | bat --paging=always --language=log --style=plain
        } else {
            kubectl logs -f $pod | less -R
        }
    }
}

# Alternative: view recent logs without follow (better for bat)
def klogsr [] {
    let pod = (kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select pod for recent logs: ")
    if ($pod | is-not-empty) {
        if (which bat | is-not-empty) {
            kubectl logs --tail=200 $pod | bat --language=log --style=numbers,changes
        } else {
            kubectl logs --tail=200 $pod | less -R
        }
    }
}

def kdesc [] {
    let resource_type = (["pod", "service", "deployment", "configmap", "secret", "ingress", "pvc", "node"] | str join "\n" | fzf --prompt="Select resource type: ")
    if ($resource_type | is-not-empty) {
        let resource = (kubectl get $resource_type --no-headers -o custom-columns=":metadata.name" | fzf --prompt=$"Select ($resource_type) to describe: ")
        if ($resource | is-not-empty) {
            kubectl describe $resource_type $resource
        }
    }
}

def kedit [] {
    let resource_type = (["pod", "service", "deployment", "configmap", "secret", "ingress", "pvc", "daemonset", "statefulset"] | str join "\n" | fzf --prompt="Select resource type: ")
    if ($resource_type | is-not-empty) {
        let resource = (kubectl get $resource_type --no-headers -o custom-columns=":metadata.name" | fzf --prompt=$"Select ($resource_type) to edit: ")
        if ($resource | is-not-empty) {
            kubectl edit $resource_type $resource
        }
    }
}

# Port forwarding with fzf selection
def kpf [local_port: int, remote_port: int] {
    let pod = (kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select pod for port forwarding: ")
    if ($pod | is-not-empty) {
        print $"Starting port forward: localhost:($local_port) -> ($pod):($remote_port)"
        kubectl port-forward $pod $"($local_port):($remote_port)" &
        print $"Port forward running in background. Use 'kpf-stop' to stop all forwards."
    }
}

# Stop all port forwards
def kpf-stop [] {
    print "Stopping all kubectl port-forward processes..."
    ps | where name =~ "kubectl" and command =~ "port-forward" | each { |proc| kill $proc.pid }
    print "✅ All port forwards stopped"
}

# List active port forwards
def kpf-list [] {
    print "Active kubectl port-forward processes:"
    ps | where name =~ "kubectl" and command =~ "port-forward" | select pid command
}

# Describe Custom Resource Definitions with fzf
def kcrd [] {
    let crd = (kubectl get crd --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select CRD to describe: ")
    if ($crd | is-not-empty) {
        if (which bat | is-not-empty) {
            kubectl describe crd $crd | bat --language=yaml --style=numbers,changes
        } else {
            kubectl describe crd $crd | less -R
        }
    }
}

# View cluster events with highlighting and pagination
def kevents [] {
    if (which bat | is-not-empty) {
        kubectl get events --sort-by='.metadata.creationTimestamp' -A | bat --language=log --style=numbers,changes
    } else {
        kubectl get events --sort-by='.metadata.creationTimestamp' -A | less -R
    }
}

# Watch cluster events in real-time
def kevents-watch [] {
    print "Watching cluster events (Ctrl+C to stop)..."
    kubectl get events --sort-by='.metadata.creationTimestamp' -A --watch
}

# Rollout management with fzf (deployments and statefulsets)
def krollout [] {
    let resource_type = (["deployment", "statefulset"] | str join "\n" | fzf --prompt="Select resource type: ")
    if ($resource_type | is-not-empty) {
        let resource = (kubectl get $resource_type --no-headers -o custom-columns=":metadata.name" | fzf --prompt=$"Select ($resource_type): ")
        if ($resource | is-not-empty) {
            let action = (["status", "history", "restart", "undo", "pause", "resume"] | str join "\n" | fzf --prompt="Select rollout action: ")
            if ($action | is-not-empty) {
                print $"Executing: kubectl rollout ($action) ($resource_type)/($resource)"
                kubectl rollout $action $"($resource_type)/($resource)"
            }
        }
    }
}

# Quick restart (deployments and statefulsets)
def krestart [] {
    let resource_type = (["deployment", "statefulset"] | str join "\n" | fzf --prompt="Select resource type: ")
    if ($resource_type | is-not-empty) {
        let resource = (kubectl get $resource_type --no-headers -o custom-columns=":metadata.name" | fzf --prompt=$"Select ($resource_type) to restart: ")
        if ($resource | is-not-empty) {
            print $"Restarting ($resource_type): ($resource)"
            kubectl rollout restart $"($resource_type)/($resource)"
        }
    }
}

# Scale resources interactively (deployments and statefulsets)
def kscale [] {
    let resource_type = (["deployment", "statefulset"] | str join "\n" | fzf --prompt="Select resource type: ")
    if ($resource_type | is-not-empty) {
        let resource = (kubectl get $resource_type --no-headers -o custom-columns=":metadata.name" | fzf --prompt=$"Select ($resource_type) to scale: ")
        if ($resource | is-not-empty) {
            print $"Current replicas for ($resource_type)/($resource):"
            kubectl get $resource_type $resource -o jsonpath='{.spec.replicas}'
            print ""
            if ($resource_type == "statefulset") {
                print "⚠️  StatefulSet scaling is sequential - pods will be created/deleted one by one"
            }
            let replicas = (input "Enter desired replica count: ")
            if ($replicas | is-not-empty) {
                print $"Scaling ($resource_type)/($resource) to ($replicas) replicas..."
                kubectl scale $resource_type $resource --replicas=$replicas
            }
        }
    }
}

# Show logs from failing pods only
def klogs-failing [] {
    let failing_pods = (kubectl get pods --no-headers -o custom-columns=":metadata.name,:status.phase" | lines | where $it !~ "Running|Succeeded" | each { |line| $line | split column " " | get 0 })
    if ($failing_pods | is-empty) {
        print "✅ No failing pods found"
        return
    }
    let pod = ($failing_pods | str join "\n" | fzf --prompt="Select failing pod for logs: ")
    if ($pod | is-not-empty) {
        print $"Showing logs for failing pod: ($pod)"
        if (which bat | is-not-empty) {
            kubectl logs --tail=200 $pod | bat --language=log --style=numbers,changes
        } else {
            kubectl logs --tail=200 $pod | less -R
        }
    }
}

# List failing pods with detailed status
def kpods-failing [] {
    print "Failing pods in cluster:"
    if (which bat | is-not-empty) {
        kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded -o wide | bat --language=log --style=plain
    } else {
        kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded -o wide
    }
}

# Watch rollout progress (deployments and statefulsets)
def kdeploy-watch [] {
    let resource_type = (["deployment", "statefulset"] | str join "\n" | fzf --prompt="Select resource type: ")
    if ($resource_type | is-not-empty) {
        let resource = (kubectl get $resource_type --no-headers -o custom-columns=":metadata.name" | fzf --prompt=$"Select ($resource_type) to watch: ")
        if ($resource | is-not-empty) {
            print $"Watching rollout progress for: ($resource_type)/($resource) (Ctrl+C to stop)"
            kubectl rollout status $"($resource_type)/($resource)" --watch=true
        }
    }
}

# ConfigMap management with fzf
def kcm [] {
    let cm = (kubectl get configmaps --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select ConfigMap: ")
    if ($cm | is-not-empty) {
        let action = (["view", "edit", "describe"] | str join "\n" | fzf --prompt="Select action: ")
        if ($action | is-not-empty) {
            match $action {
                "view" => {
                    if (which bat | is-not-empty) {
                        kubectl get configmap $cm -o yaml | bat --language=yaml --style=numbers,changes
                    } else {
                        kubectl get configmap $cm -o yaml | less -R
                    }
                }
                "edit" => { kubectl edit configmap $cm }
                "describe" => {
                    if (which bat | is-not-empty) {
                        kubectl describe configmap $cm | bat --language=yaml --style=plain
                    } else {
                        kubectl describe configmap $cm | less -R
                    }
                }
            }
        }
    }
}

# Secret management with fzf (safe viewing)
def ksec [] {
    let secret = (kubectl get secrets --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select Secret: ")
    if ($secret | is-not-empty) {
        let action = (["describe", "view-keys", "decode", "edit"] | str join "\n" | fzf --prompt="Select action: ")
        if ($action | is-not-empty) {
            match $action {
                "describe" => {
                    if (which bat | is-not-empty) {
                        kubectl describe secret $secret | bat --language=yaml --style=plain
                    } else {
                        kubectl describe secret $secret | less -R
                    }
                }
                "view-keys" => {
                    print $"Keys in secret ($secret):"
                    kubectl get secret $secret -o jsonpath='{.data}' | from json | columns
                }
                "decode" => {
                    let key = (kubectl get secret $secret -o jsonpath='{.data}' | from json | columns | str join "\n" | fzf --prompt="Select key to decode: ")
                    if ($key | is-not-empty) {
                        print $"Decoded value for ($key):"
                        kubectl get secret $secret -o jsonpath=$"{.data.($key)}" | decode base64
                    }
                }
                "edit" => { kubectl edit secret $secret }
            }
        }
    }
}

# Resource usage with fzf selection
def ktop [] {
    let resource_type = (["pods", "nodes"] | str join "\n" | fzf --prompt="Select resource type for usage: ")
    if ($resource_type | is-not-empty) {
        if (which bat | is-not-empty) {
            kubectl top $resource_type | bat --language=log --style=plain
        } else {
            kubectl top $resource_type
        }
    }
}

# Clean up evicted pods
def kclean-evicted [] {
    print "Finding evicted pods..."
    let evicted_pods = (kubectl get pods --field-selector=status.phase=Failed --all-namespaces --no-headers | lines | where $it =~ "Evicted")
    if ($evicted_pods | is-empty) {
        print "✅ No evicted pods found"
        return
    }
    print $"Found ($evicted_pods | length) evicted pods:"
    $evicted_pods | each { |pod| print $"  ($pod)" }
    let confirm = (input "Delete all evicted pods? (y/N): ")
    if ($confirm | str downcase) == "y" {
        kubectl get pods --field-selector=status.phase=Failed --all-namespaces --no-headers -o custom-columns=":metadata.namespace,:metadata.name" | lines | where $it =~ "Evicted" | each { |line|
            let parts = ($line | split column " ")
            let namespace = ($parts | get 0)
            let pod = ($parts | get 1)
            kubectl delete pod $pod -n $namespace
        }
        print "✅ Evicted pods cleaned up"
    }
}

# Clean up completed jobs and pods
def kclean-completed [] {
    print "Finding completed jobs and pods..."
    let completed_jobs = (kubectl get jobs --field-selector=status.successful=1 --all-namespaces --no-headers)
    let completed_pods = (kubectl get pods --field-selector=status.phase=Succeeded --all-namespaces --no-headers)
    
    if ($completed_jobs | is-empty) and ($completed_pods | is-empty) {
        print "✅ No completed resources found"
        return
    }
    
    if ($completed_jobs | is-not-empty) {
        print $"Found ($completed_jobs | lines | length) completed jobs"
    }
    if ($completed_pods | is-not-empty) {
        print $"Found ($completed_pods | lines | length) completed pods"
    }
    
    let confirm = (input "Delete all completed jobs and pods? (y/N): ")
    if ($confirm | str downcase) == "y" {
        if ($completed_jobs | is-not-empty) {
            kubectl delete jobs --field-selector=status.successful=1 --all-namespaces
        }
        if ($completed_pods | is-not-empty) {
            kubectl delete pods --field-selector=status.phase=Succeeded --all-namespaces
        }
        print "✅ Completed resources cleaned up"
    }
}

# Job management with fzf
def kjobs [] {
    let job = (kubectl get jobs --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select Job: ")
    if ($job | is-not-empty) {
        let action = (["logs", "describe", "delete", "pods"] | str join "\n" | fzf --prompt="Select action: ")
        if ($action | is-not-empty) {
            match $action {
                "logs" => {
                    let pod = (kubectl get pods --selector=job-name=$job --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select pod for logs: ")
                    if ($pod | is-not-empty) {
                        if (which bat | is-not-empty) {
                            kubectl logs $pod | bat --language=log --style=numbers,changes
                        } else {
                            kubectl logs $pod | less -R
                        }
                    }
                }
                "describe" => {
                    if (which bat | is-not-empty) {
                        kubectl describe job $job | bat --language=yaml --style=plain
                    } else {
                        kubectl describe job $job | less -R
                    }
                }
                "delete" => {
                    let confirm = (input $"Delete job ($job)? (y/N): ")
                    if ($confirm | str downcase) == "y" {
                        kubectl delete job $job
                        print $"✅ Job ($job) deleted"
                    }
                }
                "pods" => { kubectl get pods --selector=job-name=$job }
            }
        }
    }
}

# Manually trigger CronJob
def kcron-trigger [] {
    let cronjob = (kubectl get cronjobs --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select CronJob to trigger: ")
    if ($cronjob | is-not-empty) {
        let job_name = $"($cronjob)-manual-(date now | format date '%Y%m%d%H%M%S')"
        print $"Triggering CronJob ($cronjob) as job ($job_name)..."
        kubectl create job $job_name --from=cronjob/$cronjob
        print $"✅ Job ($job_name) created from CronJob ($cronjob)"
    }
}

# Node operations with fzf selection
def knodes [] {
    let node = (kubectl get nodes --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select node: ")
    if ($node | is-not-empty) {
        let action = (["describe", "drain", "uncordon", "top"] | str join "\n" | fzf --prompt="Select node action: ")
        if ($action | is-not-empty) {
            match $action {
                "describe" => {
                    if (which bat | is-not-empty) {
                        kubectl describe node $node | bat --language=yaml --style=plain
                    } else {
                        kubectl describe node $node | less -R
                    }
                }
                "drain" => {
                    let confirm = (input $"Drain node ($node)? This will evict pods (y/N): ")
                    if ($confirm | str downcase) == "y" {
                        print $"Draining node: ($node)"
                        kubectl drain $node --ignore-daemonsets --delete-emptydir-data
                    }
                }
                "uncordon" => {
                    print $"Uncordoning node: ($node)"
                    kubectl uncordon $node
                }
                "top" => { kubectl top node $node }
            }
        }
    }
}

# Service inspection and port checking
def ksvc [] {
    let service = (kubectl get services --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select service: ")
    if ($service | is-not-empty) {
        let action = (["describe", "endpoints", "port-check", "edit"] | str join "\n" | fzf --prompt="Select service action: ")
        if ($action | is-not-empty) {
            match $action {
                "describe" => {
                    if (which bat | is-not-empty) {
                        kubectl describe service $service | bat --language=yaml --style=plain
                    } else {
                        kubectl describe service $service | less -R
                    }
                }
                "endpoints" => { kubectl get endpoints $service -o wide }
                "port-check" => {
                    print $"Checking service ports for: ($service)"
                    kubectl get service $service -o jsonpath='{.spec.ports[*]}' | from json | table
                }
                "edit" => { kubectl edit service $service }
            }
        }
    }
}

# Create temporary debug pod or attach debug container to existing pod
def kdebug [] {
    let debug_type = (["standalone-pod", "attach-to-pod"] | str join "\n" | fzf --prompt="Select debug type: ")
    if ($debug_type | is-not-empty) {
        let image = (["busybox", "alpine", "ubuntu", "nicolaka/netshoot", "curlimages/curl"] | str join "\n" | fzf --prompt="Select debug image: ")
        if ($image | is-not-empty) {
            if $debug_type == "standalone-pod" {
                let pod_name = $"debug-pod-(date now | format date '%Y%m%d%H%M%S')"
                print $"Creating standalone debug pod: ($pod_name) with image: ($image)"
                
                if $image == "nicolaka/netshoot" {
                    kubectl run $pod_name $"--image=($image)" --rm -it --restart=Never -- bash
                } else if $image == "curlimages/curl" {
                    kubectl run $pod_name $"--image=($image)" --rm -it --restart=Never -- sh
                } else {
                    kubectl run $pod_name $"--image=($image)" --rm -it --restart=Never -- sh
                }
            } else {
                let target_pod = (kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select pod to debug: ")
                if ($target_pod | is-not-empty) {
                    print $"Attaching debug container with image: ($image) to pod: ($target_pod)"
                    
                    if $image == "nicolaka/netshoot" {
                        kubectl debug $target_pod -it $"--image=($image)" -- bash
                    } else if $image == "curlimages/curl" {
                        kubectl debug $target_pod -it $"--image=($image)" -- sh
                    } else {
                        kubectl debug $target_pod -it $"--image=($image)" -- sh
                    }
                }
            }
        }
    }
}

# Get all resources in namespace with filtering
def kget-all [] {
    let namespace = (kubectl get namespaces --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select namespace (or press ESC for current): ")
    let ns_flag = if ($namespace | is-not-empty) { $"-n ($namespace)" } else { "" }
    
    print $"Getting all resources in namespace: (if ($namespace | is-not-empty) { $namespace } else { '(current)' })"
    
    let resource_types = [
        "pods", "services", "deployments", "statefulsets", "daemonsets",
        "configmaps", "secrets", "ingresses", "persistentvolumes", 
        "persistentvolumeclaims", "jobs", "cronjobs"
    ]
    
    $resource_types | each { |resource|
        print $"\n=== ($resource | str upcase) ==="
        if ($namespace | is-not-empty) {
            kubectl get $resource -n $namespace --no-headers 2>/dev/null | lines | length | $in > 0
        } else {
            kubectl get $resource --no-headers 2>/dev/null | lines | length | $in > 0
        }
        
        if $in {
            if ($namespace | is-not-empty) {
                kubectl get $resource -n $namespace -o wide 2>/dev/null
            } else {
                kubectl get $resource -o wide 2>/dev/null
            }
        } else {
            print "  No resources found"
        }
    }
}

# Bootstrap function for fresh systems
def bootstrap-configs [] {
    print "🚀 Bootstrapping configuration management..."
    
    # Install just if not present
    if (which just | is-empty) {
        print "Installing just..."
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
        $env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.HOME)/.local/bin")
    }
    
    # Navigate to configs and run bootstrap
    if (~/repos/configs | path exists) {
        cd ~/repos/configs
        just bootstrap-unix
    } else {
        print "❌ ~/repos/configs not found. Please clone the repository first:"
        print "git clone <your-repo-url> ~/repos/configs"
    }
}

# Helper to set secrets from bitwarden with fzf selection
def --env set-secret [] {
    # Hardcoded list of available secrets
    let secrets = [
        {name: "ANTHROPIC_API_KEY", bw_item: "anthropic_api_key", desc: "Anthropic API Key (SDK, pay-as-you-go)"}
        {name: "CONTEXT7_API_KEY", bw_item: "context7_api_key", desc: "Context7 API Key"}
        {name: "CLAUDE_CODE_OAUTH_TOKEN", bw_item: "claude_oauth_token_1", desc: "Claude Code OAuth - Account 1"}
        {name: "CLAUDE_CODE_OAUTH_TOKEN", bw_item: "claude_oauth_token_2", desc: "Claude Code OAuth - Account 2"}
    ]

    let selected = ($secrets | each { |s| $"($s.desc)" } | str join "\n" | fzf --prompt="Select secret to set: ")

    if ($selected | is-empty) {
        print "❌ No secret selected"
        return
    }

    let secret_config = ($secrets | where desc == $selected | first)

    # Check bitwarden status
    let status = (^bw status | from json)

    if $status.status == "unauthenticated" {
        print "🔐 Bitwarden: Not logged in. Please log in:"
        ^bw login
    }

    if $status.status == "locked" {
        print "🔓 Bitwarden: Vault is locked. Please unlock:"
        let session = (^bw unlock --raw)
        $env.BW_SESSION = $session
    }

    # Retrieve the secret
    let result = (^bw get item $secret_config.bw_item | complete)

    if $result.exit_code != 0 {
        print $"❌ Error: Bitwarden item '($secret_config.bw_item)' not found"
        print $"   Please create this item in Bitwarden with your token"
        return
    }

    let item = ($result.stdout | from json)

    if ($item.login?.password? | is-empty) {
        print $"❌ Error: Item '($secret_config.bw_item)' has no password field"
        print $"   Please store the token in the password field of this Bitwarden item"
        return
    }

    let value = $item.login.password

    # Set the environment variable
    match $secret_config.name {
        "ANTHROPIC_API_KEY" => {
            $env.ANTHROPIC_API_KEY = $value
            print $"✅ ANTHROPIC_API_KEY has been set from '($secret_config.bw_item)'"
        }
        "CONTEXT7_API_KEY" => {
            $env.CONTEXT7_API_KEY = $value
            print $"✅ CONTEXT7_API_KEY has been set from '($secret_config.bw_item)'"
        }
        "CLAUDE_CODE_OAUTH_TOKEN" => {
            $env.CLAUDE_CODE_OAUTH_TOKEN = $value
            print $"✅ CLAUDE_CODE_OAUTH_TOKEN has been set from '($secret_config.bw_item)'"
            print "   This token works with Claude Code CLI only (not SDK)"
        }
    }
}
