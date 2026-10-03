---
name: uuid-gen
description: Generate valid UUIDs (v4) or cryptographically secure random tokens.
---

# uuid-gen

## When to Activate
Activate this skill when the user asks for a UUID, GUID, unique ID, random token, API key placeholder, or nonce.

## Steps
1. Detect the operating system to determine which script to run:
   - PowerShell (Windows): Check `$IsWindows`
   - Bash (Linux/macOS): Check `uname -s`
2. Invoke the appropriate script with the desired parameters.

### Windows (PowerShell)
```powershell
.\scripts\uuid_gen.ps1 -Type "uuid" -Count 1
.\scripts\uuid_gen.ps1 -Type "token" -Length 32 -Count 1
```

### Linux/macOS (Bash)
```bash
./scripts/uuid_gen.sh --type uuid --count 1
./scripts/uuid_gen.sh --type token --length 32 --count 1
```

## Validation
Verify that the output contains the requested number of UUIDs or tokens, printed one per line.

## Important / Guardrails
- LLMs cannot produce real UUIDs — they will make up strings that look like UUIDs but are not random. Do not guess or generate UUIDs/tokens yourself. ALWAYS use the scripts to generate valid cryptographically secure output.
