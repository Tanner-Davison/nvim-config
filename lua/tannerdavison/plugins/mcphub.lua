return {
	"ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"Joakker/lua-json5", -- Add this explicit dependency
	},
	build = "npm install -g mcp-hub@latest",
	config = function()
		-- Make sure lua-json5 is loaded first
		local json5 = require("json5")

		require("mcphub").setup({
			json_decode = json5.parse,
			port = 3002,
			config = vim.fn.expand("~/.config/nvim/mcpservers.json"), -- Use .json instead of .json5
			log = {
				level = vim.log.levels.WARN,
				to_file = true,
			},
			-- Enable Avante integration
			extensions = {
				avante = {
					make_slash_commands = true, -- Convert MCP prompts to /slash commands
				},
			},
			-- Optional: Auto-approve for development workflow
			auto_approve = false, -- Keep false initially for safety
			auto_toggle_mcp_servers = true, -- Let AI start/stop servers as needed
			on_ready = function()
				vim.notify("MCP Hub is online!")
				-- Set up keymaps after MCP is ready
				vim.keymap.set("n", "<leader>ms", ":MCPHub<CR>", { desc = "Open MCP Hub interface" })
				vim.keymap.set("n", "<leader>mw", function()
					vim.notify("Use :MCPHub to access search via Tavily, or use @mcp in chat plugins like Avante")
				end, { desc = "MCP search info" })
				vim.keymap.set("n", "<leader>mc", ":MCPHub<CR>", { desc = "Open MCP Hub" })
				-- Note: Avante keymaps (<leader>aa, etc.) are set in avante.lua to avoid conflicts
			end,
		})
	end,
}
