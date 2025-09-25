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

		-- Reliable LSP Configuration using vim.lsp.start (works consistently)
		
		-- TypeScript/JavaScript
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
			callback = function(args)
				-- Check if ts_ls is already attached to this buffer
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "ts_ls" })
				if #clients > 0 then
					return -- Already attached
				end
				
				local root_dir = vim.fs.root(args.buf, { "tsconfig.json", "package.json", ".git" }) or vim.fn.getcwd()
				
				vim.lsp.start({
					name = "ts_ls",
					cmd = { "typescript-language-server", "--stdio" },
					root_dir = root_dir,
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						-- Disable formatting in favor of prettier/conform
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
				}, { bufnr = args.buf })
			end,
		})

		-- CSS/SCSS/Less/Sass
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "css", "scss", "less", "sass" },
			callback = function(args)
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "cssls" })
				if #clients > 0 then return end
				
				local root_dir = vim.fs.root(args.buf, { "package.json", ".git" }) or vim.fn.getcwd()
				
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
				}, { bufnr = args.buf })
			end,
		})

		-- HTML
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "html" },
			callback = function(args)
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "html" })
				if #clients > 0 then return end
				
				local root_dir = vim.fs.root(args.buf, { "package.json", ".git" }) or vim.fn.getcwd()
				
				vim.lsp.start({
					name = "html",
					cmd = { "vscode-html-language-server", "--stdio" },
					root_dir = root_dir,
					capabilities = capabilities,
					on_attach = on_attach,
				}, { bufnr = args.buf })
			end,
		})

		-- Tailwind CSS (only when config exists)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
			callback = function(args)
				-- Only start if tailwind config exists
				local root_dir = vim.fs.root(args.buf, { "tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs", "tailwind.config.mjs" })
				if not root_dir then return end
				
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "tailwindcss" })
				if #clients > 0 then return end
				
				vim.lsp.start({
					name = "tailwindcss",
					cmd = { "tailwindcss-language-server", "--stdio" },
					root_dir = root_dir,
					capabilities = capabilities,
					on_attach = on_attach,
				}, { bufnr = args.buf })
			end,
		})

		-- Lua
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "lua" },
			callback = function(args)
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "lua_ls" })
				if #clients > 0 then return end
				
				local root_dir = vim.fs.root(args.buf, { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" }) or vim.fn.getcwd()
				
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
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false,
							},
							telemetry = { enable = false },
						},
					},
				}, { bufnr = args.buf })
			end,
		})

		-- C/C++ (clangd) with vcpkg support
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "c", "cpp", "objc", "objcpp" },
			callback = function(args)
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "clangd" })
				if #clients > 0 then return end
				
				local root_dir = vim.fs.root(args.buf, { ".clangd", "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", ".git" }) or vim.fn.getcwd()
				
				-- Cross-platform clangd path detection
				local clangd_cmd
				
				-- Check if we're on macOS
				if vim.fn.has('macunix') == 1 or (vim.fn.has('unix') == 1 and vim.fn.system('uname -s'):match('Darwin')) then
					-- macOS - check common locations
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
					
					-- Fallback to generic clangd if specific path not found
					if not clangd_cmd and vim.fn.executable("clangd") == 1 then
						clangd_cmd = "clangd"
					end
				elseif vim.fn.has('win32') == 1 then
					-- Windows
					clangd_cmd = "clangd"
				else 
					-- Linux - prefer versioned clangd, fallback to generic
					if vim.fn.executable("/usr/bin/clangd-14") == 1 then
						clangd_cmd = "/usr/bin/clangd-14"
					elseif vim.fn.executable("/usr/bin/clangd-15") == 1 then
						clangd_cmd = "/usr/bin/clangd-15"
					elseif vim.fn.executable("/usr/bin/clangd-16") == 1 then
						clangd_cmd = "/usr/bin/clangd-16"
					elseif vim.fn.executable("/usr/bin/clangd-17") == 1 then
						clangd_cmd = "/usr/bin/clangd-17"
					elseif vim.fn.executable("/usr/bin/clangd-18") == 1 then
						clangd_cmd = "/usr/bin/clangd-18"
					else
						clangd_cmd = "clangd"
					end
				end
				
				-- Exit if no clangd found
				if not clangd_cmd or vim.fn.executable(clangd_cmd) == 0 then
					vim.notify("clangd not found. Please install clang/llvm.", vim.log.levels.WARN)
					return
				end
				
				-- Create compile_flags.txt for vcpkg includes if needed
				local compile_flags_path = root_dir .. "/compile_flags.txt"
				local vcpkg_root = os.getenv("VCPKG_ROOT")
				local home = os.getenv("HOME") or os.getenv("USERPROFILE")
				
				-- Try to find vcpkg if not set
				if not vcpkg_root and home then
					local potential_paths = {
						home .. "/tools/vcpkg",
						home .. "/vcpkg",
						"C:/tools/vcpkg",
						"F:/tools/vcpkg",
					}
					for _, path in ipairs(potential_paths) do
						if vim.fn.isdirectory(path) == 1 then
							vcpkg_root = path
							break
						end
					end
					
					-- Create compile_flags.txt if vcpkg found and no compile_commands.json exists
					if vcpkg_root and vim.fn.filereadable(root_dir .. "/compile_commands.json") == 0 and vim.fn.filereadable(compile_flags_path) == 0 then
						local triplet = os.getenv("VCPKG_DEFAULT_TRIPLET")
						if not triplet then
							if vim.fn.has('win32') == 1 then
								triplet = "x64-windows"
							elseif vim.fn.has('macunix') == 1 or (vim.fn.has('unix') == 1 and vim.fn.system('uname -s'):match('Darwin')) then
								-- Detect ARM vs Intel Mac
								local arch = vim.fn.system("uname -m"):gsub("%s+", "")
								triplet = arch:match("arm64") and "arm64-osx" or "x64-osx"
							else
								triplet = "x64-linux"
							end
						end
						
						local vcpkg_include_path = vcpkg_root .. "/installed/" .. triplet .. "/include"
						if vim.fn.isdirectory(vcpkg_include_path) == 1 then
							-- Write compile_flags.txt with vcpkg include path
							local flags = {
								"-I" .. vcpkg_include_path,
								"-std=c++23",
								"-Wall",
								"-Wextra"
							}
							local file = io.open(compile_flags_path, "w")
							if file then
								for _, flag in ipairs(flags) do
									file:write(flag .. "\n")
								end
								file:close()
							end
						end
					end
				end
				
				-- Start clangd with the detected path
				local cmd = { clangd_cmd, "--fallback-style=file" }
				
				vim.lsp.start({
					name = "clangd",
					cmd = cmd,
					root_dir = root_dir,
					capabilities = capabilities,
					on_attach = on_attach,
					init_options = {
						clangdFileStatus = true,
						usePlaceholders = true,
						completeUnimported = true,
						semantictokens = true,
					},
				}, { bufnr = args.buf })
			end,
		})

		-- Python
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "python" },
			callback = function(args)
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "pyright" })
				if #clients > 0 then return end
				
				local root_dir = vim.fs.root(args.buf, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" }) or vim.fn.getcwd()
				
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
				}, { bufnr = args.buf })
			end,
		})

		-- Prisma (only if prisma-language-server is available)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "prisma" },
			callback = function(args)
				if vim.fn.executable("prisma-language-server") == 0 then return end
				
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "prismals" })
				if #clients > 0 then return end
				
				local root_dir = vim.fs.root(args.buf, { "package.json", ".git" }) or vim.fn.getcwd()
				
				vim.lsp.start({
					name = "prismals",
					cmd = { "prisma-language-server", "--stdio" },
					root_dir = root_dir,
					capabilities = capabilities,
					on_attach = on_attach,
				}, { bufnr = args.buf })
			end,
		})

		-- Custom commands
		vim.api.nvim_create_user_command("LSPDebug", function()
			local clients = vim.lsp.get_clients()
			print("Active LSP clients:")
			for _, client in ipairs(clients) do
				print(string.format("  - %s (id: %d)", client.name, client.id))
			end
		end, { desc = "Debug LSP servers" })

		vim.api.nvim_create_user_command("LSPRestart", function()
			local clients = vim.lsp.get_clients()
			for _, client in ipairs(clients) do
				vim.lsp.stop_client(client.id)
			end
			attached_buffers = {}
			print("All LSP clients stopped. Servers will restart when you open appropriate files.")
		end, { desc = "Restart all LSP servers" })
	end,
}
