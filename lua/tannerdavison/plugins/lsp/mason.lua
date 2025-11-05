return {
	"williamboman/mason.nvim",
	dependencies = {
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

		-- Configure mason-tool-installer for formatters and linters ONLY
		-- Language servers are configured separately via vim.lsp.start()
		require("mason-tool-installer").setup({
			ensure_installed = {
				-- Formatters
				"prettier",
				"stylua",
				"isort",
				"black",
				"cmakelang",
				-- Linters
				"eslint_d",
				-- Note: LSP servers (typescript-language-server, css-lsp, html-lsp, etc.)
				-- are NOT needed here since we use vim.lsp.start() directly in lspconfig.lua
				-- Just install them manually via :Mason if needed
			},
		})
	end,
}
