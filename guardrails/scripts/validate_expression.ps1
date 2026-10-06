param (
    [Parameter(Mandatory=$true)]
    [string]$Expression
)

$blockedPatterns = @(
    "System\.",
    "IO\.",
    "Net\.",
    "Diagnostics\.",
    "Invoke-",
    "Start-",
    "Stop-",
    "Get-",
    "Set-",
    "New-",
    "Remove-",
    "Out-",
    "Write-",
    "Read-",
    "&",
    "\|",
    ";",
    "\\$"
)

foreach ($pattern in $blockedPatterns) {
    if ($Expression -match $pattern) {
        Write-Error "Expression validation failed: Blocked pattern '$pattern' detected."
        exit 1
    }
}

Write-Output "Expression is safe."
exit 0
