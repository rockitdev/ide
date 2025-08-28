local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.colorcolumn = "80"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of word
opt.iskeyword:append("-")

-- Disable swap files
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Undo history
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Update time
opt.updatetime = 50

-- Completion
opt.completeopt = "menuone,noselect"

-- Better command line completion
opt.wildmode = "longest:full,full"

-- Hide command line when not used
opt.cmdheight = 1

-- Global status line
opt.laststatus = 3