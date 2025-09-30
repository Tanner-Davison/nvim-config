return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		-- REQUIRED
		harpoon:setup()

		-- Basic telescope configuration
		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

		-- Key mappings
		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Add file to harpoon" })

		-- Clear harpoon list
		vim.keymap.set("n", "<leader>ac", function()
			harpoon:list():clear()
			vim.notify("Harpoon list cleared", vim.log.levels.INFO)
		end, { desc = "Clear harpoon list" })

		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Toggle harpoon menu" })

		-- Use telescope for harpoon list (better UI)
		vim.keymap.set("n", "<leader>h", function()
			toggle_telescope(harpoon:list())
		end, { desc = "Open harpoon with telescope" })

		-- Quick navigation (using leader-based keys to avoid conflicts)
		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon file 1" })
		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon file 2" })
		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon file 3" })
		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon file 4" })
		
		-- Alternative: Use function keys (F1-F4)
		vim.keymap.set("n", "<F1>", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon file 1" })
		vim.keymap.set("n", "<F2>", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon file 2" })
		vim.keymap.set("n", "<F3>", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon file 3" })
		vim.keymap.set("n", "<F4>", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon file 4" })

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<leader>hp", function()
			harpoon:list():prev()
		end, { desc = "Previous harpoon file" })
		vim.keymap.set("n", "<leader>hn", function()
			harpoon:list():next()
		end, { desc = "Next harpoon file" })
	end,
}
