hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,

		border_size = 2,

		col = {
			active_border = { colors = { "rgba(ff69b4ee)", "rgba(e39ff6ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		resize_on_border = false,

		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 1,

			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},
})

-- fazzi's animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 1.4, bezier = "linear" })
hl.animation({ leaf = "fadePopups", enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "quick", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 4, bezier = "quick" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidevert" })

-- disable the bootup animation
hl.animation({ leaf = "monitorAdded", enabled = false })
