$ErrorActionPreference = "Stop"

$tcpRuleName = "RC Link Lab - TCP local"
$udpRuleName = "RC Link Lab - WebRTC UDP local"

if (-not (Get-NetFirewallRule -DisplayName $tcpRuleName -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule `
    -DisplayName $tcpRuleName `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort 3000, 8889 `
    -Profile Public, Private `
    -RemoteAddress LocalSubnet | Out-Null
}

if (-not (Get-NetFirewallRule -DisplayName $udpRuleName -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule `
    -DisplayName $udpRuleName `
    -Direction Inbound `
    -Action Allow `
    -Protocol UDP `
    -LocalPort 8189 `
    -Profile Public, Private `
    -RemoteAddress LocalSubnet | Out-Null
}

Write-Output "Acesso local liberado para TCP 3000/8889 e UDP 8189."
