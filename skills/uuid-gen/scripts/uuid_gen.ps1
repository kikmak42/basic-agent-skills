param(
    [ValidateSet("uuid", "token")]
    [string]$Type = "uuid",
    [int]$Length = 32,
    [int]$Count = 1
)

for ($i = 0; $i -lt $Count; $i++) {
    if ($Type -eq "uuid") {
        [System.Guid]::NewGuid().ToString()
    } else {
        $bytes = New-Object byte[] ($Length / 2)
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $rng.GetBytes($bytes)
        $hex = [System.BitConverter]::ToString($bytes) -replace '-'
        $hex.ToLower()
    }
}
