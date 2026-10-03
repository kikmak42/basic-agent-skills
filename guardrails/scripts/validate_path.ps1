param (
    [Parameter(Mandatory=$true)]
    [string]$Path
)

# Resolve the path to get its absolute form
$resolvedPath = [System.IO.Path]::GetFullPath($Path)

# Check for path traversal attempts
if ($Path -match "\.\.") {
    Write-Error "Path validation failed: Path traversal detected."
    exit 1
}

$blockedPaths = @(
    "C:\Windows\System32",
    "C:\Windows\System",
    "C:\Windows\regedit.exe"
)

$blockedPatterns = @(
    "\.ssh[/\\]id_rsa",
    "\.aws[/\\]credentials",
    "\.env"
)

foreach ($bp in $blockedPaths) {
    if ($resolvedPath.StartsWith($bp, [System.StringComparison]::InvariantCultureIgnoreCase)) {
        Write-Error "Path validation failed: Access to sensitive path '$bp' blocked."
        exit 1
    }
}

foreach ($pattern in $blockedPatterns) {
    if ($Path -match $pattern -or $resolvedPath -match $pattern) {
        Write-Error "Path validation failed: Access to sensitive file pattern '$pattern' blocked."
        exit 1
    }
}

Write-Output "Path is safe."
exit 0
