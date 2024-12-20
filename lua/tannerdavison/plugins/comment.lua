return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		-- import comment plugin safely
		local comment = require("Comment")
		local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")
		-- enable comment
		comment.setup({
			-- for commenting tsx, jsx, svelte, html files
			pre_hook = ts_context_commentstring.create_pre_hook(),

			padding = true, -- Add space between comment and line
			sticky = true, -- Whether cursor should stay at current position
			ignore = "^$", -- Ignore empty lines

			toggler = {
				line = "gcc", -- Line comment toggle
				block = "gbc", -- Block comment toggle
			},

			opleader = {
				line = "gc", -- Line comment
				block = "gb", -- Block comment
			},

			extra = {
				above = "gcO", -- Add comment on line above
				below = "gco", -- Add comment on line below
				eol = "gcA", -- Add comment at end of line
			},

			-- Changed from nil to function that returns empty string
			post_hook = function() end,

			mappings = {
				basic = true, -- Enable basic mappings
				extra = true, -- Enable extra mappings
			},
		})
	end,
}
