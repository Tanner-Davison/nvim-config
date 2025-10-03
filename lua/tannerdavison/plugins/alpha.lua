return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header using a raw multiline string to avoid quoting issues
		dashboard.section.header.val = vim.split(
			[[

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⢤⠶⠶⠶⢦⣤⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣀⡤⠴⠶⢤⣄⡀⠀⠀⠀⢀⣤⠶⠛⠋⣁⣀⣤⣤⣤⣤⣤⣤⣤⣀⣈⠉⠛⠳⢤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣠⠞⢁⣠⣤⣤⣤⣀⠙⠲⣤⠖⠋⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⡈⠓⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢰⠃⢠⣿⣿⣿⣿⣿⣿⣷⡦⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢰⡏⠀⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⠿⢿⣿⣿⣿⣿⣿⣿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠙⣄⠀⠀⠀⠀⠀⠀⠀⠀
⢸⡇⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢱⣶⡎⢿⣿⣿⣿⣿⢣⣾⣆⢻⣿⣿⣿⣿⣿⣿⣿⣿⣆⠈⢦⡀⠀⠀⠀⠀⠀⠀
⠈⣷⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⡇⢸⣿⣿⣿⡏⢸⣿⡟⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠈⢧⠀⠀⠀⠀⠀⠀
⠀⢹⡆⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠉⠀⢸⣿⣿⣿⡇⠀⠉⠁⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠘⡇⠀⠀⠀⠀⠀
⠀⠀⢿⡄⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⢸⣿⣿⣿⣇⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠹⣆⠀⠀⠀⠀
⠀⠀⠀⠙⣆⠈⢋⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⣾⣿⣿⣿⣿⡀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠈⢦⠀⠀⠀
⠀⠀⠀⠀⢸⡇⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣾⡟⠉⠉⠉⠙⣷⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠈⢧⡀⠀
⠀⠀⠀⠀⠘⡇⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠰⣿⡷⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠸⡇⠀
⠀⠀⠀⠀⠀⣧⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣿⠀
⠀⠀⠀⠀⠀⢻⡆⠸⣿⣿⣿⣿⣿ Neovim ⣿⣿⣿⣿⣿⣿⣿ Tanner Davison ⣿⣿
⠀⠀⠀⠀⠀⠈⣿⡀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠻⣿⣿⣿⠿⠋⢀⡞⠁⠀
]],
			"\n"
		)

		-- Kirby pink header highlight
		dashboard.section.header.opts = dashboard.section.header.opts or {}
		dashboard.section.header.opts.hl = "AlphaHeader"

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

		-- ONLY close alpha when auto-session SUCCESSFULLY restores a session
		vim.api.nvim_create_autocmd("User", {
			pattern = "AutoSessionRestorePost",
			group = vim.api.nvim_create_augroup("alpha_autoclose", { clear = true }),
			callback = function()
				-- Check if session was actually restored with real files
				local buffers = vim.api.nvim_list_bufs()
				local has_real_buffers = false

				for _, buf in ipairs(buffers) do
					if vim.api.nvim_buf_is_loaded(buf) then
						local bufname = vim.api.nvim_buf_get_name(buf)
						local buftype = vim.bo[buf].buftype
						local filetype = vim.bo[buf].filetype
						-- Check if this is a real file buffer
						if
							bufname ~= ""
							and buftype == ""
							and filetype ~= "alpha"
							and not bufname:match("alpha")
						then
							has_real_buffers = true
							break
						end
					end
				end

				-- Only close alpha if we have real buffers from the session
				if has_real_buffers then
					local alpha_buf = vim.fn.bufnr("alpha")
					if alpha_buf ~= -1 and vim.api.nvim_buf_is_valid(alpha_buf) then
						vim.api.nvim_buf_delete(alpha_buf, { force = true })
					end
				end
			end,
		})

		-- Disable folding on alpha buffer
		vim.cmd([[
			autocmd FileType alpha setlocal nofoldenable
			autocmd FileType alpha setlocal nonumber
			autocmd FileType alpha setlocal norelativenumber
		]])
	end,
}
