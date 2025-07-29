return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Import cmp-nvim-lsp plugin for capabilities
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local lspconfig = require("lspconfig")
		local keymap = vim.keymap -- for conciseness

		-- Global flag to prevent duplicate clangd setup
		if _G.clangd_configured then
			return
		end
		_G.clangd_configured = true

		-- Create autocmd for file type detection
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

		-- Set up enhanced capabilities for all LSP servers
		local capabilities = cmp_nvim_lsp.default_capabilities()
		-- Fix for position encoding warnings
		capabilities.textDocument.positionEncoding = "utf-16"

		-- Configure diagnostic signs
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Configure diagnostic display to be less noisy
		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

		-- Filter out problematic diagnostics
		vim.diagnostic.handlers.virtual_text = {
			show = function(namespace, bufnr, diagnostics, opts)
				-- Filter out specific diagnostic messages that are false positives
				local filtered_diagnostics = {}
				for _, diagnostic in ipairs(diagnostics) do
					local message = diagnostic.message:lower()
					local should_show = true
					
					-- Filter out common false positives
					if message:find("lines should be %d+ characters long") then
						should_show = false
					elseif message:find("at least two spaces is best between code and comments") then
						should_show = false
					elseif message:find("included header") and message:find("is not used directly") then
						should_show = false
					elseif message:find("found c%+%+ system header after other header") then
						should_show = false
					elseif message:find("no copyright message found") then
						should_show = false
					elseif message:find("include the directory when naming header files") then
						should_show = false
					end
					
					if should_show then
						table.insert(filtered_diagnostics, diagnostic)
					end
				end
				
				-- Call the original handler with filtered diagnostics
				vim.diagnostic.handlers.virtual_text.show(namespace, bufnr, filtered_diagnostics, opts)
			end,
		}

		-- Common on_attach function with improved error handling
		local on_attach = function(client, bufnr)
			local opts = { buffer = bufnr, silent = true }

			-- Enhanced keybindings with capability checks and better error handling
			opts.desc = "Show LSP references"
			keymap.set("n", "gR", function()
				if client and client.server_capabilities and client.server_capabilities.referencesProvider then
					vim.cmd("Telescope lsp_references")
				else
					vim.notify("LSP server does not support references", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", function()
				if client and client.server_capabilities and client.server_capabilities.declarationProvider then
					vim.lsp.buf.declaration()
				else
					vim.notify("LSP server does not support go to declaration", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Show function signature help"
			keymap.set("n", "<leader>sp", function()
				if client and client.server_capabilities and client.server_capabilities.signatureHelpProvider then
					vim.lsp.buf.signature_help()
				else
					vim.notify("LSP server does not support signature help", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", function()
				-- Try Telescope first, fallback to vim.lsp.buf.definition
				local success, result = pcall(vim.cmd, "Telescope lsp_definitions")
				if not success then
					-- Fallback to direct LSP call
					vim.lsp.buf.definition()
				end
			end, opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", function()
				if client and client.server_capabilities and client.server_capabilities.implementationProvider then
					vim.cmd("Telescope lsp_implementations")
				else
					vim.notify("LSP server does not support implementations", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", function()
				if client and client.server_capabilities and client.server_capabilities.typeDefinitionProvider then
					vim.cmd("Telescope lsp_type_definitions")
				else
					vim.notify("LSP server does not support type definitions", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", function()
				if client and client.server_capabilities and client.server_capabilities.codeActionProvider then
					vim.lsp.buf.code_action()
				else
					vim.notify("LSP server does not support code actions", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", function()
				if client and client.server_capabilities and client.server_capabilities.renameProvider then
					vim.lsp.buf.rename()
				else
					vim.notify("LSP server does not support rename", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", function()
				if client and client.server_capabilities and client.server_capabilities.hoverProvider then
					vim.lsp.buf.hover()
				else
					vim.notify("LSP server does not support hover", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

			-- Toggle diagnostic visibility
			opts.desc = "Toggle diagnostic visibility"
			keymap.set("n", "<leader>td", function()
				local current = vim.diagnostic.config().virtual_text
				vim.diagnostic.config({ virtual_text = not current })
			end, opts)

			-- Clear all diagnostics
			opts.desc = "Clear all diagnostics"
			keymap.set("n", "<leader>cd", function()
				vim.diagnostic.reset()
			end, opts)
		end

		-- Configure TypeScript server with modern syntax
		-- Check if ts_ls is already configured to avoid duplicates
		local ts_clients = vim.lsp.get_clients({ name = "ts_ls" })
		if #ts_clients == 0 then
			-- Ensure definition provider is enabled
			local ts_capabilities = vim.deepcopy(capabilities)
			ts_capabilities.textDocument = ts_capabilities.textDocument or {}
			ts_capabilities.textDocument.definition = {
				dynamicRegistration = true,
			}
			
			lspconfig.ts_ls.setup({
				capabilities = ts_capabilities,
				on_attach = on_attach,
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
				-- Use Neovim's default timeout (most conservative)
				init_options = {
					hostInfo = "neovim",
				},
			})
		end

		-- Configure CSS server
		lspconfig.cssls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
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

		-- Configure Svelte server
		lspconfig.svelte.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Configure GraphQL server
		lspconfig.graphql.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

		-- Configure Emmet server
		lspconfig.emmet_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
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

		-- Configure Clangd server
		-- Check if clangd is already configured to avoid duplicates
		local clangd_clients = vim.lsp.get_clients({ name = "clangd" })
		if #clangd_clients == 0 then
			lspconfig.clangd.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = {
					"clangd",
					"--background-index",
					"--completion-style=detailed",
					"--fallback-style=llvm",
					"--enable-config",
					"--offset-encoding=utf-16",
					"--compile-commands-dir=.",
					"--all-scopes-completion",
					"--pch-storage=memory",
					"-j=2", -- Reduced from 4 to be less aggressive
					"--clang-tidy-checks=-*,readability-identifier-naming,modernize-use-trailing-return-type",
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "h", "hpp" },
				init_options = {
					clangdFileStatus = true,
					usePlaceholders = true,
					completeUnimported = true,
					semanticHighlighting = true,
					fallbackFlags = (function()
						local system_name = vim.loop.os_uname().sysname
						local fallback_flags = {}
						if system_name == "Windows_NT" then
							table.insert(fallback_flags, "-std=c++23")
						elseif system_name == "Darwin" then
							-- Mac-specific flags
							table.insert(fallback_flags, "-std=c++17")
							table.insert(fallback_flags, "-I/usr/local/include")
							table.insert(fallback_flags, "-I/opt/homebrew/include")
						end
						return fallback_flags
					end)(),
				},
				-- Suppress problematic diagnostics
				settings = {
					clangd = {
						arguments = {
							"--clang-tidy-checks=-*,readability-identifier-naming,modernize-use-trailing-return-type",
							"--header-insertion=never",
						},
					},
				},
			})
		end

		-- Configure Lua server
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})

		-- Configure HTML server
		lspconfig.html.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Configure Tailwind CSS server
		lspconfig.tailwindcss.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Configure Prisma server
		lspconfig.prismals.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Configure Python server
		lspconfig.pyright.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Additional fix: Override make_position_params to handle encoding properly
		local original_make_position_params = vim.lsp.util.make_position_params
		vim.lsp.util.make_position_params = function(window, offset_encoding)
			window = window or 0
			local buf = vim.api.nvim_win_get_buf(window)
			local clients = vim.lsp.get_clients({ bufnr = buf })

			-- Use the first client's offset encoding or default to utf-16
			if not offset_encoding and #clients > 0 then
				offset_encoding = clients[1].offset_encoding or "utf-16"
			else
				offset_encoding = offset_encoding or "utf-16"
			end

			return original_make_position_params(window, offset_encoding)
		end
	end,
}
