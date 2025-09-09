-- configuration of lsp enables (lspconfig, saga)
local saga = require "lspsaga"
local lc = require "lspconfig"

-- start saga with defaults
saga.init_lsp_saga()

-- servers
-- https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
-- install python latex html yaml vim lua json bash tailwindcss haskell
require'lspinstall'.setup() -- important
local servers = require'lspinstall'.installed_servers()

for _, server in pairs(servers) do
  -- setup the servers with completion attach
  lc[server].setup{
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  }
end
