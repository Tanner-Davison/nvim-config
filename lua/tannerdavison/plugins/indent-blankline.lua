return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = { char = "" }, -- No character for indentation (empty arrow)
		whitespace = {
			highlight = { "CursorColumn", "Whitespace" },
			remove_blankline_trail = false, -- Don't remove trailing blank lines
		},
		scope = { enabled = false }, -- Disable scope highlighting
	},
	config = function()
		local highlight = {
			"CursorColumn",
			"Whitespace",
		}

		require("ibl").setup({
			indent = { highlight = highlight, char = " " }, -- Empty character for indent
			whitespace = {
				highlight = highlight,
				remove_blankline_trail = false, -- Keep trailing blank lines
			},
			scope = { enabled = false }, -- Disable scope
		})
	end,
}
