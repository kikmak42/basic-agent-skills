param(
    [Parameter(Mandatory=$true)]
    [string]$Pattern,
    [string]$InputString,
    [string]$File,
    [string]$Operation = 'match',
    [string]$Replacement = '',
    [switch]$IgnoreCase,
    [switch]$Multiline
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $InputString -and -not $File) {
    Write-Error "Either -InputString or -File must be provided."
    exit 1
}

$Options = [System.Text.RegularExpressions.RegexOptions]::None
if ($IgnoreCase) { $Options = $Options -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase }
if ($Multiline) { $Options = $Options -bor [System.Text.RegularExpressions.RegexOptions]::Multiline }

try {
    $Regex = New-Object System.Text.RegularExpressions.Regex($Pattern, $Options)
} catch [System.ArgumentException] {
    Write-Error "Invalid regex pattern: $Pattern"
    exit 1
}

$Content = if ($File) { Get-Content $File -Raw } else { $InputString }

switch ($Operation) {
    'match' {
        $Match = $Regex.Match($Content)
        if ($Match.Success) {
            Write-Host "MATCH"
            Write-Host "Value: $($Match.Value)"
            for ($i = 0; $i -lt $Match.Groups.Count; $i++) {
                Write-Host "Group $i: $($Match.Groups[$i].Value)"
            }
        } else {
            Write-Host "NO MATCH"
        }
    }
    'findall' {
        $Matches = $Regex.Matches($Content)
        if ($Matches.Count -gt 0) {
            foreach ($m in $Matches) {
                Write-Host $m.Value
            }
        } else {
            Write-Host "NO MATCHES"
        }
    }
    'replace' {
        if (-not $PSBoundParameters.ContainsKey('Replacement') -and $Replacement -eq '') {
            Write-Error "-Replacement is required for replace operation."
            exit 1
        }
        $Regex.Replace($Content, $Replacement)
    }
    'split' {
        $Regex.Split($Content) | ForEach-Object { Write-Host $_ }
    }
    'count' {
        $Matches = $Regex.Matches($Content)
        Write-Host "Count: $($Matches.Count)"
    }
    default {
        Write-Error "Invalid operation: $Operation"
    }
}
