return {
	"abecodes/tabout.nvim",
	lazy = false,
	config = function()
		require("tabout").setup({
			tabkey = "<Tab>",
			backwards_tabkey = "<S-Tab>",
			act_as_tab = true,
			completion = true,
			-- Better handling of complex contexts
			ignore_beginning = false,
			-- Don't trigger in certain contexts where we want completion
			exclude = { "TelescopePrompt", "spectre_panel" },
			-- Add more specific configuration for better JavaScript support
			tabouts = {
				{ open = "'", close = "'" },
				{ open = '"', close = '"' },
				{ open = "`", close = "`" },
				{ open = "(", close = ")" },
				{ open = "[", close = "]" },
				{ open = "{", close = "}" },
				{ open = "<", close = ">" },
			},
			-- Better integration with autopairs
			ignore_beginning = false,
			-- Force tabout in certain contexts
			force_ignore = {
				-- Don't tabout in comments
				comment = true,
				-- Don't tabout in strings (except when we want to)
				string = false,
			},
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"hrsh7th/nvim-cmp",
		"windwp/nvim-autopairs", -- Add autopairs as dependency
	},
}
