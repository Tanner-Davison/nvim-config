return {
	"rmagatti/auto-session",
	lazy = false, -- Load on startup since user uses it frequently
	config = function()
		local auto_session = require("auto-session")
		auto_session.setup({
			auto_restore = true,
			suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
			-- Set legacy_cmds to false to remove deprecated command warnings
			legacy_cmds = false,
		})
		local keymap = vim.keymap
		-- Use the new AutoSession commands (note the capital 'A')
		keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" })
		keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session for auto session root dir" })
		keymap.set("n", "<leader>wd", "<cmd>AutoSession delete<CR>", { desc = "Delete a session" })
		keymap.set("n", "<leader>wf", "<cmd>AutoSession search<CR>", { desc = "Search sessions" })
	end,
}
