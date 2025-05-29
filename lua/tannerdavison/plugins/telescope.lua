return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8", -- Latest stable tag
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				prompt_prefix = "🔍 ",
				selection_caret = "  ",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "bottom",
						preview_width = 0.5,
						results_width = 0.5,
					},
					vertical = {
						mirror = false,
					},
					width = 0.9,
					height = 0.8,
					preview_cutoff = 120,
				},
				sorting_strategy = "descending",
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-x>"] = actions.select_horizontal,
						["<C-v>"] = actions.select_vertical,
						["<C-t>"] = actions.select_tab,
						["<C-u>"] = actions.preview_scrolling_up,
						["<C-d>"] = actions.preview_scrolling_down,
						["<PageUp>"] = actions.results_scrolling_up,
						["<PageDown>"] = actions.results_scrolling_down,
						["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
						["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
						["<C-c>"] = actions.close,
						["<M-p>"] = actions.cycle_history_next,
						["<M-n>"] = actions.cycle_history_prev,
						["<C-w>"] = { "<c-s-w>", type = "command" },
					},
					n = {
						["<esc>"] = actions.close,
						["<CR>"] = actions.select_default,
						["<C-x>"] = actions.select_horizontal,
						["<C-v>"] = actions.select_vertical,
						["<C-t>"] = actions.select_tab,
						["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
						["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
						["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
						["j"] = actions.move_selection_next,
						["k"] = actions.move_selection_previous,
						["H"] = actions.move_to_top,
						["M"] = actions.move_to_middle,
						["L"] = actions.move_to_bottom,
						["<Down>"] = actions.move_selection_next,
						["<Up>"] = actions.move_selection_previous,
						["gg"] = actions.move_to_top,
						["G"] = actions.move_to_bottom,
						["<C-u>"] = actions.preview_scrolling_up,
						["<C-d>"] = actions.preview_scrolling_down,
						["<PageUp>"] = actions.results_scrolling_up,
						["<PageDown>"] = actions.results_scrolling_down,
						["?"] = actions.which_key,
					},
				},
				file_ignore_patterns = {
					"node_modules",
					".git/",
					"dist/",
					"build/",
					"%.lock",
				},
				color_devicons = true,
				set_env = { ["COLORTERM"] = "truecolor" },
			},
			pickers = {
				find_files = {
					hidden = true,
					find_command = {
						"rg",
						"--files",
						"--hidden",
						"--glob",
						"!**/.git/*",
						"--glob",
						"!**/node_modules/*",
					},
				},
				live_grep = {
					additional_args = function(opts)
						return { "--hidden" }
					end,
				},
				grep_string = {
					additional_args = function(opts)
						return { "--hidden" }
					end,
				},
				buffers = {
					previewer = false,
					initial_mode = "normal",
					mappings = {
						i = {
							["<C-d>"] = actions.delete_buffer,
						},
						n = {
							["dd"] = actions.delete_buffer,
						},
					},
				},
				planets = {
					show_pluto = true,
					show_moon = true,
				},
				git_files = {
					show_untracked = true,
				},
				lsp_references = {
					initial_mode = "normal",
				},
				lsp_definitions = {
					initial_mode = "normal",
				},
				lsp_implementations = {
					initial_mode = "normal",
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		})

		-- Load extensions
		telescope.load_extension("fzf")

		-- Set keymaps with better descriptions
		local keymap = vim.keymap

		-- File pickers
		keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>fb", builtin.buffers, { desc = "List open buffers" })
		keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "List available help tags" })

		-- Git pickers
		keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "List git commits" })
		keymap.set("n", "<leader>gfc", builtin.git_bcommits, { desc = "List git commits for current buffer" })
		keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "List git branches" })
		keymap.set("n", "<leader>gs", builtin.git_status, { desc = "List current changes per file" })
		keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Fuzzy find git files" })

		-- LSP pickers
		keymap.set("n", "<leader>lr", builtin.lsp_references, { desc = "List LSP references" })
		keymap.set("n", "<leader>ld", builtin.lsp_definitions, { desc = "List LSP definitions" })
		keymap.set("n", "<leader>li", builtin.lsp_implementations, { desc = "List LSP implementations" })
		keymap.set("n", "<leader>lt", builtin.lsp_type_definitions, { desc = "List LSP type definitions" })
		keymap.set("n", "<leader>lws", builtin.lsp_workspace_symbols, { desc = "List LSP workspace symbols" })
		keymap.set("n", "<leader>lds", builtin.lsp_document_symbols, { desc = "List LSP document symbols" })

		-- Vim pickers
		keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "List normal mode keymappings" })
		keymap.set("n", "<leader>fco", builtin.commands, { desc = "List available plugin/user commands" })
		keymap.set("n", "<leader>fo", builtin.vim_options, { desc = "List vim options" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

		-- Custom function to find files relative to current buffer
		keymap.set("n", "<leader>fd", function()
			builtin.find_files({
				cwd = vim.fn.expand("%:p:h"),
			})
		end, { desc = "Fuzzy find files relative to current file" })

		-- Custom function to search in current buffer
		keymap.set("n", "<leader>f/", function()
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "Fuzzily search in current buffer" })

		-- Telescope meta picker
		keymap.set("n", "<leader>ftp", builtin.builtin, { desc = "List all telescope pickers" })
	end,
}
