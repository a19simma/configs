# Sync files from kickstart.nvim
sync-kickstart:
    @TMP_DIR=$(mktemp -d) && git clone https://github.com/nvim-lua/kickstart.nvim.git "$TMP_DIR" && cp -r "$TMP_DIR"/* nvim/ && rm -rf "$TMP_DIR"

# Backup local config files
backup-configs:
    @echo "Backing up local configs..."
    cp ~/.zshrc ~/.zshrc.bak
    cp -R ~/.config ~/.config.bak
    @echo "✅ Configs backed up to ~/.zshrc.bak and ~/.config.bak"

# Link repo files to local config (sync from repo to system)
sync-to-local:
    @echo "Linking repo configs to local system..."
    rm -rf ~/.config/nvim
    ln -s "$(pwd)/nvim" ~/.config/nvim
    ln -sf "$(pwd)/zsh/.zshrc" ~/.zshrc
    @echo "✅ Repo configs linked to local system"

# Setup Bitwarden CLI
setup-bitwarden:
    @echo "Setting up Bitwarden CLI..."
    @echo "1. Login to Bitwarden:"
    bw login
    @echo "2. Unlock vault and set session:"
    @echo "Run: export BW_SESSION=\$$(bw unlock --raw)"

# Create Anthropic API key in Bitwarden
create-anthropic-api-key:
    @./scripts/create-anthropic-key.sh

# Create Gemini API key in Bitwarden
create-gemini-api-key:
    @./scripts/create-gemini-key.sh

# Create Tavily API key in Bitwarden
create-tavily-api-key:
    @./scripts/create-tavily-key.sh

# Create Morph API key in Bitwarden
create-morph-api-key:
    @./scripts/create-morph-key.sh

# Copy local files to repo (sync from system to repo)
sync-from-local:
    @echo "Syncing configs from local system to repo..."
    cp ~/.zshrc ./zsh/.zshrc
    cp -R ~/.config/nvim ./
    @echo "✅ Local configs synced to repo"

# Install all dependencies
install-deps:
    @echo "Installing dependencies with brew..."
    brew install gitleaks jq bitwarden-cli just
    @echo "✅ All dependencies installed"

# Security checks using GitLeaks
check-secrets:
    @if command -v gitleaks >/dev/null 2>&1; then \
        echo "Running GitLeaks scan..."; \
        gitleaks detect --config .gitleaks.toml --verbose; \
    else \
        echo "❌ GitLeaks not installed. Run: just install-deps"; \
        exit 1; \
    fi
