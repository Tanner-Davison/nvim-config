-- LSP setup for Neovim 0.12: vim.lsp.config() declares each server, vim.lsp.enable()
-- starts it. nvim-lspconfig is kept only for its bundled per-server defaults
-- (the `lsp/*.lua` files it ships); everything project-specific lives below.
return {
	"neovim/nvim-lspconfig",
	version = false,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp", -- provides the LSP capabilities (completion, snippets, ...)
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/lazydev.nvim", ft = "lua", opts = {} },
	},
	config = function()
		local keymap = vim.keymap

		-- ================================================================
		-- FILETYPE DETECTION
		-- ================================================================
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = {
				"*.h", "*.hpp", "*.cpp", "*.c", "*.dll",
				"*.ino", -- Arduino sketches treated as C++
				"*/include/*", "*/SDL2/*", "**/src/**/*.cpp", "*/MSVC/*",
			},
			callback = function()
				vim.bo.filetype = "cpp"
			end,
		})

		-- ================================================================
		-- SHARED CAPABILITIES + KEYMAPS
		-- ================================================================
		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(),
		})

		-- One LspAttach autocmd replaces the old per-server on_attach copies.
		-- (0.12 also ships defaults like gra/grr/gri/grn/gO; these keep your muscle memory.)
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("tannerdavison_lsp_attach", { clear = true }),
			callback = function(ev)
				local function map(mode, lhs, rhs, desc)
					keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
				end

				map("n", "gR", function() Snacks.picker.lsp_references() end, "Show LSP references")
				map("n", "gd", vim.lsp.buf.definition, "Go to definition")
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "gi", vim.lsp.buf.implementation, "Show LSP implementations")
				map("n", "gt", vim.lsp.buf.type_definition, "Show LSP type definitions")
				map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "See available code actions")
				map("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")
				map("n", "<leader>D", function() Snacks.picker.diagnostics_buffer() end, "Show buffer diagnostics")
				map("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
				map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Go to previous diagnostic")
				map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Go to next diagnostic")
				map("n", "K", vim.lsp.buf.hover, "Show documentation for what is under cursor")
			end,
		})

		-- ================================================================
		-- SERVER DEFINITIONS
		-- ================================================================

		-- TypeScript / JavaScript (formatting is handled by conform/prettier, not ts_ls)
		vim.lsp.config("ts_ls", {
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
			root_markers = { "tsconfig.json", "package.json", ".git" },
			on_attach = function(client)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
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

		-- CSS / SCSS / Less / Sass
		vim.lsp.config("cssls", {
			cmd = { "vscode-css-language-server", "--stdio" },
			filetypes = { "css", "scss", "less", "sass" },
			root_markers = { "package.json", ".git" },
			settings = {
				css = { validate = true, lint = { unknownAtRules = "ignore" } },
				scss = { validate = true, lint = { unknownAtRules = "ignore" } },
				less = { validate = true, lint = { unknownAtRules = "ignore" } },
			},
		})

		-- HTML
		vim.lsp.config("html", {
			cmd = { "vscode-html-language-server", "--stdio" },
			filetypes = { "html" },
			root_markers = { "package.json", ".git" },
		})

		-- Tailwind CSS (only starts inside a project that has a tailwind config)
		vim.lsp.config("tailwindcss", {
			cmd = { "tailwindcss-language-server", "--stdio" },
			filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
			root_markers = { "tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs", "tailwind.config.mjs" },
			workspace_required = true,
		})

		-- Lua
		vim.lsp.config("lua_ls", {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
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

		-- C / C++ (clangd): pick the newest clangd binary that is actually installed
		local function find_clangd()
			if vim.fn.has("win32") == 1 then
				return "clangd"
			end
			local candidates
			if vim.fn.has("mac") == 1 then
				candidates = {
					"/opt/homebrew/opt/llvm/bin/clangd", -- Homebrew LLVM (Apple Silicon)
					"/usr/local/opt/llvm/bin/clangd", -- Homebrew LLVM (Intel)
					"/opt/homebrew/bin/clangd",
					"/usr/local/bin/clangd",
					"/usr/bin/clangd", -- Apple/Xcode clangd
					"clangd",
				}
			else
				candidates = {
					"/usr/bin/clangd-18", "/usr/bin/clangd-17", "/usr/bin/clangd-16",
					"/usr/bin/clangd-15", "/usr/bin/clangd-14", "clangd",
				}
			end
			for _, path in ipairs(candidates) do
				if vim.fn.executable(path) == 1 then
					return path
				end
			end
		end

		local clangd_bin = find_clangd()
		if clangd_bin then
			-- Compilers clangd may ask for include paths (Arduino ARM toolchain, system gcc).
			-- ~ is expanded so this follows whatever home directory this machine uses.
			local query_driver = table.concat({
				vim.fn.expand("~/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/*/bin/arm-none-eabi-g*"),
				"/usr/bin/arm-none-eabi-g*",
				"/usr/bin/g++",
				"/usr/bin/gcc",
			}, ",")

			vim.lsp.config("clangd", {
				cmd = {
					clangd_bin,
					"--fallback-style=file",
					"--background-index=false",
					"--header-insertion=never",
					"--query-driver=" .. query_driver,
				},
				filetypes = { "c", "cpp", "objc", "objcpp" }, -- *.ino is remapped to cpp above
				root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", ".git" },
				init_options = {
					clangdFileStatus = true,
					usePlaceholders = true,
					completeUnimported = true,
					semanticHighlighting = true,
				},
			})
		end

		-- Python
		vim.lsp.config("pyright", {
			cmd = { "pyright-langserver", "--stdio" },
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

		-- GLSL
		vim.lsp.config("glsl_analyzer", {
			cmd = { "glsl_analyzer" },
			filetypes = { "glsl" }, -- .vert/.frag/.comp/... are all detected as "glsl"
			root_markers = { ".git" },
		})

		-- Slang (slangd): shader language used in forge3d; ships with the Vulkan / Slang SDK
		vim.lsp.config("slangd", {
			cmd = { "slangd" },
			filetypes = { "slang" },
			root_markers = { ".git" },
		})

		-- Prisma
		vim.lsp.config("prismals", {
			cmd = { "prisma-language-server", "--stdio" },
			filetypes = { "prisma" },
			root_markers = { "package.json", ".git" },
		})

		-- ================================================================
		-- ENABLE SERVERS
		-- ================================================================
		-- A server is enabled as soon as its binary exists. If it is not installed yet
		-- (e.g. Mason is still installing it), retry the first time a matching filetype opens.
		local servers = {
			{ "ts_ls", "typescript-language-server", { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
			{ "cssls", "vscode-css-language-server", { "css", "scss", "less", "sass" } },
			{ "html", "vscode-html-language-server", { "html" } },
			{ "tailwindcss", "tailwindcss-language-server", { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" } },
			{ "lua_ls", "lua-language-server", { "lua" } },
			{ "pyright", "pyright-langserver", { "python" } },
			{ "glsl_analyzer", "glsl_analyzer", { "glsl" } },
			{ "slangd", "slangd", { "slang" } },
			{ "prismals", "prisma-language-server", { "prisma" } },
		}
		if clangd_bin then
			table.insert(servers, { "clangd", clangd_bin, { "c", "cpp", "objc", "objcpp" } })
		end

		for _, server in ipairs(servers) do
			local name, exe, filetypes = server[1], server[2], server[3]
			if vim.fn.executable(exe) == 1 then
				vim.lsp.enable(name)
			else
				vim.api.nvim_create_autocmd("FileType", {
					pattern = filetypes,
					once = true,
					callback = function()
						if vim.fn.executable(exe) == 1 then
							vim.lsp.enable(name)
						end
					end,
				})
			end
		end

		-- ================================================================
		-- ARDUINO: hide AVR false-positive diagnostics from clangd in .ino files
		-- ================================================================
		-- Uses a reentrance guard to prevent DiagnosticChanged -> set -> DiagnosticChanged loops.
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
				if msg:find(pat, 1, true) then
					return true
				end
			end
			return msg:find("unknown type name '__", 1, true) ~= nil
		end

		local ino_ns = vim.api.nvim_create_namespace("arduino_filtered_diag")
		local _ino_filtering = {} -- bufnr -> bool

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(ev)
				if not vim.api.nvim_buf_get_name(ev.buf):match("%.ino$") then
					return
				end

				vim.api.nvim_create_autocmd("DiagnosticChanged", {
					buffer = ev.buf,
					callback = function()
						local bufnr = ev.buf
						if _ino_filtering[bufnr] then
							return
						end
						_ino_filtering[bufnr] = true

						local filtered = vim.tbl_filter(function(d)
							-- Keep diagnostics that are NOT from our own namespace and not false positives
							return d.namespace ~= ino_ns and not is_arduino_fp(d.message)
						end, vim.diagnostic.get(bufnr))

						vim.diagnostic.reset(ino_ns, bufnr)
						vim.diagnostic.set(ino_ns, bufnr, filtered)

						-- Hide clangd's raw diagnostics so only our filtered set shows
						for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })) do
							vim.diagnostic.hide(vim.lsp.diagnostic.get_namespace(client.id), bufnr)
						end

						_ino_filtering[bufnr] = false
					end,
				})
			end,
		})
	end,
}
