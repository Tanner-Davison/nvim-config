-- tiny-inline-diagnostic.nvim: nicer inline diagnostics (replaces the built-in
-- virtual_text, which is switched off in core/init.lua via vim.diagnostic.config).
-- Change `preset` to try other looks: modern, classic, minimal, powerline, ghost, simple.
return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	priority = 1000, -- load before other UI plugins so it can wrap diagnostic handlers
	opts = {
		preset = "modern",
		options = {
			show_source = { enabled = true, if_many = true },
			multilines = { enabled = true },
		},
	},
}
