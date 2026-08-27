local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

wezterm.on('window-config-reloaded', function(window, pane)
	window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
end)

-- foot: pipe-scrollback → Control+Shift+E
--   sh -c "f=$(mktemp) && cat - > $f && foot $EDITOR $f"
wezterm.on('open-scrollback-in-editor', function(window, pane)
	local dims = pane:get_dimensions()
	local scrollback = pane:get_lines_as_text(dims.scrollback_rows)
	local name = os.tmpname()
	local f = assert(io.open(name, 'w'))
	f:write(scrollback)
	f:close()
	local editor = os.getenv('EDITOR') or 'nvim'
	window:perform_action(
		act.SpawnCommandInNewWindow {
			args = { 'sh', '-c', editor .. ' "$@"', 'sh', name },
		},
		pane
	)
end)

return {
	tab_bar_position = 'Left',
	enable_wayland = true,
	window_padding = {
		left = '2cell',
		right = '1cell',
		top = '0.5cell',
		bottom = '0.5cell'
	},
	notification_handling = "AlwaysShow",
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	use_ime = true,
	default_prog = {'D:\\msys64\\usr\\bin\\zsh.exe', '-l'},
	-- font = wezterm.font 'Sarasa Mono SC',
	font = wezterm.font_with_fallback {'等距更纱黑体 SC', 'Noto Sans SC'},
	set_environment_variables = {
		CHERE_INVOKING = 'enabled_from_arguments',
		TERM = 'xterm-256color',
		HOME = 'D:\\inbox'
	},
	skip_close_confirmation_for_processes_named = {'bash', 'sh', 'zsh', 'fish', 'tmux', 'nu', 'zsh.exe', 'bash.exe',
	'cmd.exe', 'pwsh.exe'},
	-- Keybindings aligned with foot (foot.ini [key-bindings] / [search-bindings] / [url-bindings])
	-- plus a few wezterm-only pane helpers kept from before.
	keys = {
		-- foot defaults (explicit where they differ from wezterm defaults)
		{
			key = 'c',
			mods = 'CTRL|SHIFT',
			action = act.CopyTo 'Clipboard',
		},
		{
			key = 'v',
			mods = 'CTRL|SHIFT',
			action = act.PasteFrom 'Clipboard',
		},
		{
			key = 'Insert',
			mods = 'SHIFT',
			action = act.PasteFrom 'PrimarySelection',
		},
		-- foot: search-start=Control+Shift+r  (wezterm default is Ctrl+Shift+f)
		{
			key = 'r',
			mods = 'CTRL|SHIFT',
			action = act.Search { CaseInSensitiveString = '' },
		},
		-- foot: spawn-terminal=Control+Shift+n
		{
			key = 'n',
			mods = 'CTRL|SHIFT',
			action = act.SpawnWindow,
		},
		-- foot: show-urls-launch=Control+Shift+o
		{
			key = 'o',
			mods = 'CTRL|SHIFT',
			action = act.QuickSelectArgs {
				label = 'open url',
				patterns = {
					'https?://\\S+',
					'file://\\S+',
				},
				action = wezterm.action_callback(function(window, pane, url)
					wezterm.open_with(url)
				end),
			},
		},
		-- foot: pipe-scrollback … Control+Shift+E
		{
			key = 'E',
			mods = 'CTRL|SHIFT',
			action = act.EmitEvent 'open-scrollback-in-editor',
		},
		-- foot: font-increase / font-decrease / font-reset
		{
			key = '=',
			mods = 'CTRL',
			action = act.IncreaseFontSize,
		},
		{
			key = '+',
			mods = 'CTRL',
			action = act.IncreaseFontSize,
		},
		{
			key = '-',
			mods = 'CTRL',
			action = act.DecreaseFontSize,
		},
		{
			key = '0',
			mods = 'CTRL',
			action = act.ResetFontSize,
		},
		-- wezterm-only pane helpers (foot has no panes)
		{
			key = 'd',
			mods = 'CTRL|SHIFT',
			action = act.CloseCurrentPane {
				confirm = true
			}
		},
		{
			key = '3',
			mods = 'CTRL',
			action = act.SplitHorizontal {
				domain = 'CurrentPaneDomain'
			}
		},
		{
			key = '2',
			mods = 'CTRL',
			action = act.SplitVertical {
				domain = 'CurrentPaneDomain'
			}
		},
	},
	-- foot [search-bindings]
	key_tables = {
		search_mode = {
			{ key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
			-- cancel=Control+g Control+c Escape
			{ key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
			{ key = 'c', mods = 'CTRL', action = act.CopyMode 'Close' },
			{ key = 'g', mods = 'CTRL', action = act.CopyMode 'Close' },
			-- find-prev / find-next
			{ key = 'r', mods = 'CTRL|SHIFT', action = act.CopyMode 'PriorMatch' },
			{ key = 's', mods = 'CTRL|SHIFT', action = act.CopyMode 'NextMatch' },
			-- keep useful wezterm defaults
			{ key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
			{ key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
			{ key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
			{ key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
			{ key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
			{ key = 'PageDown', mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
			{ key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
			{ key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
		},
	},
	colors = {
		-- Paper / Indigo light theme. Keep this palette aligned with foot.
		foreground = '#263238',
		background = '#f7f4ed',

		-- Overrides the cell background color when the current cell is occupied by the
		-- cursor and the cursor style is set to Block
		cursor_bg = '#2457c5',
		-- Overrides the text color when the current cell is occupied by the cursor
		cursor_fg = '#f7f4ed',
		-- Specifies the border color of the cursor when the cursor style is set to Block,
		-- or the color of the vertical or horizontal bar when the cursor style is set to
		-- Bar or Underline.
		cursor_border = '#2457c5',

		-- the foreground color of selected text
		selection_fg = '#263238',
		-- the background color of selected text
		selection_bg = '#cfe1ff',

		-- The color of the scrollbar "thumb"; the portion that represents the current viewport
		scrollbar_thumb = '#8b95a5',

		-- The color of the split lines between panes
		split = '#aab4c3',

		ansi = {'#263238', '#b42318', '#18794e', '#9a6700', '#2457c5', '#8d3ab8', '#087f8c', '#5b6472'},
		brights = {'#4b5563', '#c83c3c', '#248a5b', '#b17a17', '#3b6ee8', '#a657c4', '#159ba8', '#ffffff'}
	}
}
