#!/usr/bin/env bash
# Entrypoint script for gvisor-dev container

set -e

# Fix ownership of mounted directory if running as non-root
if [ -n "$HOST_UID" ] && [ -n "$HOST_GID" ]; then
    if [ "$HOST_UID" != "$(id -u)" ] || [ "$HOST_GID" != "$(id -g)" ]; then
        echo "Fixing ownership for UID $HOST_UID GID $HOST_GID..."
        if [ -d "/home/developer" ]; then
            chown -R developer:developer /home/developer 2>/dev/null || true
        fi
    fi
fi

# Add mise and starship to PATH
export PATH="/root/.local/bin:/root/.local/share/mise/shims:$PATH"

# Source mise env if available
if [ -f "/root/.local/share/mise/env.sh" ]; then
    source /root/.local/share/mise/env.sh 2>/dev/null || true
fi

# Add user local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Check if we're in a tmux session or if we have a TTY
if [ -t 0 ]; then
    # We have a TTY - start tmux session
    if [ -z "$TMUX" ]; then
        # Create a named tmux session
        tmux new-session -d -s dev
        
        # Send command to first pane to start nushell
        tmux send-keys -t dev:0 'exec nu' C-m
        
        # Split vertically (creates pane 1)
        tmux split-window -v -t dev:0
        
        # Send command to second pane to start nushell
        tmux send-keys -t dev:0.1 'exec nu' C-m
        
        # Select the first pane
        tmux select-pane -t dev:0
        
        # Attach to the session
        tmux attach-session -t dev
        
        # If detached, start Claude Code in the first pane (if available)
        if command -v claude &> /dev/null; then
            tmux send-keys -t dev:0 'claude --dangerously-skip-permissions' C-m
        fi
    else
        exec nu
    fi
else
    # No TTY - keep container running
    tail -f /dev/null
fi
