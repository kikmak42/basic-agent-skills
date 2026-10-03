---
name: base64
description: Encode text/bytes to base64 or decode base64 back to text.
---

# base64

## When to Activate
Activate when the user asks to base64 encode or decode something, encode a file, decode a JWT payload, or encode credentials.

## OS Detection
Before executing the script, detect the OS:
- **Windows**: Use `$IsWindows` in PowerShell
- **Linux/macOS**: Use `uname -s` in Bash

## Steps

### 1. Execute the appropriate script

**Windows**:
```powershell
pwsh -NoProfile -File .\scripts\base64_ops.ps1 -Operation encode -InputString "my text"
```

**Unix**:
```bash
bash ./scripts/base64_ops.sh --operation decode --input "bXkgdGV4dA=="
```

## Validation
A valid output is the correct base64 encoded string or decoded text output on a single line (unless the decoded output is multi-line).

## Important / Guardrails
**NEVER** guess base64 encoding or decoding. LLMs frequently make encoding errors (especially with `=` padding and line wrapping). Always execute the scripts.
