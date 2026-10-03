param (
    [Parameter(Mandatory=$true)]
    [string]$InputText
)

$secretKeys = "SECRET|TOKEN|PASSWORD|PASS|KEY|CREDENTIAL|AUTH|API_KEY"

# Match KEY=value
$InputText = [regex]::Replace($InputText, "(?i)([a-z0-9_]*($secretKeys)[a-z0-9_]*)=.*", '$1=[REDACTED]')

# Match 'key': 'value' or "key": "value"
$InputText = [regex]::Replace($InputText, "(?i)(['""]?)([a-z0-9_]*($secretKeys)[a-z0-9_]*)(['""]?)\s*:\s*(['""]).*?(['""])", '${1}${2}${4}: ${5}[REDACTED]${6}')

Write-Output $InputText
exit 0
