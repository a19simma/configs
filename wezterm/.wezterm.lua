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
config.font = wezterm.font_with_fallback({ 'JetBrains Mono', 'Hack', 'Symbols Nerd Font', 'Noto Sans CJK TC' })
config.color_scheme = 'Dracula+'
config.default_prog = { 'C:\\Program Files\\PowerShell\\7\\pwsh.exe' }
config.window_background_opacity = 0.85
config.adjust_window_size_when_changing_font_size = false

config.enable_tab_bar = true
config.tab_bar_at_bottom = true

config.keys = { {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane {
        confirm = true
    }
} }

config.wsl_domains = { {
    name = 'wsl',
    distribution = 'Debian'
} }

config.ssh_domains = {
    {
        name = 'wslix',
        remote_address = 'INEX-FPFMKN3.int.inexchange.com:2222',
        username = 'root',
        ssh_option = {
            identityfile = 'C:\\Users\\simon\\main-key',
        },
    },
    {
        name = 'ix',
        remote_address = 'INEX-FPFMKN3.int.inexchange.com:6922',
        username = 'simon.malm',
        ssh_option = {
            identityfile = 'C:\\Users\\simon\\main-key',
        },
    },
}

-- and finally, return the configuration to wezterm
return config
