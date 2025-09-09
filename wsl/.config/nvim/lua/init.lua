-- Lua-based configuration of NeoVim >=0.5
-- Sources:
-- https://github.com/wbthomason/dotfiles/tree/linux/neovim/.config/nvim
-- https://github.com/sunjon/dotfiles-1/blob/master/nvim

local init = function()
  require "plugins"  -- Loads packer commands with package configurations
  require "options"  -- Includes general commands for the behaviour of nvim
  require "keybinds" -- set the general keybindings
end

init() --> Load the confs


-- Extra configurations not applicable in a modular way
-- ...
