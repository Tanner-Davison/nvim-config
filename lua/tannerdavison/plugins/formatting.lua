return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				-- C++ formatting handled by clangd LSP
			},

			formatter_opts = {
				prettier = {
					singleQuote = true,
					trailingComma = "es5",
					semi = true,
					tabWidth = 2,
					useTabs = false,
				},
				-- clang_format removed - using clangd LSP for C++
			},

			-- Enable format on save for all file types
			format_on_save = {
				lsp_fallback = true, -- Enable LSP fallback for better C++ formatting
				async = false,
				timeout_ms = 1000,
			},
		})

		-- Format on save for all file types
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				conform.format({
					bufnr = args.buf,
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end,
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
