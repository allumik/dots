-- Main options defined in LUA
local opt = vim.opt

-- just to be safe, define some options here...
opt.backupdir = vim.fn.stdpath('cache') .. '/backup'
opt.writebackup = false
opt.directory = vim.fn.stdpath('cache') .. '/swap'
opt.undofile = true
opt.undodir = vim.fn.stdpath('cache') .. '/undo'

opt.termguicolors = true
opt.mouse = 'a'
opt.lazyredraw = true
opt.visualbell = false
opt.belloff = 'all'
opt.autoread = true
opt.hidden = true -- hidden buffers
opt.wildmenu = true -- enhanced tab completion for vim command bar
-- opt.wildmode = 'listfull' -- Displays a handy list of commands we can tab thru'
opt.startofline = false  -- don't go to the start of the line when moving to another file
opt.compatible = false

opt.wrap = false
opt.backspace = '2' -- this makes backspace work as normal

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true -- spaces instead of tabs
opt.smartindent = true
opt.smarttab = true
opt.clipboard = 'unnamedplus'
-- opt.pastetoggle = '<F2>'
opt.signcolumn = 'yes:1'

opt.timeoutlen = 1200
opt.shortmess = 'c'
opt.completeopt = 'menuone,noinsert,noselect'
opt.ignorecase = true
opt.infercase = true

opt.laststatus = 2
opt.ruler = true
-- opt.showcmd = false
opt.showmode = false
