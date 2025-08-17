# Nushell Configuration - Minimal Setup

# Basic shell behavior
$env.config = {
    show_banner: false
    edit_mode: emacs
    buffer_editor: "nvim"
}

# Initialize Starship prompt
use ~/.cache/starship/init.nu

# Initialize Zoxide
source ~/.zoxide.nu