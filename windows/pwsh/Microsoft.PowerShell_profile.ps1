# pwsh configuration

## ENV VARS
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:EUPORIE_CONFIG_FILE = (Join-Path $env:APPDATA "euporie\config.json")

## Set aliases here
# Set-Alias zl zellij
Set-Alias ll dir

# remap the coreutils (from MS) to native commands, overwriting if needed
$coreutilsCommands = @('cat', 'cp', 'date', 'echo', 'ls', 'mkdir', 'mv', 'pwd', 'rm', 'rmdir', 'sleep', 'sort', 'tee', 'uptime')
foreach ($command in $coreutilsCommands) {
  if (Get-Alias -Name $command -ErrorAction SilentlyContinue) {
    Remove-Item -Path "Alias:\$command" -Force -ErrorAction SilentlyContinue
  }
  Set-Alias -Name $command -Value "$command.exe" -Scope Global -Force
}

## UTILITIES
# wrapper for calling wsl bash
function bash {
  $env:CHERE_INVOKING = 1
  & "C:\Windows\system32\wsl.exe" --distribution Ubuntu -e bash
}

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

# Pixi autocompletion setup
(& pixi completion --shell powershell) | Out-String | Invoke-Expression
