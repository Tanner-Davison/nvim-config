-- colorscheme.lua
return {
	"Mofiqul/vscode.nvim",
	config = function()
		local c = require("vscode.colors").get_colors()
		require("vscode").setup({
			-- Enable transparent background
			transparent = true,
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
				-- Your existing overrides...
				Keyword = { fg = "#FF79C6", bold = true },
				Type = { fg = "#67D4FF", bold = true },
				AlphaHeader = { fg = "#ff6fb7", bold = true }, -- Kirby pink for alpha header
				Function = { fg = "#67D4FF", italic = true },
				String = { fg = "#50FA7B" },
				Number = { fg = "#FFB86C" },
				Comment = { fg = "#98C379", italic = true },
				CursorLine = { bg = "#081016" },
				Visual = { bg = "#103362" },
				Search = { bg = "#2C4B8C", fg = "#F1FA8C" },

				-- ADD THESE FOR VISIBLE COMPLETION MENU:
				Pmenu = { bg = "#1B1B19", fg = "#d4d4d4" },
				PmenuSel = { bg = "#103362", fg = "#F1FA8C", bold = true },
				PmenuSbar = { bg = "#405779" },
				PmenuThumb = { bg = "#67D4FF" },

				-- Define the custom groups your nvim-cmp references:
				CmpPmenu = { bg = "#1B1B19", fg = "#d4d4d4" },
				CmpSel = { bg = "#103362", fg = "#F1FA8C", bold = true },
				CmpDoc = { bg = "#0A1824", fg = "#d4d4d4" },

				CmpItemAbbrMatch = { fg = "#67D4FF", bold = true },
				CmpItemAbbrMatchFuzzy = { fg = "#67D4FF" },
				CmpItemKind = { fg = "#BD93F9" },
			},
		})

		vim.cmd("colorscheme vscode")
		vim.g.vscode_style = "dark"
		
		-- Force comment color to override Tree-sitter
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				vim.api.nvim_set_hl(0, "Comment", { fg = "#98C379", italic = true })
				vim.api.nvim_set_hl(0, "@comment", { fg = "#98C379", italic = true })
				vim.api.nvim_set_hl(0, "@comment.documentation", { fg = "#98C379", italic = true })
			end,
		})
		
		-- Apply immediately
		vim.api.nvim_set_hl(0, "Comment", { fg = "#98C379", italic = true })
		vim.api.nvim_set_hl(0, "@comment", { fg = "#98C379", italic = true })
		vim.api.nvim_set_hl(0, "@comment.documentation", { fg = "#98C379", italic = true })
		
		-- nvim-cmp highlight groups
		vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#9CA3AF", italic = true })
		vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
		vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#67D4FF" })
		vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpItemAbbrMatch" })
		vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#67D4FF" })
		vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
		vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
		vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#67D4FF" })
		vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
		vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#FF79C6" })
		vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
		vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })
	end,
}
