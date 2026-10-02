<#
.SYNOPSIS
    Returns the current date and time from the operating system clock.

.DESCRIPTION
    Prints the current local date, time, and timezone so the agent has
    an authoritative, non-hallucinated answer for "what date/time is it?"

.EXAMPLE
    .\get_date.ps1
    # Output: Saturday, October 03 2026 01:16:35 IST
#>

$now = Get-Date
$tz  = [System.TimeZoneInfo]::Local.StandardName

# Short timezone abbreviation (e.g. "IST", "UTC", "EST")
$tzAbbr = ($tz -replace '(\b\w)\w+\s*', '$1').ToUpper()

$output = $now.ToString("dddd, MMMM dd yyyy HH:mm:ss") + " $tzAbbr"
Write-Output $output

# Also output ISO 8601 for machine parsing
Write-Output ("ISO 8601: " + $now.ToString("o"))
