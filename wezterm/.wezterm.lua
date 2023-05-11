-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- config.window_decorations = "NONE"
-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.font = wezterm.font_with_fallback({ 'JetBrains Mono', 'Hack', 'Symbols Nerd Font', 'Noto Sans CJK TC' })
config.color_scheme = 'Rosé Pine (base16)'
config.default_prog = { 'C:\\Program Files\\PowerShell\\7\\pwsh.exe' }
config.window_background_opacity = 0.85

-- and finally, return the configuration to wezterm
return config
