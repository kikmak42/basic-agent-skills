<#
.SYNOPSIS
    Returns the current date and time with full timezone support.

.DESCRIPTION
    Prints the current date/time in local time (or a specified timezone),
    UTC, Unix timestamp, ISO 8601, and DST status.
    Accepts IANA timezone names (e.g. "America/New_York") or Windows
    timezone IDs (e.g. "Eastern Standard Time").

.PARAMETER Timezone
    IANA or Windows timezone name. Defaults to the system local timezone.
    Special values: "UTC", "utc", "local"
    Examples: "America/New_York", "Europe/London", "Asia/Tokyo",
              "Pacific Standard Time", "UTC"

.PARAMETER Format
    Output format: long (default), short, iso, unix, all

.PARAMETER Compare
    Show the same moment in multiple timezones (comma-separated or multiple args).
    Example: -Compare "UTC","America/New_York","Asia/Kolkata"

.PARAMETER ListTimezones
    List all available timezone IDs on this system.

.EXAMPLE
    .\get_date.ps1
    # Local time with UTC + ISO 8601

.EXAMPLE
    .\get_date.ps1 -Timezone "America/New_York"
    # Current time in New York

.EXAMPLE
    .\get_date.ps1 -Compare "UTC","America/New_York","Europe/London","Asia/Kolkata"
    # World clock view

.EXAMPLE
    .\get_date.ps1 -Format unix
    # Unix timestamp (seconds since epoch)

.EXAMPLE
    .\get_date.ps1 -ListTimezones
    # List all available timezone IDs
#>

param(
    [string]   $Timezone      = "",
    [ValidateSet("long","short","iso","unix","all")]
    [string]   $Format        = "long",
    [string]   $Compare       = "",   # Comma-separated IANA timezone names, e.g. "UTC,America/New_York"
    [switch]   $ListTimezones
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Timezone resolution ────────────────────────────────────────────────────

function Resolve-Timezone {
    param([string]$TzId)

    if ($TzId -eq "" -or $TzId -eq "local") {
        return [System.TimeZoneInfo]::Local
    }
    if ($TzId -eq "UTC" -or $TzId -eq "utc" -or $TzId -eq "Etc/UTC") {
        return [System.TimeZoneInfo]::Utc
    }

    # 1. Exact Windows ID match
    try { return [System.TimeZoneInfo]::FindSystemTimeZoneById($TzId) } catch {}

    # 2. IANA → Windows conversion (PowerShell 7+ / .NET 6+)
    try {
        $winId = $null
        if ([System.TimeZoneInfo]::TryConvertIanaIdToWindowsId($TzId, [ref]$winId)) {
            return [System.TimeZoneInfo]::FindSystemTimeZoneById($winId)
        }
    } catch {}

    # 3. Fuzzy display-name match
    $all = [System.TimeZoneInfo]::GetSystemTimeZones()
    $match = $all | Where-Object {
        $_.Id -like "*$TzId*" -or $_.DisplayName -like "*$TzId*" -or $_.StandardName -like "*$TzId*"
    } | Select-Object -First 1
    if ($match) { return $match }

    Write-Error "Unknown timezone: '$TzId'. Run with -ListTimezones to see available IDs."
    exit 1
}

# ─── List timezones ──────────────────────────────────────────────────────────

if ($ListTimezones) {
    [System.TimeZoneInfo]::GetSystemTimeZones() |
        Select-Object @{N="ID";E={$_.Id}},
                      @{N="DisplayName";E={$_.DisplayName}},
                      @{N="UTCOffset";E={$_.BaseUtcOffset.ToString()}} |
        Format-Table -AutoSize
    exit 0
}

# ─── Core time logic ─────────────────────────────────────────────────────────

$utcNow = [System.DateTime]::UtcNow

function Format-TzOutput {
    param(
        [System.TimeZoneInfo] $Tz,
        [string]              $Fmt,
        [System.DateTime]     $UtcTime
    )

    $local   = [System.TimeZoneInfo]::ConvertTimeFromUtc($UtcTime, $Tz)
    $offset  = $Tz.GetUtcOffset($UtcTime)
    $isDST   = $Tz.IsDaylightSavingTime($local)
    $sign    = if ($offset.TotalMinutes -ge 0) { "+" } else { "-" }
    $offStr  = "{0}{1:D2}:{2:D2}" -f $sign, [Math]::Abs($offset.Hours), [Math]::Abs($offset.Minutes)
    $dstTag  = if ($isDST) { " [DST active]" } else { "" }

    # Abbreviation: special-case UTC, then derive from standard/daylight name
    $abbr = if ($Tz.Id -eq "UTC" -or $Tz.StandardName -eq "Coordinated Universal Time") {
        "UTC"
    } elseif ($isDST -and $Tz.DaylightName) {
        ($Tz.DaylightName -replace '(\b\w)\w+\s*','$1').ToUpper()
    } else {
        ($Tz.StandardName -replace '(\b\w)\w+\s*','$1').ToUpper()
    }

    switch ($Fmt) {
        "short" {
            "{0}  ({1}  UTC{2}{3})" -f $local.ToString("yyyy-MM-dd HH:mm"), $abbr, $offStr, $dstTag
        }
        "iso" {
            $local.ToString("yyyy-MM-ddTHH:mm:ss") + $offStr
        }
        "unix" {
            [long]($UtcTime - [datetime]"1970-01-01 00:00:00Z").TotalSeconds
        }
        "all" {
            @(
                "Timezone   : {0} ({1})" -f $Tz.Id, $Tz.DisplayName
                "Local time : {0}" -f $local.ToString("dddd, MMMM dd yyyy  HH:mm:ss")
                "Abbrev     : {0}{1}" -f $abbr, $dstTag
                "UTC offset : UTC{0}" -f $offStr
                "ISO 8601   : {0}{1}" -f $local.ToString("yyyy-MM-ddTHH:mm:ss"), $offStr
                "UTC time   : {0}" -f $UtcTime.ToString("yyyy-MM-dd HH:mm:ss")
                "Unix epoch : {0}" -f [long]($UtcTime - [datetime]"1970-01-01 00:00:00Z").TotalSeconds
            ) -join "`n"
        }
        default { # long
            "{0}  {1}  UTC{2}{3}" -f $local.ToString("dddd, MMMM dd yyyy  HH:mm:ss"), $abbr, $offStr, $dstTag
        }
    }
}

# ─── Compare mode ────────────────────────────────────────────────────────────

if ($Compare -ne "") {
    $zones = $Compare -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    Write-Output ("=" * 60)
    Write-Output ("  World Clock  —  UTC: " + $utcNow.ToString("yyyy-MM-dd HH:mm:ss"))
    Write-Output ("=" * 60)
    foreach ($tzId in $zones) {
        $tz     = Resolve-Timezone $tzId
        $output = Format-TzOutput -Tz $tz -Fmt "short" -UtcTime $utcNow
        "{0,-30} {1}" -f ($tz.Id + ":"), $output
    }
    exit 0
}

# ─── Single timezone output ───────────────────────────────────────────────────

$tz = Resolve-Timezone $Timezone
Format-TzOutput -Tz $tz -Fmt $Format -UtcTime $utcNow
