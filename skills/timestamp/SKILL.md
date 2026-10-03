---
name: timestamp
description: Convert between Unix epoch timestamps and human-readable dates, with timezone support.
---

# timestamp

## When to Activate
Activate when the user asks to convert a Unix timestamp, asks what date/time 1729900000 is, asks for the Unix timestamp of a specific date, or asks how many seconds since epoch.

## OS Detection
Before executing the script, detect the OS:
- **Windows**: Use `$IsWindows` in PowerShell
- **Linux/macOS**: Use `uname -s` in Bash

## Steps

### 1. Execute the appropriate script

**Windows**:
```powershell
pwsh -NoProfile -File .\scripts\timestamp_ops.ps1 -Timestamp 1729900000 -Timezone "America/New_York"
```

**Unix**:
```bash
bash ./scripts/timestamp_ops.sh --timestamp 1729900000 --timezone "America/New_York"
```

## Validation
A valid output is a formatted string representing the date, or an integer Unix timestamp.

## Important / Guardrails
**NEVER** attempt to convert timestamps or handle timezones mentally. LLMs frequently make arithmetic errors converting timestamps and often get timezone offsets wrong. Always execute the script.
