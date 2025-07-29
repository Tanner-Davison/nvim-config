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
				cpp = { "clang-format" },
				c = { "clang-format" },
				h = { "clang-format" },
				hpp = { "clang-format" },
				cc = { "clang-format" },
				cxx = { "clang-format" },
				objc = { "clang-format" },
				objcpp = { "clang-format" },
			},

			formatter_opts = {
				prettier = {
					singleQuote = true,
					trailingComma = "es5",
					semi = true,
					tabWidth = 2,
					useTabs = false,
				},
				["clang-format"] = {
					-- Use project-specific .clang-format file if available, otherwise fallback to LLVM
					args = { "-style=file" },
					-- Alternative: use a specific style
					-- style = "LLVM",
				},
			},

			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000, -- Increased timeout for C++ files
			},

			-- Notify on format errors
			notify_on_error = true,
		})

		-- Enhanced format keymap with better error handling
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
			}, function(err)
				if err then
					vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
				else
					vim.notify("Format successful", vim.log.levels.INFO)
				end
			end)
		end, { desc = "Format file or range (in visual mode)" })

		-- Add a keymap to format the current buffer
		vim.keymap.set("n", "<leader>mf", function()
			conform.format({
				bufnr = vim.api.nvim_get_current_buf(),
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
			}, function(err)
				if err then
					vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
				else
					vim.notify("Format successful", vim.log.levels.INFO)
				end
			end)
		end, { desc = "Format current buffer" })
	end,
}
