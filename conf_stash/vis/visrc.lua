-- load standard vis module, providing parts of the Lua API
require('vis')
-- and add any other local files and functions
require('vis-repl')

-- PLUGINS
-- load plugin manager
local plug = (function() if not pcall(require, 'plugins/vis-plug') then
 	os.execute('git clone --quiet https://github.com/erf/vis-plug ' ..
	 	(os.getenv('XDG_CONFIG_HOME') or os.getenv('HOME') .. '/.config')
	 	.. '/vis/plugins/vis-plug')
end return require('plugins/vis-plug') end)()
-- declare your plugins here
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
-- Add some small custom functions here if needed


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
    -- NB: this doesn't work with multiple cursors, just gets last selection
    vis:map(vis.modes.VISUAL, 'gy', function() 
      vis:feedkeys(':>vis-clipboard --copy 2>/dev/null || wl-copy 2>/dev/null -n<Enter>') 
    end, "Copy to vis-clipboard, with fallback to wl-copy")

    -- Use the REPL commands
    vis:map(vis.modes.VISUAL, 'gts', ':repl-send<Enter>')
    vis:map(vis.modes.VISUAL, 'gtb', ':repl-block<Enter>')
    -- send the lines inside of a code block (delimiter "`")
    vis:map(vis.modes.NORMAL, 'gtV', 'Vi`:repl-block-run<Enter><Escape>') 
    vis:map(vis.modes.VISUAL, 'gtB', ':repl-block-run<Enter>')
    vis:map(vis.modes.NORMAL, 'gtc', ':repl-cmd<Enter>')
end)