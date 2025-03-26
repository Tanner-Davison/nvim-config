-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

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
keymap.set("n", "<leader>tD", function()
	local date = os.date("%Y-%m-%d")
	local todo_text = "// TODO [" .. date .. "]: "

	-- Get current cursor position
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	-- Insert the TODO text at current line
	vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { todo_text })

	-- Move cursor to end of inserted text
	vim.api.nvim_win_set_cursor(0, { row, col + #todo_text })

	-- Enter insert mode
	vim.cmd("startinsert")
end, { desc = "Insert a TODO with date" })
keymap.set("n", "<leader>td", function()
	local comment_prefix = "// " -- Default to JavaScript-style comments
	local filetype = vim.bo.filetype
	if filetype == "lua" then
		comment_prefix = "-- "
	elseif filetype == "python" or filetype == "sh" then
		comment_prefix = "# "
	elseif filetype == "c" or filetype == "cpp" then
		comment_prefix = "// "
	end

	-- Insert TODO comment and stay at the end in insert mode
	local todo_text = comment_prefix .. "TODO: "
	vim.api.nvim_put({ todo_text }, "", false, true)
	vim.cmd("startinsert!")
end, { desc = "Insert a TODO comment dynamically" })
-- Media Query Snippets
vim.keymap.set("n", "<leader>mq", function()
	local lines = {
		"${media.fullWidth}{",
		"",
		"}",
		"${media.tablet}{",
		"",
		"}",
		"${media.mobile}{",
		"",
		"}",
	}
	vim.api.nvim_put(lines, "l", true, true)
end, { desc = "Insert media queries" })

--                                                        CPP COMPILING COMMANDS

-- Compile Single file C++ code with <Leader>cc
vim.keymap.set("n", "<Space>cc", ":!g++ -g -O0 -std=c++2b -Wall -Wextra % -o %:t:r <CR>", { desc = "Compile C++ code" })

-- Compile all *CPP files on WINDOWS & Mac machines
vim.keymap.set("n", "<Space>cx", function()
	vim.cmd("w!") -- Save the current file
	local output_name = vim.fn.expand("%:t:r") -- Get the file name without extension

	-- Adjust command based on the operating system
	if vim.fn.has("win32") == 1 then
		vim.cmd("!dir /b *.cpp > allcppfiles.txt && g++ -Wall -Wextra @allcppfiles.txt -o " .. output_name)
	elseif vim.fn.has("mac") == 1 then
		vim.cmd("!ls *.cpp > allcppfiles.txt && clang++ -std=c++23 -Wall -Wextra @allcppfiles.txt -o " .. output_name)
	else
		vim.cmd("!ls *.cpp > allcppfiles.txt && g++ @allcppfiles.txt -o " .. output_name)
	end
end, { desc = "Compile all C++ allcppfiles" })

-- Run the compiled executable with <Leader>cv
vim.keymap.set("n", "<Space>cv", function()
	vim.cmd("w!") -- Save the current file
	local output_name = vim.fn.expand("%:t:r") -- Get the file name without extension

	-- Create a new split window and open a proper terminal buffer
	if vim.fn.has("win32") == 1 then
		vim.cmd("split | terminal cmd /k " .. output_name .. ".exe")
	elseif vim.fn.has("mac") == 1 then
		vim.cmd("split | terminal ./" .. output_name)
	else
		vim.cmd("split | terminal ./" .. output_name)
	end
end, { desc = "Run compiled C++ code" })
-- Unit Conversion For MEDIA QUERY BREAK POINTS
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

--                       CMake commands
--           RUN IN THIS ORDER TO CREATE CMAKE PROJECT
-- <leader>mf   -- Creates CMakeLists.txt with detected files
-- <leader>mg   -- Creates build directory and generates build files
-- <leader>mb   -- Actually compiles your code and creates executable
-- <leader>mx   -- Runs the executable
vim.keymap.set("n", "<leader>mf", function()
	-- Check for existing CMakeLists.txt
	if vim.fn.filereadable("CMakeLists.txt") == 1 then
		local confirm = vim.fn.input("CMakeLists.txt already exists. Overwrite? (y/n): ")
		if confirm ~= "y" then
			print("\nCanceled CMakeLists.txt generation")
			return
		end
	end

	-- Detect source files
	local cpp_files = vim.fn.glob("**/*.cpp", false, true)
	local hpp_files = vim.fn.glob("**/*.hpp", false, true)
	local h_files = vim.fn.glob("**/*.h", false, true)

	-- Create source files string for CMake
	local sources = table.concat(cpp_files, "\n    ")
	local headers = table.concat(vim.fn.extend(hpp_files, h_files), "\n    ")

	local file, err = io.open("CMakeLists.txt", "w")
	if not file then
		print("Error creating CMakeLists.txt: " .. (err or "unknown error"))
		return
	end

	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

	local cmake_content = string.format(
		[[
cmake_minimum_required(VERSION 3.15)
project(%s)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Source files found in project
set(SOURCES
   %s
)

# Header files found in project
set(HEADERS
   %s
)

# Add executable
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS})

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# If using SDL2
# find_package(SDL2 REQUIRED)
# target_link_libraries(${PROJECT_NAME} PRIVATE SDL2::SDL2)
]],
		project_name,
		sources,
		headers
	)

	local success, write_err = pcall(function()
		file:write(cmake_content)
		file:close()
	end)

	if not success then
		print("Error writing to CMakeLists.txt: " .. (write_err or "unknown error"))
		return
	end

	print(
		string.format(
			"Generated CMakeLists.txt with %d source files and %d header files",
			#cpp_files,
			#hpp_files + #h_files
		)
	)
end, { desc = "Generate CMakeLists.txt" })
-- CMake commands
keymap.set("n", "<leader>mg", function()
	vim.cmd("!cmake -S . -B build") -- Generate build files
end, { desc = "CMake Generate" })

keymap.set("n", "<leader>mb", function()
	vim.cmd("!cmake --build build") -- Build project
end, { desc = "CMake Build" })

keymap.set("n", "<leader>mc", function()
	vim.cmd("!rm -rf build") -- Clean build directory
end, { desc = "CMake Clean" })

keymap.set("n", "<leader>mr", function()
	-- Clean, regenerate, and build
	vim.cmd("!rm -rf build && cmake -S . -B build && cmake --build build")
end, { desc = "CMake Rebuild" })
-- Start Cmake Executable
keymap.set("n", "<leader>mx", function()
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	if vim.fn.has("win32") == 1 then
		-- Windows path with .exe extension
		-- vim.cmd("!.\\build\\Debug\\" .. project_name .. ".exe")
		vim.cmd("!start cmd /k .\\build\\Debug\\" .. project_name .. ".exe")
		-- Or if you're using Release build:
		-- vim.cmd("!.\\build\\Release\\" .. project_name .. ".exe")
	else
		-- Unix path
		vim.cmd("!./build/" .. project_name)
	end
end, { desc = "Run CMake executable" })
