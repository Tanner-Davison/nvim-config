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

		-- Configure mason-lspconfig
		-- Note: With the new LSP configuration system, mason-lspconfig's role
		-- is primarily to install servers, not to configure them
		require("mason-lspconfig").setup({
			-- List of servers for mason to install
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"pyright",
				"clangd",
			},
			-- Configure TypeScript server settings
			handlers = {
				-- Configure ts_ls with proper settings
				ts_ls = function()
					local lspconfig = require("lspconfig")
					local cmp_nvim_lsp = require("cmp_nvim_lsp")
					
					local capabilities = cmp_nvim_lsp.default_capabilities()
					capabilities.textDocument.positionEncoding = "utf-16"
					
					lspconfig.ts_ls.setup({
						capabilities = capabilities,
						settings = {
							typescript = {
								plugins = {
									{
										name = "typescript-styled-plugin",
										location = "node_modules/typescript-styled-plugin",
									},
								},
								suggest = {
									enabled = true,
									includeCompletionsForModuleExports = true,
									includeCompletionsWithObjectLiteralMethodSnippets = true,
									autoImports = true,
									includeAutomaticOptionalChainCompletions = false,
									includeCompletionsWithInsertText = true,
									includeCompletionsWithSnippetText = true,
									includeCompletionsWithClassMemberSnippets = true,
									includeCompletionsWithImportStatements = true,
								},
								preferences = {
									importModuleSpecifierPreference = "non-relative",
									quoteStyle = "single",
								},
							},
							javascript = {
								plugins = {
									name = "typescript-styled-plugin",
									location = "node_modules/typescript-styled-plugin",
								},
								suggest = {
									enabled = true,
									includeCompletionsForModuleExports = true,
									includeCompletionsWithObjectLiteralMethodSnippets = true,
									autoImports = true,
									includeAutomaticOptionalChainCompletions = false,
									includeCompletionsWithSnippetText = true,
									includeCompletionsWithImportStatements = true,
									completeJSDocs = false,
								},
								preferences = {
									importModuleSpecifierPreference = "non-relative",
									quoteStyle = "single",
									quotePreference = "single",
									jsxAttributeCompletionStyle = "html",
								},
							},
						},
						init_options = {
							hostInfo = "neovim",
						},
					})
				end,
			},
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
			},
		})
	end,
}
