# pwsh configuration
# install fzf, ripgrep, neovim

# set some defaults
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:EUPORIE_CONFIG_FILE = (Join-Path $env:APPDATA "euporie\config.json")

# set aliases here for quicker access
# Set-Alias zl zellij
Set-Alias ll dir

# Wrapper for calling wsl bash
function bash {
  $env:CHERE_INVOKING = 1
  & "C:\Windows\system32\wsl.exe" --distribution Ubuntu -e bash
}

# and some functionality, taking into account that we have some tools installed
# use fzf for backwards search
Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
  $line = ""
  $cursor = 0
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  
  $command = Get-Content (Get-PSReadLineOption).HistorySavePath |
    Select-Object -Unique |
    fzf --query "$line" --reverse
  
  if ($command) {
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
  }
}
