param(
  [string]$CameraName = "HD Pro Webcam C920",
  [int]$Width = 1280,
  [int]$Height = 720,
  [int]$FrameRate = 30,
  [int]$BitrateKbps = 4000
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent
$runtimeDir = Join-Path $projectRoot ".runtime"
$packagesDir = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"

New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null

$ffmpeg = Get-ChildItem -LiteralPath $packagesDir -Recurse -Filter "ffmpeg.exe" |
  Where-Object FullName -Match "Gyan\.FFmpeg" |
  Select-Object -First 1 -ExpandProperty FullName
$mediaMtx = Get-ChildItem -LiteralPath $packagesDir -Recurse -Filter "mediamtx.exe" |
  Where-Object FullName -Match "bluenviron\.mediamtx" |
  Select-Object -First 1 -ExpandProperty FullName

if (-not $ffmpeg) { throw "FFmpeg não encontrado. Instale Gyan.FFmpeg pelo winget." }
if (-not $mediaMtx) { throw "MediaMTX não encontrado. Instale bluenviron.mediamtx pelo winget." }

$mediaMtxDir = Split-Path $mediaMtx -Parent
$mediaMtxConfig = Join-Path $mediaMtxDir "mediamtx.yml"
$mediaMtxPidFile = Join-Path $runtimeDir "mediamtx.pid"
$ffmpegPidFile = Join-Path $runtimeDir "camera.pid"

$mediaMtxProcess = Start-Process `
  -FilePath $mediaMtx `
  -ArgumentList "`"$mediaMtxConfig`"" `
  -WorkingDirectory $mediaMtxDir `
  -WindowStyle Hidden `
  -RedirectStandardOutput (Join-Path $runtimeDir "mediamtx.out.log") `
  -RedirectStandardError (Join-Path $runtimeDir "mediamtx.err.log") `
  -PassThru
$mediaMtxProcess.Id | Set-Content -LiteralPath $mediaMtxPidFile

Start-Sleep -Milliseconds 800
if ($mediaMtxProcess.HasExited) {
  throw "MediaMTX encerrou ao iniciar. Consulte .runtime\mediamtx.err.log."
}

$bufferKbps = [Math]::Max(200, [Math]::Round($BitrateKbps / 10))
$arguments = @(
  "-hide_banner -loglevel info",
  "-f dshow -rtbufsize 32M",
  "-video_size ${Width}x${Height} -framerate $FrameRate -vcodec mjpeg",
  "-i `"video=$CameraName`"",
  "-an -c:v libx264 -preset ultrafast -tune zerolatency",
  "-profile:v baseline -level 3.1",
  "-b:v ${BitrateKbps}k -maxrate ${BitrateKbps}k -bufsize ${bufferKbps}k",
  "-g $FrameRate -keyint_min $FrameRate -bf 0 -pix_fmt yuv420p",
  "-rtsp_transport tcp -f rtsp rtsp://127.0.0.1:8554/rc"
) -join " "

$cameraProcess = Start-Process `
  -FilePath $ffmpeg `
  -ArgumentList $arguments `
  -WindowStyle Hidden `
  -RedirectStandardOutput (Join-Path $runtimeDir "camera.out.log") `
  -RedirectStandardError (Join-Path $runtimeDir "camera.err.log") `
  -PassThru
$cameraProcess.Id | Set-Content -LiteralPath $ffmpegPidFile

Start-Sleep -Seconds 2
if ($cameraProcess.HasExited) {
  throw "O transmissor da câmera encerrou. Consulte .runtime\camera.err.log."
}

Write-Output "Transmissor iniciado."
Write-Output "Player direto: http://127.0.0.1:8889/rc"
Write-Output "Endpoint WHEP: http://127.0.0.1:8889/rc/whep"
Write-Output "MediaMTX PID: $($mediaMtxProcess.Id)"
Write-Output "Câmera PID: $($cameraProcess.Id)"
