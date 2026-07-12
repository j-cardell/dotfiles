-- Sourced Window Rules (Translated from config/windowrules.conf)
-- =============================================================

-- --- Picture-in-Picture ---
hl.window_rule({
	match = { title = "(?i)^Picture[- ]in[- ]picture$" },
	float = true,
	size = { 640, 360 },
	move = { 1880, 1060 },
	pin = true,
	border_size = 0,
})

hl.window_rule({
	match = { initial_title = "(?i)^Picture[- ]in[- ]picture$" },
	float = true,
	size = { 640, 360 },
	move = { 1880, 1060 },
	pin = true,
	border_size = 0,
})

-- --- Steam Fixes ---
-- 1. Tile the main Steam window
hl.window_rule({
	match = { class = "^steam$", title = "^Steam$" },
	tile = true,
})

-- 2. Force Steam popups/menus to float and stay focused
hl.window_rule({
	match = { class = "^steam$", title = "^$" },
	float = true,
})
hl.window_rule({
	match = { class = "^steam$", modal = true },
	float = true,
	stay_focused = true,
})

-- --- Telegram Fixes ---
-- 1. Tile the main Telegram window
hl.window_rule({
	match = { class = "^Telegram$", title = "^Telegram$" },
	tile = true,
})
hl.window_rule({
	match = { class = "^org\\.telegram\\.desktop$", title = "^Telegram.*$" },
	tile = true,
})

-- 2. Force Telegram 'Save' dialogs to float, stay focused, center, and stay on current workspace
hl.window_rule({
	match = { class = "^(Telegram|org\\.telegram\\.desktop)$", title = "^(Save|Open|Choose|Select|File|Dialog).*$" },
	float = true,
	stay_focused = true,
	center = true,
	workspace = "current",
})
hl.window_rule({
	match = { initial_class = "^(Telegram|org\\.telegram\\.desktop)$", initial_title = "^(Save|Open|Choose|Select|File|Dialog).*$" },
	float = true,
	stay_focused = true,
	center = true,
	workspace = "current",
})

-- --- General Tiling & Layout Rules ---
hl.window_rule({
	match = { class = "^(org\\.gnome\\.)" },
	border_size = 0,
})
hl.window_rule({
	match = { class = "^([Tt]hunar)$" },
	float = true,
})

-- --- Border Rules ---
hl.window_rule({
	match = { class = "^(org\\.wezfurlong\\.wezterm|Alacritty|zen|com\\.mitchellh\\.ghostty|kitty|ghostty|steam)$" },
	border_size = 0,
})

-- --- Opacity & Dimming ---
-- This is placed BEFORE the video overrides to ensure the video rules take precedence
hl.window_rule({
	match = { focus = false },
	opacity = "1.0 0.95 override",
})

-- --- Video Overrides (Apply to all applications) ---
-- These are placed after the general dimming rules to ensure precedence in the new system
hl.window_rule({ match = { title = ".*YouTube.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { title = ".*youtube.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })

hl.window_rule({ match = { title = ".*Rumble.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { title = ".*rumble.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })

hl.window_rule({ match = { title = ".*Twitch.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { title = ".*twitch.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })

hl.window_rule({ match = { title = ".*Pepperbox.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { title = ".*pepperbox.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })

hl.window_rule({ match = { title = ".*Kick.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { title = ".*kick.*" }, opaque = true, no_dim = true, opacity = "1.0 override 1.0 override" })


-- --- Layer Rules ---
hl.layer_rule({
	match = { namespace = "^(quickshell)$" },
	no_anim = true,
})
