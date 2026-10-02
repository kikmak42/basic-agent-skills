<#
.SYNOPSIS
    Evaluates a mathematical expression using PowerShell's engine.

.PARAMETER Expression
    A valid PowerShell / .NET math expression to evaluate.
    Supports standard operators (+, -, *, /, %, **) and [Math]:: methods.

.EXAMPLE
    .\calculate.ps1 -Expression "17 * 83"
    # Output: 1411

.EXAMPLE
    .\calculate.ps1 -Expression "2 ** 32"
    # Output: 4294967296

.EXAMPLE
    .\calculate.ps1 -Expression "[Math]::Sqrt(2)"
    # Output: 1.4142135623730951

.EXAMPLE
    .\calculate.ps1 -Expression "(123 + 456) / 7 - 89"
    # Output: -6.28571428571429

.EXAMPLE
    .\calculate.ps1 -Expression "0.15 * 847"
    # Output: 127.05
#>

param(
    [Parameter(Mandatory = $true)]
    [string] $Expression
)

# Replace Python-style ** with PowerShell [Math]::Pow for exponentiation
# e.g. "2 ** 10"  ->  "[Math]::Pow(2, 10)"
$expr = $Expression -replace '(\S+)\s*\*\*\s*(\S+)', '[Math]::Pow($1, $2)'

try {
    $result = Invoke-Expression $expr
    Write-Output $result
} catch {
    Write-Error "Failed to evaluate expression '$Expression': $_"
    exit 1
}
