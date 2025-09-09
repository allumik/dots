-- Keymaps
local opt = require('utils').opt
local map = require('utils').map
local silent = { silent = true }
local noremap = { noremap = true }
local def = { silent = true, noremap = true }

-- Korn - Follow the Leader (1998)
opt('g', {
      mapleader = [[ ]],
      maplocalleader = [[ c]],
})

-- disable ex mode
map("n", "Q", [[<Nop>]], noremap)

-- commands for changing working dir (wd)
vim.cmd([[command CwdHere cd %:h]])
map("n", "<leader>dh", [[:cd %:h<cr>]])

-- remap the exit strategy for terminal-mode
map("t", "<c-t><c-t>", [[<c-\><c-n>]])

-- dont't rebound after yanking
map("v", "y", "ygv<esc>")

-- paste from previous yank
map({"n", "v"}, "<leader>p", [["0p]])

-- show file info when not using modeline
map("n", "<leader>i", [[:f<cr>]])

-- some code navigation sensibilies for vim
-- NOTE: Don't map insert mode to move as zsh/alacritty should handle it
map("i", "<C-H>", "<C-W>", noremap)
map("i", "<C-BS>", "<C-W>", noremap)
map({"n", "v"}, "<c-right>", "e", noremap)
map({"n", "v"}, "<c-left>", "b", noremap)
map({"n", "v"}, "<c-l>", "e", noremap)
map({"n", "v"}, "<c-h>", "b", noremap)
map({"n", "v"}, "<c-down>", "}", noremap)
map({"n", "v"}, "<c-up>", "{", noremap)
map({"n", "v"}, "<c-j>", "}", noremap)
map({"n", "v"}, "<c-k>", "{", noremap)

-- think of buffer not as "b" but as "e" as in ~editor~
-- needed when using tmux
map("n", "<c-e><c-l>", ":bn<cr>")
map("n", "<c-e><c-h>", ":bp<cr>")
map("n", "<c-e><c-right>", ":bn<cr>")
map("n", "<c-e><c-left>", ":bp<cr>")

map("n", "<C-e><C-q>", ":Bdelete<cr>", silent)
map("n", "<leader>eq", ":Bdelete<cr>", silent)
map("n", "<leader>bq", ":Bdelete<cr>", silent)
map("n", "<leader>efq", ":Bdelete!<cr>", silent)

map("n", "<leader>qq", ":qa<cr>", silent)
map("n", "<leader>qr", [[:source $MYVIMRC<cr>]], silent)
map("n", "<leader>qf", ":qa!<cr>", silent)

-- make ctrl+windows work with arrows
map("n", "<C-w><C-right>", ":wincmd l<cr>", silent)
map("n", "<C-w><C-left>",  ":wincmd h<cr>", silent)
map("n", "<C-w><C-down>",  ":wincmd j<cr>", silent)
map("n", "<C-w><C-up>",    ":wincmd k<cr>", silent)

-- buffer mode
map("n", "<leader>e<right>", ":bn<cr>", silent)
map("n", "<leader>e<left>", ":bp<cr>", silent)
map("n", "<leader>el", ":bn<cr>", silent)
map("n", "<leader>eh", ":bp<cr>", silent)
map("n", "<leader>eq", ":Bdelete<cr>", silent)
map("n", "<leader>ez", [[:e $MYVIMRC<cr>]], silent)

-- window mode
-- let g:which_key_map.w = { 'name': '+window' }
map("n", "<leader>w<right>", ":wincmd l<cr>", silent)
map("n", "<leader>w<left>", ":wincmd h<cr>", silent)
map("n", "<leader>w<down>", ":wincmd j<cr>", silent)
map("n", "<leader>w<up>", ":wincmd k<cr>", silent)
map("n", "<leader>wl", ":wincmd l<cr>", silent)
map("n", "<leader>wh", ":wincmd h<cr>", silent)
map("n", "<leader>wj", ":wincmd j<cr>", silent)
map("n", "<leader>wk", ":wincmd k<cr>", silent)
map("n", "<leader>wL", ":wincmd L<cr>", silent)
map("n", "<leader>wH", ":wincmd H<cr>", silent)
map("n", "<leader>wJ", ":wincmd J<cr>", silent)
map("n", "<leader>wK", ":wincmd K<cr>", silent)
map("n", "<leader>w<S-right>", ":wincmd L<cr>", silent)
map("n", "<leader>w<S-left>", ":wincmd H<cr>", silent)
map("n", "<leader>w<S-down>", ":wincmd J<cr>", silent)
map("n", "<leader>w<S-up>", ":wincmd K<cr>", silent)
map("n", "<leader>wq", ":close<cr>", silent)
map("n", "<leader>ws", ":split<cr>", silent)
map("n", "<leader>wv", ":vsplit<cr>", silent)
map("n", "<leader>w=", ":wincmd =<cr>", silent)
map("n", "<leader>w<", ":wincmd <<cr>", silent)
map("n", "<leader>w>", ":wincmd ><cr>", silent)
map("n", "<leader>w+", ":wincmd +<cr>", silent)
map("n", "<leader>w-", ":wincmd -<cr>", silent)

-- tab navigation
map("n", "<leader>t<right>", ":tabNext<cr>", silent)
map("n", "<leader>t<left>", ":tabprevious<cr>", silent)
map("n", "<leader>tl", ":tabNext<cr>", silent)
map("n", "<leader>th", ":tabprevious<cr>", silent)
map("n", "<leader>tn", ":tabnew<cr>", silent)


-- EasyAlign
map({ "n", "x" }, "ga", ":EasyAlign<cr>")

-- Suda
-- save root files conviniently
-- if they are not opened automatically...
map("n", "<leader>sr", ":SudaRead<cr>", silent)
map("n", "<leader>sw", ":SudaWrite<cr>", silent)

-- going through windows
map("n", "<leader>ww", ":ChooseWin<cr>", silent)
map("n", "<leader>wW", ":ChooseWinSwap<cr>", silent)

-- Telescope
map("n", "<leader><leader>", [[:Telescope buffers<cr>]], silent)
map("n", "<leader>ff", [[:Telescope find_files<cr>]], silent)
map("n", "<leader>fr", [[:Telescope frecency<cr>]], silent)
map({ "n", "v" }, "<leader>fm", [[:Telescope media_files<cr>]], silent)
map({ "n", "v" }, "<leader>fh", [[:Telescope help_tags<cr>]], silent)
map({ "n", "v" }, "<leader>fc", [[:Telescope commands<cr>]], silent)
map({ "n", "v" }, [[<leader>f']], [[:Telescope registers<cr>]], silent)

-- find words to type
map("n", "<leader>sd", [[:Telescope live_grep<cr>]], silent)
map("n", "<leader>ss", [[:Telescope current_buffer_fuzzy_find<cr>]], silent)
map("n", "<c-s>", [[:Telescope current_buffer_fuzzy_find<cr>]], silent)


-- general convenience
-- undotree
map("n", "<leader>ut", ":UndotreeToggle<cr>", silent)
-- ma... *khm-khm* neogit
map("n", "<leader>og", ":Neogit<cr>", silent)


-- Other terminal goodness
-- navigation shortcuts
-- map("n", "<leader>or", [[:RnvimrToggle<cr>]], silent)
-- map("t", "<leader>or", [[<C-\><C-n>:RnvimrToggle<cr>]], silent)
map("n", "<leader>oR", [[:NnnExplorer %:p:h<cr>]], silent)
map("n", "<leader>or", [[:NnnPicker<cr>]], silent)
map("n", "<leader>otv", ":vertical Topen<cr>", def)
map("n", "<leader>ots", ":rightbelow Topen<cr>", def)
map("n", "<leader>otn", ":Tnew<cr>", def)


-- Neovim REPL support
--"gv<esc" at the end quarantees that you won't rebound to the end
map("n", "<leader>rr", ":TREPLSendSelection<cr>gv<esc>", def)
map("n", "<leader>re", ":TREPLSendFile<cr>", def)
--" Send selected contents in visual mode."
map("x", "<leader>rr", ":TREPLSendSelection<cr>gv<esc>", def)
map("x", "<leader>re", ":TREPLSendFile<cr>", def)
--" Send line in normal.
map("n", "<leader>rl", ":TREPLSendSelection<cr>gv<esc>", def)


-- Sniprun
map({"n", "x"}, "<leader>rs", ":Sniprun", def)


-- LSP setup
-- lsp provider to find the cursor word definition and reference
map("n", "<leader>hf", [[:Lspsaga lsp_finder<CR>]], silent)
map("n", "<leader>hd", [[:Lspsaga hover_doc<CR>]], silent)
map("n", "<leader>hs", [[:Lspsaga signature_help<CR>]], silent)
map("n", "<leader>hp", [[:Lspsaga preview_definition<CR>]], silent)
-- scroll down hover doc or scroll in definition preview
map("n", "<c-p>", [[<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>]], silent)
-- scroll up hover doc
map("n", "<c-n>", [[<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>]], silent)
-- Use <Tab> and <S-Tab> to navigate through popup menu
map("i", "<tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], {expr = true, noremap = false})
map("i", "<S-tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], {expr = true, noremap = false})

-- vsnip
map("n", "<C-j>", "vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'", {expr = true})
map("i", "<C-j>", "vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'", {expr = true})
