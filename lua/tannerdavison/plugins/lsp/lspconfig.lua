return {
	"neovim/nvim-lspconfig",
	version = false, -- Use the latest version
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/lazydev.nvim", ft = "lua", opts = {} },
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

		-- Common on_attach function
		local on_attach = function(client, bufnr)
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

		-- Use vim.lsp.config for modern Neovim 0.11+ setup
		-- This is the non-deprecated way to configure LSP servers
		
		-- TypeScript/JavaScript
		vim.lsp.config('ts_ls', {
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
			root_dir = function(fname)
				local util = require('lspconfig.util')
				return util.root_pattern('tsconfig.json', 'package.json', '.git')(fname)
			end,
			capabilities = capabilities,
			on_attach = function(client, bufnr)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
				on_attach(client, bufnr)
			end,
			settings = {
				typescript = {
					suggest = { autoImports = true },
					preferences = {
						importModuleSpecifier = "non-relative",
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
				javascript = {
					suggest = { autoImports = true },
					preferences = {
						importModuleSpecifier = "non-relative",
						quoteStyle = "single",
					},
				},
			},
		})
		vim.lsp.enable('ts_ls')

		-- CSS/SCSS/Less/Sass
		vim.lsp.config('cssls', {
			cmd = { "vscode-css-language-server", "--stdio" },
			filetypes = { "css", "scss", "less", "sass" },
			root_dir = function(fname)
				local util = require('lspconfig.util')
				return util.root_pattern('package.json', '.git')(fname)
			end,
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				css = { validate = true, lint = { unknownAtRules = "ignore" } },
				scss = { validate = true, lint = { unknownAtRules = "ignore" } },
				less = { validate = true, lint = { unknownAtRules = "ignore" } },
			},
		})
		vim.lsp.enable('cssls')

		-- HTML
		vim.lsp.config('html', {
			cmd = { "vscode-html-language-server", "--stdio" },
			filetypes = { "html" },
			root_dir = function(fname)
				local util = require('lspconfig.util')
				return util.root_pattern('package.json', '.git')(fname)
			end,
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable('html')

		-- Tailwind CSS
		vim.lsp.config('tailwindcss', {
			cmd = { "tailwindcss-language-server", "--stdio" },
			filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
			root_dir = function(fname)
				local util = require('lspconfig.util')
				return util.root_pattern('tailwind.config.js', 'tailwind.config.ts', 'tailwind.config.cjs', 'tailwind.config.mjs')(fname)
			end,
			capabilities = capabilities,
			on_attach = on_attach,
		})
		vim.lsp.enable('tailwindcss')

		-- Lua
		vim.lsp.config('lua_ls', {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			root_dir = function(fname)
				local util = require('lspconfig.util')
				return util.root_pattern('.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', '.git')(fname)
			end,
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					completion = { callSnippet = "Replace" },
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = { enable = false },
				},
			},
		})
		vim.lsp.enable('lua_ls')

		-- C/C++ (clangd)
		local function setup_clangd()
			local clangd_cmd
			
			if vim.fn.has('macunix') == 1 or (vim.fn.has('unix') == 1 and vim.fn.system('uname -s'):match('Darwin')) then
				local macos_paths = {
					"/usr/bin/clangd",
					"/opt/homebrew/bin/clangd",
					"/usr/local/bin/clangd"
				}
				for _, path in ipairs(macos_paths) do
					if vim.fn.executable(path) == 1 then
						clangd_cmd = path
						break
					end
				end
				if not clangd_cmd and vim.fn.executable("clangd") == 1 then
					clangd_cmd = "clangd"
				end
			elseif vim.fn.has('win32') == 1 then
				clangd_cmd = "clangd"
			else 
				local linux_paths = {
					"/usr/bin/clangd-18",
					"/usr/bin/clangd-17",
					"/usr/bin/clangd-16",
					"/usr/bin/clangd-15",
					"/usr/bin/clangd-14",
					"clangd"
				}
				for _, path in ipairs(linux_paths) do
					if vim.fn.executable(path) == 1 then
						clangd_cmd = path
						break
					end
				end
			end
			
			if not clangd_cmd or vim.fn.executable(clangd_cmd) == 0 then
				return
			end

			vim.lsp.config('clangd', {
				cmd = { clangd_cmd, "--fallback-style=file" },
				filetypes = { "c", "cpp", "objc", "objcpp" },
				root_dir = function(fname)
					local util = require('lspconfig.util')
					return util.root_pattern('.clangd', 'compile_commands.json', 'compile_flags.txt', 'CMakeLists.txt', '.git')(fname)
				end,
				capabilities = capabilities,
				on_attach = on_attach,
				init_options = {
					clangdFileStatus = true,
					usePlaceholders = true,
					completeUnimported = true,
					semanticHighlighting = true,
				},
			})
			vim.lsp.enable('clangd')
		end
		setup_clangd()

		-- Python
		vim.lsp.config('pyright', {
			cmd = { "pyright-langserver", "--stdio" },
			filetypes = { "python" },
			root_dir = function(fname)
				local util = require('lspconfig.util')
				return util.root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git')(fname)
			end,
			capabilities = capabilities,
			on_attach = on_attach,
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
		vim.lsp.enable('pyright')

		-- Prisma
		if vim.fn.executable("prisma-language-server") == 1 then
			vim.lsp.config('prismals', {
				cmd = { "prisma-language-server", "--stdio" },
				filetypes = { "prisma" },
				root_dir = function(fname)
					local util = require('lspconfig.util')
					return util.root_pattern('package.json', '.git')(fname)
				end,
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable('prismals')
		end
	end,
}
