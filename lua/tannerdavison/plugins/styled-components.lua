return {
	-- Enhanced styled-components support
	{
		"styled-components/vim-styled-components",
		branch = "main",
		lazy = true,
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		config = function()
			-- Enable styled-components syntax highlighting
			vim.g.styled_components_highlight = true
		end,
	},
	
	-- CSS-in-JS support for better completions
	{
		"mattn/emmet-vim",
		lazy = true,
		ft = { "html", "css", "scss", "less", "javascriptreact", "typescriptreact" },
		config = function()
			vim.g.user_emmet_settings = {
				javascript = {
					extends = 'jsx',
				},
				typescript = {
					extends = 'tsx',
				},
			}
		end,
	},
}
