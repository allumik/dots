-- INIT
-- Minimal monolithic configuration for minimal neovim
-- Divided into headless and full modes
-- For main chapters: 1. Setup 2. Plugins and Configuration 3. Keybinds


-- SETUP

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

-- Set up 'mini.deps'
require('mini.deps').setup({ path = { package = path_package } })

local add = MiniDeps.add
local in_vscode = vim.g.vscode ~= nil
-- add other headlessnesses here
local headless = in_vscode

-- for some plugins, add lazyloading
local now_setups = {}
local later_setups = {}


-- PLUGINS & CONFIGURATION

if headless then
  -- Core modules safe for headless execution
  now_setups = {
    function() require('mini.basics').setup() end,
    function() require('mini.bracketed').setup() end,
  }
  
  later_setups = {
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
  }
else
  -- Standard configurations for terminal usage
  add({ source = 'jpalardy/vim-slime' })
  add({ source = 'yousefhadder/markdown-plus.nvim' })
  now_setups = {
    function() 
      vim.cmd('colorscheme default')
      -- set Visual mode to have a distinct background
      vim.api.nvim_set_hl(0, "Visual", { bg = "none", fg = "none", strikethrough = true })
      -- remove highlights from indentation, statusline etc
      local highlights = { "Normal", "NormalFloat", "SignColumn", "StatusLine" }
      for _, group in ipairs(highlights) do
        vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
      end
      -- add underlines to menu selection highlights, works with all colors
      local selection_groups = { "PmenuSel", "WildMenu", "TelescopeSelection", "FzfLuaSelection", "MiniPickMatchCurrent" }
      for _, group in ipairs(selection_groups) do
        vim.api.nvim_set_hl(0, group, { underline = true })
      end
    end,
    function() require('mini.basics').setup() end,
    function() require('mini.bracketed').setup() end,
    function() require('mini.icons').setup({ style = 'ascii' }) end,
    function() require('mini.statusline').setup({ use_icons = false }) end,
    function() require('mini.starter').setup() end,
  }

  later_setups = {
    function() require('mini.completion').setup() end,
    function() require('mini.hipatterns').setup() end,
    function() require('mini.indentscope').setup() end,
    function() require('mini.bufremove').setup() end,
    function() require('mini.diff').setup() end,
    function() require('mini.files').setup() end,
    function()
      if vim.fn.executable('git') == 1 then
        require('mini.git').setup()
      end
    end,
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
        triggers = {
          { mode = 'n', keys = '<leader>' },
          { mode = 'x', keys = '<leader>' },
          { mode = 'n', keys = '<C-k>' },
          { mode = 'x', keys = '<C-k>' },
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },
        }
      })
    end,
    function() require('mini.pick').setup() end,
    function() require('mini.extra').setup() end,
    function() require('mini.notify').setup() end,
    function() 
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function() require('markdown-plus').setup() end,
      }) 
    end
  }
end

-- load those modules now via mini.deps execution windows
local now, later = MiniDeps.now, MiniDeps.later
for _, func in ipairs(now_setups) do now(func) end
for _, func in ipairs(later_setups) do later(func) end


-- KEYBINDS

-- options shared across headless and full environments
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.clipboard = "unnamedplus"
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.gdefault = true

local map = vim.keymap.set

-- need to remap some vscode-specific things
if in_vscode then
  local vscode = require('vscode')

  -- Remap undo to host IDE to preserve buffer sync
  -- Might not be necessary, test it
  -- map('n', 'u', function() vscode.action('undo') end, { silent = true })

  -- Window split and layout management
  map('n', '<leader>wv', function() vscode.action('workbench.action.splitEditor') end, { silent = true })
  map('n', '<leader>ws', function() vscode.action('workbench.action.splitEditorOrthogonal') end, { silent = true })
  map('n', '<leader>wb', function() vscode.action('workbench.action.toggleSidebarVisibility') end, { silent = true })
  map('n', '<leader>wq', function() vscode.action('workbench.action.closeActiveEditor') end, { silent = true })
  map('n', '<leader>w=', function() vscode.action('workbench.action.evenEditorWidths') end, { silent = true })

  -- Contextual tools and inputs
  map('n', '<leader>ot', function() vscode.action('workbench.action.terminal.new') end, { silent = true })
  map('n', '<leader>is', function() vscode.action('editor.action.insertSnippet') end, { silent = true })

  -- Custom extension integrations
  map('n', '<leader>ss', function() vscode.action('fuzzySearch.activeTextEditor') end, { silent = true })
  map('x', '<leader>ss', function() vscode.action('fuzzySearch.activeTextEditorWithCurrentSelection') end, { silent = true })
else
  -- standalone configuration variables
  vim.opt.termguicolors = false
  vim.g.markdown_fenced_languages = { 
    "ts=typescript", "python", "bash", "zsh", "lua", "r", "java", "kotlin", "nix"
  }

  vim.g.slime_target = "tmux"
  vim.g.slime_bracketed_paste = 1
  vim.g.slime_no_mappings = 1
  vim.g.slime_dont_ask_default = 1
  vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }

  -- netrw as a simple file tree sidebar (used by tmux's golden-ratio layout)
  vim.g.netrw_banner = 0
  vim.g.netrw_liststyle = 3
  vim.g.netrw_winsize = 25

  -- blank out the netrw window's statusline (window-local, so the nvim
  -- buffer split next to it keeps mini.statusline's normal content)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function() vim.wo.statusline = ' ' end,
  })

  -- Native picker shortcuts
  map('n', '<leader>ff', ':Pick files<cr>', { silent = true })
  map('n', '<leader>fo', ':lua MiniFiles.open()<cr>', { silent = true })
  map('n', '<leader>fe', ':Lexplore<cr>', { silent = true })
  map('n', '<leader>fr', ':Pick oldfiles<cr>', { silent = true })
  map('n', '<leader>fs', ':Pick grep_live<cr>', { silent = true })
  map('n', '<leader> ',  ':Pick commands<cr>', { silent = true })
  map('n', '<leader>s',  ':Pick buf_lines<cr>', { silent = true })
  map('n', '<leader>b',  ':Pick buffers<cr>', { silent = true })
  map('n', '<leader>"',  ':Pick registers<cr>', { silent = true })

  map('x', '<leader>ts', '<Plug>SlimeRegionSend', { silent = true })
  map('n', '<leader>ts', '<Plug>SlimeParagraphSend', { silent = true })
end
