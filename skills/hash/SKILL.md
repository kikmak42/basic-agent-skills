---
name: hash
description: Compute cryptographic hash digests of text strings or files.
---

# hash

## When to Activate
Activate this skill when the user asks to hash something, compute SHA256/MD5/SHA512, verify integrity, or generate a checksum.

## OS Detection
Before executing the script, detect the OS:
- **Windows**: Use `$IsWindows` in PowerShell
- **Linux/macOS**: Use `uname -s` in Bash

## Steps

### 1. Execute the appropriate script

**Windows**:
```powershell
pwsh -NoProfile -File .\scripts\hash_text.ps1 -Input "my text" -Algorithm sha256
```

**Unix**:
```bash
bash ./scripts/hash_text.sh --input "my text" --algorithm sha256
```

## Validation
A valid output is a lowercase hex string containing the computed hash (e.g., `dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f`).

## Important / Guardrails
**NEVER** attempt to compute a hash mentally or infer the hex digest. The result will inevitably be wrong because LLMs cannot perform cryptographic hashing natively. Always run the script to produce the correct hash.
