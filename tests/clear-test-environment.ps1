$ErrorActionPreference = "Stop"

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$nvim = if ($env:NVIM) { $env:NVIM } else { "nvim" }

& $nvim -l (Join-Path $scriptDirectory "clear_test_environment.lua")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
