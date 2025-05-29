return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header (keeping your original)
		dashboard.section.header.val = {
			"                                                     ",
			"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
			"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
			"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
			"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
			"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
			"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
			"                                                     ",
		}

		-- Menu with your original working icons + a few additions
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
			dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
			dashboard.button("SPC ff", "󰱼 > Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC fr", "  > Recent Files", "<cmd>Telescope oldfiles<CR>"),
			dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
			dashboard.button("c", "  > Config", "<cmd>edit $MYVIMRC<CR>"),
			dashboard.button("u", "  > Update Plugins", "<cmd>Lazy update<CR>"),
			dashboard.button("q", " > Quit NVIM", "<cmd>qa<CR>"),
		}

		-- Add footer with plugin count and info
		local function footer()
			local total_plugins = require("lazy").stats().count
			local datetime = os.date("%Y-%m-%d   %H:%M:%S")
			local version = vim.version()
			local nvim_version_info = "v" .. version.major .. "." .. version.minor .. "." .. version.patch

			return datetime .. "   " .. total_plugins .. " plugins   " .. nvim_version_info
		end

		dashboard.section.footer.val = footer()

		-- Better layout
		dashboard.config.layout = {
			{ type = "padding", val = 2 },
			dashboard.section.header,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 1 },
			dashboard.section.footer,
		}

		-- Send config to alpha
		alpha.setup(dashboard.config)

		-- Disable folding on alpha buffer
		vim.cmd([[
      autocmd FileType alpha setlocal nofoldenable
      autocmd FileType alpha setlocal nonumber
      autocmd FileType alpha setlocal norelativenumber
    ]])
	end,
}
