-- colorscheme.lua
-- vscode.nvim with an OLED-friendly palette. Every color lives in `P` and every
-- highlight override lives in one table (`hl`) that is used both when vscode.nvim
-- builds the theme and again after any :colorscheme reload.
return {
	"Mofiqul/vscode.nvim",
	config = function()
		-- ------------------------------------------------------------
		-- Palette
		-- ------------------------------------------------------------
		local P = {
			cyan = "#67D4FF", -- functions, methods, matches
			orange = "#FFB86C", -- numbers, constants
			pink = "#FF79C6", -- keywords
			green = "#50FA7B", -- strings
			yellow = "#F1FA8C", -- classes, search text
			purple = "#BD93F9", -- control flow
			lavender = "#C3A6FF", -- types
			violet = "#8E07B8", -- return
			comment = "#98C379",
			red = "#FF5555",
			kirby = "#ff6fb7",

			fg = "#d4d4d4",
			muted = "#9CA3AF",
			dim = "#808080",

			bg = "#13171a",
			panel = "#1B1B19", -- menus / left bar
			panel_alt = "#0A1824", -- docs, inactive tab
			deep = "#081016", -- cursor line, active tab
			selection = "#103362",
			line_nr = "#405779",
			search_bg = "#2C4B8C",

			indent = "#2D3A4A",
			indent_scope = "#3B4D63",
		}

		-- ------------------------------------------------------------
		-- Highlight overrides
		-- ------------------------------------------------------------
		local type_hl = { fg = P.lavender, bold = true }
		local kw_hl = { fg = P.pink, bold = true }
		local ctrl_hl = { fg = P.purple, bold = true }
		local comment_hl = { fg = P.comment, italic = true }

		local hl = {
			-- Core syntax
			Keyword = kw_hl,
			Type = type_hl,
			Function = { fg = P.cyan, italic = true },
			String = { fg = P.green },
			Number = { fg = P.orange },
			Comment = comment_hl,
			AlphaHeader = { fg = P.kirby, bold = true }, -- Kirby pink for the alpha header

			-- Editor chrome
			CursorLine = { bg = P.deep },
			Visual = { bg = P.selection },
			Search = { bg = P.search_bg, fg = P.yellow },

			-- Control flow / statements (purple)
			Statement = ctrl_hl,
			Conditional = ctrl_hl,
			Repeat = ctrl_hl,
			Exception = ctrl_hl,
			["@keyword.control"] = ctrl_hl,
			["@keyword.conditional"] = ctrl_hl,
			["@keyword.repeat"] = ctrl_hl,
			["@keyword.exception"] = ctrl_hl,
			["@keyword.import"] = ctrl_hl, -- using namespace
			["@keyword.return"] = { fg = P.violet, bold = true },

			-- Comments
			["@comment"] = comment_hl,
			["@comment.documentation"] = comment_hl,

			-- Types -> lavender (Tree-sitter + LSP semantic tokens)
			["@type"] = type_hl,
			["@type.builtin"] = type_hl,
			["@type.definition"] = type_hl,
			["@type.qualifier"] = type_hl,
			["@lsp.type.type"] = type_hl,
			["@lsp.type.class"] = type_hl,
			["@lsp.type.struct"] = type_hl,
			["@lsp.type.enum"] = type_hl,
			["@lsp.type.typeParameter"] = type_hl,
			["@lsp.type.interface"] = type_hl,
			["@lsp.type.typescriptType"] = type_hl,

			-- Keywords -> pink
			["@keyword"] = kw_hl,
			["@keyword.function"] = kw_hl,
			["@keyword.operator"] = kw_hl,
			["@keyword.modifier"] = kw_hl, -- virtual, public, static, ...
			["@storageclass"] = kw_hl, -- static, extern, register
			StorageClass = kw_hl,
			["@lsp.type.keyword"] = kw_hl,

			-- Diff: DiffChange stays transparent so unchanged lines in a changed hunk
			-- aren't flooded; DiffText carries the character-level highlight.
			DiffAdd = { bg = "#14342a", fg = "NONE" },
			DiffChange = { bg = "NONE", fg = "NONE" },
			DiffDelete = { bg = "#3a1a1a", fg = "#6b3a3a" },
			DiffText = { bg = "#1e5a3a", fg = "NONE", bold = true },

			-- Gitsigns gutter markers
			GitSignsAdd = { fg = P.green },
			GitSignsChange = { fg = P.yellow },
			GitSignsDelete = { fg = P.red },
			GitSignsAddNr = { fg = P.green },
			GitSignsChangeNr = { fg = P.yellow },
			GitSignsDeleteNr = { fg = P.red },

			-- Native popup menu (used by anything that is not blink.cmp)
			Pmenu = { bg = P.panel, fg = P.fg },
			PmenuSel = { bg = P.selection, fg = P.yellow, bold = true },
			PmenuSbar = { bg = P.line_nr },
			PmenuThumb = { bg = P.cyan },

			-- blink.cmp
			BlinkCmpMenu = { bg = P.panel, fg = P.fg },
			BlinkCmpMenuBorder = { bg = P.panel, fg = P.line_nr },
			BlinkCmpMenuSelection = { bg = P.selection, fg = P.yellow, bold = true },
			BlinkCmpScrollBarThumb = { bg = P.cyan },
			BlinkCmpDoc = { bg = P.panel_alt, fg = P.fg },
			BlinkCmpDocBorder = { bg = P.panel_alt, fg = P.line_nr },
			BlinkCmpSignatureHelp = { bg = P.panel_alt, fg = P.fg },
			BlinkCmpSignatureHelpBorder = { bg = P.panel_alt, fg = P.line_nr },
			BlinkCmpLabelMatch = { fg = P.cyan, bold = true },
			BlinkCmpLabelDeprecated = { fg = P.dim, strikethrough = true },
			BlinkCmpGhostText = { fg = P.muted, italic = true },
			BlinkCmpKind = { fg = P.purple },
			BlinkCmpKindVariable = { fg = P.cyan },
			BlinkCmpKindInterface = { fg = P.cyan },
			BlinkCmpKindText = { fg = P.cyan },
			BlinkCmpKindFunction = { fg = P.cyan },
			BlinkCmpKindMethod = { fg = P.cyan },
			BlinkCmpKindKeyword = { fg = P.pink },
			BlinkCmpKindProperty = { fg = P.pink },
			BlinkCmpKindUnit = { fg = P.pink },

			-- snacks.nvim indent guides (replaced indent-blankline)
			SnacksIndent = { fg = P.indent },
			SnacksIndentScope = { fg = P.indent_scope },
		}

		-- Highlights that point at other groups (can't go through vscode.nvim's table)
		local links = {
			GitSignsAddPreview = "DiffAdd", -- inline diff popups (<leader>hv)
			GitSignsDeletePreview = "DiffDelete",
		}

		local function apply_overrides()
			for name, spec in pairs(hl) do
				vim.api.nvim_set_hl(0, name, spec)
			end
			for name, target in pairs(links) do
				vim.api.nvim_set_hl(0, name, { link = target })
			end
		end

		-- ------------------------------------------------------------
		-- Terminal colors (:terminal splits, compile/run output)
		-- Without these, Neovim falls back to the host terminal's plain 16-color palette,
		-- which looks washed out next to the theme. Uses the same palette as the editor.
		-- ------------------------------------------------------------
		local ansi = {
			"#21222C", P.red, P.green, P.yellow, P.purple, P.pink, P.cyan, P.fg,
			"#6272A4", "#FF6E6E", "#69FF94", "#FFFFA5", "#D6ACFF", "#FF92DF", "#A4FFFF", "#FFFFFF",
		}
		for i, color in ipairs(ansi) do
			vim.g["terminal_color_" .. (i - 1)] = color
		end

		-- ------------------------------------------------------------
		-- Theme
		-- ------------------------------------------------------------
		require("vscode").setup({
			transparent = true,
			italic_comments = true,
			disable_nvimtree_bg = true,
			color_overrides = {
				-- Enhanced base colors for OLED
				vscBack = P.bg,
				vscLeft = P.panel,
				vscLineNumber = P.line_nr,
				vscSelection = P.selection,

				-- More vibrant syntax colors
				vscBlue = P.cyan,
				vscOrange = P.orange,
				vscPink = P.pink,
				vscGreen = P.green,
				vscYellow = P.yellow,
				vscPurple = P.purple,

				-- Enhanced UI elements
				vscDarkBlue = P.deep, -- active tab
				vscMediumBlue = P.panel_alt, -- inactive tab
				vscLightBlue = P.cyan,
			},
			group_overrides = hl,
		})

		vim.cmd("colorscheme vscode")
		apply_overrides()

		-- Re-apply after any colorscheme reload
		vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_overrides })
	end,
}
