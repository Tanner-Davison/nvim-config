return {
	"ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	build = "npm install -g mcp-hub@latest",
	config = function()
		-- Cross-platform JSON parsing function
		local json_decode
		local has_json5, json5 = pcall(require, "json5")

		if has_json5 then
			json_decode = json5.parse
		else
			if vim.json and vim.json.decode then
				json_decode = vim.json.decode
			else
				local plenary_ok, plenary_json = pcall(require, "plenary.json")
				if plenary_ok then
					json_decode = plenary_json.decode
				else
					json_decode = function(str)
						local ok, result = pcall(vim.fn.json_decode, str)
						if ok then
							return result
						else
							error("No JSON parser available")
						end
					end
				end
			end
		end

		require("mcphub").setup({
			json_decode = json_decode,
			port = 3002,
			config = vim.fn.expand("~/.config/nvim/mcpservers.json5"),
			log = {
				level = vim.log.levels.INFO,
				to_file = true,
			},
			auto_approve = true,
			auto_toggle_mcp_servers = true,

			-- Per-project MCP server configs
			workspace = {
				enabled = true,
				look_for = { ".mcphub/servers.json", ".cursor/mcp.json" },
				reload_on_dir_changed = true,
				port_range = { min = 40000, max = 41000 },
			},

			on_ready = function()
				vim.notify("🚀 MCP Hub ready! Use :MCPHub to open", vim.log.levels.INFO)
			end,
		})
	end,
}
