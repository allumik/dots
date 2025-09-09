-- confugration of lualine status

require("lualine").setup {
  options = {
    theme = "jellybeans", -- "papercolor_light", "jellybeans"
    section_separators = '',
    component_separators = '|',
  },
  sections = {
    lualine_a = {"location"},
    lualine_b = {"filename"},
    lualine_c = {"branch"},
    lualine_x = {"encoding", "fileformat"},
    lualine_y = {"filetype"},
    lualine_z = {"progress"}
  },
  inactive_sections = {
    lualine_a = {'location'},
    lualine_b = {'filename'},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
}
