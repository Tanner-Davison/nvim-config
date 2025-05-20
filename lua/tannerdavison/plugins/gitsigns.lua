return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	init = function()
		-- This ensures gitsigns.setup is called in the main loop, not in a callback
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyLoad",
			callback = function(event)
				if event.data == "gitsigns.nvim" then
					vim.schedule(function()
						require("gitsigns").setup({
							on_attach = function(bufnr)
								local gs = package.loaded.gitsigns
								local function map(mode, l, r, desc)
									vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
								end
								-- Navigation
								map("n", "]h", function()
									vim.schedule(function()
										gs.next_hunk()
									end)
								end, "Next Hunk")
								map("n", "[h", function()
									vim.schedule(function()
										gs.prev_hunk()
									end)
								end, "Prev Hunk")
								-- Actions
								map("n", "<leader>hs", function()
									vim.schedule(function()
										gs.stage_hunk()
									end)
								end, "Stage hunk")
								map("n", "<leader>hr", function()
									vim.schedule(function()
										gs.reset_hunk()
									end)
								end, "Reset hunk")
								map("v", "<leader>hs", function()
									vim.schedule(function()
										gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
									end)
								end, "Stage hunk")
								map("v", "<leader>hr", function()
									vim.schedule(function()
										gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
									end)
								end, "Reset hunk")
								map("n", "<leader>hS", function()
									vim.schedule(function()
										gs.stage_buffer()
									end)
								end, "Stage buffer")
								map("n", "<leader>hR", function()
									vim.schedule(function()
										gs.reset_buffer()
									end)
								end, "Reset buffer")
								map("n", "<leader>hu", function()
									vim.schedule(function()
										gs.undo_stage_hunk()
									end)
								end, "Undo stage hunk")
								map("n", "<leader>hp", function()
									vim.schedule(function()
										gs.preview_hunk()
									end)
								end, "Preview hunk")
								map("n", "<leader>hb", function()
									vim.schedule(function()
										gs.blame_line({ full = true })
									end)
								end, "Blame line")
								map("n", "<leader>hB", function()
									vim.schedule(function()
										gs.toggle_current_line_blame()
									end)
								end, "Toggle line blame")
								map("n", "<leader>hd", function()
									vim.schedule(function()
										gs.diffthis()
									end)
								end, "Diff this")
								map("n", "<leader>hD", function()
									vim.schedule(function()
										gs.diffthis("~")
									end)
								end, "Diff this ~")
								-- Text object
								map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
							end,
						})
					end)
				end
			end,
		})
	end,
	-- Set cond = false to prevent automatic setup by LazyVim
	cond = false,
}
