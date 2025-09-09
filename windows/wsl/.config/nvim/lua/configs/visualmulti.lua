-- visual multi settings
local cmd = vim.cmd

cmd([[
let g:VM_mouse_mappings = 1
let g:VM_leader = '<leader>m'

let g:VM_maps = {}
let g:VM_maps['Add Cursor Down'] = '<M-Down>'
let g:VM_maps['Add Cursor Up'] = '<M-Up>'
let g:VM_maps['Add Cursor At Pos'] = '<M-Enter>'
let g:VM_maps['Mouse Cursor'] = '<M-LeftMouse>'
let g:VM_maps['Mouse Column'] = '<M-RightMouse>'
]])
