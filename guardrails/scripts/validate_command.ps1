param (
    [Parameter(Mandatory=$true)]
    [string]$Command
)

$blockedCommands = @(
    "format",
    "shutdown",
    "reboot",
    "halt",
    "del /F /S /Q C:\",
    "rmdir /S /Q C:\"
)

$blockedPatterns = @(
    "Invoke-WebRequest",
    "Invoke-RestMethod",
    "Remove-Item.*-Recurse.*C:\\"
)

foreach ($cmd in $blockedCommands) {
    if ($Command -match "(?i)^\s*$cmd\b") {
        Write-Error "Command validation failed: Command '$cmd' is blocked."
        exit 1
    }
}

foreach ($pattern in $blockedPatterns) {
    if ($Command -match "(?i)$pattern") {
        Write-Error "Command validation failed: Pattern '$pattern' is blocked."
        exit 1
    }
}

Write-Output "Command is safe."
exit 0
