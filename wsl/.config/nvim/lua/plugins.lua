-- Plugin setup and import

-- bootstrapper
local fn = vim.fn
local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
  vim.cmd "packadd packer.nvim"
end


-- The plugins:
return require("packer").startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  -- Dependencies
  use "lewis6991/impatient.nvim"
  use "nvim-lua/popup.nvim" -- adds support ...
  use "nvim-lua/plenary.nvim" -- ... for the telescope plugin and others


  -- General
  use "famiu/bufdelete.nvim"
  use "justinmk/vim-gtfo"
  use "lambdalisue/suda.vim" -- sudo this file
  use "chaoren/vim-wordmotion" -- separate snakecase
  use "t9md/vim-choosewin" -- jump into windows without breaking them
  use "tpope/vim-rsi" -- make vim more emacs for that nice RSI feeling
  use "roxma/vim-tmux-clipboard" -- make tmux + neovim work by syncing the clipboards
  use "mechatroner/rainbow_csv"
  use { "kassio/neoterm", config = [[require("configs.neoterm")]] }
  use { "mbbill/undotree", cmd = "UndotreeToggle" } -- turn making mistakes into a system

  use {
    "junegunn/vim-easy-align",
    opt = false,
    config = [[vim.g.easy_align_delimiters = { 
      '>' = { 'pattern' = '>>\|=>\|>' },
      '<' = { 'pattern' = '<<\|=<\|<' },
      '~' = { 'pattern' = '~'}
    }]]
  }

  use {
    "luukvbaal/nnn.nvim",
    config = function()
      require("nnn").setup({
        picker = {
        	cmd = "nnn",       -- command override (-p flag is implied)
	       	style = {
			      width = 1,     -- width in percentage of the viewport
			      height = 0.4,    -- height in percentage of the viewport
			      xoffset = 1,   -- xoffset in percentage
			      -- yoffset = 0.5,   -- yoffset in percentage
			      border = "single"-- border decoration for example "rounded"(:h nvim_open_win)
		      },
    		  session = "local",      -- or "global" / "local" / "shared"
        },
        set_default_mappings = 0,
        replace_netrw = "picker",
      })
    end
  }

  use {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = [[require('configs.treesitter')]],
  }

  use {
    "folke/which-key.nvim",
    event = "BufWinEnter",
    config = [[require('configs.which-key')]],
  }

  use {
    "blackCauldron7/surround.nvim",
    config = function()
      require"surround".setup {mappings_style = "surround"}
    end
  }

  use {
    "nvim-telescope/telescope.nvim",
    requires = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-media-files.nvim",
      {
        "nvim-telescope/telescope-frecency.nvim",
        requires = "tami5/sql.nvim",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
      },
      {
        "nvim-telescope/telescope-arecibo.nvim",
        rocks = {"openssl", "lua-http-parser"}
      },
    },
    cmd = "Telescope",
    module = "telescope",
    config = [[require('configs.telescope')]],
  }


  -- Languages
  use {
    "mhartington/formatter.nvim",
    config = [[require('configs.formatter')]],
  }

  use {
    "neovim/nvim-lspconfig", -- LSP defaults
    opt = false,
    requires = { "glepnir/lspsaga.nvim", "kabouzeid/nvim-lspinstall" },
    config = [[require("configs.lsp")]],
  }

  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-vsnip",
      "rafamadriz/friendly-snippets"
    },
    config = [[require("configs.autocmp")]]
  }


use "rafamadriz/friendly-snippets"

  use {
    "jalvesaq/Nvim-R",
    branch = "stable",
    config = [[require("configs.nvimr")]]
  }


  -- Get git
  -- Magit for Neovim
  use {
    "TimUntersberger/neogit",
    opt = false,
    config = function ()
      require("neogit").setup {
        disable_signs = false,
        disable_context_highlighting = true,
        signs = {
          -- { CLOSED, OPENED }
          section = { "", "" },
          item = { "+", "-" },
          hunk = { "", "" },
        },
        integrations = {
          diffview = true
        }
      }
    end
  }


  -- Project Management/Sessions
  use {
    "dhruvasagar/vim-prosession",
    after = "vim-obsession",
    requires = { { "tpope/vim-obsession", cmd = "Prosession" } },
  }

  use {
    "kristijanhusak/orgmode.nvim",
    config = function()
          require('orgmode').setup{}
    end
  }


  -- Terminal
  use {
    "michaelb/sniprun",
    run = "bash ./install.sh",
    config = function()
      require("sniprun").setup({ display = { "VirtualTextOk", } })
    end
  }


  -- Cosmetics
  use {
    "adisen99/apprentice.nvim",
    requires = {"rktjmp/lush.nvim"},
    config = [[require("configs.theme")]]
  }

  use {
    'nvim-lualine/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = [[require("configs.statusline")]]
  }

  use {
    'yamatsum/nvim-nonicons',
    requires = {'kyazdani42/nvim-web-devicons'}
  }

  use {
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
  }

  use {
    "norcalli/nvim-colorizer.lua",
    config = [[require("colorizer").setup()]],
  }

  use {
    "folke/twilight.nvim",
    config = function()
      require("twilight").setup {
        alpha = 0.20, -- amount of dimming
      }
    end
  }
end)
