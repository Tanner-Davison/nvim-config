return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = {
				"*.h",
				"*.hpp",
				"*.cpp",
				"*.c",
				"*.dll",
				"*/include/*",
				"*/SDL2/*",
				"**/src/**/*.cpp",
				"*/MSVC/*",
			},
			callback = function()
				vim.bo.filetype = "cpp"
			end,
		})
		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show function signature help"
				keymap.set("n", "<leader>sp", vim.lsp.buf.signature_help, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["ts_ls"] = function()
				lspconfig["ts_ls"].setup({
					capabilities = capabilities,
					filetypes = {
						"typescript",
						"typescriptreact",
						"typescript.tsx",
						"javascript",
						"javascriptreact",
						"javascript.jsx",
					},
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
				})
			end,
			["cssls"] = function()
				lspconfig["cssls"].setup({
					capabilities = capabilities,
					filetypes = { "css", "scss", "less", "sass", "javascriptreact", "typescriptreact" },
					settings = {
						css = {
							validate = true,
							lint = {
								unknownAtRules = "ignore",
							},
							completion = {
								completePropertyWithSemiColon = true,
								triggerPropertyValueCompletion = true,
							},
						},
						scss = {
							validate = true,
							lint = {
								unknownAtRules = "ignore",
							},
						},
						less = {
							validate = true,
							lint = {
								unknownAtRules = "ignore",
							},
						},
					},
				})
			end,
			["svelte"] = function()
				-- configure svelte server
				lspconfig["svelte"].setup({
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePost", {
							pattern = { "*.js", "*.ts" },
							callback = function(ctx)
								-- Here use ctx.match instead of ctx.file
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
							end,
						})
					end,
				})
			end,
			["graphql"] = function()
				-- configure graphql language server
				lspconfig["graphql"].setup({
					capabilities = capabilities,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				})
			end,
			["emmet_ls"] = function()
				-- configure emmet language server
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					filetypes = {
						"html",
						"typescriptreact",
						"javascriptreact",
						"javascript",
						"javascript.jsx",
						"typescript",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
					},
					init_options = {
						html = {
							options = {
								["bem.enabled"] = true,
								["jsx.enabled"] = true,
							},
						},
					},
					settings = {
						emmet = {
							showSuggestionsAsSnippets = true,
							showExpandedAbbreviation = "always",
							includedLanguages = {
								javascript = "html",
								typescript = "html",
							},
							preferences = {
								["css.intUnit"] = "px",
								["css.floatUnit"] = "rem",
								["jsx.enabled"] = true,
								["markup.selfClosingStyle"] = "xhtml",
								["tailwind.enable"] = false,
							},
							syntaxProfiles = {
								javascript = {
									quote_char = "'",
								},
							},
						},
					},
				})
			end,
			["clangd"] = function()
				lspconfig["clangd"].setup({
					capabilities = capabilities,
					cmd = {
						"clangd",
						"--background-index",
						"--completion-style=detailed",
						"--header-insertion=iwyu",
						"--fallback-style=llvm",
						"--enable-config",
						"--query-driver=**", -- Add this to help find system compilers
						"--clang-tidy", -- Enable clang-tidy
						"--offset-encoding=utf-16", -- Important for Windows
						"--compile-commands-dir=.", -- Look for compile_commands.json in the root
						"--header-insertion-decorators",
						"--all-scopes-completion",
						"--pch-storage=memory",
						"-j=4", -- Number of workers
					},
					filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "h", "hpp" },
					init_options = {
						clangdFileStatus = true,
						usePlaceholders = true,
						completeUnimported = true,
						semanticHighlighting = true,
					},
				})
			end,
			["lua_ls"] = function()
				-- configure lua server (with special settings)
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							-- make the language server recognize "vim" global
							diagnostics = {
								globals = { "vim" },
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				})
			end,
		})
	end,
}
