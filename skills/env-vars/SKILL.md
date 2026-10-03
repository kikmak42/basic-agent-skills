---
name: env-vars
description: Read actual environment variables from the running process with secret redaction.
---

# env-vars

## When to Activate
Activate this skill when the user asks what environment variables are set, asks for the value of a specific env var, or needs to check if an env var exists.

## Steps
1. Detect the operating system to determine which script to run:
   - PowerShell (Windows): Check `$IsWindows`
   - Bash (Linux/macOS): Check `uname -s`
2. Invoke the appropriate script with the desired parameters.

### Windows (PowerShell)
```powershell
.\scripts\env_vars.ps1
.\scripts\env_vars.ps1 -Name "PATH"
.\scripts\env_vars.ps1 -Prefix "AWS_"
```

### Linux/macOS (Bash)
```bash
./scripts/env_vars.sh
./scripts/env_vars.sh --name PATH
./scripts/env_vars.sh --prefix AWS_
```

## Validation
Verify that the output contains the environment variables and that any secrets are redacted.

## Important / Guardrails
- LLMs cannot know what env vars are set — always read from the real environment.
- **IMPORTANT**: Always redact secret-looking variables. Never print raw values of variables whose names suggest they contain credentials (e.g., KEY, SECRET, TOKEN, PASSWORD, PASS, CREDENTIAL, AUTH, API). The scripts will handle this automatically. Do NOT guess values.
