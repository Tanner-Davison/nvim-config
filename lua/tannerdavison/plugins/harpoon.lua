return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		-- REQUIRED
		harpoon:setup()

		-- Harpoon list shown in a Snacks picker (file preview included)
		local function harpoon_picker(harpoon_files)
			local items = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(items, { text = item.value, file = item.value })
			end

			Snacks.picker({
				title = "Harpoon",
				items = items,
				format = "file",
				preview = "file",
			})
		end

		-- Key mappings - all under <leader>h prefix
		vim.keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
		end, { desc = "Harpoon: Add file" })

		-- Clear harpoon list
		vim.keymap.set("n", "<leader>hc", function()
			harpoon:list():clear()
			vim.notify("Harpoon list cleared", vim.log.levels.INFO)
		end, { desc = "Harpoon: Clear list" })

		-- Toggle quick menu (Ctrl-e for quick access)
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: Toggle menu" })

		-- Picker UI for the harpoon list
		vim.keymap.set("n", "<leader>ht", function()
			harpoon_picker(harpoon:list())
		end, { desc = "Harpoon: Picker UI" })

		-- Quick navigation to files 1-4
		vim.keymap.set("n", "<leader>h1", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon: File 1" })
		vim.keymap.set("n", "<leader>h2", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon: File 2" })
		vim.keymap.set("n", "<leader>h3", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon: File 3" })
		vim.keymap.set("n", "<leader>h4", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon: File 4" })

		-- Toggle previous & next buffers
		vim.keymap.set("n", "<leader>hp", function()
			harpoon:list():prev()
		end, { desc = "Harpoon: Previous file" })
		vim.keymap.set("n", "<leader>hn", function()
			harpoon:list():next()
		end, { desc = "Harpoon: Next file" })
	end,
}
