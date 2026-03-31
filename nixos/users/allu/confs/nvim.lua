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
add({ source = 'jpalardy/vim-slime' })
add({ source = 'serenevoid/kiwi.nvim' })
add({ source = 'yousefhadder/markdown-plus.nvim' })

-- Safely execute at startup
local now_setups = {
  function() vim.cmd('colorscheme minischeme') end,
  function() require('mini.basics').setup() end, 
  function() require('mini.bracketed').setup() end, 
  
  -- use ascii so that it works with anything
  function() require('mini.icons').setup({ style = 'ascii' }) end,
  function() require('mini.statusline').setup({ use_icons = false }) end,
  function() require('mini.starter').setup() end,
}

-- Safely execute lazily
local later_setups = {
  function() require('mini.completion').setup() end,
  function() require('mini.hipatterns').setup() end, 
  function() require('mini.cursorword').setup() end, 
  function() require('mini.indentscope').setup() end, 
  function() require('mini.bufremove').setup() end,
  function() require('mini.diff').setup() end,
  function() require('mini.files').setup() end,
  function() require('mini.git').setup() end,
  function() require('mini.sessions').setup() end,
  function() require('mini.visits').setup() end,

  function() require('mini.align').setup() end, 
  function()
    require('mini.move').setup({
      mappings = {
        up = '<M-<Up>>',
        down = '<M-<Down>>',
        left = '<M-<Left>>',
        right = '<M-<Right>>',
        line_left = '<M-<Left>>',
        line_right = '<M-<Right>>',
        line_down = '<M-<Down>>',
        line_up = '<M-<Up>>',
      }
    })
  end, 
  function() require('mini.jump').setup({ mappings = { forward_till = '', backward_till = '', } }) end, 
  function() require('mini.pairs').setup({ markdown = true, skip_unbalanced = true }) end, 
  function() require('mini.surround').setup({ respect_selection_type = true, }) end, 
  function()
    require('mini.clue').setup({
      triggers = 
        { mode = 'n', keys = '<leader>' },
        { mode = 'x', keys = '<leader>' },
        { mode = 'n', keys = '<C-k>' },
        { mode = 'x', keys = '<C-k>' },
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
    })
  end,
  function() require('mini.pick').setup() end,
  function() require('mini.notify').setup() end,
  function() 
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function() require('markdown-plus').setup() end,
  }) end,
  function() require('kiwi').setup({{ name = "notes", path = "/home/allu/Documents/Notes/notes" }}) end,
}

-- And call them
local now, later = MiniDeps.now, MiniDeps.later
for _, func in ipairs(now_setups) do now(func) end
for _, func in ipairs(later_setups) do later(func) end

-- Some configuration after all the setups
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.clipboard = "unnamedplus"
vim.opt.number = false
vim.opt.relativenumber = false
vim.g.markdown_fenced_languages = { 
  "ts=typescript", "python", "bash", "zsh", "lua", "r", "java", "kotlin", "nix"
}

-- Plugin configurations
vim.g.slime_target = "zellij"
vim.g.slime_bracketed_paste = 1
vim.g.slime_no_mappings = 1
vim.g.slime_dont_ask_default = 1
vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }

-- Keyboard shortcuts
local map = vim.keymap.set

map('n', '<leader>ff', ':Pick files<cr>', { silent = true })
map('n', '<leader>fo', ':lua MiniFiles.open()<cr>', { silent = true })
map('n', '<leader> ',  ':Pick commands<cr>', { silent = true })
map('n', '<leader>fr', ':Pick oldfiles<cr>', { silent = true })
map('n', '<leader>s',  ':Pick buf_lines<cr>', { silent = true })
map('n', '<leader>fs', ':Pick grep_live<cr>', { silent = true })
map('n', '<leader>b',  ':Pick buffers<cr>', { silent = true })
map('n', '<leader>"',  ':Pick registers<cr>', { silent = true })

map('x', '<leader>ts', ':<c-u>call slime#send_op(visualmode(), 1)<cr>', { silent = true })
map('n', '<leader>tc', ':<c-u>call slime#send_cell()<cr>', { silent = true })

map('n', '<leader>nn', ':lua require("kiwi").open_wiki_index("notes")<cr>', { silent = true })
map('n', '<C-k>t',     ':lua require("kiwi").todo.toggle()<cr>', { silent = true })
