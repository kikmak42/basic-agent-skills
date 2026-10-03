---
name: password-gen
description: Generate cryptographically secure passwords and passphrases.
---

# password-gen

## When to Activate
Activate this skill when the user asks questions like:
- "Generate a password for me."
- "Create a secure password."
- "Generate a passphrase."
- "Create a random string."
- "Check this password's strength."

## OS Detection
Before running, detect the OS:
- **Windows**: Use `pwsh -NoProfile -File scripts\password_gen.ps1`
- **Unix (Linux/macOS)**: Use `bash scripts/password_gen.sh`

## Steps

### Windows
```powershell
pwsh -NoProfile -File c:\Users\Kaushik\Work\2026\basic-agent-skills\skills\password-gen\scripts\password_gen.ps1 -Length 16 -Include "uppercase,lowercase,digits,symbols"
```

### Unix
```bash
bash /path/to/basic-agent-skills/skills/password-gen/scripts/password_gen.sh --length 16 --include "uppercase,lowercase,digits,symbols"
```

## Validation
Valid output is the requested password, passphrase, or strength evaluation based on length and entropy.

## Important / Guardrails
- **Why LLMs need this tool**: LLMs cannot produce truly random passwords—they will be biased toward memorable-looking patterns. Always use this tool for generating real credentials.
