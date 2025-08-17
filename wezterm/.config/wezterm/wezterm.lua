-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.window_decorations = "RESIZE"
-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.font = wezterm.font_with_fallback({ 'Monaspace Krypton', 'JetBrains Mono', 'Hack', 'Symbols Nerd Font',
    'Noto Sans CJK TC' })
config.colors = {
                foreground = "#dcd7ba",
                background = "#1f1f28",

                cursor_bg = "#c8c093",
                cursor_fg = "#c8c093",
                cursor_border = "#c8c093",

                selection_fg = "#c8c093",
                selection_bg = "#2d4f67",

                scrollbar_thumb = "#16161d",
                split = "#16161d",

                ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
                brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
                indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
}

-- Function to detect the best available shell
local function get_default_shell()
    -- On Windows, try to find nushell first, then fall back to PowerShell
    local shells_to_try = {
        'nu.exe',
        'nu',
        'C:\\Program Files\\PowerShell\\7\\pwsh.exe',
        'pwsh.exe',
        'powershell.exe'
    }
    
    for _, shell in ipairs(shells_to_try) do
        -- Try to execute the shell to see if it exists
        local success, exit_code = wezterm.run_child_process({shell, '--version'})
        if success and exit_code == 0 then
            wezterm.log_info('Selected shell: ' .. shell)
            return { shell }
        end
    end
    
    -- Fallback to PowerShell 7 if nothing else works
    return { 'C:\\Program Files\\PowerShell\\7\\pwsh.exe' }
end

-- Set the default shell dynamically
config.default_prog = get_default_shell()
config.window_background_opacity = 1
config.adjust_window_size_when_changing_font_size = false

config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true

config.keys = {
    {
        key = 'w',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CloseCurrentPane {
            confirm = true
        },
    },
    {
        key = 'l',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
        key = 'h',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
        key = 'k',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
        key = 'j',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivatePaneDirection 'Down',
    }
}

config.wsl_domains = { {
    name = 'wsl',
    distribution = 'Debian'
} }

-- and finally, return the configuration to wezterm
return config