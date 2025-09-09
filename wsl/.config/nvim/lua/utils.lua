local cmd = vim.cmd
local map_key = vim.api.nvim_set_keymap

-- NOTE: DEBUG
P = function(stuff)
  print(vim.inspect(stuff))
end

-- vim.o: behaves like :set
-- vim.go: behaves like :setglobal
-- vim.bo: behaves like :setlocal for buffer-local options
-- vim.wo: behaves like :setlocal for window-local options
local function opt(locality, options)
  local scopes = { o = vim.o, b = vim.bo, g = vim.g, w = vim.wo, go = vim.go}
  local scope = scopes[locality]
  for key, value in pairs(options) do
    scope[key] = value
  end
end

local function autocmd(group, cmds, clear)
  clear = clear == nil and false or clear
  if type(cmds) == 'string' then cmds = {cmds} end
  cmd('augroup ' .. group)
  if clear then cmd [[au!]] end
  for _, c in ipairs(cmds) do
    cmd('autocmd ' .. c)
  end
  cmd [[augroup END]]
end

local function map(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  if type(modes) == 'string' then modes = {modes} end
  for _, mode in ipairs(modes) do
    map_key(mode, lhs, rhs, opts)
  end
end

-- helper for defining highlight groups
local set_hl = function(group, opts)
  local bg     = opts.bg == nil and "" or "guibg=" .. opts.bg
  local fg     = opts.fg == nil and "" or "guifg=" .. opts.fg
  local gui    = opts.gui == nil and "" or "gui=" .. opts.gui
  local guisp  = opts.guisp == nil and "" or "guisp=" .. opts.guisp
  local link   = opts.link or false

  if not link then
    vim.cmd(string.format("hi %s %s %s %s %s", group, bg, fg, gui, guisp))
  else
    vim.cmd(string.format("hi! link %s %s", group, link))
  end
end

return {opt = opt, autocmd = autocmd, map = map, set_hl = set_hl}
