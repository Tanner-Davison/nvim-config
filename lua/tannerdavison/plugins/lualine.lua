return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status")

		local colors = {
			-- Brighter, more saturated accent colors for HDR
			blue = "#67D4FF", -- Slightly more vibrant
			green = "#40FFE0", -- More saturated cyan-green
			violet = "#FF65F2", -- Brighter magenta
			yellow = "#FFE07B", -- Warmer yellow
			red = "#FF4D4D", -- Slightly brighter red

			-- Text and background colors optimized for OLED
			fg = "#E8EBEF", -- Softer white for better eye comfort
			bg = "#030507", -- Near-black for OLED efficiency
			inactive_bg = "#050A0F", -- Slightly lighter than bg for distinction
			semilightgray = "#8A92A0", -- Added missing color definition
		}

		local my_lualine_theme = {
			normal = {
				a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			insert = {
				a = { bg = colors.green, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			visual = {
				a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			command = {
				a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			replace = {
				a = { bg = colors.red, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			inactive = {
				a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
				b = { bg = colors.inactive_bg, fg = colors.semilightgray },
				c = { bg = colors.inactive_bg, fg = colors.semilightgray },
			},
		}

		lualine.setup({
			options = {
				theme = my_lualine_theme,
			},
			sections = {
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
					},
					{
						function()
							if not vim.g.loaded_mcphub then
								return "󰐻 -"
							end
							local count = vim.g.mcphub_servers_count or 0
							local status = vim.g.mcphub_status or "stopped"
							local executing = vim.g.mcphub_executing
							if status == "stopped" then
								return "󰐻 -"
							end
							if executing or status == "starting" or status == "restarting" then
								local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
								local frame = math.floor(vim.loop.now() / 100) % #frames + 1
								return "󰐻 " .. frames[frame]
							end
							return "󰐻 " .. count
						end,
						color = function()
							local status = vim.g.mcphub_status or "stopped"
							if status == "connected" then
								return { fg = "#40FFE0" }
							elseif status == "connecting" or status == "starting" then
								return { fg = "#FFE07B" }
							else
								return { fg = "#FF4D4D" }
							end
						end,
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
