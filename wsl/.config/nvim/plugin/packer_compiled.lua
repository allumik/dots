-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/allu/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/allu/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/allu/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/allu/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/allu/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Nvim-R"] = {
    config = { 'require("configs.nvimr")' },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/Nvim-R"
  },
  ["apprentice.nvim"] = {
    config = { 'require("configs.theme")' },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/apprentice.nvim"
  },
  ["bufdelete.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/bufdelete.nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp"
  },
  ["cmp-vsnip"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/cmp-vsnip"
  },
  ["formatter.nvim"] = {
    config = { "require('configs.formatter')" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/formatter.nvim"
  },
  ["friendly-snippets"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/friendly-snippets"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["impatient.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/impatient.nvim"
  },
  ["lspsaga.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/lspsaga.nvim"
  },
  ["lualine.nvim"] = {
    config = { 'require("configs.statusline")' },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/lualine.nvim"
  },
  ["lush.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/lush.nvim"
  },
  neogit = {
    config = { "\27LJ\2\2ß\1\0\0\4\0\14\0\0176\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\3\0005\2\5\0005\3\4\0=\3\6\0025\3\a\0=\3\b\0025\3\t\0=\3\n\2=\2\v\0015\2\f\0=\2\r\1B\0\2\1K\0\1\0\17integrations\1\0\1\rdiffview\2\nsigns\thunk\1\3\0\0\5\5\titem\1\3\0\0\6+\6-\fsection\1\0\0\1\3\0\0\bïƒš\bïƒ—\1\0\2\18disable_signs\1!disable_context_highlighting\2\nsetup\vneogit\frequire\0" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/neogit"
  },
  neoterm = {
    config = { 'require("configs.neoterm")' },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/neoterm"
  },
  ["nnn.vim"] = {
    config = { "\27LJ\2\2µ\1\0\0\4\0\b\0\v6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\3\0005\2\5\0005\3\4\0=\3\6\2=\2\a\1B\0\2\1K\0\1\0\vlayout\vwindow\1\0\0\1\0\3\fyoffset\3\1\vheight\4š³æÌ\t™³æþ\3\nwidth\3\1\1\0\3\fsession\nlocal\25set_default_mappings\3\0\18replace_netrw\3\1\nsetup\bnnn\frequire\0" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nnn.vim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\2<\0\0\2\0\3\0\0066\0\0\0'\1\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nvim-autopairs"
  },
  ["nvim-cmp"] = {
    config = { 'require("configs.autocmp")' },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    config = { 'require("colorizer").setup()' },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua"
  },
  ["nvim-lspconfig"] = {
    config = { 'require("configs.lsp")' },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-lspinstall"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nvim-lspinstall"
  },
  ["nvim-nonicons"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nvim-nonicons"
  },
  ["nvim-treesitter"] = {
    config = { "require('configs.treesitter')" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["orgmode.nvim"] = {
    config = { "\27LJ\2\0029\0\0\2\0\3\0\a6\0\0\0'\1\1\0B\0\2\0029\0\2\0004\1\0\0B\0\2\1K\0\1\0\nsetup\forgmode\frequire\0" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/orgmode.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  rainbow_csv = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/rainbow_csv"
  },
  sniprun = {
    config = { "\27LJ\2\2^\0\0\3\0\6\0\t6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\4\0005\2\3\0=\2\5\1B\0\2\1K\0\1\0\fdisplay\1\0\0\1\2\0\0\18VirtualTextOk\nsetup\fsniprun\frequire\0" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/sniprun"
  },
  ["sql.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/sql.nvim"
  },
  ["suda.vim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/suda.vim"
  },
  ["surround.nvim"] = {
    config = { "\27LJ\2\2U\0\0\2\0\4\0\a6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\3\0B\0\2\1K\0\1\0\1\0\1\19mappings_style\rsurround\nsetup\rsurround\frequire\0" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/surround.nvim"
  },
  ["telescope-arecibo.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/telescope-arecibo.nvim"
  },
  ["telescope-frecency.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/telescope-frecency.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim"
  },
  ["telescope-media-files.nvim"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/telescope-media-files.nvim"
  },
  ["telescope.nvim"] = {
    commands = { "Telescope" },
    config = { "require('configs.telescope')" },
    loaded = false,
    needs_bufread = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/opt/telescope.nvim"
  },
  ["twilight.nvim"] = {
    config = { "\27LJ\2\2N\0\0\2\0\4\0\a6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\3\0B\0\2\1K\0\1\0\1\0\1\nalpha\4š³æÌ\t™³¦þ\3\nsetup\rtwilight\frequire\0" },
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/twilight.nvim"
  },
  undotree = {
    commands = { "UndotreeToggle" },
    loaded = false,
    needs_bufread = false,
    path = "/home/allu/.local/share/nvim/site/pack/packer/opt/undotree"
  },
  ["vim-choosewin"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/vim-choosewin"
  },
  ["vim-easy-align"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/vim-easy-align"
  },
  ["vim-gtfo"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/vim-gtfo"
  },
  ["vim-obsession"] = {
    after = { "vim-prosession" },
    commands = { "Prosession" },
    loaded = false,
    needs_bufread = false,
    path = "/home/allu/.local/share/nvim/site/pack/packer/opt/vim-obsession"
  },
  ["vim-prosession"] = {
    load_after = {
      ["vim-obsession"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/allu/.local/share/nvim/site/pack/packer/opt/vim-prosession"
  },
  ["vim-rsi"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/vim-rsi"
  },
  ["vim-tmux-clipboard"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/vim-tmux-clipboard"
  },
  ["vim-vsnip"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/vim-vsnip"
  },
  ["vim-wordmotion"] = {
    loaded = true,
    path = "/home/allu/.local/share/nvim/site/pack/packer/start/vim-wordmotion"
  },
  ["which-key.nvim"] = {
    config = { "require('configs.which-key')" },
    loaded = false,
    needs_bufread = false,
    path = "/home/allu/.local/share/nvim/site/pack/packer/opt/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
local module_lazy_loads = {
  ["^telescope"] = "telescope.nvim"
}
local lazy_load_called = {['packer.load'] = true}
local function lazy_load_module(module_name)
  local to_load = {}
  if lazy_load_called[module_name] then return nil end
  lazy_load_called[module_name] = true
  for module_pat, plugin_name in pairs(module_lazy_loads) do
    if not _G.packer_plugins[plugin_name].loaded and string.match(module_name, module_pat) then
      to_load[#to_load + 1] = plugin_name
    end
  end

  if #to_load > 0 then
    require('packer.load')(to_load, {module = module_name}, _G.packer_plugins)
    local loaded_mod = package.loaded[module_name]
    if loaded_mod then
      return function(modname) return loaded_mod end
    end
  end
end

if not vim.g.packer_custom_loader_enabled then
  table.insert(package.loaders, 1, lazy_load_module)
  vim.g.packer_custom_loader_enabled = true
end

-- Config for: surround.nvim
time([[Config for surround.nvim]], true)
try_loadstring("\27LJ\2\2U\0\0\2\0\4\0\a6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\3\0B\0\2\1K\0\1\0\1\0\1\19mappings_style\rsurround\nsetup\rsurround\frequire\0", "config", "surround.nvim")
time([[Config for surround.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
require('configs.treesitter')
time([[Config for nvim-treesitter]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
require("configs.autocmp")
time([[Config for nvim-cmp]], false)
-- Config for: orgmode.nvim
time([[Config for orgmode.nvim]], true)
try_loadstring("\27LJ\2\0029\0\0\2\0\3\0\a6\0\0\0'\1\1\0B\0\2\0029\0\2\0004\1\0\0B\0\2\1K\0\1\0\nsetup\forgmode\frequire\0", "config", "orgmode.nvim")
time([[Config for orgmode.nvim]], false)
-- Config for: Nvim-R
time([[Config for Nvim-R]], true)
require("configs.nvimr")
time([[Config for Nvim-R]], false)
-- Config for: apprentice.nvim
time([[Config for apprentice.nvim]], true)
require("configs.theme")
time([[Config for apprentice.nvim]], false)
-- Config for: neogit
time([[Config for neogit]], true)
try_loadstring("\27LJ\2\2ß\1\0\0\4\0\14\0\0176\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\3\0005\2\5\0005\3\4\0=\3\6\0025\3\a\0=\3\b\0025\3\t\0=\3\n\2=\2\v\0015\2\f\0=\2\r\1B\0\2\1K\0\1\0\17integrations\1\0\1\rdiffview\2\nsigns\thunk\1\3\0\0\5\5\titem\1\3\0\0\6+\6-\fsection\1\0\0\1\3\0\0\bïƒš\bïƒ—\1\0\2\18disable_signs\1!disable_context_highlighting\2\nsetup\vneogit\frequire\0", "config", "neogit")
time([[Config for neogit]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
require("colorizer").setup()
time([[Config for nvim-colorizer.lua]], false)
-- Config for: neoterm
time([[Config for neoterm]], true)
require("configs.neoterm")
time([[Config for neoterm]], false)
-- Config for: twilight.nvim
time([[Config for twilight.nvim]], true)
try_loadstring("\27LJ\2\2N\0\0\2\0\4\0\a6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\3\0B\0\2\1K\0\1\0\1\0\1\nalpha\4š³æÌ\t™³¦þ\3\nsetup\rtwilight\frequire\0", "config", "twilight.nvim")
time([[Config for twilight.nvim]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
require("configs.statusline")
time([[Config for lualine.nvim]], false)
-- Config for: sniprun
time([[Config for sniprun]], true)
try_loadstring("\27LJ\2\2^\0\0\3\0\6\0\t6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\4\0005\2\3\0=\2\5\1B\0\2\1K\0\1\0\fdisplay\1\0\0\1\2\0\0\18VirtualTextOk\nsetup\fsniprun\frequire\0", "config", "sniprun")
time([[Config for sniprun]], false)
-- Config for: nnn.vim
time([[Config for nnn.vim]], true)
try_loadstring("\27LJ\2\2µ\1\0\0\4\0\b\0\v6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\3\0005\2\5\0005\3\4\0=\3\6\2=\2\a\1B\0\2\1K\0\1\0\vlayout\vwindow\1\0\0\1\0\3\fyoffset\3\1\vheight\4š³æÌ\t™³æþ\3\nwidth\3\1\1\0\3\fsession\nlocal\25set_default_mappings\3\0\18replace_netrw\3\1\nsetup\bnnn\frequire\0", "config", "nnn.vim")
time([[Config for nnn.vim]], false)
-- Config for: formatter.nvim
time([[Config for formatter.nvim]], true)
require('configs.formatter')
time([[Config for formatter.nvim]], false)
-- Config for: nvim-autopairs
time([[Config for nvim-autopairs]], true)
try_loadstring("\27LJ\2\2<\0\0\2\0\3\0\0066\0\0\0'\1\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0", "config", "nvim-autopairs")
time([[Config for nvim-autopairs]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
require("configs.lsp")
time([[Config for nvim-lspconfig]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Telescope lua require("packer.load")({'telescope.nvim'}, { cmd = "Telescope", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndotreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndotreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Prosession lua require("packer.load")({'vim-obsession'}, { cmd = "Prosession", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufWinEnter * ++once lua require("packer.load")({'which-key.nvim'}, { event = "BufWinEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
