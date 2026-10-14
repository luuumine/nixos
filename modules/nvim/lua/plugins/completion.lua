return {
	"saghen/blink.cmp",
	version = "1.*",
	opts = {
		keymap = {
			preset = "default",
			["<Tab>"] = { "accept", "fallback" },
		},
		appearance = { nerd_font_variant = "mono" },
		signature = { enabled = true },
	},
}
