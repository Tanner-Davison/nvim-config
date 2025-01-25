-- colorscheme.lua
return {
	"Mofiqul/vscode.nvim",
	config = function()
		local c = require("vscode.colors").get_colors()
		require("vscode").setup({
			-- Enable transparent background
			transparent = false,
			-- Enable italic comments
			italic_comments = true,
			-- Disable nvim-tree background color
			disable_nvimtree_bg = true,
			-- Override colors
			color_overrides = {
				-- Enhanced base colors for OLED
				vscBack = "#13171a", -- #13171a
				vscLeft = "#1B1B19",
				vscLineNumber = "#405779",
				vscSelection = "#103362",

				-- More vibrant syntax colors
				vscBlue = "#67D4FF", -- Functions, methods
				vscOrange = "#FFB86C", -- Constants, numbers
				vscPink = "#FF79C6", -- Keywords
				vscGreen = "#50FA7B", -- Strings
				vscYellow = "#F1FA8C", -- Classes, types
				vscPurple = "#BD93F9", -- Control flow

				-- Enhanced UI elements
				vscDarkBlue = "#081016", -- Active tab
				vscMediumBlue = "#0A1824", -- Inactive tab
				vscLightBlue = "#67D4FF", -- Highlights
			},

			-- Enable group overrides
			group_overrides = {
				-- Enhance specific syntax elements
				Keyword = { fg = "#FF79C6", bold = true },
				Type = { fg = "#F1FA8C", bold = true },
				Function = { fg = "#67D4FF", italic = true },
				String = { fg = "#50FA7B" },
				Number = { fg = "#FFB86C" },
				Comment = { fg = "#6272A4", italic = true },

				-- UI enhancements
				CursorLine = { bg = "#081016" },
				Visual = { bg = "#103362" },
				Search = { bg = "#2C4B8C", fg = "#F1FA8C" },
			},
		})

		vim.cmd("colorscheme vscode")
		vim.g.vscode_style = "dark"
	end,
}
