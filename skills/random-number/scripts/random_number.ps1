<#
.SYNOPSIS
    Generates cryptographically-seeded random numbers.

.PARAMETER Min
    Lower bound (inclusive). Default: 1.

.PARAMETER Max
    Upper bound (inclusive for integers, exclusive for floats). Default: 100.

.PARAMETER Count
    How many random values to generate. Default: 1.

.PARAMETER Type
    "int" for integers, "float" for floating-point values. Default: int.

.EXAMPLE
    .\random_number.ps1 -Min 1 -Max 6
    # Dice roll — outputs a single integer between 1 and 6

.EXAMPLE
    .\random_number.ps1 -Min 1 -Max 100 -Count 5
    # Five random integers between 1 and 100

.EXAMPLE
    .\random_number.ps1 -Type float
    # Single random float between 0.0 and 1.0
#>

param(
    [double] $Min   = 1,
    [double] $Max   = 100,
    [int]    $Count = 1,
    [ValidateSet("int","float")]
    [string] $Type  = "int"
)

# Use RNGCryptoServiceProvider for genuine OS-level entropy
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$bytes = New-Object byte[] 8

for ($i = 0; $i -lt $Count; $i++) {
    $rng.GetBytes($bytes)
    # Convert bytes to a [0,1) double
    $fraction = [BitConverter]::ToUInt64($bytes, 0) / [double]([UInt64]::MaxValue)

    if ($Type -eq "int") {
        $range  = [Math]::Floor($Max) - [Math]::Ceiling($Min) + 1
        $result = [Math]::Floor($fraction * $range) + [Math]::Ceiling($Min)
        Write-Output ([long]$result)
    } else {
        $result = $Min + $fraction * ($Max - $Min)
        Write-Output $result
    }
}
