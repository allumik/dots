">>--------------------------------------------------------------------------------------------<<"
">>> "Eat and work like it is your guilty pleasure, spend the free time like it is your work" <<<"
">>--------------------------------------------------------------------------------------------<<"

" neovide configuration
if exists('g:neovide')
  let neovide_remember_window_size=v:true
  let g:neovide_input_use_logo=v:false
  set guifont=Iosevka\ Term\ SS08:h15
endif

"run lua configuration if nvim > 0.5,
"otherwise run minimal configuration for vim with no external deps (standalone)

"TODO: check if 0.5 or greater
if has('nvim-0.5')

  if exists(':PackerSync')
    lua require('impatient')
  endif
  
  lua require('init')

  " some commands that don't work"
  " * autocmd does not work before 0.6
  " https://github.com/neovim/neovim/issues/14850

else
  runtime init-min.vim
endif

