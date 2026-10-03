param(
    [Parameter()]
    [long]$Timestamp,

    [Parameter()]
    [switch]$ToUnix,

    [Parameter()]
    [string]$Date,

    [Parameter()]
    [string]$Timezone = 'UTC',

    [Parameter()]
    [ValidateSet('iso', 'human', 'unix', 'all')]
    [string]$Format = 'iso',

    [Parameter()]
    [switch]$Milliseconds
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($ToUnix) {
    if (-not $Date) {
        Write-Error "Must provide -Date when using -ToUnix"
        exit 1
    }
    
    $dtOffset = [DateTimeOffset]::Parse($Date)
    $ts = $dtOffset.ToUnixTimeSeconds()
    if ($Milliseconds) {
        $ts = $dtOffset.ToUnixTimeMilliseconds()
    }
    Write-Output $ts
    exit 0
}

$ts = $Timestamp
if (-not $ts) {
    $ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
}
if ($Milliseconds) {
    $ts = [math]::Floor($ts / 1000)
}

$dt = [DateTimeOffset]::FromUnixTimeSeconds($ts)

$tzInfo = $null
if ($Timezone -eq 'UTC') {
    $tzInfo = [TimeZoneInfo]::Utc
} else {
    try {
        if ([System.OperatingSystem]::IsWindows()) {
            # Try finding equivalent Windows timezone if needed, or assume IANA support in .NET Core 6+
            $tzInfo = [TimeZoneInfo]::FindSystemTimeZoneById($Timezone)
        } else {
            $tzInfo = [TimeZoneInfo]::FindSystemTimeZoneById($Timezone)
        }
    } catch {
        Write-Error "Invalid or unsupported timezone: $Timezone. Use UTC or a valid system timezone."
        exit 1
    }
}

$localDt = [TimeZoneInfo]::ConvertTime($dt, $tzInfo)

if ($Format -eq 'iso') {
    Write-Output $localDt.ToString('o')
} elseif ($Format -eq 'human') {
    Write-Output $localDt.ToString('yyyy-MM-dd HH:mm:ss zzz')
} elseif ($Format -eq 'unix') {
    Write-Output $ts
} elseif ($Format -eq 'all') {
    Write-Output "UTC: $($dt.ToString('o'))"
    Write-Output "Local ($Timezone): $($localDt.ToString('yyyy-MM-dd HH:mm:ss zzz'))"
    Write-Output "ISO: $($localDt.ToString('o'))"
    Write-Output "Unix: $ts"
    Write-Output "Day of week: $($localDt.DayOfWeek)"
}
