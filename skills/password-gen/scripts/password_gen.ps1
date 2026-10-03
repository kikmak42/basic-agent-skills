param(
    [int]$Length = 16,
    [int]$Count = 1,
    [string[]]$Include = @('uppercase', 'lowercase', 'digits', 'symbols'),
    [string]$Exclude = '',
    [switch]$NoAmbiguous,
    [switch]$Passphrase,
    [int]$Words = 4,
    [string]$Separator = '-',
    [switch]$Strength,
    [string]$InputString = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Ambiguous = "0O1lI|`'"

if ($Strength) {
    if (-not $InputString) {
        Write-Error "-InputString is required when -Strength is specified."
        exit 1
    }
    $l = $InputString.Length
    $charsetSize = 0
    if ($InputString -match '[a-z]') { $charsetSize += 26 }
    if ($InputString -match '[A-Z]') { $charsetSize += 26 }
    if ($InputString -match '[0-9]') { $charsetSize += 10 }
    if ($InputString -match '[^a-zA-Z0-9]') { $charsetSize += 32 }
    
    $entropy = if ($charsetSize -gt 0) { [math]::Round($l * [math]::Log($charsetSize, 2), 2) } else { 0 }
    Write-Host "Password length: $l"
    Write-Host "Charset size roughly: $charsetSize"
    Write-Host "Estimated entropy: $entropy bits"
    exit 0
}

$Upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
$Lower = 'abcdefghijklmnopqrstuvwxyz'
$Digits = '0123456789'
$Symbols = '!@#$%^&*()-_=+[]{}|;:,.<>?'

if ($Passphrase) {
    # small wordlist
    $WordList = @('apple', 'banana', 'orange', 'grape', 'lemon', 'peach', 'cherry', 'melon', 'berry', 'plum',
                  'car', 'bike', 'train', 'plane', 'boat', 'ship', 'truck', 'bus', 'cart', 'van',
                  'dog', 'cat', 'bird', 'fish', 'frog', 'bear', 'wolf', 'lion', 'tiger', 'deer',
                  'red', 'blue', 'green', 'yellow', 'black', 'white', 'gray', 'pink', 'purple', 'brown',
                  'sun', 'moon', 'star', 'cloud', 'rain', 'snow', 'wind', 'storm', 'sky', 'sea',
                  'tree', 'leaf', 'root', 'branch', 'flower', 'grass', 'bush', 'plant', 'seed', 'wood',
                  'house', 'door', 'window', 'roof', 'wall', 'floor', 'room', 'bed', 'chair', 'table',
                  'book', 'pen', 'paper', 'desk', 'lamp', 'clock', 'phone', 'computer', 'screen', 'mouse',
                  'happy', 'sad', 'angry', 'fast', 'slow', 'big', 'small', 'hot', 'cold', 'warm',
                  'run', 'walk', 'jump', 'swim', 'fly', 'drive', 'ride', 'climb', 'fall', 'stand')
    for ($c = 0; $c -lt $Count; $c++) {
        $phrase = @()
        for ($i = 0; $i -lt $Words; $i++) {
            $bytes = [byte[]]::new(4)
            [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
            $idx = [BitConverter]::ToUInt32($bytes, 0) % $WordList.Count
            $phrase += $WordList[$idx]
        }
        Write-Host ($phrase -join $Separator)
    }
    exit 0
}

if ($Length -lt 8 -or $Length -gt 128) {
    Write-Error "Length must be between 8 and 128."
    exit 1
}

$CharSet = ""
$Requirements = @()

if ($Include -match 'uppercase') { $CharSet += $Upper; $Requirements += $Upper }
if ($Include -match 'lowercase') { $CharSet += $Lower; $Requirements += $Lower }
if ($Include -match 'digits') { $CharSet += $Digits; $Requirements += $Digits }
if ($Include -match 'symbols') { $CharSet += $Symbols; $Requirements += $Symbols }

if ($NoAmbiguous) {
    $Exclude += $Ambiguous
}

if ($Exclude) {
    foreach ($char in $Exclude.ToCharArray()) {
        $CharSet = $CharSet.Replace($char.ToString(), '')
        for ($i=0; $i -lt $Requirements.Count; $i++) {
            $Requirements[$i] = $Requirements[$i].Replace($char.ToString(), '')
        }
    }
}

if ($CharSet.Length -eq 0) {
    Write-Error "Character set is empty after applying exclusions."
    exit 1
}

function Get-RandomChar($set) {
    if ($set.Length -eq 0) { return '' }
    $bytes = [byte[]]::new(4)
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $idx = [BitConverter]::ToUInt32($bytes, 0) % $set.Length
    return $set[$idx]
}

for ($c = 0; $c -lt $Count; $c++) {
    $pwdArray = @()
    foreach ($req in $Requirements) {
        $pwdArray += Get-RandomChar $req
    }
    
    while ($pwdArray.Count -lt $Length) {
        $pwdArray += Get-RandomChar $CharSet
    }
    
    # Shuffle using Fisher-Yates
    for ($i = $pwdArray.Count - 1; $i -gt 0; $i--) {
        $bytes = [byte[]]::new(4)
        [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
        $j = [BitConverter]::ToUInt32($bytes, 0) % ($i + 1)
        $temp = $pwdArray[$i]
        $pwdArray[$i] = $pwdArray[$j]
        $pwdArray[$j] = $temp
    }
    
    Write-Host ($pwdArray -join '')
}
