# syntax=docker/dockerfile:1
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    tar \
    build-essential \
    ca-certificates \
    libssl-dev \
    pkg-config \
    gnupg \
    procps \
    file \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user first
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Homebrew manually to developer user's home directory
RUN su - developer -c "git clone https://github.com/Homebrew/brew /home/developer/.linuxbrew"
ENV PATH="/home/developer/.linuxbrew/bin:/home/developer/.local/bin:$PATH"

# Add brew to PATH
ENV PATH="/home/developer/.linuxbrew/bin:/home/developer/.local/bin:$PATH"

# Install tools via brew
RUN su - developer -c "export PATH=/home/developer/.linuxbrew/bin:\$PATH && brew install starship zoxide nushell neovim tmux fzf node python docker"

# Install playwright via npm
RUN npm install -g playwright && npx playwright install --with-deps chromium

# Copy entrypoint script
COPY gvisor-dev/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER developer
WORKDIR /home/developer

# Copy config directories
COPY --chown=developer:developer nushell/ /home/developer/.config/nushell/
COPY --chown=developer:developer gvisor-dev/tmux.conf /home/developer/.config/tmux/tmux.conf
COPY --chown=developer:developer opencode/ /home/developer/.config/opencode/
COPY --chown=developer:developer .claude/ /home/developer/.claude/
COPY --chown=developer:developer neovim/ /home/developer/.config/nvim/
COPY --chown=developer:developer k9s/ /home/developer/.config/k9s/

# Create stub files
RUN mkdir -p /home/developer/.cache/starship && echo "# starship stub" > /home/developer/.cache/starship/init.nu
RUN echo "# zoxide stub" > /home/developer/.zoxide.nu
RUN echo "# mise placeholder" > /home/developer/.config/nushell/mise.nu

# Set default shell
SHELL ["/bin/bash", "-l"]
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/entrypoint.sh"]
