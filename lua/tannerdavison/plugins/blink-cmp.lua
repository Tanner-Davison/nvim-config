-- blink.cmp: completion engine (replaces nvim-cmp + the cmp-* source plugins,
-- lspkind, cmp-under-comparator and vsnip). Snippets use Neovim's native
-- vim.snippet with friendly-snippets; path/buffer/lsp/omni sources are built in.
--
-- Supermaven's inline ghost-text + Tab accept lives in supermaven.lua and is unchanged.
return {
	"saghen/blink.cmp",
	version = "1.*", -- stable v1 line (downloads a prebuilt fuzzy-matcher, no Rust toolchain needed)
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"rafamadriz/friendly-snippets",
		"windwp/nvim-autopairs", -- set up first so our <CR> handler can call into it
		"folke/lazydev.nvim",
	},
	opts_extend = { "sources.default" },
	---@module "blink.cmp"
	---@type blink.cmp.Config
	opts = {
		-- <leader>tc flips vim.g.blink_cmp_disabled (see core/keymaps.lua)
		enabled = function()
			return not vim.g.blink_cmp_disabled and vim.bo.buftype ~= "prompt"
		end,

		keymap = {
			preset = "none",

			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },

			-- Navigation. <C-j> falls back to accepting one word of a Supermaven suggestion.
			["<C-j>"] = {
				"select_next",
				function()
					local ok, sm = pcall(require, "supermaven-nvim.completion_preview")
					if ok and sm.has_suggestion() then
						sm.on_accept_suggestion_word()
						return true
					end
				end,
				"fallback",
			},
			["<C-k>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<Up>"] = { "select_prev", "fallback" },

			-- Documentation scrolling
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },

			-- Enter accepts only an item you actually selected; otherwise it is a normal
			-- <CR> routed through nvim-autopairs so {|} still expands onto its own line.
			["<CR>"] = {
				"accept",
				function()
					local keys = "\r"
					local ok, npairs = pcall(require, "nvim-autopairs")
					if ok and type(npairs.autopairs_cr) == "function" then
						keys = npairs.autopairs_cr()
					end
					vim.api.nvim_feedkeys(keys, "n", false)
					return true
				end,
			},

			-- Shift+Tab accepts the top item (Tab stays free for Supermaven / tabout.nvim);
			-- with no menu open it falls through to tabout's backwards jump.
			["<S-Tab>"] = { "select_and_accept", "fallback" },

			-- Snippet placeholders (Tab is taken, so Alt+l / Alt+h)
			["<A-l>"] = { "snippet_forward", "fallback" },
			["<A-h>"] = { "snippet_backward", "fallback" },
		},

		appearance = {
			nerd_font_variant = "mono",
			kind_icons = {
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
		},

		completion = {
			-- completeopt "noselect" equivalent: nothing is pre-selected, so <CR> never
			-- accepts by accident.
			list = { selection = { preselect = false, auto_insert = false } },
			accept = { auto_brackets = { enabled = true } },
			menu = {
				border = "rounded",
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
						{ "source_name" },
					},
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 150,
				window = { border = "rounded" },
			},
			ghost_text = { enabled = true },
		},

		signature = { enabled = true, window = { border = "rounded" } },

		snippets = { preset = "default" },

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				lua = { inherit_defaults = true, "lazydev" },
				gitcommit = { "buffer" },
				markdown = { "omni", "buffer", "path" },
				codecompanion = { "codecompanion" },
			},
			providers = {
				lsp = { name = "LSP" },
				path = { name = "Path" },
				-- keep snippets below real symbols, like the old custom cmp comparator did
				snippets = { name = "Snippet", score_offset = -3 },
				buffer = { name = "Buffer", min_keyword_length = 3 },
				omni = { name = "Omni" },
				lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				codecompanion = { name = "CodeCompanion", module = "codecompanion.providers.completion.blink" },
			},
		},

		-- ":" and "/" completion (replaces cmp-cmdline / cmp-path in the cmdline)
		cmdline = {
			enabled = true,
			keymap = { preset = "cmdline" },
			completion = {
				menu = { auto_show = true },
				list = { selection = { preselect = false } },
			},
		},
	},
}
