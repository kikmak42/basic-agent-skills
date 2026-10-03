param(
    [Parameter()]
    [string]$InputString,

    [Parameter()]
    [string]$File,

    [Parameter()]
    [ValidateSet('sha256', 'sha512', 'sha1', 'md5')]
    [string]$Algorithm = 'sha256',

    [Parameter()]
    [ValidateSet('utf8', 'ascii', 'hex')]
    [string]$Encoding = 'utf8'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $InputString -and -not $File) {
    Write-Error "Must provide either -InputString or -File"
    exit 1
}

if ($File) {
    if (-not (Test-Path $File)) {
        Write-Error "File not found: $File"
        exit 1
    }
    $hash = (Get-FileHash -Algorithm $Algorithm -Path $File).Hash.ToLower()
    Write-Output $hash
    exit 0
}

$bytes = $null
if ($Encoding -eq 'utf8') {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
} elseif ($Encoding -eq 'ascii') {
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($InputString)
} elseif ($Encoding -eq 'hex') {
    $bytes = [byte[]]::new($InputString.Length / 2)
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        $bytes[$i] = [Convert]::ToByte($InputString.Substring($i * 2, 2), 16)
    }
}

$algo = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm.ToUpper())
$hashBytes = $algo.ComputeHash($bytes)
$hash = [BitConverter]::ToString($hashBytes) -replace '-', ''
Write-Output $hash.ToLower()
