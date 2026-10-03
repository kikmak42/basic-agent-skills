param(
    [Parameter(Mandatory=$true)]
    [string]$Command
)

$ErrorActionPreference = "Continue"

$blockedPatterns = @("rm -rf /", "format ", "del /F /S", "shutdown")

foreach ($pattern in $blockedPatterns) {
    if ($Command -match $pattern) {
        Write-Error "Command blocked by security guardrails: Matches pattern '$pattern'"
        exit 1
    }
}

Write-Output "Executing: $Command"
try {
    Invoke-Expression $Command
    Write-Output "Exit Code: $LASTEXITCODE"
} catch {
    Write-Error "Command execution failed: $_"
    Write-Output "Exit Code: 1"
}
