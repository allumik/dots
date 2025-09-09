set guifont=Iosevka\ Term:h16
" 
" " Cursor tweaks
" " FVimCursorSmoothMove v:true
" FVimCursorSmoothBlink v:true
" 
" " Title bar tweaks
" " themed with colorscheme
" FVimCustomTitleBar v:true
" FVimUIPopupMenu v:false
" 
" " Font tweaks
" FVimFontAntialias v:true
" FVimFontAutohint v:true
" FVimFontHintLevel 'full'
" FVimFontLigature v:true
" " FVimFontLineHeight '+1.0' " can be 'default', '14.0', '-1.0' etc.
" FVimFontSubpixel v:true
" " FVimFontNoBuiltInSymbols v:true " Disable built-in Nerd font symbols
" 
" " Try to snap the fonts to the pixels, reduces blur
" " in some situations (e.g. 100% DPI).
" FVimFontAutoSnap v:true
" 
" nnoremap <silent> <C-ScrollWheelUp> :set guifont=+<CR>
" nnoremap <silent> <C-ScrollWheelDown> :set guifont=-<CR>
" nnoremap <C-CR> :FVimToggleFullScreen<CR>

" Here on we have the settings for nvim-qt

" Guifont! Iosevka Term:h12
" GuiTabline 0
" GuiPopupmenu 0
set title
set guioptions=m

" " right-click context menu for fun
" nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
" inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
" vnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>

