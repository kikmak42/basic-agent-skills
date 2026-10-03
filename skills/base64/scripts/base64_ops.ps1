param(
    [Parameter()]
    [ValidateSet('encode', 'decode')]
    [string]$Operation = 'encode',

    [Parameter()]
    [string]$InputString,

    [Parameter()]
    [string]$File,

    [Parameter()]
    [switch]$NoPadding,

    [Parameter()]
    [switch]$UrlSafe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $InputString -and -not $File) {
    Write-Error "Must provide either -InputString or -File"
    exit 1
}

if ($Operation -eq 'encode') {
    $bytes = $null
    if ($File) {
        $bytes = [System.IO.File]::ReadAllBytes($File)
    } else {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    }
    
    $b64 = [Convert]::ToBase64String($bytes)
    
    if ($UrlSafe) {
        $b64 = $b64 -replace '\+', '-' -replace '/', '_'
    }
    if ($NoPadding) {
        $b64 = $b64.TrimEnd('=')
    }
    Write-Output $b64
} else {
    $b64 = $InputString
    if ($File) {
        $b64 = [System.IO.File]::ReadAllText($File).Trim()
    }
    
    if ($UrlSafe) {
        $b64 = $b64 -replace '-', '+' -replace '_', '/'
    }
    
    $pad = $b64.Length % 4
    if ($pad -ne 0) {
        $b64 += '=' * (4 - $pad)
    }
    
    $bytes = [Convert]::FromBase64String($b64)
    Write-Output ([System.Text.Encoding]::UTF8.GetString($bytes))
}
