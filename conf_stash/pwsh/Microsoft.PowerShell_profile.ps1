$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

Set-Alias zl zellij

function bash {
  $env:CHERE_INVOKING = 1
  $env:MSYSTEM = "UCRT64"
  & "C:\msys64\usr\bin\bash.exe" --login
}
