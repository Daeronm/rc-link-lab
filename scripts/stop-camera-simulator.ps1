$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent
$runtimeDir = Join-Path $projectRoot ".runtime"

foreach ($name in @("camera", "mediamtx")) {
  $pidFile = Join-Path $runtimeDir "$name.pid"
  if (-not (Test-Path -LiteralPath $pidFile)) { continue }

  $processId = [int](Get-Content -LiteralPath $pidFile)
  $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
  if ($process) {
    Stop-Process -Id $processId
    Write-Output "$name encerrado (PID $processId)."
  }
  Remove-Item -LiteralPath $pidFile -Force
}
