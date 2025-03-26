return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local todo_comments = require("todo-comments")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "]t", function()
			todo_comments.jump_next()
		end, { desc = "Next todo comment" })

		keymap.set("n", "[t", function()
			todo_comments.jump_prev()
		end, { desc = "Previous todo comment" })

		-- Custom regex to match TODOs with dates
		todo_comments.setup({
			keywords = {
				TODO = {
					icon = " ", -- Custom icon
					color = "info",
					alt = { "todo", "Todo", "TASK" }, -- Alternative keywords
					regex = "TODO%s*%[%d%d%d%d%-%d%d%-%d%d%]:", -- Match TODOs with YYYY-MM-DD format
				},
			},
		})
	end,
}
