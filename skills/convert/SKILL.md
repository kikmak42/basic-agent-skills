---
name: convert
description: Accurate unit conversion (length, weight, temperature, volume, speed, data sizes).
---

# convert

## When to Activate
Activate this skill when the user asks to convert between units, e.g. 'how many miles is 10km', 'convert 100F to Celsius', '5GB in MB'.

## Steps
1. Detect the operating system to determine which script to run:
   - PowerShell (Windows): Check `$IsWindows`
   - Bash (Linux/macOS): Check `uname -s`
2. Invoke the appropriate script with the desired parameters.

### Windows (PowerShell)
```powershell
.\scripts\convert.ps1 -Value 10 -From "km" -To "mi"
```

### Linux/macOS (Bash)
```bash
./scripts/convert.sh --value 10 --from km --to mi
```

## Validation
Ensure the output presents the converted value with its target unit.

## Important / Guardrails
- LLMs know conversion factors but make arithmetic errors. ALWAYS use the script to perform conversions; do not compute them yourself.
