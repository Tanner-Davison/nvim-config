return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = {
			char = "│", -- Using a vertical line for indentation
			highlight = "IndentBlanklineChar",
		},
		whitespace = {
			highlight = { "Whitespace" },
			remove_blankline_trail = false,
		},
		scope = {
			enabled = true,
			char = "│",
			highlight = "IndentBlanklineContextChar",
		},
	},
	config = function()
		-- Set up custom highlights for indent lines
		vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#2D3A4A" }) -- Normal indent
		vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#3B4D63" }) -- Active indent

		require("ibl").setup({
			indent = {
				char = "",
				highlight = "IndentBlanklineChar",
			},
			whitespace = {
				highlight = { "Whitespace" },
				remove_blankline_trail = false,
			},
			scope = {
				enabled = true,
				char = "│",
				highlight = "IndentBlanklineContextChar",
			},
		})
	end,
}
