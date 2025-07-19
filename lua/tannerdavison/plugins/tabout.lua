return {
	"abecodes/tabout.nvim",
	lazy = false,
	config = function()
		require("tabout").setup({
			tabkey = "<Tab>",
			backwards_tabkey = "<S-Tab>",
			act_as_tab = true,
			completion = true,
			-- Ensure tabout works well with autopairs
			ignore_beginning = false,
			-- Don't trigger in certain contexts where we want completion
			exclude = { "TelescopePrompt", "spectre_panel" },
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"hrsh7th/nvim-cmp",
		"windwp/nvim-autopairs", -- Add autopairs as dependency
	},
}
