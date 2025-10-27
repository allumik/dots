-- load standard vis module, providing parts of the Lua API
require('vis')



-- PLUGINS

-- load plugins
local plug = (function() if not pcall(require, 'plugins/vis-plug') then
 	os.execute('git clone --quiet https://github.com/erf/vis-plug ' ..
	 	(os.getenv('XDG_CONFIG_HOME') or os.getenv('HOME') .. '/.config')
	 	.. '/vis/plugins/vis-plug')
end return require('plugins/vis-plug') end)()

local plugins = {
    { 'erf/vis-cursors' },
    { 'peaceant/vis-fzf-mru', file = 'fzf-mru' },
    { 'git.sr.ht/~mcepl/vis-fzf-open' },
    { 'git.sr.ht/~mcepl/vis-open-file-under-cursor' },
    { 'git.sr.ht/~mcepl/vis-yank-highlight' },
    { 'repo.or.cz/vis-surround.git' },
    { 'lutobler/vis-commentary' },
    { 'milhnl/vis-format' },
    { 'Nomarian/vis-remove-trailing-whitespace' },
}

-- require and optionally install plugins on init
plug.init(plugins, true)

-- access plugins via alias
-- TODO: add keyboard aliases and enable some plugins features
-- plug.plugins.hi.patterns[' +\n'] = { style = 'back:#444444' }



-- FUNCTIONS

vis:command_register("repl-set", function(argv, _, win)
    local pane = argv[1]
    if not pane then
        local f = io.popen(
            "tmux lsp -a -F \"#D #{pane_marked}\" \\;" ..
            "     select-pane -M " ..
            "| awk '$2 == 1 { print $1; }'")
        for line in f:lines() do
            pane = line
        end
        f:close()
    end
    if pane then
        win.repl_target_pane = pane
    else
        vis:message("repl-set: No pane ID given and no marked pane!")
    end
end)

-- Sends the given line of text to the REPL target pane.
-- Can be used to call a command in the other pane, for example to recompile
-- your project, you can open a shell in the target pane and use:
--   :repl-send make
vis:command_register("repl-sendln", function(argv, _, win)
    if win.repl_target_pane then
        vis:command('! tmux send-keys -t '.. win.repl_target_pane ..
                    ' ' .. argv[1] .. ' Enter')
    end
end)

-- Sends the selected text to the REPL target pane. (use in visual mode)
vis:command_register("repl-send", function(argv, _, win)
    if win.repl_target_pane then
        vis:command('> sed \'s/;$/\\\\\\;/g; s/\\(.*\\)/\\1\\\\nEnter/\' ' ..
                    '  | tr "\\\\n" "\\0" ' ..
                    '  | xargs -0 tmux send-keys -t ' .. win.repl_target_pane)
    end
end)

-- Sends the given line of text to the REPL target pane.
-- Can be used to call a command in the other pane, for example to recompile
-- your project, you can open a shell in the target pane and use:
--   :repl-send make
vis:command_register("repl-sendln", function(argv, _, win)
    if win.repl_target_pane then
        vis:command('! tmux send-keys -t '.. win.repl_target_pane ..
                    ' ' .. argv[1] .. ' Enter')
    end
end)



-- CONFIGURATION

vis.events.subscribe(vis.events.INIT, function()
    -- Your global configuration options
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
    -- Your per window configuration options
    vis:command('set expandtab on')
    vis:command('set tabwidth 04')
    vis:command('set autoindent on')
    
    -- Use system clipboard
    vis:map(vis.modes.NORMAL, 'gp', '"+p')
    vis:map(vis.modes.VISUAL, 'gp', '"+p')
    -- TODO: this doesn't work with multiple cursors, just gets last selection
    vis:map(vis.modes.VISUAL, 'gy', function() vis:feedkeys(':>vis-clipboard --copy 2>/dev/null || wl-copy 2>/dev/null -n<Enter>') end, "Copy to vis-clipboard, with fallback to wl-copy")
end)