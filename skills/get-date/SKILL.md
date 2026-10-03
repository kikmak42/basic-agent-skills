---
name: get-date
description: >-
  Use this skill whenever the user asks for today's date, the current time,
  the current day of the week, the current time in a specific city or timezone,
  a world clock comparison, a Unix timestamp, or any "right now" temporal
  information. LLMs have a static training cutoff and cannot know the real
  current date or time — always detect the OS and run the appropriate helper
  script. The script supports IANA timezones, DST detection, UTC offsets,
  and multi-timezone world clock views.
---

# Get Today's Date (Timezone-Aware)

LLMs have no internal clock and no knowledge of the current time. **Never
guess or fabricate the current date, time, or timezone offset.**

Always detect the operating system, then run the matching helper script.
The scripts support full IANA timezone names, DST detection, UTC offsets,
and world clock comparisons.

---

## When to Activate

- "What is today's date?"
- "What time is it?" / "What time is it in Tokyo?"
- "What's the current time in New York / London / UTC?"
- "Show me a world clock for these cities"
- "What day of the week is it?"
- "What is the current Unix timestamp?"
- "What is the UTC offset for [timezone]?"
- "Is DST currently active in [place]?"
- Any question whose answer changes depending on when it is asked.

---

## Steps

### 1 — Detect the Operating System

```powershell
# PowerShell
$IsWindows   # $true on Windows
$IsLinux     # $true on Linux
$IsMacOS     # $true on macOS
```

```bash
# Bash
uname -s   # Linux | Darwin | MINGW* (Windows Git Bash)
```

### 2 — Extract Parameters from the Request

| Parameter | What to extract | Default |
|-----------|----------------|---------|
| `timezone` | IANA name (e.g. `America/New_York`) or `UTC` | System local timezone |
| `format` | `long` \| `short` \| `iso` \| `unix` \| `all` | `long` |
| `compare` | Comma-separated IANA names for world clock | _(none)_ |

**Common IANA timezone names:**
| City / Region | IANA Name |
|--------------|-----------|
| UTC | `UTC` |
| London | `Europe/London` |
| New York | `America/New_York` |
| Los Angeles | `America/Los_Angeles` |
| Chicago | `America/Chicago` |
| São Paulo | `America/Sao_Paulo` |
| Paris / Berlin | `Europe/Paris` / `Europe/Berlin` |
| Dubai | `Asia/Dubai` |
| India (IST) | `Asia/Kolkata` |
| Singapore | `Asia/Singapore` |
| Tokyo | `Asia/Tokyo` |
| Sydney | `Australia/Sydney` |

### 3 — Run the Correct Script

**Windows (PowerShell):**
```powershell
# Default local time
.\skills\get-date\scripts\get_date.ps1

# Specific timezone
.\skills\get-date\scripts\get_date.ps1 -Timezone "America/New_York"

# All details (ISO, UTC, Unix, DST status)
.\skills\get-date\scripts\get_date.ps1 -Format all

# World clock
.\skills\get-date\scripts\get_date.ps1 -Compare "UTC","America/New_York","Europe/London","Asia/Kolkata","Asia/Tokyo"

# Unix timestamp
.\skills\get-date\scripts\get_date.ps1 -Format unix

# List available timezones
.\skills\get-date\scripts\get_date.ps1 -ListTimezones
```

**Linux / macOS (Bash):**
```bash
# Default local time
bash ./skills/get-date/scripts/get_date.sh

# Specific timezone
bash ./skills/get-date/scripts/get_date.sh --timezone "America/New_York"

# All details
bash ./skills/get-date/scripts/get_date.sh --format all

# World clock
bash ./skills/get-date/scripts/get_date.sh --compare "UTC,America/New_York,Europe/London,Asia/Kolkata,Asia/Tokyo"

# Unix timestamp
bash ./skills/get-date/scripts/get_date.sh --format unix

# List timezones
bash ./skills/get-date/scripts/get_date.sh --list-timezones
```

### 4 — Interpret the Output

**`long` format (default):**
```
Saturday, October 04 2026  01:16:35  IST  UTC+05:30 [DST active]
```

**`all` format:**
```
Timezone   : Asia/Kolkata
Local time : Saturday, October 04 2026  01:16:35
Abbrev     : IST
UTC offset : UTC+05:30
ISO 8601   : 2026-10-04T01:16:35+05:30
UTC time   : 2026-10-03 19:46:35
Unix epoch : 1759524395
```

**World clock (`--compare`) format:**
```
============================================================
  World Clock  —  UTC: 2026-10-03 19:46:35
============================================================
UTC:                           2026-10-03 19:46  (UTC  UTC+00:00)
America/New_York:              2026-10-03 15:46  (EDT  UTC-04:00 [DST active])
Europe/London:                 2026-10-03 20:46  (BST  UTC+01:00 [DST active])
Asia/Kolkata:                  2026-10-04 01:16  (IST  UTC+05:30)
Asia/Tokyo:                    2026-10-04 04:46  (JST  UTC+09:00)
```

### 5 — Report the Result

Report the script output verbatim. For world clock requests, present the
table clearly. If the user asks "is DST active?", check for `[DST active]`
in the output.

---

## Validation

- Output must be non-empty and contain a recognisable year (4 digits).
- `--format iso` output must match `YYYY-MM-DDTHH:MM:SS±HH:MM`.
- `--format unix` output must be a large integer (~10 digits).
- If timezone is unknown, the script prints an error and lists fuzzy matches.

**Fallback** if scripts fail:
```powershell
Get-Date -Format "dddd, MMMM dd yyyy HH:mm:ss zzz"
```
```bash
date "+%A, %B %d %Y %H:%M:%S %Z (UTC%z)"
```

---

## ⚠️ Important

- **Do NOT** guess or assume the current date from your training data.
- **Do NOT** assume a timezone offset — always run the script to get the live DST-aware offset.
- **Do NOT** say "as of my knowledge cutoff…" for simple date questions.
- **Always** detect the OS first and use the script output as the authoritative answer.
- For timezone name ambiguity (e.g. "EST" vs "Eastern Time"), prefer the full IANA name.
