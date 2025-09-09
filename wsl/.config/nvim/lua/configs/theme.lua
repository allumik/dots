-- configurations for themes
local g = vim.g
-- TODO: make it change depending on the day cycle


-- Theming
g.wwdc17_frame_color = 0
g.modus_green_strings = 1
g.apprentice_contrast_dark = "hard"

-- require("github-theme").setup({
--   comment_style = 'italic',
--   keyword_style = 'italic',
--   theme_style = "dark",
--
--   hide_inactive_statusline = false,
--   sidebars = {"terminal", "packer"},
--   dark_sidebar = true,
--   dark_float = true
-- })

vim.cmd([[
  colorscheme apprentice

  highlight Comment cterm=italic gui=italic
  highlight clear LineNr
  highlight clear SignColumn
]])
