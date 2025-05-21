return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
	config = function()
		local comment = require("Comment")
		local ts_context = require("ts_context_commentstring.integrations.comment_nvim")

		comment.setup({
			-- Core settings
			padding = true, -- Add space between comment and line
			sticky = true, -- Keep cursor at current position
			ignore = "^$", -- Ignore empty lines

			-- Key mappings
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

			-- Enable all mappings
			mappings = {
				basic = true,
				extra = true,
			},

			-- Hooks
			pre_hook = ts_context.create_pre_hook(), -- For JSX, TSX, etc.
			post_hook = function() end,
		})
	end,
}
