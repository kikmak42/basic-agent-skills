param(
    [string]$Show = 'all',
    [string]$Path = '.',
    [int]$Count = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git is not available on this system."
    exit 1
}

$isGit = & git -C $Path rev-parse --git-dir 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Directory '$Path' is not a git repository."
    exit 0
}

switch ($Show) {
    'all' {
        Write-Host "--- Branch ---"
        & git -C $Path branch --show-current
        Write-Host "--- Status ---"
        & git -C $Path status -sb
        Write-Host "--- Recent Commits ---"
        & git -C $Path log -n 5 --oneline
    }
    'branch' {
        & git -C $Path branch --show-current
        & git -C $Path status -sb | Select-Object -First 1
    }
    'status' {
        & git -C $Path status --short
    }
    'log' {
        & git -C $Path log -n $Count
    }
    'remotes' {
        & git -C $Path remote -v
    }
    'stash' {
        & git -C $Path stash list
    }
    'diff-stat' {
        & git -C $Path diff --stat HEAD
    }
    default {
        Write-Error "Invalid value for -Show: $Show"
    }
}
