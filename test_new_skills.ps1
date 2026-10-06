$ErrorActionPreference = "Stop"

Write-Host "--- Testing hash ---"
pwsh -NoProfile -File skills/hash/scripts/hash_text.ps1 -Input "hello" -Algorithm "sha256"

Write-Host "--- Testing base64 ---"
pwsh -NoProfile -File skills/base64/scripts/base64_ops.ps1 -Operation "encode" -Input "hello"

Write-Host "--- Testing timestamp ---"
pwsh -NoProfile -File skills/timestamp/scripts/timestamp_ops.ps1 -Timestamp 1700000000

Write-Host "--- Testing network-info ---"
pwsh -NoProfile -File skills/network-info/scripts/network_info.ps1

Write-Host "--- Testing git-info ---"
pwsh -NoProfile -File skills/git-info/scripts/git_info.ps1

Write-Host "--- Testing regex ---"
pwsh -NoProfile -File skills/regex/scripts/regex_ops.ps1 -Operation "match" -Pattern "^hello" -Input "hello world"

Write-Host "--- Testing password-gen ---"
pwsh -NoProfile -File skills/password-gen/scripts/password_gen.ps1 -Length 16

Write-Host "--- All remaining skills tested successfully ---"
