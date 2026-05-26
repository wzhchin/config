vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.laststatus = 2
vim.opt.statusline = "%m%r%w %F  %y %=  %l/%L, %c %{&ff}"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "120"
vim.opt.swapfile = false
vim.opt.autowriteall = true
vim.opt.list = true
vim.opt.listchars = { tab = "↦ ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
vim.opt.background = "light"
vim.cmd("colorscheme lunaperche")
