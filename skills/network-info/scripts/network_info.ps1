param(
    [Parameter()]
    [ValidateSet('all', 'ipv4', 'ipv6', 'hostname', 'interfaces', 'external')]
    [string]$Show = 'all'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Show -in @('all', 'hostname')) {
    $hostname = [System.Net.Dns]::GetHostName()
    Write-Output "Hostname: $hostname"
    if ($Show -eq 'hostname') { exit 0 }
}

if ($Show -in @('all', 'ipv4')) {
    $ipv4 = Get-NetIPAddress -AddressFamily IPv4 | Where-Object IPAddress -ne '127.0.0.1' | Select-Object -ExpandProperty IPAddress
    Write-Output "IPv4 Addresses:"
    $ipv4 | ForEach-Object { Write-Output "  $_" }
    if ($Show -eq 'ipv4') { exit 0 }
}

if ($Show -in @('all', 'ipv6')) {
    $ipv6 = Get-NetIPAddress -AddressFamily IPv6 | Where-Object IPAddress -ne '::1' | Select-Object -ExpandProperty IPAddress
    Write-Output "IPv6 Addresses:"
    $ipv6 | ForEach-Object { Write-Output "  $_" }
    if ($Show -eq 'ipv6') { exit 0 }
}

if ($Show -eq 'interfaces') {
    $adapters = Get-NetAdapter | Where-Object Status -eq 'Up'
    foreach ($adapter in $adapters) {
        $ips = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex | Select-Object -ExpandProperty IPAddress
        Write-Output "Interface: $($adapter.Name)"
        $ips | ForEach-Object { Write-Output "  $_" }
    }
    exit 0
}

if ($Show -in @('all', 'external')) {
    try {
        $ext = Invoke-RestMethod -Uri "https://api.ipify.org?format=text" -TimeoutSec 5
        Write-Output "External IP: $ext"
    } catch {
        Write-Output "External IP: [Failed to fetch - network access issue]"
    }
    if ($Show -eq 'external') { exit 0 }
}
