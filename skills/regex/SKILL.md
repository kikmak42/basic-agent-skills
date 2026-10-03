---
name: regex
description: Test regex patterns against strings, extract all matches, or perform replacements.
---

# regex

## When to Activate
Activate this skill when the user asks questions like:
- "Does this string match the pattern?"
- "Extract all emails/URLs/numbers from this text."
- "Test a regex for me."
- "Count occurrences of this pattern in the file."
- "Replace text matching this pattern."
- "Validate if this email/URL/date format is correct."

## OS Detection
Before running, detect the OS:
- **Windows**: Use `pwsh -NoProfile -File scripts\regex_ops.ps1`
- **Unix (Linux/macOS)**: Use `bash scripts/regex_ops.sh`

## Steps

### Windows
```powershell
pwsh -NoProfile -File c:\Users\Kaushik\Work\2026\basic-agent-skills\skills\regex\scripts\regex_ops.ps1 -Pattern 'regex_here' -InputString 'string_here' -Operation match
```

### Unix
```bash
bash /path/to/basic-agent-skills/skills/regex/scripts/regex_ops.sh --pattern 'regex_here' --input 'string_here' --operation match
```

## Validation
Valid output will return "MATCH" or "NO MATCH" and include matched groups or modified strings depending on the operation.

## Important / Guardrails
- **Why LLMs need this tool**: LLMs often predict regex matches incorrectly, especially for complex patterns, lookaheads, backreferences, and edge cases.
