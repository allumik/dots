-- vis-repl: A module for interacting with a tmux REPL.
-- TODO: make it into a plugin!

local M = {}

function M.get_target_pane(win)
  if win.repl_target_pane then
    return win.repl_target_pane
  end
  return "'+'"
end

function M.prep_text_bracketed(win)
  local target = M.get_target_pane(win)
  if not vis.win.selection then
    vis:info("ERROR: repl-block requires a visual selection.")
    return
  end

  -- 1. `>` pipes the visual selection from vis.
  -- 2. `tmux load-buffer -` loads stdin into a tmux buffer.
  -- 3. `;` separates the shell commands.
  -- 4. `tmux paste-buffer ...` pastes the buffer into the target pane.
  --    "-d" Delete buffer after pasting; "-p" Use bracketed paste mode
  return '> tmux load-buffer - ; tmux paste-buffer -d -p -t ' .. target
end

function M.prep_text_send(win)
  local target = M.get_target_pane(win)
  if not vis.win.selection then
    vis:info("ERROR: repl-send requires a visual selection.")
    return
  end

  -- Send multiline text line-by-line
  -- 1. `>` pipes the visual selection to stdin.
  -- 2. `sed ...`: Appends a literal `\Enter` to each line for tmux.
  -- 3. `tr "\\n" "\\0"`: Replaces newlines with null characters for safe handling.
  -- 4. `xargs -0 ...`: Executes `tmux send-keys` with the null-separated input.
  local cmd = '' ..
    '> sed \'s/;$/\\\\\\;/g; s/\\(.*\\)/\\1\\\\nEnter/\' ' ..
    '  | tr "\\\\n" "\\0" ' ..
    '  | xargs -0 tmux send-keys -t ' .. target
end)


vis:command_register("repl-set", function(argv, _, win)
  local pane = argv[1]
  if pane then
    win.repl_target_pane = pane
    vis:info("REPL target set to: " .. pane)
  else
    win.repl_target_pane = nil
    vis:info("REPL target unset. Will default to the next pane.")
  end
end)

-- Sends the selected text by simulating keystrokes.
vis:command_register("repl-send",
  function(argv, _, win) vis:command(M.prep_text_send(win)) 
end)

-- Sends the selected text and send an Enter to run the command
vis:command_register("repl-send-run", function(argv, _, win)
  local target = M.get_target_pane(win)
  vis:command(
    M.prep_text_send(win) .. '; tmux send-keys -t ' .. target .. ' Enter')
end)

-- Sends the selected text using tmux buffers and bracketed paste mode.
vis:command_register("repl-block", 
  function(argv, _, win) vis:command(M.prep_text_bracketed(win)) 
end)

-- Sends the selected text using tmux buffers and sends an Enter to run the command
vis:command_register("repl-block-run", function(argv, _, win)
  local target = M.get_target_pane(win)
  vis:command(
    M.prep_text_bracketed(win) .. '; tmux send-keys -t ' .. target .. ' Enter')
end)

-- Sends the given text to the REPL target pane.
vis:command_register("repl-cmd", function(argv, _, win)
  local target = M.get_target_pane(win)
  local cmd = '! tmux send-keys -t '.. target ..
               ' ' .. argv[1] .. ' Enter'
  vis:command(cmd)
end)

return M
