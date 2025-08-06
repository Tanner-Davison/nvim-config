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

		-- Track which buffers have already had keymaps attached
		local attached_buffers = {}

		-- Common on_attach function with improved error handling and duplicate prevention
		local on_attach = function(client, bufnr)
			-- Prevent duplicate keymap registration
			if attached_buffers[bufnr] then
				return
			end
			attached_buffers[bufnr] = true

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

			opts.desc = "Go to definition"
			keymap.set("n", "gd", function()
				if client and client.server_capabilities and client.server_capabilities.definitionProvider then
					vim.lsp.buf.definition()
				else
					vim.notify("LSP server does not support definition", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", function()
				if client and client.server_capabilities and client.server_capabilities.declarationProvider then
					vim.lsp.buf.declaration()
				else
					vim.notify("LSP server does not support declaration", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", function()
				if client and client.server_capabilities and client.server_capabilities.implementationProvider then
					vim.lsp.buf.implementation()
				else
					vim.notify("LSP server does not support implementation", vim.log.levels.WARN)
				end
			end, opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", function()
				if client and client.server_capabilities and client.server_capabilities.typeDefinitionProvider then
					vim.lsp.buf.type_definition()
				else
					vim.notify("LSP server does not support type definition", vim.log.levels.WARN)
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
		end

		-- Clean up attached_buffers when buffers are deleted
		vim.api.nvim_create_autocmd("BufDelete", {
			callback = function(args)
				attached_buffers[args.buf] = nil
			end,
		})

		-- Configure TypeScript server with enhanced styled-components support
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
					-- Enhanced CSS-in-JS support
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		})

		-- Configure CSS server with enhanced styled-components support
		lspconfig.cssls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "css", "scss", "less", "sass", "javascriptreact", "typescriptreact", "javascript", "typescript" },
			-- Ensure CSS LSP works in template literals
			init_options = {
				provideFormatter = true,
			},
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
					completion = {
						completePropertyWithSemiColon = true,
						triggerPropertyValueCompletion = true,
						completePropertyWithColon = true,
						completePropertyWithSemicolon = true,
					},
					-- Enhanced CSS-in-JS support
					format = {
						newlineBetweenSelectors = true,
						newlineBetweenRules = true,
					},
				},
				scss = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
					completion = {
						completePropertyWithSemiColon = true,
						triggerPropertyValueCompletion = true,
					},
				},
				less = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
					completion = {
						completePropertyWithSemiColon = true,
						triggerPropertyValueCompletion = true,
					},
				},
			},
		})

		-- Configure Svelte server
		lspconfig.svelte.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Debug command to check LSP servers
		vim.api.nvim_create_user_command("LSPDebug", function()
			local clients = vim.lsp.get_clients()
			print("Active LSP clients:")
			for _, client in ipairs(clients) do
				print(string.format("  - %s (filetypes: %s)", client.name, table.concat(client.config.filetypes or {}, ", ")))
			end
		end, { desc = "Debug LSP servers" })

		-- Improved LSP cleanup command with smart client selection
		vim.api.nvim_create_user_command("LSPCleanup", function()
			local clients = vim.lsp.get_clients()
			local client_counts = {}
			local clients_by_name = {}
			
			-- Group clients by name and count them
			for _, client in ipairs(clients) do
				if not client_counts[client.name] then
					client_counts[client.name] = 0
					clients_by_name[client.name] = {}
				end
				client_counts[client.name] = client_counts[client.name] + 1
				table.insert(clients_by_name[client.name], client)
			end
			
			-- Remove duplicates for each client type with smart selection
			for client_name, count in pairs(client_counts) do
				if count > 1 then
					print("Found " .. count .. " " .. client_name .. " clients. Analyzing configurations...")
					
					local client_list = clients_by_name[client_name]
					local to_remove = {}
					
					-- Analyze each client to determine which to keep
					for i, client in ipairs(client_list) do
						local has_custom_settings = false
						local has_custom_on_attach = false
						
						-- Check if client has custom settings
						if client.config and client.config.settings then
							has_custom_settings = true
						end
						
						-- Check if client has custom on_attach function
						if client.config and client.config.on_attach then
							has_custom_on_attach = true
						end
						
						-- Mark for removal if it has fewer customizations
						-- Priority: keep clients with custom settings/on_attach
						if not has_custom_settings and not has_custom_on_attach then
							table.insert(to_remove, { client = client, index = i, reason = "default configuration" })
						else
							print("  Keeping client " .. i .. " (has custom configuration)")
						end
					end
					
					-- If we still have duplicates after prioritizing custom configs, remove the oldest ones
					if #to_remove < count - 1 then
						-- Sort remaining clients by creation time (keep newer ones)
						local remaining = {}
						for i, client in ipairs(client_list) do
							local should_remove = false
							for _, remove_info in ipairs(to_remove) do
								if remove_info.index == i then
									should_remove = true
									break
								end
							end
							if not should_remove then
								table.insert(remaining, { client = client, index = i })
							end
						end
						
						-- Sort by client ID (higher ID = newer client)
						table.sort(remaining, function(a, b)
							return a.client.id > b.client.id
						end)
						
						-- Remove older clients until we have only one
						for i = 2, #remaining do
							table.insert(to_remove, { 
								client = remaining[i].client, 
								index = remaining[i].index, 
								reason = "older duplicate" 
							})
						end
					end
					
					-- Remove the marked clients
					for _, remove_info in ipairs(to_remove) do
						print("  Removing client " .. remove_info.index .. " (" .. remove_info.reason .. ")")
						vim.lsp.stop_client(remove_info.client.id)
					end
				end
			end
			
			-- Clear attached buffers to allow re-attachment
			attached_buffers = {}
			print("LSP cleanup completed!")
		end, { desc = "Remove duplicate LSP clients" })

		-- Restart LSP servers command
		vim.api.nvim_create_user_command("LSPRestart", function()
			-- Stop all current LSP clients
			local clients = vim.lsp.get_clients()
			for _, client in ipairs(clients) do
				vim.lsp.stop_client(client.id)
			end
			-- Clear attached buffers
			attached_buffers = {}
			-- Restart with our configuration
			vim.cmd("LspStart")
			print("LSP servers restarted with manual configuration")
		end, { desc = "Restart LSP servers" })

		-- Install required LSP servers
		vim.api.nvim_create_user_command("LSPInstall", function()
			vim.cmd("MasonInstall ts_ls cssls")
			print("Installing required LSP servers...")
		end, { desc = "Install required LSP servers" })

		-- Additional fix: Override make_position_params to handle encoding properly
		local original_make_position_params = vim.lsp.util.make_position_params
		vim.lsp.util.make_position_params = function(window, offset_encoding)
			window = window or 0
			local buf = vim.api.nvim_win_get_buf(window)
			local clients = vim.lsp.get_clients({ bufnr = buf })
			if #clients > 0 then
				offset_encoding = offset_encoding or clients[1].offset_encoding
			end
			return original_make_position_params(window, offset_encoding)
		end

		-- Configure Clangd server
		-- Use default nvim-lspconfig setup to avoid duplicates
		lspconfig.clangd.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			-- Enable formatting capabilities with custom style
			settings = {
				clangd = {
					formatting = {
						style = {
							BasedOnStyle = "LLVM",
							IndentWidth = 2,
							ColumnLimit = 150,
							AlignConsecutiveDeclarations = "Consecutive",
							AlignConsecutiveAssignments = "Consecutive",
							AlignTrailingComments = true,
							TabWidth = 8,
							UseTab = "ForIndentation",
							AlignConsecutiveDeclarationsOptions = {
								AcrossEmptyLines = true,
								AcrossComments = true,
								AlignCompound = true,
								PadOperators = true,
							},
						},
					},
				},
			},
		})

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

		-- Improved auto-cleanup with better timing and logic
		-- Trigger on any buffer attachment, not just specific file types
		vim.api.nvim_create_autocmd({ "LspAttach" }, {
			callback = function()
				-- Wait a bit for LSP servers to attach
				vim.defer_fn(function()
					local clients = vim.lsp.get_clients()
					local client_counts = {}
					local clients_by_name = {}
					
					-- Group clients by name and count them
					for _, client in ipairs(clients) do
						if not client_counts[client.name] then
							client_counts[client.name] = 0
							clients_by_name[client.name] = {}
						end
						client_counts[client.name] = client_counts[client.name] + 1
						table.insert(clients_by_name[client.name], client)
					end
					
					-- Remove duplicates for each client type with smart selection
					for client_name, count in pairs(client_counts) do
						if count > 1 then
							print("Auto-cleanup: Found " .. count .. " " .. client_name .. " clients. Analyzing configurations...")
							
							local client_list = clients_by_name[client_name]
							local to_remove = {}
							
							-- Analyze each client to determine which to keep
							for i, client in ipairs(client_list) do
								local has_custom_settings = false
								local has_custom_on_attach = false
								
								-- Check if client has custom settings
								if client.config and client.config.settings then
									has_custom_settings = true
								end
								
								-- Check if client has custom on_attach function
								if client.config and client.config.on_attach then
									has_custom_on_attach = true
								end
								
								-- Mark for removal if it has fewer customizations
								-- Priority: keep clients with custom settings/on_attach
								if not has_custom_settings and not has_custom_on_attach then
									table.insert(to_remove, { client = client, index = i, reason = "default configuration" })
								end
							end
							
							-- If we still have duplicates after prioritizing custom configs, remove the oldest ones
							if #to_remove < count - 1 then
								-- Sort remaining clients by creation time (keep newer ones)
								local remaining = {}
								for i, client in ipairs(client_list) do
									local should_remove = false
									for _, remove_info in ipairs(to_remove) do
										if remove_info.index == i then
											should_remove = true
											break
										end
									end
									if not should_remove then
										table.insert(remaining, { client = client, index = i })
									end
								end
								
								-- Sort by client ID (higher ID = newer client)
								table.sort(remaining, function(a, b)
									return a.client.id > b.client.id
								end)
								
								-- Remove older clients until we have only one
								for i = 2, #remaining do
									table.insert(to_remove, { 
										client = remaining[i].client, 
										index = remaining[i].index, 
										reason = "older duplicate" 
									})
								end
							end
							
							-- Remove the marked clients
							for _, remove_info in ipairs(to_remove) do
								print("  Auto-removing client " .. remove_info.index .. " (" .. remove_info.reason .. ")")
								vim.lsp.stop_client(remove_info.client.id)
							end
							print("Duplicate " .. client_name .. " clients automatically removed!")
						end
					end
				end, 3000) -- Wait 3 seconds for LSP servers to attach
			end,
		})
	end,
}
