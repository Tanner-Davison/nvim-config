return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		-- File type detection
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = {
				"*.h", "*.hpp", "*.cpp", "*.c", "*.dll",
				"*/include/*", "*/SDL2/*", "**/src/**/*.cpp", "*/MSVC/*",
			},
			callback = function()
				vim.bo.filetype = "cpp"
			end,
		})

		-- Enhanced capabilities
		local capabilities = cmp_nvim_lsp.default_capabilities()
		capabilities.textDocument.positionEncoding = "utf-16"

		-- Diagnostic signs
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Track attached buffers
		local attached_buffers = {}

		-- Common on_attach function
		local on_attach = function(client, bufnr)
			if attached_buffers[bufnr] then return end
			attached_buffers[bufnr] = true

			local opts = { buffer = bufnr, silent = true }

			-- LSP Keymaps
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", vim.tbl_extend("force", opts, { desc = "Show LSP references" }))
			keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
			keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
			keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Show LSP implementations" }))
			keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Show LSP type definitions" }))
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "See available code actions" }))
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Smart rename" }))
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", vim.tbl_extend("force", opts, { desc = "Show buffer diagnostics" }))
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show line diagnostics" }))
			keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Go to previous diagnostic" }))
			keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Go to next diagnostic" }))
			keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show documentation for what is under cursor" }))
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
		end

		-- Clean up on buffer delete
		vim.api.nvim_create_autocmd("BufDelete", {
			callback = function(args)
				attached_buffers[args.buf] = nil
			end,
		})

		-- Modern LSP Configuration using vim.lsp.config (Neovim 0.11+)

		-- TypeScript/JavaScript (using ts_ls - the new name)
		-- Add custom root_dir to prevent session restoration issues
		vim.lsp.config("ts_ls", {
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				-- Disable formatting in favor of prettier/conform
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
				on_attach(client, bufnr)
			end,
			filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
			root_markers = { "tsconfig.json", "package.json", ".git" },
			-- Custom root_dir to prevent session errors
			root_dir = function(fname)
				-- Ensure fname is a string
				if type(fname) ~= "string" then
					return vim.fn.getcwd()
				end
				return vim.fs.root(fname, { "tsconfig.json", "package.json", ".git" }) or vim.fn.getcwd()
			end,
			settings = {
				typescript = {
					suggest = { autoImports = true },
					preferences = {
						importModuleSpecifierPreference = "non-relative",
						quoteStyle = "single",
					},
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

		-- CSS
		vim.lsp.config("cssls", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "css", "scss", "less", "sass", "javascriptreact", "typescriptreact" },
			root_markers = { "package.json", ".git" },
			settings = {
				css = { validate = true, lint = { unknownAtRules = "ignore" } },
				scss = { validate = true, lint = { unknownAtRules = "ignore" } },
				less = { validate = true, lint = { unknownAtRules = "ignore" } },
			},
		})

		-- Lua
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "lua" },
			root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					completion = { callSnippet = "Replace" },
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
				},
			},
		})

		-- HTML
		vim.lsp.config("html", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "html" },
			root_markers = { "package.json", ".git" },
		})

		-- Tailwind CSS
		vim.lsp.config("tailwindcss", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
			root_markers = { "tailwind.config.js", "tailwind.config.ts", "package.json", ".git" },
		})

		-- C/C++ (clangd)
		vim.lsp.config("clangd", {
			capabilities = capabilities,
			on_attach = on_attach,
			cmd = { "/usr/bin/clangd-14", "--fallback-style=file" },
			filetypes = { "c", "cpp", "objc", "objcpp" },
			root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
		})

		-- Python
		vim.lsp.config("pyright", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "python" },
			root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "workspace",
					},
				},
			},
		})

		-- Prisma
		vim.lsp.config("prismals", {
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "prisma" },
			root_markers = { "package.json", ".git" },
		})

		-- ESLint (recommended for TS/JS projects)
		vim.lsp.config("eslint", {
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				-- Auto-fix on save
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					command = "EslintFixAll",
				})
				on_attach(client, bufnr)
			end,
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			root_markers = { ".eslintrc.js", ".eslintrc.json", "package.json", ".git" },
			settings = {
				packageManager = 'npm'
			},
		})

		-- Auto-start LSP servers on buffer attach using direct vim.lsp.start
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
			callback = function()
				-- Check if ts_ls is already running for this buffer
				local clients = vim.lsp.get_clients({ name = "ts_ls" })
				if #clients > 0 then
					return -- Already running
				end
				
				-- Start TypeScript server using the same method that works manually
				vim.defer_fn(function()
					vim.lsp.start({
						name = "ts_ls",
						cmd = { "typescript-language-server", "--stdio" },
						root_dir = vim.fs.root(vim.api.nvim_buf_get_name(0), { "tsconfig.json", "package.json", ".git" }) or vim.fn.getcwd(),
						filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
						on_attach = function(client, bufnr)
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentRangeFormattingProvider = false
							on_attach(client, bufnr)
						end,
						capabilities = capabilities,
					})
					end, 100) -- Small delay to ensure buffer is ready
			end,
		})
		
		-- Auto-start Lua LSP
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "lua" },
			callback = function()
				local clients = vim.lsp.get_clients({ name = "lua_ls" })
				if #clients > 0 then
					return
				end
				
				vim.defer_fn(function()
					vim.lsp.start({
						name = "lua_ls",
						cmd = { "lua-language-server" },
						root_dir = vim.fs.root(vim.api.nvim_buf_get_name(0), { ".luarc.json", ".luarc.jsonc", ".git" }) or vim.fn.getcwd(),
						filetypes = { "lua" },
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
								completion = { callSnippet = "Replace" },
								workspace = {
									checkThirdParty = false,
									library = vim.api.nvim_get_runtime_file("", true),
								},
							},
						},
					})
				end, 100)
			end,
		})
		
		-- Auto-start C/C++ LSP (clangd)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "c", "cpp" },
			callback = function()
				local clients = vim.lsp.get_clients({ name = "clangd" })
				if #clients > 0 then
					return
				end
				
				vim.defer_fn(function()
					vim.lsp.start({
						name = "clangd",
						cmd = { "/usr/bin/clangd-14", "--fallback-style=file" },
						root_dir = vim.fs.root(vim.api.nvim_buf_get_name(0), { "compile_commands.json", "compile_flags.txt", ".git" }) or vim.fn.getcwd(),
						filetypes = { "c", "cpp", "objc", "objcpp" },
						on_attach = on_attach,
						capabilities = capabilities,
					})
				end, 100)
			end,
		})

		-- Custom commands
		vim.api.nvim_create_user_command("LSPDebug", function()
			local clients = vim.lsp.get_clients()
			print("Active LSP clients:")
			for _, client in ipairs(clients) do
				print(string.format("  - %s (filetypes: %s)", client.name, table.concat(client.config.filetypes or {}, ", ")))
			end
		end, { desc = "Debug LSP servers" })

		-- Manual LSP start command with better debugging
		vim.api.nvim_create_user_command("LSPStart", function(opts)
			local server = opts.args
			if server == "" then
				-- Auto-detect server for current filetype
				local ft = vim.bo.filetype
				server = server_filetypes[ft]
				if not server then
					print("No LSP server configured for filetype: " .. ft)
					return
				end
			end
			
			print("Attempting to start LSP server: " .. server)
			
			-- Check if typescript-language-server is executable
			if server == "ts_ls" and vim.fn.executable("typescript-language-server") == 0 then
				print("ERROR: typescript-language-server not found in PATH")
				return
			end
			
			print("Command found, attempting to start...")
			
			-- Try direct vim.lsp.start for ts_ls
			if server == "ts_ls" then
				local success, err = pcall(function()
					vim.lsp.start({
						name = "ts_ls",
						cmd = { "typescript-language-server", "--stdio" },
						root_dir = vim.fs.root(vim.api.nvim_buf_get_name(0), { "tsconfig.json", "package.json", ".git" }) or vim.fn.getcwd(),
						filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
						on_attach = function(client, bufnr)
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentRangeFormattingProvider = false
							on_attach(client, bufnr)
						end,
						capabilities = capabilities,
					})
					print("Direct vim.lsp.start called successfully")
				end)
				if not success then
					print("ERROR in vim.lsp.start: " .. tostring(err))
					return
				end
			else
				-- Try vim.lsp.enable for other servers
				local success = pcall(function()
					vim.lsp.enable(server)
				end)
				if not success then
					print("vim.lsp.enable failed, trying fallback...")
					vim.cmd("LspStart " .. server)
				else
					print("Server start attempted with vim.lsp.enable")
				end
			end
			
			-- Give it a moment then check if it started
			vim.defer_fn(function()
				local clients = vim.lsp.get_clients()
				local found = false
				for _, client in ipairs(clients) do
					if client.name == server then
						found = true
						print("SUCCESS: " .. server .. " is now active!")
						break
					end
				end
				if not found then
					print("FAILED: " .. server .. " did not start. Check :LspLog for errors.")
				end
			end, 2000)
		end, { 
			desc = "Start LSP server with debugging",
			nargs = "?",
			complete = function()
				return vim.tbl_keys(server_filetypes)
			end
		})

		vim.api.nvim_create_user_command("LSPRestart", function()
			local clients = vim.lsp.get_clients()
			for _, client in ipairs(clients) do
				vim.lsp.stop_client(client.id)
			end
			attached_buffers = {}
			-- Re-enable servers for current buffer filetype
			local ft = vim.bo.filetype
			if ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
				vim.defer_fn(function()
					vim.lsp.start({
						name = "ts_ls",
						cmd = { "typescript-language-server", "--stdio" },
						root_dir = vim.fs.root(vim.api.nvim_buf_get_name(0), { "tsconfig.json", "package.json", ".git" }) or vim.fn.getcwd(),
						filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
						on_attach = function(client, bufnr)
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentRangeFormattingProvider = false
							on_attach(client, bufnr)
						end,
						capabilities = capabilities,
					})
				end, 500)
			elseif ft == "lua" then
				vim.defer_fn(function()
					vim.lsp.start({
						name = "lua_ls",
						cmd = { "lua-language-server" },
						root_dir = vim.fs.root(vim.api.nvim_buf_get_name(0), { ".luarc.json", ".luarc.jsonc", ".git" }) or vim.fn.getcwd(),
						filetypes = { "lua" },
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
								completion = { callSnippet = "Replace" },
								workspace = {
									checkThirdParty = false,
									library = vim.api.nvim_get_runtime_file("", true),
								},
							},
						},
					})
				end, 500)
			elseif ft == "c" or ft == "cpp" then
				vim.defer_fn(function()
					vim.lsp.start({
						name = "clangd",
						cmd = { "/usr/bin/clangd-14", "--fallback-style=file" },
						root_dir = vim.fs.root(vim.api.nvim_buf_get_name(0), { "compile_commands.json", "compile_flags.txt", ".git" }) or vim.fn.getcwd(),
						filetypes = { "c", "cpp", "objc", "objcpp" },
						on_attach = on_attach,
						capabilities = capabilities,
					})
				end, 500)
			end
			print("LSP servers restarted")
		end, { desc = "Restart LSP servers" })
	end,
}