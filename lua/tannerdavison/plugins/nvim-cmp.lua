return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		-- Core completion sources
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lsp-signature-help",

		-- Snippet engine and source
		"hrsh7th/vim-vsnip",
		"hrsh7th/cmp-vsnip",
		"rafamadriz/friendly-snippets",

		-- Additional useful sources
		"hrsh7th/cmp-nvim-lua", -- Neovim Lua API completion
		"ray-x/cmp-treesitter", -- Treesitter completion

		-- UI enhancements
		"onsails/lspkind.nvim",
	},

	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")

		-- ================================================================
		-- VSNIP CONFIGURATION
		-- ================================================================

		-- Configure vsnip filetypes and behavior
		vim.g.vsnip_filetypes = {
			javascriptreact = { "javascript" },
			typescriptreact = { "typescript" },
			vue = { "javascript", "html" },
			svelte = { "javascript", "html" },
		}

		-- Enable snippet suggestions
		vim.g.vsnip_snippet_dir = vim.fn.stdpath("config") .. "/snippets"

		-- ================================================================
		-- HELPER FUNCTIONS
		-- ================================================================

		-- Check if we're in a snippet and can jump
		local function has_words_before()
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
		end

		-- Smart tab behavior for snippets and completion
		local function smart_tab(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif vim.fn["vsnip#available"](1) == 1 then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-expand-or-jump)", true, true, true), "")
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end

		-- Smart shift-tab behavior
		local function smart_shift_tab(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif vim.fn["vsnip#jumpable"](-1) == 1 then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-jump-prev)", true, true, true), "")
			else
				fallback()
			end
		end

		-- ================================================================
		-- CMP SETUP
		-- ================================================================

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview,noselect",
				keyword_length = 1,
			},

			-- Performance settings
			performance = {
				debounce = 60,
				throttle = 30,
				max_view_entries = 200,
			},

			snippet = {
				expand = function(args)
					vim.fn["vsnip#anonymous"](args.body)
				end,
			},

			-- Enhanced key mappings
			mapping = cmp.mapping.preset.insert({
				-- Navigation
				["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
				["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),

				-- Documentation scrolling
				["<C-u>"] = cmp.mapping.scroll_docs(-4),
				["<C-d>"] = cmp.mapping.scroll_docs(4),

				-- Completion control
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<Esc>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					end
					-- Always return to normal mode
					vim.cmd("stopinsert")
				end, { "i", "s" }),

				-- Confirm selection
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				}),

				-- Smart tab completion with snippet support
				["<Tab>"] = cmp.mapping(smart_tab, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(smart_shift_tab, { "i", "s" }),
			}),

			-- Completion sources with priority
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "nvim_lsp_signature_help", priority = 900 },
				{ name = "vsnip", priority = 800 },
				{ name = "nvim_lua", priority = 700 },
			}, {
				{ name = "treesitter", priority = 600 },
				{ name = "buffer", priority = 500, keyword_length = 3 },
				{ name = "path", priority = 400 },
			}),

			-- Enhanced formatting
			formatting = {
				fields = { "kind", "abbr", "menu" },
				expandable_indicator = true,
				format = lspkind.cmp_format({
					mode = "symbol_text",
					maxwidth = 50,
					ellipsis_char = "...",
					show_labelDetails = true,

					-- Custom menu labels
					menu = {
						nvim_lsp = "[LSP]",
						nvim_lua = "[Lua]",
						vsnip = "[Snippet]",
						buffer = "[Buffer]",
						path = "[Path]",
						treesitter = "[TS]",
						cmdline = "[Cmd]",
					},

					-- Custom kind icons (optional override)
					symbol_map = {
						Text = "󰉿",
						Method = "󰆧",
						Function = "󰊕",
						Constructor = "",
						Field = "󰜢",
						Variable = "󰀫",
						Class = "󰠱",
						Interface = "",
						Module = "",
						Property = "󰜢",
						Unit = "󰑭",
						Value = "󰎠",
						Enum = "",
						Keyword = "󰌋",
						Snippet = "",
						Color = "󰏘",
						File = "󰈙",
						Reference = "󰈇",
						Folder = "󰉋",
						EnumMember = "",
						Constant = "󰏿",
						Struct = "󰙅",
						Event = "",
						Operator = "󰆕",
						TypeParameter = "",
					},
				}),
			},

			-- Window configuration
			window = {
				completion = cmp.config.window.bordered({
					border = "rounded",
					winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
				}),
				documentation = cmp.config.window.bordered({
					border = "rounded",
					winhighlight = "Normal:CmpDoc",
				}),
			},

			-- Experimental features
			experimental = {
				ghost_text = {
					hl_group = "CmpGhostText",
				},
			},

			-- Sorting configuration
			sorting = {
				priority_weight = 2,
				comparators = {
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					cmp.config.compare.locality,
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},
		})

		-- ================================================================
		-- AUTOCOMPLETE TOGGLE FUNCTION (ADDED AFTER CMP.SETUP)
		-- ================================================================

		-- Toggle function using a more reliable approach
		local cmp_enabled = true
		local function toggle_autocomplete()
			if cmp_enabled then
				cmp.setup.buffer({ enabled = false })
				cmp_enabled = false
				print("✗ Autocomplete disabled")
			else
				cmp.setup.buffer({ enabled = true })
				cmp_enabled = true
				print("✓ Autocomplete enabled")
			end
		end

		-- Set up the toggle keybinding
		vim.keymap.set({ "n", "i" }, "<leader>tc", toggle_autocomplete, {
			desc = "Toggle autocomplete",
			silent = true,
		})

		-- ================================================================
		-- FILETYPE-SPECIFIC CONFIGURATIONS
		-- ================================================================

		-- Git commit completion
		cmp.setup.filetype("gitcommit", {
			sources = cmp.config.sources({
				{ name = "buffer" },
			}),
		})

		-- Command line completion
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})

		-- ================================================================
		-- CUSTOM HIGHLIGHTS
		-- ================================================================

		-- Define custom highlight groups for better visibility
		vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
		vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
		vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
		vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
		vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#9CDCFE" })
		vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
		vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
		vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
		vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
		vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
		vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
		vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })
	end,
}
