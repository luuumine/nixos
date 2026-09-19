-- Make discord start in special workspace
hl.window_rule({
	name = "make discord start in special",
	match = {
		initial_class = "^(discord(-.*)?)$",
	},
	workspace = "special:discord silent",
})

-- Make signal start in special workspace
hl.window_rule({
	name = "make signal start in special",
	match = {
		initial_class = "^(signal)$",
	},
	workspace = "special:signal silent",
})

hl.window_rule({
	name = "browser in workspace 2",
	match = {
		initial_class = "^($browser.*)$",
	},
	workspace = "2 silent",
})

hl.layer_rule({
	name = "quickshell blur",
	match = {
		namespace = "quickshell",
	},
	blur = true,
})
