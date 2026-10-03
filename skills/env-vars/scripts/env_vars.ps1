param(
    [string]$Name = "",
    [string]$Prefix = ""
)

$secretsPattern = "(?i)(KEY|SECRET|TOKEN|PASSWORD|PASS|CREDENTIAL|AUTH|API)"

$vars = Get-ChildItem Env:

if ($Name) {
    $vars = $vars | Where-Object { $_.Name -eq $Name }
} elseif ($Prefix) {
    $vars = $vars | Where-Object { $_.Name -like "$Prefix*" }
}

foreach ($var in $vars) {
    $val = $var.Value
    if ($var.Name -match $secretsPattern) {
        $val = "[REDACTED]"
    }
    Write-Output "$($var.Name)=$val"
}
