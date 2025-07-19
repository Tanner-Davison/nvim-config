return {
	"abecodes/tabout.nvim",
	lazy = false,
	config = function()
		require("tabout").setup({
			tabkey = "<Tab>",
			backwards_tabkey = "<S-Tab>",
			act_as_tab = true,
			completion = true,
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"hrsh7th/nvim-cmp",
	},
}
