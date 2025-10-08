-- load standard vis module, providing parts of the Lua API
require('vis')

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
    { 'maciejjan/vis-tmux-repl', file = 'tmux-repl' },
}

-- require and optionally install plugins on init
plug.init(plugins, true)

-- access plugins via alias
-- TODO: add keyboard aliases and enable some plugins features
-- plug.plugins.hi.patterns[' +\n'] = { style = 'back:#444444' }


vis.events.subscribe(vis.events.INIT, function()
	-- Your global configuration options
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
	-- Your per window configuration options e.g.
	-- vis:command('set number')
end)