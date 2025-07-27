return {
	-- Other plugins here
	{
		"styled-components/vim-styled-components",
		branch = "main",
		lazy = true, -- Only load when needed
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" }, -- Only load for JS/TS files
	},
}
