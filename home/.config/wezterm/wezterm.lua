local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("Hack Nerd Font")
config.font_size = 14.0
config.color_scheme = "Builtin Dark"
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 5000
config.hide_tab_bar_if_only_one_tab = true

return config
