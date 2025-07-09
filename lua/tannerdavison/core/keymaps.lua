-- ================================================================
-- NEOVIM KEYMAPS CONFIGURATION
-- ================================================================

-- Set leader key to space
vim.g.mapleader = " "
local keymap = vim.keymap -- for conciseness

-- ================================================================
-- GENERAL KEYMAPS
-- ================================================================

-- Exit insert mode with jk
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- ================================================================
-- WINDOW MANAGEMENT
-- ================================================================
-- Split windows
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- ================================================================
-- TAB MANAGEMENT
-- ================================================================
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- ================================================================
-- TODO GENERATION
-- ================================================================

-- Insert TODO with date
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

-- Insert dynamic TODO comment based on filetype
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

-- ================================================================
-- WEB DEVELOPMENT - MEDIA QUERIES
-- ================================================================

-- Insert media query template
keymap.set("n", "<leader>mq", function()
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

-- ================================================================
-- UNIT CONVERSION FOR MEDIA QUERIES
-- ================================================================

-- Set up breakpoints for unit conversion
vim.opt.selection = "exclusive"
local breakpoints = {
	desktop = 1600,
	tablet = 1024,
	mobile = 480,
}

-- Helper function to format viewport width values
local function format_vw(value)
	local formatted = string.format("%.3f", value)
	formatted = formatted:gsub("%.?0+$", "")
	return formatted .. "vw"
end

-- Convert between px and vw units
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

			local new_line = line:gsub("(%d+%.?%d*)(px|vw)", result)
			vim.api.nvim_set_current_line(new_line)
		end
	end
end

-- Create keymaps for unit conversion
local modes = { d = "desktop", t = "tablet", m = "mobile" }
for key, mode in pairs(modes) do
	keymap.set("n", "<leader>" .. key .. "z", function()
		convert_units(mode, false)
	end, { desc = "Convert units for " .. mode })

	keymap.set("v", "<leader>" .. key .. "z", function()
		convert_units(mode, true)
	end, { desc = "Convert units for " .. mode .. " (visual)" })
end

-- ================================================================
-- C++ DEVELOPMENT - COMPILATION
-- ================================================================

-- Compile single C++ file
keymap.set("n", "<Space>cc", ":!g++ -g -O0 -std=c++2b -Wall -Wextra % -o %:t:r <CR>", { desc = "Compile C++ code" })

-- Compile all CPP files (cross-platform)
keymap.set("n", "<Space>cx", function()
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
end, { desc = "Compile all C++ files" })

-- Run compiled C++ executable
keymap.set("n", "<Space>cv", function()
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

-- ================================================================
-- CMAKE DEVELOPMENT
-- ================================================================

-- Generate CMakeLists.txt
keymap.set("n", "<leader>mf", function()
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

-- CMake build commands
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

-- Run CMake executable
keymap.set("n", "<leader>mx", function()
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	if vim.fn.has("win32") == 1 then
		-- Windows path with .exe extension
		vim.cmd("!start cmd /k .\\build\\Debug\\" .. project_name .. ".exe")
	else
		-- Unix path
		vim.cmd("!./build/" .. project_name)
	end
end, { desc = "Run CMake executable" })

-- ================================================================
-- CLAUDE AI INTEGRATION
-- ================================================================

-- Load Claude modules safely
local claude, utils
pcall(function()
	claude = require("tannerdavison.core.claude")
	utils = require("tannerdavison.core.utils")
end)

-- Set up Claude keymaps if modules are available
if claude and utils then
	-- Ask Claude a question
	keymap.set("n", "<leader>k", function()
		vim.ui.input({ prompt = "Ask Claude: " }, function(input)
			if input then
				claude.query_claude(input)
			end
		end)
	end, { desc = "Claude - Ask a question" })

	-- Generic prompt with selected text
	keymap.set("v", "<leader>k", function()
		local text = utils.get_visual_selection()
		claude.query_claude(text, nil, "Claude Response")
	end, { desc = "Claude - Generic prompt" })

	-- Ask about selected text with context
	keymap.set("v", "<leader>kq", function()
		local text = utils.get_visual_selection()
		claude.query_claude_with_context(text, "Claude Response")
	end, { desc = "Claude - Ask about selected text" })

	-- Explain selected code
	keymap.set("v", "<leader>ke", function()
		local text = utils.get_visual_selection()
		claude.explain_code(text)
	end, { desc = "Claude - Explain code" })

	-- Complete selected code
	keymap.set("v", "<leader>kc", function()
		local text = utils.get_visual_selection()
		claude.complete_code(text)
	end, { desc = "Claude - Complete code" })

	-- Refactor selected code
	keymap.set("v", "<leader>kr", function()
		local text = utils.get_visual_selection()
		claude.refactor_code(text)
	end, { desc = "Claude - Refactor code" })

	-- Generate documentation for selected code
	keymap.set("v", "<leader>kd", function()
		local text = utils.get_visual_selection()
		claude.generate_docs(text)
	end, { desc = "Claude - Generate documentation" })

	-- Show Claude conversation history
	keymap.set("n", "<leader>kh", function()
		local claude_module = require("tannerdavison.core.claude")
		claude_module.show_conversations()
	end, { desc = "Claude - Show conversation history" })
end
-- React Storyblok Component Boilerplate
keymap.set("n", "<leader>rsc", function()
	local filename = vim.fn.expand("%:t:r") -- Get filename without extension
	local component_name = filename:gsub("^%l", string.upper) -- Capitalize first letter

	local lines = {
		'"use client";',
		'import React from "react";',
		'import styled, { ThemeProvider } from "styled-components";',
		'import RichTextRenderer from "@/components/renderers/RichTextRenderer";',
		'import { useAvailableThemes } from "@/context/ThemeContext";',
		'import { storyblokEditable } from "@storyblok/react/rsc";',
		'import media from "@/styles/media";',
		'import useMedia from "@/functions/useMedia";',
		"",
		"const " .. component_name .. " = ({ blok }) => {",
		"  // console.log(blok);",
		"  const themes = useAvailableThemes();",
		"  const selectedTheme = themes[blok.theme] || themes.default;",
		"",
		"  return (",
		"    <ThemeProvider theme={selectedTheme}>",
		"      <Wrapper",
		"        spacing={blok.section_spacing}",
		"        spacingOffset={blok.offset_spacing}",
		"      >",
		"<CopyWrapper>",
		"          {blok?.copy_section[0]?.copy ? (",
		"<RichTextRenderer document={blok.copy_section[0].copy} />",
		"         ) : ",
		"       <h1>{'No Copy_Section... Default Hello World'}</h1>",
		"     }",
		"</CopyWrapper>",

		"        <h1>Hello World! :) </h1>",
		"      </Wrapper>",
		"    </ThemeProvider>",
		"  );",
		"};",
		"",
		"export default " .. component_name .. ";",
		"",
		"const CopyWrapper = styled.div``;",
		"const Wrapper = styled.div`",
		"  display: flex;",
		"  flex-direction: column;",
		"  align-items: center;",
		"  justify-content: center;",
		"  padding: ${(props) => {",
		'    if (props.spacingOffset === "top") {',
		'      return props.spacing === "default"',
		'        ? "3.75vw 0 0"',
		"        : props.spacing",
		"          ? `${props.spacing}px 0 0`",
		'          : "3.75vw 0 0";',
		"    }",
		'    if (props.spacingOffset === "bottom") {',
		'      return props.spacing === "default"',
		'        ? "0 0 3.75vw"',
		"        : props.spacing",
		"          ? `0 0 ${props.spacing}px`",
		'          : "0 0 3.75vw";',
		"    }",
		'    return props.spacing === "default"',
		'      ? "3.75vw 0"',
		"      : props.spacing",
		"        ? `${props.spacing}px 0`",
		'        : "3.75vw 0";',
		"  }};",
		"  ${media.fullWidth} {",
		"    padding: ${(props) => {",
		'      if (props.spacingOffset === "top") {',
		'        return props.spacing === "default"',
		'          ? "60px 0 0"',
		"          : props.spacing",
		"            ? `${props.spacing}px 0 0`",
		'            : "60px 0 0";',
		"      }",
		'      if (props.spacingOffset === "bottom") {',
		'        return props.spacing === "default"',
		'          ? "0 0 60px"',
		"          : props.spacing",
		"            ? `0 0 ${props.spacing}px`",
		'            : "0 0 60px";',
		"      }",
		'      return props.spacing === "default"',
		'        ? "60px 0"',
		"        : props.spacing",
		"          ? `${props.spacing}px 0`",
		'          : "60px 0";',
		"    }};",
		"  }",
		"  ${media.tablet} {",
		"    padding: ${(props) => {",
		'      if (props.spacingOffset === "top") {',
		'        return props.spacing === "default"',
		'          ? "5.859vw 0 0"',
		"          : props.spacing",
		"            ? `${props.spacing}px 0 0`",
		'            : "5.859vw 0 0";',
		"      }",
		'      if (props.spacingOffset === "bottom") {',
		'        return props.spacing === "default"',
		'          ? "0 0 5.859vw"',
		"          : props.spacing",
		"            ? `0 0 ${props.spacing}px`",
		'            : "0 0 5.859vw";',
		"      }",
		'      return props.spacing === "default"',
		'        ? "5.859vw 0"',
		"        : props.spacing",
		"          ? `${props.spacing}px 0`",
		'          : "5.859vw 0";',
		"    }};",
		"  }",
		"  ${media.mobile} {",
		"    padding: ${(props) => {",
		'      if (props.spacingOffset === "top") {',
		'        return props.spacing === "default"',
		'          ? "12.5vw 0 0"',
		"          : props.spacing",
		"            ? `${props.spacing}px 0 0`",
		'            : "12.5vw 0 0";',
		"      }",
		'      if (props.spacingOffset === "bottom") {',
		'        return props.spacing === "default"',
		'          ? "0 0 12.5vw"',
		"          : props.spacing",
		"            ? `0 0 ${props.spacing}px`",
		'            : "0 0 12.5vw";',
		"      }",
		'      return props.spacing === "default"',
		'        ? "12.5vw 0"',
		"        : props.spacing",
		"          ? `${props.spacing}px 0`",
		'          : "12.5vw 0";',
		"    }};",
		"  }",
		"`;",
	}

	vim.api.nvim_put(lines, "l", true, true)

	-- Move cursor to the component name for easy replacement
	-- Go up to the component declaration line and position after "const "
	vim.cmd("normal! " .. (#lines - 9) .. "k6l")

	-- Select the component name for easy replacement
	vim.cmd("normal! v" .. string.len(component_name) .. "l")
end, { desc = "Insert React Storyblok Component boilerplate" })
-- ================================================================
-- COMPLETION TOGGLE
-- ================================================================

-- Toggle autocomplete on/off
keymap.set({ "n", "i" }, "<leader>tc", function()
	local cmp = require("cmp")
	local current_setting = cmp.get_config().enabled
	if current_setting ~= false then
		cmp.setup({ enabled = false })
		print("✗ Autocomplete disabled")
	else
		cmp.setup({ enabled = true })
		print("✓ Autocomplete enabled")
	end
end, { desc = "Toggle autocomplete" })
