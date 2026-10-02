---
name: get-date
description: >-
  Use this skill whenever the user asks for today's date, the current time,
  the current day of the week, or any "right now" temporal information.
  LLMs have a static training cutoff and cannot know the real current date —
  always detect the OS and run the appropriate helper script instead of guessing.
---

# Get Today's Date

LLMs have no internal clock. **Never guess or fabricate the current date/time.**
Always detect the operating system, then run the matching helper script to get
the real value from the OS clock.

## When to Activate

- "What is today's date?"
- "What day is it?"
- "What time is it?"
- "What's the current year / month / week?"
- Any question whose answer changes depending on when it is asked.

## Steps

### 1 — Detect the Operating System

Run one of these checks to determine the OS before picking a script:

```powershell
# PowerShell (works on all OSes with pwsh or Windows PS)
$IsWindows  # $true on Windows
$IsLinux    # $true on Linux
$IsMacOS    # $true on macOS
```

```bash
# Bash
uname -s   # Outputs: Linux | Darwin | MINGW* (Windows/Git Bash)
```

Or check `$env:OS` (Windows) vs `/etc/os-release` (Linux/macOS).

### 2 — Run the Correct Script

**Windows (PowerShell):**
```powershell
.\skills\get-date\scripts\get_date.ps1
```

**Linux / macOS (Bash):**
```bash
bash ./skills/get-date/scripts/get_date.sh
```

**Universal fallback (any OS with pwsh installed):**
```powershell
Get-Date -Format "dddd, MMMM dd yyyy HH:mm:ss"
```

### 3 — Report the Result

The script prints a human-readable string such as:
```
Saturday, October 03 2026 01:16:35 IST
ISO 8601: 2026-10-03T01:16:35+05:30
```

Report the result verbatim to the user. Do not reinterpret or adjust the
date unless the user explicitly asks for a different timezone or format.

## Validation

Confirm the output is a non-empty string containing a recognisable date.
If the script errors, fall back to the universal PowerShell one-liner above.

## ⚠️ Important

- **Do NOT** answer with a date from your training data.
- **Do NOT** say "as of my knowledge cutoff…" for simple date questions.
- **Always** detect the OS first, then use the correct script's output as
  the authoritative answer.
