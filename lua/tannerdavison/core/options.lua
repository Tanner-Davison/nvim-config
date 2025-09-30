vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = true -- disable line wrapping

-- folding
opt.foldenable = true -- enable folding
opt.foldlevel = 99 -- start with all folds open
opt.foldmethod = "manual" -- use manual folding
opt.foldtext = ""

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- Cursor shapes for different modes (add this anywhere in the file)
opt.guicursor = {
	"n-v-c:block", -- Normal, visual, command: block cursor
	"i-ci-ve:ver25", -- Insert modes: thin vertical bar (25% width)
	"r-cr:hor20", -- Replace modes: horizontal bar (20% height)
	"o:hor50", -- Operator-pending: thicker horizontal bar
	"a:blinkwait700-blinkoff400-blinkon250", -- Blinking settings
}
-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- bracket matching
opt.showmatch = true -- show matching brackets
opt.matchtime = 2 -- show matching brackets for 0.2 seconds
