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
			-- Basic settings
			check_ts = true, -- Enable Tree-sitter for better context
			disable_filetype = { "TelescopePrompt", "spectre_panel" },
			enable_check_bracket_line = true,
			-- Improved pattern to work better with tabout
			ignored_next_char = "[%w%.%s]", -- will ignore alphanumeric, `.`, and whitespace
			enable_moveright = true,
			enable_afterquote = true,
			enable_bracket_in_quote = true,
			map_cr = true,
			map_bs = true, -- Map backspace to delete bracket pair
			map_c_h = false, -- Disable Ctrl+h mapping
			map_c_w = false, -- Disable Ctrl+w mapping
			-- Don't map Tab to avoid conflicts with tabout.nvim
			map_c_t = false,
			ts_config = {
				lua = { "string" }, -- Don't add pairs in Lua string nodes
				javascript = { "template_string", "string", "jsx_element" }, -- Better JS support
				javascriptreact = { "template_string", "string", "jsx_element" },
				typescript = { "template_string", "jsx_element" },
				typescriptreact = { "template_string", "jsx_element" },
				java = false, -- Disable Tree-sitter for Java
				cpp = { "string" }, -- Don't add pairs in C++ string nodes
			},
		})
		-- Import nvim-autopairs completion functionality
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp = require("cmp") -- Import nvim-cmp plugin (completions plugin)

		-- Ensure autopairs works with nvim-cmp
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
