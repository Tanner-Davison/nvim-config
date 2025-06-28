return {
	"neovim/nvim-lspconfig",
	-- Remove the commit pin to get the latest version
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Import cmp-nvim-lsp plugin for capabilities
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap -- for conciseness

		-- Create autocmd for file type detection (same as your original)
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

		-- Configure diagnostic signs (same as your original)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Set default config for all LSP servers
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		-- Configure TypeScript server
		vim.lsp.config.ts_ls = {
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
		}

		-- Configure CSS server
		vim.lsp.config.cssls = {
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
		}

		-- Configure Svelte server
		vim.lsp.config.svelte = {
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
					end,
				})
			end,
		}

		-- Configure GraphQL server
		vim.lsp.config.graphql = {
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		}

		-- Configure Emmet server
		vim.lsp.config.emmet_ls = {
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
		}

		-- Configure Clangd server
		vim.lsp.config.clangd = {
			cmd = {
				"clangd",
				"--background-index",
				"--completion-style=detailed",
				"--header-insertion=iwyu",
				"--fallback-style=llvm",
				"--enable-config",
				"--query-driver=**",
				"--clang-tidy",
				"--offset-encoding=utf-16",
				"--compile-commands-dir=.",
				"--header-insertion-decorators",
				"--all-scopes-completion",
				"--pch-storage=memory",
				"-j=4",
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
					end
					return fallback_flags
				end)(),
			},
		}

		-- Configure Lua server
		vim.lsp.config.lua_ls = {
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
		}

		-- Create keymaps on LSP attach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				-- Use the same keybindings as your original config
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show function signature help"
				keymap.set("n", "<leader>sp", vim.lsp.buf.signature_help, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		-- Enable all the servers
		local servers = {
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
		}

		for _, server in ipairs(servers) do
			vim.lsp.enable(server)
		end
	end,
}
