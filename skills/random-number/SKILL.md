---
name: random-number
description: >-
  Use this skill whenever the user asks for a random number, a random integer
  in a range, a random float, a random choice from a list, or anything requiring
  genuine randomness. LLMs are deterministic and cannot produce truly random
  values — always detect the OS and delegate to the appropriate helper script.
---

# Generate a Random Number

LLMs produce deterministic outputs — they only **appear** random. For real
randomness (e.g., dice rolls, lottery picks, passwords, sampling), always
detect the operating system and run the matching script which uses the OS
entropy source (`RNGCryptoServiceProvider` on Windows, `/dev/urandom` on Unix).

## When to Activate

- "Give me a random number."
- "Pick a random number between X and Y."
- "Roll a die / flip a coin."
- "Choose a random item from this list."
- "Generate a random float between 0 and 1."

## Steps

### 1 — Identify the Parameters

Extract from the user's request:
- `min` — lower bound (default: `1`)
- `max` — upper bound (default: `100`)
- `count` — how many numbers to generate (default: `1`)
- `type` — `int` or `float` (default: `int`)

### 2 — Detect the Operating System

```powershell
# PowerShell
$IsWindows  # $true on Windows
$IsLinux    # $true on Linux
$IsMacOS    # $true on macOS
```

```bash
# Bash
uname -s   # Linux | Darwin | MINGW* (Windows/Git Bash)
```

### 3 — Run the Correct Script

**Windows (PowerShell):**
```powershell
.\skills\random-number\scripts\random_number.ps1 -Min <min> -Max <max> -Count <count> -Type <type>
```

Examples:
```powershell
# Dice roll
.\skills\random-number\scripts\random_number.ps1 -Min 1 -Max 6

# Three random integers
.\skills\random-number\scripts\random_number.ps1 -Min 1 -Max 100 -Count 3

# Random float
.\skills\random-number\scripts\random_number.ps1 -Type float
```

**Linux / macOS (Bash):**
```bash
bash ./skills/random-number/scripts/random_number.sh --min <min> --max <max> --count <count> --type <type>
```

Examples:
```bash
# Dice roll
bash ./skills/random-number/scripts/random_number.sh --min 1 --max 6

# Three random integers
bash ./skills/random-number/scripts/random_number.sh --min 1 --max 100 --count 3

# Random float
bash ./skills/random-number/scripts/random_number.sh --type float
```

### 4 — Report the Output

The script prints each generated value on its own line. Report these to the user.

To pick a random item from a list, generate a random integer index from `0` to
`len(list) - 1`, then return `list[index]`.

## Validation

- The output must be within `[min, max]` (inclusive for integers).
- Verify the script ran successfully (exit code 0) before reporting results.

## ⚠️ Important

- **Do NOT** type out a number yourself and claim it is random.
- **Do NOT** use patterns like "42" or "7" which feel random but are biased.
- **Always** detect the OS and use the correct script for any randomness request.
