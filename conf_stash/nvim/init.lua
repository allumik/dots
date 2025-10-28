-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none', '--branch', 'stable',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })


-- Install plugins
local add = MiniDeps.add


-- Safely execute at startup
local now_setups = {
  function() require('mini.basics').setup() end, 
  function() require('mini.bracketed').setup() end, 
  function() require('mini.completion').setup() end,
  
  function() require('mini.icons').setup({ style = 'ascii' }) end,
  function() require('mini.statusline').setup({ use_icons = false }) end,
  function() require('mini.hipatterns').setup() end, 
  function() require('mini.cursorword').setup() end, 
  function() require('mini.indentscope').setup() end, 
  function() require('mini.starter').setup() end,
}

-- Safely execute lazily
local later_setups = {
  function() require('mini.bufremove').setup() end,
  function() require('mini.diff').setup() end,
  function() require('mini.files').setup() end,
  -- function() require('mini.git').setup() end,
  function() require('mini.sessions').setup() end,
  function() require('mini.visits').setup() end,

  function() require('mini.align').setup() end, 
  function() require('mini.move').setup() end, 
  function() require('mini.jump').setup() end, 
  function() require('mini.pairs').setup() end, 
  function() require('mini.surround').setup() end, 
  function() require('mini.clue').setup() end,
  function() require('mini.pick').setup() end,
  function() require('mini.notify').setup() end,
}

-- And call them
local now, later = MiniDeps.now, MiniDeps.later
for _, func in ipairs(now_setups) do now(func) end
for _, func in ipairs(later_setups) do later(func) end


-- Some configuration after all the setups
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.number = false
vim.opt.relativenumber = false
now(function() vim.cmd('colorscheme quiet') end)


-- TODO: Add keyboard shortcuts from the nix config
