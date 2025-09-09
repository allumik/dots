-- nvim-R
local g = vim.g

-- require("utils").autocmd("rmarkdown", { [[BufRead,BufNewFile *.rmd set filetype=rmarkdown]] })

g.R_assign = 0 -- don't add the <- automatically
g.R_close_term = 1 -- try to not close it, might fix the issues
g.R_nvim_wd = 1 -- make R's working directory the same as vim
g.R_app = "radian"
g.R_cmd = "R"
g.R_hl_term = 0
-- g.rrst_syn_hl_chunk = 0
-- g.rmd_syn_hl_chunk = 0 -- disable rmd code highlight
g.R_args = [[--vanilla]]
g.R_bracketed_paste = 1
g.R_path = "~/R/"
g.R_pdfviewer = "evince"
