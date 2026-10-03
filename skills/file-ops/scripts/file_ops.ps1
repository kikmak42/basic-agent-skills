param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("read","list","exists","write")]
    [string]$Operation,
    
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$false)]
    [string]$Content
)

$ErrorActionPreference = "Stop"

switch ($Operation) {
    "read" {
        if (Test-Path $Path) {
            Get-Content $Path -Raw
        } else {
            Write-Output "File does not exist: $Path"
        }
    }
    "list" {
        if (Test-Path $Path) {
            Get-ChildItem $Path | Select-Object Name, Length, LastWriteTime
        } else {
            Write-Output "Directory does not exist: $Path"
        }
    }
    "exists" {
        if (Test-Path $Path) {
            Write-Output "True"
        } else {
            Write-Output "False"
        }
    }
    "write" {
        $dir = Split-Path $Path -Parent
        if ($dir -and -not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
        Set-Content -Path $Path -Value $Content
        Write-Output "File written to $Path"
    }
}
