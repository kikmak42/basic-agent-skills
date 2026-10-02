---
name: basic-math
description: >-
  Use this skill whenever the user asks for arithmetic calculations, number
  crunching, expression evaluation, percentages, powers, square roots, or any
  numerical computation where precision matters. LLMs can make arithmetic
  mistakes — always detect the OS and run the appropriate calculator script
  to get the exact answer.
---

# Basic Math / Arithmetic

LLMs are language models, not calculators. They can and do make arithmetic
errors, especially with large numbers, floating-point values, or multi-step
expressions. **Always detect the OS and delegate numerical computation to
the correct script.**

## When to Activate

- "What is 17 × 83?"
- "Calculate 2^32."
- "What is 15% of 847?"
- "Evaluate: (123 + 456) / 7 - 89"
- "What is the square root of 2?"
- Any expression involving `+`, `-`, `*`, `/`, `**`, `%`, `sqrt`, `log`, etc.

## Steps

### 1 — Extract the Expression

Take the expression exactly as stated by the user, or translate their words
into a mathematical expression (e.g., "15 percent of 847" → `0.15 * 847`).

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
.\skills\basic-math\scripts\calculate.ps1 -Expression "<expression>"
```

Examples:
```powershell
.\skills\basic-math\scripts\calculate.ps1 -Expression "17 * 83"
.\skills\basic-math\scripts\calculate.ps1 -Expression "2 ** 32"
.\skills\basic-math\scripts\calculate.ps1 -Expression "(123 + 456) / 7 - 89"
.\skills\basic-math\scripts\calculate.ps1 -Expression "0.15 * 847"
.\skills\basic-math\scripts\calculate.ps1 -Expression "[Math]::Sqrt(2)"
```

**Linux / macOS (Bash):**
```bash
bash ./skills/basic-math/scripts/calculate.sh "<expression>"
```

Examples:
```bash
bash ./skills/basic-math/scripts/calculate.sh "17 * 83"
bash ./skills/basic-math/scripts/calculate.sh "2 ** 32"
bash ./skills/basic-math/scripts/calculate.sh "(123 + 456) / 7 - 89"
bash ./skills/basic-math/scripts/calculate.sh "0.15 * 847"
bash ./skills/basic-math/scripts/calculate.sh "math.sqrt(2)"
```

> The bash script uses `python3` (preferred) or `bc` as a fallback.
> Common math functions (`sqrt`, `log`, `log10`, `sin`, `cos`, `pi`, `e`) are
> available directly without a `math.` prefix when using the script.

### 4 — Report the Result

Show the expression and the computed answer. Example:
> `17 × 83 = 1411`

## Supported Operations

| Operation | PowerShell Syntax | Bash / Python Syntax |
|-----------|------------------|---------------------|
| Addition | `3 + 4` | `3 + 4` |
| Subtraction | `10 - 7` | `10 - 7` |
| Multiplication | `6 * 9` | `6 * 9` |
| Division | `22 / 7` | `22 / 7` |
| Integer division | `[Math]::Truncate(22/7)` | `22 // 7` |
| Modulo | `17 % 5` | `17 % 5` |
| Exponentiation | `2 ** 10` | `2 ** 10` |
| Square root | `[Math]::Sqrt(144)` | `sqrt(144)` |
| Logarithm | `[Math]::Log(1000, 10)` | `log10(1000)` |
| Absolute value | `[Math]::Abs(-42)` | `abs(-42)` |

## Validation

- The script prints the numeric result on a single line.
- If the script returns an error (e.g., division by zero), report the error
  clearly and do not guess an answer.

## ⚠️ Important

- **Do NOT** compute multi-step arithmetic in your head and present it as fact.
- **Do NOT** round or approximate unless the user explicitly asks.
- **Always** detect the OS and run the correct script.
