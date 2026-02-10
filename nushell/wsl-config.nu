# WSL-specific configuration for Nushell
# This file is only sourced when running in WSL

# Install WSL helper scripts to ~/.local/bin if they don't exist
let local_bin = ($env.HOME | path join ".local" "bin")
let scripts_dir = ($env.HOME | path join "repos" "configs" "wsl-scripts")

# Ensure ~/.local/bin exists
if not ($local_bin | path exists) {
    mkdir $local_bin
}

# Install chrome wrapper if it doesn't exist
let chrome_script = ($local_bin | path join "chrome")
if not ($chrome_script | path exists) {
    let source_script = ($scripts_dir | path join "chrome")
    if ($source_script | path exists) {
        cp $source_script $chrome_script
        chmod +x $chrome_script
    }
}

# Install google-chrome wrapper if it doesn't exist
let google_chrome_script = ($local_bin | path join "google-chrome")
if not ($google_chrome_script | path exists) {
    let source_script = ($scripts_dir | path join "google-chrome")
    if ($source_script | path exists) {
        cp $source_script $google_chrome_script
        chmod +x $google_chrome_script
    }
}

# Install chrome-debug wrapper if it doesn't exist
let chrome_debug_script = ($local_bin | path join "chrome-debug")
if not ($chrome_debug_script | path exists) {
    let source_script = ($scripts_dir | path join "chrome-debug")
    if ($source_script | path exists) {
        cp $source_script $chrome_debug_script
        chmod +x $chrome_debug_script
    }
}

# Additional WSL-specific configurations can go here
