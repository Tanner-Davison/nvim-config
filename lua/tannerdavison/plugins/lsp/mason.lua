return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- Import mason
		local mason = require("mason")

		-- Enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- Configure mason-lspconfig - ONLY for installation, not configuration
		require("mason-lspconfig").setup({
			-- Don't automatically configure servers - we'll do it manually
			automatic_installation = false,
			-- Explicitly disable automatic setup for all servers
			ensure_installed = {},
			-- Don't run any automatic setup
			handlers = {},
			-- Disable all automatic configuration
			automatic_installation = false,
		})

		-- Configure mason-tool-installer for formatting and linting tools
		require("mason-tool-installer").setup({
			ensure_installed = {
				"prettier",
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint",
				"eslint_d",
				"cmakelang",
				"cpplint",
				-- clangd moved to mason-lspconfig to prevent duplicates
			},
		})
	end,
}
