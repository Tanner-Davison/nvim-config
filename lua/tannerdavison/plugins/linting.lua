return {
	"mfussenegger/nvim-lint",
	event = { "BufWritePost", "BufReadPost" },
	config = function()
		local lint = require("lint")

		-- Just modify the args to include --no-warn-ignored
		if lint.linters.eslint_d and lint.linters.eslint_d.args then
			table.insert(lint.linters.eslint_d.args, 1, "--no-warn-ignored")
		end

		lint.linters_by_ft = {
			javascript = { "eslint" },
			typescript = { "eslint" },
			javascriptreact = { "eslint" },
			typescriptreact = { "eslint" },
			svelte = { "eslint_d" },
			python = { "pylint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
			group = lint_augroup,
			callback = function()
				-- Only lint if the linter executable exists
				local linters = lint.linters_by_ft[vim.bo.filetype] or {}
				for _, linter_name in ipairs(linters) do
					local linter = lint.linters[linter_name]
					if linter and linter.cmd then
						-- Extract command name (could be string or table)
						local cmd = type(linter.cmd) == "table" and linter.cmd[1] or linter.cmd
						-- Check if command is executable before trying to lint
						if type(cmd) == "string" and vim.fn.executable(cmd) == 1 then
							lint.try_lint(linter_name)
						end
					end
				end
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
