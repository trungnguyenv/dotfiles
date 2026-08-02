local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("Hack Nerd Font")
config.font_size = 14.0
config.color_scheme = "Builtin Dark"
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 5000
config.hide_tab_bar_if_only_one_tab = true
config.native_macos_fullscreen_mode = true

config.keys = {
	{
		key = "E",
		mods = "CMD|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

return config
