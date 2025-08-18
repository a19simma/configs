# Nushell Configuration - Minimal Setup

# Basic shell behavior
$env.config = {
    show_banner: false
    edit_mode: emacs
    buffer_editor: "nvim"
    cursor_shape: {
        emacs: line
        vi_insert: line 
        vi_normal: block
    }
    use_ansi_coloring: true
    bracketed_paste: true
    render_right_prompt_on_last_line: false
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: false  # Disable OSC 133 to fix WezTerm scrolling issue on Windows
        osc633: true
        reset_application_mode: true
    }
    table: {
        mode: rounded
        index_mode: always
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
        }
    }
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
    }
}

# Initialize Starship prompt if available
if ("~/.cache/starship/init.nu" | path exists) {
    use ~/.cache/starship/init.nu
}

# Initialize Zoxide
source ~/.zoxide.nu

# Load Windows-specific configuration
if $nu.os-info.name == "windows" {
    try {
        source config-windows.nu
    }
}