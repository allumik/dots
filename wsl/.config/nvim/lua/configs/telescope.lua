local telescope = require 'telescope'
local actions = require 'telescope.actions'

local previewers = require('telescope.previewers')

local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}

  filepath = vim.fn.expand(filepath)
  vim.loop.fs_stat(filepath, function(_, stat)
    if not stat then return end
    if stat.size > 100000 then
      return
    else
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
    end
  end)
end

telescope.setup {
  defaults = {
    buffer_previewer_maker = new_maker,
    layout_strategy = 'bottom_pane',
    sorting_strategy = 'ascending',
    scroll_strategy = 'cycle',
    dynamic_preview_title = true,
    -- border = false,
    borderchars = { "─", " ", "─", " ", "─", "─", "─", "─" },
    prompt_prefix = ' λ ~ ',
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '-u' -- hidden files
    },
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
    },
  },
  extensions = {
    frecency = {
      show_unindexed  = true,
      ignore_patterns = { "*.git/*", "*/tmp/*" },
      workspaces = { git = '/home/allu/git' }
    },
    fzf = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
    media_files = {
      filetypes = { "png", "webp", "jpg", "jpeg", "pdf", "mkv" },
      find_cmd  = "rg",
    },
    arecibo = {
      ["selected_engine"]   = "duckduckgo",
      ["url_open_command"]  = "xdg-open",
      ["show_http_headers"] = false,
      ["show_domain_icons"] = true,
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      previewer = false,
    },
    find_files = {
      file_ignore_patterns = { ".git", ".gitignore"},
    },
  },
}

-- Extensions
telescope.load_extension 'frecency'
telescope.load_extension 'fzf'
telescope.load_extension 'arecibo'
telescope.load_extension 'media_files'

