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
vim.keymap.set("n", "<Space>cc", ":!g++ -std=c++23 -Wall % -o %:t:r <CR>", { desc = "Compile C++ code" })

-- Compile all *Cpp allcppfiles on windows machine
-- vim.keymap.set("n", "<Space>cx", function()
-- 	vim.cmd("w!") -- Save the current file
-- 	local output_name = vim.fn.expand("%:t:r") -- Get the file name without extension

-- 	-- Adjust command based on the operating system
-- 	if vim.fn.has("win32") == 1 then
-- 		vim.cmd("!dir /b *.cpp > allcppfiles.txt && g++ @allcppfiles.txt -o " .. output_name)
-- 	elseif vim.fn.has("mac") == 1 then
-- 		vim.cmd("!ls *.cpp > allcppfiles.txt && !clang++ -std=c++23 @allcppfiles.txt -o " .. output_name)
-- 	else
-- 		vim.cmd("!ls *.cpp > allcppfiles.txt && g++ @allcppfiles.txt -o " .. output_name)
-- 	end
-- end, { desc = "Compile all C++ allcppfiles" })
vim.keymap.set("n", "<Space>cx", function()
	vim.cmd("w!") -- Save the current file
	local output_name = vim.fn.expand("%:t:r") -- Get the file name without extension
	-- Adjust command based on the operating system
	if vim.fn.has("win32") == 1 then
		vim.cmd("!dir /b *.cpp > allcppfiles.txt && g++ @allcppfiles.txt -o " .. output_name)
	elseif vim.fn.has("mac") == 1 then
		-- Fixed Mac command: removed extra ! and added proper spacing
		vim.cmd("!ls *.cpp > allcppfiles.txt && clang++ -std=c++23 @allcppfiles.txt -o " .. output_name)
	else
		vim.cmd("!ls *.cpp > allcppfiles.txt && g++ @allcppfiles.txt -o " .. output_name)
	end
end, { desc = "Compile all C++ files" })
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
