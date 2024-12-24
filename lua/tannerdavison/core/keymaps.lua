-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- CPP compiling
-- Compile C++ code with <Leader>cc
vim.keymap.set("n", "<Space>cc", ":!g++ % -o %:t:r <CR>", { desc = "Compile C++ code" })

-- Compile all *Cpp allcppfiles on windows machine
vim.keymap.set("n", "<Space>cx", function()
	vim.cmd("w!") -- Save the current file
	local output_name = vim.fn.expand("%:t:r") -- Get the file name without extension

	-- Adjust command based on the operating system
	if vim.fn.has("win32") == 1 then
		vim.cmd("!dir /b *.cpp > allcppfiles.txt && g++ @allcppfiles.txt -o " .. output_name)
	elseif vim.fn.has("mac") == 1 then
		vim.cmd("!ls *.cpp > allcppfiles.txt && clang++ @allcppfiles.txt -o " .. output_name)
	else
		vim.cmd("!ls *.cpp > allcppfiles.txt && g++ @allcppfiles.txt -o " .. output_name)
	end
end, { desc = "Compile all C++ allcppfiles" })

-- Run the compiled executable with <Leader>cv
vim.keymap.set("n", "<Space>cv", function()
	vim.cmd("w!") -- Save the current file
	local output_name = vim.fn.expand("%:t:r") -- Get the file name without extension

	-- Adjust command based on the operating system
	if vim.fn.has("win32") == 1 then
		vim.cmd("!cmd /c " .. output_name .. ".exe")
	elseif vim.fn.has("mac") == 1 then
		vim.cmd("!./" .. output_name)
	else
		vim.cmd("!./" .. output_name)
	end
end, { desc = "Run compiled C++ code" })

-- Unit Conversion For
vim.opt.selection = "exclusive"
local breakpoints = {
	desktop = 1600,
	tablet = 1024,
	mobile = 480,
}

local function format_vw(value)
	local formatted = string.format("%.3f", value)
	formatted = formatted:gsub("%.?0+$", "")
	return formatted .. "vw"
end

local function convert_units(mode, is_visual)
	local viewport = breakpoints[mode]

	if is_visual then
		local start_row = vim.fn.line("'<")
		local end_row = vim.fn.line("'>")

		-- Check if any line contains vw
		local has_vw = false
		for i = start_row, end_row do
			local line = vim.fn.getline(i)
			if line:match("%d+%.?%d*vw") then
				has_vw = true
				break
			end
		end

		for i = start_row, end_row do
			local line = vim.fn.getline(i)
			local new_line
			if has_vw then
				new_line = line:gsub("(%d+%.?%d*)vw", function(num)
					return string.format("%dpx", math.floor(tonumber(num) * viewport / 100))
				end)
			else
				new_line = line:gsub("(%d+%.?%d*)px", function(num)
					return format_vw(tonumber(num) / viewport * 100)
				end)
			end
			vim.fn.setline(i, new_line)
		end
	else
		local line = vim.fn.getline(".")
		local value, unit = line:match("(%d+%.?%d*)(px|vw)")

		if value and unit then
			local result
			if unit == "vw" then
				result = string.format("%dpx", math.floor(tonumber(value) * viewport / 100))
			else
				result = format_vw(tonumber(value) / viewport * 100)
			end
			--
			local new_line = line:gsub("(%d+%.?%d*)(px|vw)", result)
			vim.api.nvim_set_current_line(new_line)
		end
	end
end
--
local modes = { d = "desktop", t = "tablet", m = "mobile" }
for key, mode in pairs(modes) do
	vim.keymap.set("n", "<leader>" .. key .. "z", function()
		convert_units(mode, false)
	end)
	vim.keymap.set("v", "<leader>" .. key .. "z", function()
		convert_units(mode, true)
	end)
end
