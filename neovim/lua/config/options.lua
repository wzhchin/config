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

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
