return {
	"neovim/nvim-lspconfig",
	version = false,
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
				"*.ino",                                       -- Arduino sketches treated as C++
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
		end

		-- TypeScript/JavaScript
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
			callback = function(ev)
				local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(ev.buf), { 'tsconfig.json', 'package.json', '.git' })

				vim.lsp.start({
					name = "ts_ls",
					cmd = { "typescript-language-server", "--stdio" },
					root_dir = root_dir,
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
			end,
		})

		-- CSS/SCSS/Less/Sass
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "css", "scss", "less", "sass" },
			callback = function(ev)
				local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(ev.buf), { 'package.json', '.git' })

				vim.lsp.start({
					name = "cssls",
					cmd = { "vscode-css-language-server", "--stdio" },
					root_dir = root_dir,
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						css = { validate = true, lint = { unknownAtRules = "ignore" } },
						scss = { validate = true, lint = { unknownAtRules = "ignore" } },
						less = { validate = true, lint = { unknownAtRules = "ignore" } },
					},
				})
			end,
		})

		-- HTML
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "html" },
			callback = function(ev)
				local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(ev.buf), { 'package.json', '.git' })

				vim.lsp.start({
					name = "html",
					cmd = { "vscode-html-language-server", "--stdio" },
					root_dir = root_dir,
					capabilities = capabilities,
					on_attach = on_attach,
				})
			end,
		})

		-- Tailwind CSS
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
			callback = function(ev)
				local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(ev.buf), { 'tailwind.config.js', 'tailwind.config.ts', 'tailwind.config.cjs', 'tailwind.config.mjs' })

				if root_dir then
					vim.lsp.start({
						name = "tailwindcss",
						cmd = { "tailwindcss-language-server", "--stdio" },
						root_dir = root_dir,
						capabilities = capabilities,
						on_attach = on_attach,
					})
				end
			end,
		})

		-- Lua
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "lua" },
			callback = function(ev)
				local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(ev.buf), { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', '.git' })

				vim.lsp.start({
					name = "lua_ls",
					cmd = { "lua-language-server" },
					root_dir = root_dir,
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							completion = { callSnippet = "Replace" },
							workspace = {
								library = { vim.env.VIMRUNTIME },
								checkThirdParty = false,
							},
							telemetry = { enable = false },
						},
					},
				})
			end,
		})

		-- C/C++ (clangd)
		local function setup_clangd()
			local clangd_cmd

			if vim.fn.has('macunix') == 1 or (vim.fn.has('unix') == 1 and vim.fn.system('uname -s'):match('Darwin')) then
				local macos_paths = {
					"/usr/bin/clangd",
					"/opt/homebrew/bin/clangd",
					"/usr/local/bin/clangd",
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
					"clangd",
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

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "c", "cpp", "objc", "objcpp" },  -- *.ino is remapped to cpp above
				callback = function(ev)
					local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(ev.buf), { '.clangd', 'compile_commands.json', 'compile_flags.txt', 'CMakeLists.txt', '.git' })

					vim.lsp.start({
						name = "clangd",
						cmd = {
							clangd_cmd,
							"--fallback-style=file",
							"--background-index=false",
							"--query-driver=/home/tanner/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/*/bin/arm-none-eabi-g*,/usr/bin/arm-none-eabi-g*,/usr/bin/g++,/usr/bin/gcc",
						},
						root_dir = root_dir,
						capabilities = capabilities,
						on_attach = on_attach,
						init_options = {
							clangdFileStatus = true,
							usePlaceholders = true,
							completeUnimported = true,
							semanticHighlighting = true,
						},
					})
				end,
			})
		end
		setup_clangd()

		-- Python
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "python" },
			callback = function(ev)
				local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(ev.buf), { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' })

				vim.lsp.start({
					name = "pyright",
					cmd = { "pyright-langserver", "--stdio" },
					root_dir = root_dir,
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
			end,
		})

		-- Arduino .ino: filter AVR false-positive diagnostics from clangd.
		-- Uses a reentrance guard to prevent DiagnosticChanged → set → DiagnosticChanged loops.
		local arduino_fp_patterns = {
			"undeclared identifier 'OUTPUT'",
			"undeclared identifier 'INPUT'",
			"undeclared identifier 'INPUT_PULLUP'",
			"undeclared identifier 'HIGH'",
			"undeclared identifier 'LOW'",
			"undeclared identifier 'pinMode'",
			"undeclared identifier 'digitalWrite'",
			"undeclared identifier 'digitalRead'",
			"undeclared identifier 'analogWrite'",
			"undeclared identifier 'analogRead'",
			"undeclared identifier 'delay'",
			"undeclared identifier 'delayMicroseconds'",
			"undeclared identifier 'millis'",
			"undeclared identifier 'micros'",
			"undeclared identifier 'tone'",
			"undeclared identifier 'noTone'",
			"undeclared identifier 'Serial'",
			"undeclared identifier 'Wire'",
			"undeclared identifier 'SPI'",
		}

		local function is_arduino_fp(msg)
			for _, pat in ipairs(arduino_fp_patterns) do
				if msg:find(pat, 1, true) then return true end
			end
			if msg:find("unknown type name '__", 1, true) then return true end
			return false
		end

		local ino_ns = vim.api.nvim_create_namespace("arduino_filtered_diag")
		-- Per-buffer reentrance guard: bufnr -> bool
		local _ino_filtering = {}

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(ev)
				if not vim.api.nvim_buf_get_name(ev.buf):match("%.ino$") then return end

				vim.api.nvim_create_autocmd("DiagnosticChanged", {
					buffer = ev.buf,
					callback = function()
						local bufnr = ev.buf
						-- Guard: if we're already inside filtering for this buf, bail out
						if _ino_filtering[bufnr] then return end
						_ino_filtering[bufnr] = true

						local all = vim.diagnostic.get(bufnr)
						local filtered = vim.tbl_filter(function(d)
							-- Only keep diagnostics NOT from our own namespace AND not false positives
							return d.namespace ~= ino_ns and not is_arduino_fp(d.message)
						end, all)

						vim.diagnostic.reset(ino_ns, bufnr)
						vim.diagnostic.set(ino_ns, bufnr, filtered)

						-- Hide clangd's raw diagnostics so only our filtered set shows
						for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })) do
							local clangd_ns = vim.lsp.diagnostic.get_namespace(client.id)
							vim.diagnostic.hide(clangd_ns, bufnr)
						end

						_ino_filtering[bufnr] = false
					end,
				})
			end,
		})

		-- Prisma
		if vim.fn.executable("prisma-language-server") == 1 then
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "prisma" },
				callback = function(ev)
					local root_dir = vim.fs.root(vim.api.nvim_buf_get_name(ev.buf), { 'package.json', '.git' })

					vim.lsp.start({
						name = "prismals",
						cmd = { "prisma-language-server", "--stdio" },
						root_dir = root_dir,
						capabilities = capabilities,
						on_attach = on_attach,
					})
				end,
			})
		end
	end,
}
