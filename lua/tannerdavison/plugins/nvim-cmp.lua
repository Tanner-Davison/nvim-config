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
		"hrsh7th/cmp-omni", -- Omni completion for markdown
		"lukas-reineke/cmp-under-comparator", -- Better sorting

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

		-- Smart shift-tab behavior for completion and snippets
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
				debounce = 150,
				throttle = 60,
				max_view_entries = 100,
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

				-- Use Shift+Tab to accept LSP completions
				-- This leaves Tab free for tabout.nvim
				["<S-Tab>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true,
				}),

				-- Don't map Tab to anything - let tabout.nvim handle it
				-- ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
			}),

					-- Completion sources with priority
		sources = cmp.config.sources({
			{ name = "nvim_lsp", priority = 1000 },
			{ name = "nvim_lsp_signature_help", priority = 900 },
			{ name = "css", priority = 850 },
			{ name = "buffer", priority = 800, keyword_length = 3 },
			{ name = "nvim_lua", priority = 700 },
		}, {
			{ name = "treesitter", priority = 600 },
			{ name = "path", priority = 400 },
			{ name = "vsnip", priority = 300 },
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
					-- Custom comparator to deprioritize snippets
					function(entry1, entry2)
						local kind1 = entry1:get_kind()
						local kind2 = entry2:get_kind()
						
						-- If one is a snippet and the other isn't, prioritize the non-snippet
						if kind1 == cmp.lsp.CompletionItemKind.Snippet and kind2 ~= cmp.lsp.CompletionItemKind.Snippet then
							return false
						elseif kind2 == cmp.lsp.CompletionItemKind.Snippet and kind1 ~= cmp.lsp.CompletionItemKind.Snippet then
							return true
						end
						
						return nil -- Let other comparators handle it
					end,
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},
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

		-- Markdown completion
		cmp.setup.filetype("markdown", {
			sources = cmp.config.sources({
				{ name = "omni", priority = 1000 },
				{ name = "buffer", priority = 500 },
				{ name = "path", priority = 400 },
			}),
		})

		-- CSS-in-JS completion for styled-components
		cmp.setup.filetype({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, {
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "nvim_lsp_signature_help", priority = 900 },
				{ name = "css", priority = 850 },
				{ name = "buffer", priority = 800, keyword_length = 3 },
				{ name = "nvim_lua", priority = 700 },
				{ name = "treesitter", priority = 600 },
				{ name = "path", priority = 400 },
				{ name = "vsnip", priority = 300 },
			}),
			sorting = {
				priority_weight = 2,
				comparators = {
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					cmp.config.compare.locality,
					-- Custom comparator to deprioritize snippets
					function(entry1, entry2)
						local kind1 = entry1:get_kind()
						local kind2 = entry2:get_kind()
						
						-- If one is a snippet and the other isn't, prioritize the non-snippet
						if kind1 == cmp.lsp.CompletionItemKind.Snippet and kind2 ~= cmp.lsp.CompletionItemKind.Snippet then
							return false
						elseif kind2 == cmp.lsp.CompletionItemKind.Snippet and kind1 ~= cmp.lsp.CompletionItemKind.Snippet then
							return true
						end
						
						return nil -- Let other comparators handle it
					end,
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},
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
		vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpItemAbbrMatch" })
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
