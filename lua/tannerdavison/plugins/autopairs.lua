return {
	"windwp/nvim-autopairs",
	event = { "InsertEnter" },
	dependencies = {
		"hrsh7th/nvim-cmp",
	},
	config = function()
		-- Import nvim-autopairs
		local autopairs = require("nvim-autopairs")

		-- Configure autopairs
		autopairs.setup({
			check_ts = true, -- Enable Tree-sitter for better context
			ts_config = {
				lua = { "string" }, -- Don't add pairs in Lua string nodes
				javascript = { "template_string" }, -- Don't add pairs in JavaScript template string nodes
				javascriptreact = { "template_string", "string" },
				typescript = { "template_string " },
				typescriptreact = { "template_string" },
				java = false, -- Disable Tree-sitter for Java
				cpp = { "string" }, -- Don't add pairs in C++ string nodes
			},
			disable_filetype = { "TelescopePrompt" },
			enable_check_bracket_line = true,
			ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
			enable_moveright = true,
			enable_afterquote = true,
			enable_bracket_in_quote = true,
			map_cr = true,
		})
		-- Import nvim-autopairs completion functionality
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp = require("cmp") -- Import nvim-cmp plugin (completions plugin)

		-- Ensure autopairs works with nvim-cmp
		cmp.event:on("confirm_done", function()
			cmp_autopairs.on_confirm_done() -- This ensures autopairs and completion work together
		end)
	end,
}
