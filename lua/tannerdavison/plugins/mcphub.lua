return {
	"ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- Conditionally load json5 dependency based on platform
		(function()
			-- Check if we can require json5 (available on Linux)
			local has_json5 = pcall(require, "json5")
			if has_json5 then
				return "Joakker/lua-json5"
			else
				-- Fallback: use built-in vim.json or plenary.nvim's json
				return nil
			end
		end)(),
	},
	build = "npm install -g mcp-hub@latest",
	config = function()
		-- Cross-platform JSON parsing function
		local json_decode
		local has_json5, json5 = pcall(require, "json5")
		
		if has_json5 then
			-- Use json5 if available (Linux with lua-json5 installed)
			json_decode = json5.parse
		else
			-- Fallback to vim.json.decode (available in Neovim 0.7+)
			-- or plenary's json if vim.json is not available
			if vim.json and vim.json.decode then
				json_decode = vim.json.decode
			else
				-- Use plenary as final fallback
				local plenary_ok, plenary_json = pcall(require, "plenary.json")
				if plenary_ok then
					json_decode = plenary_json.decode
				else
					-- If all else fails, use a simple JSON parser
					json_decode = function(str)
						-- This is a very basic fallback - you might want to install a proper JSON parser
						local ok, result = pcall(vim.fn.json_decode, str)
						if ok then
							return result
						else
							error("No JSON parser available. Please install lua-json5 or ensure vim.json is available.")
						end
					end
				end
			end
		end

		require("mcphub").setup({
			json_decode = json_decode,
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
