-- WezTerm configuration
local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- Window appearance
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Font configuration
config.font = wezterm.font_with_fallback({
  'JetBrainsMono Nerd Font',
  'Hack Nerd Font',
  'FiraCode Nerd Font',
})
config.font_size = 14.0
config.line_height = 1.2

-- Color scheme (TokyoNight)
config.colors = {
  foreground = '#c0caf5',
  background = '#1a1b26',
  cursor_bg = '#c0caf5',
  cursor_fg = '#1a1b26',
  cursor_border = '#c0caf5',
  selection_fg = '#c0caf5',
  selection_bg = '#33467c',
  scrollbar_thumb = '#292e42',
  split = '#7aa2f7',
  
  ansi = {
    '#15161e',  -- black
    '#f7768e',  -- red
    '#9ece6a',  -- green
    '#e0af68',  -- yellow
    '#7aa2f7',  -- blue
    '#bb9af7',  -- magenta
    '#7dcfff',  -- cyan
    '#a9b1d6',  -- white
  },
  
  brights = {
    '#414868',  -- bright black
    '#f7768e',  -- bright red
    '#9ece6a',  -- bright green
    '#e0af68',  -- bright yellow
    '#7aa2f7',  -- bright blue
    '#bb9af7',  -- bright magenta
    '#7dcfff',  -- bright cyan
    '#c0caf5',  -- bright white
  },
  
  tab_bar = {
    background = '#1a1b26',
    active_tab = {
      bg_color = '#7aa2f7',
      fg_color = '#1a1b26',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#292e42',
      fg_color = '#545c7e',
    },
    inactive_tab_hover = {
      bg_color = '#292e42',
      fg_color = '#7aa2f7',
      italic = false,
    },
    new_tab = {
      bg_color = '#1a1b26',
      fg_color = '#7aa2f7',
    },
    new_tab_hover = {
      bg_color = '#7aa2f7',
      fg_color = '#1a1b26',
    },
  },
}

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.tab_max_width = 25

-- Cursor
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 700
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- Performance
config.max_fps = 120
config.animation_fps = 60
config.front_end = 'WebGpu'

-- Scrollback
config.scrollback_lines = 10000

-- Bell
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}

-- Key bindings
config.keys = {
  -- Split panes
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'D', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane({ confirm = true }) },
  
  -- Navigate panes
  { key = 'h', mods = 'CMD|CTRL', action = wezterm.action.ActivatePaneDirection('Left') },
  { key = 'l', mods = 'CMD|CTRL', action = wezterm.action.ActivatePaneDirection('Right') },
  { key = 'k', mods = 'CMD|CTRL', action = wezterm.action.ActivatePaneDirection('Up') },
  { key = 'j', mods = 'CMD|CTRL', action = wezterm.action.ActivatePaneDirection('Down') },
  
  -- Resize panes
  { key = 'h', mods = 'CMD|ALT', action = wezterm.action.AdjustPaneSize({ 'Left', 5 }) },
  { key = 'l', mods = 'CMD|ALT', action = wezterm.action.AdjustPaneSize({ 'Right', 5 }) },
  { key = 'k', mods = 'CMD|ALT', action = wezterm.action.AdjustPaneSize({ 'Up', 5 }) },
  { key = 'j', mods = 'CMD|ALT', action = wezterm.action.AdjustPaneSize({ 'Down', 5 }) },
  
  -- Tabs
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
  { key = '[', mods = 'CMD', action = wezterm.action.ActivateTabRelative(-1) },
  { key = ']', mods = 'CMD', action = wezterm.action.ActivateTabRelative(1) },
  
  -- Font size
  { key = '=', mods = 'CMD', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = wezterm.action.ResetFontSize },
  
  -- Copy/Paste
  { key = 'c', mods = 'CMD', action = wezterm.action.CopyTo('Clipboard') },
  { key = 'v', mods = 'CMD', action = wezterm.action.PasteFrom('Clipboard') },
  
  -- Other
  { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback('ScrollbackAndViewport') },
  { key = 'f', mods = 'CMD', action = wezterm.action.Search({ CaseInSensitiveString = '' }) },
  { key = 'Enter', mods = 'CMD', action = wezterm.action.ToggleFullScreen },
  { key = 'l', mods = 'CMD|SHIFT', action = wezterm.action.ShowDebugOverlay },
}

-- Launch menu (for quick access to different shells)
config.launch_menu = {
  { label = 'Bash', args = { 'bash' } },
  { label = 'Zsh', args = { 'zsh' } },
  { label = 'Fish', args = { 'fish' } },
}

-- Default shell
config.default_prog = { '/bin/zsh' }

return config