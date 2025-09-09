{ config, lib, pkgs, ... }:

# don't forget to set the env vars
# and import the nixvim module
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    globals = {
      # Disable useless providers
      loaded_ruby_provider = 0;
      loaded_perl_provider = 0;
      loaded_node_provider = 0;

      mapleader = " ";
      maplocalleader = "\\";
    };

    colorscheme = "quiet"; # this is for the builtin colorschemes
    # colorschemes.modus.enable = true; # this is for the non-standard colorschemes

    keymaps = [
      { mode = ["n"]; key = "<leader>ff"; action = ":Pick files<cr>"; } # use pick files instead
      { mode = ["n"]; key = "<leader>fo"; action = ":lua MiniFiles.open()<cr>"; } # use directory open instead
      { mode = ["n"]; key = "<leader> "; action = ":Pick commands<cr>"; } # use pick files instead
      { mode = ["n"]; key = "<leader>fr"; action = ":Pick oldfiles<cr>"; }
      { mode = ["n"]; key = "<leader>s"; action = ":Pick buf_lines<cr>"; }
      { mode = ["n"]; key = "<leader>fs"; action = ":Pick grep_live<cr>"; }
      { mode = ["n"]; key = "<leader>b"; action = ":Pick buffers<cr>"; }
      { mode = ["n"]; key = "<leader>\""; action = ":Pick registers<cr>"; }
      { mode = ["x"]; key = "<leader>ts"; action = ":<c-u>call slime#send_op(visualmode(), 1)<cr>"; }
      { mode = ["n"]; key = "<leader>tc"; action = ":<c-u>call slime#send_cell()<cr>"; }
      { mode = ["n"]; key = "<leader>nn"; action = ":lua require(\"kiwi\").open_wiki_index(\"notes\")<cr>"; }
      { mode = ["n"]; key = "<C-k>t"; action = ":lua require(\"kiwi\").todo.toggle()<cr>"; }
    ];

    opts = {
      updatetime = 100; # Faster completion

      # Line numbers
      relativenumber = false; # Relative line numbers
      number = false; # Display the absolute line number of the current line
      hidden = false; # Keep closed buffer open in the background
      mouse = "a"; # Enable mouse control
      mousemodel = "extend"; # Mouse right-click extends the current selection
      splitbelow = true; # A new window is put below the current one
      splitright = true; # A new window is put right of the current one

      # operations
      swapfile = false; # Disable the swap file
      modeline = true; # Tags such as 'vim:ft=sh'
      modelines = 100; # Sets the type of modelines
      undofile = true; # Automatically save and restore undo history
      incsearch = true; # Incremental search: show match for partly typed search command
      inccommand = "split"; # Search and replace: preview changes in quickfix list
      ignorecase = true; # When the search query is lower-case, match both lower and upper-case

      # patterns
      smartcase = true; # Override the 'ignorecase' option if the search pattern contains upper

      # case characters
      scrolloff = 8; # Number of screen lines to show around the cursor
      cursorline = false; # Highlight the screen line of the cursor
      cursorcolumn = false; # Highlight the screen column of the cursor
      signcolumn = "yes"; # Whether to show the signcolumn
      laststatus = 3; # When to use a status line for the last window
      fileencoding = "utf-8"; # File-content encoding for the current buffer
      termguicolors = true; # Enables 24-bit RGB color in the |TUI|
      spell = false; # Highlight spelling mistakes (local to window)
      wrap = false; # Prevent text from wrapping

      # Tab options
      tabstop = 2; # Number of spaces a <Tab> in the text stands for (local to buffer)
      shiftwidth = 2; # Number of spaces used for each step of (auto)indent (local to buffer)
      expandtab = true; # Expand <Tab> to spaces in Insert mode (local to buffer)
      autoindent = true; # Do clever autoindenting

      textwidth = 0; # Maximum width of text that is being inserted.  A longer line will be

      # Folding
      foldlevel = 299; # Folds with a level higher than this number will be closed
    };

    clipboard = {
      # Use system clipboard
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    luaLoader.enable = true;
    performance.byteCompileLua = {
      enable = true;
      configs = true;
      initLua = true;
      nvimRuntime = true;
      plugins = true;
    };

    plugins = {
      lz-n.enable = true;
      vim-slime = {
        enable = true;
        settings = {
          target = "tmux";
          bracketed_paste = 1;
          no_mappings = 1; # don't use the emacsian default
          dont_ask_default = 1; # use the following defaults
          default_config = {
            socket_name = "default";
            target_pane = "{last}";
          };
        };
      };
      mini = {
        enable = true;
        modules = {
          ai = {}; # this is not AI, its to extend and create a/i textobjects
          basics = {};
          bracketed = {};
          completion = {};
          # disable the t mappings, don't know what they do...
          jump = { mappings = { forward_till = ""; backward_till = "";}; };
          pick = {};
          extra = {}; # adds to `pick`, `jump` and some others
          icons = { style = "ascii"; };
          statusline = { use_icons = false; };
          hipatterns = {};
          cursorword = {};
          indentscope = {};
          starter = {};
          bufremove = {};
          diff = {};
          files = {};
          git = {};
          sessions = {};
          visits = {};
          align = {};
          move = {
            mapping = {
              up = "<M-<Up>>";
              down = "<M-<Down>>";
              left = "<M-<Left>>";
              right = "<M-<Right>>";
              line_left = "<M-<Left>>";
              line_right = "<M-<Right>>";
              line_down = "<M-<Down>>";
              line_up = "<M-<Up>>";
            };
          };
          surround = {};
          pairs = {
              markdown = true;
              skip_unbalanced = true;
          };
          notify = {};
          clue = {  
            triggers = [
              # Leader triggers
              { mode = "n"; keys = "<leader>"; } { mode = "x"; keys = "<leader>"; }
              { mode = "n"; keys = "<C-k>"; } { mode = "x"; keys = "<C-k>"; }

              # `g` key
              { mode = "n"; keys = "g"; } { mode = "x"; keys = "g"; }
              ];
          };
        };
      };
    };

    ## Don't forget to configure it too in extraConfigLua
    extraPlugins = with pkgs.vimUtils; [
      (buildVimPlugin {
        name = "kiwi.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "serenevoid";
          repo = "kiwi.nvim";
          rev = "40f32ad364b5c432b1b6102bf771051b2cb2ffcc";
          sha256 = "BgqqXObH4SWotRPXtfcXfZuahjDzR8qQ1x5us7cIAD0=";
        };
      })
    ];

    ## You've got more to say???
    extraConfigLua = ''
      require('kiwi').setup({{ name = "notes", path = "/home/allu/Documents/Notes/notes" }})
    '';

  };
}
