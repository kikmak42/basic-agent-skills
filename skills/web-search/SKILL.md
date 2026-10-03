---
name: web-search
description: Fetch live data from the web using DuckDuckGo API or URL.
---

# web-search

## When to Activate
Activate this skill when the user asks for current events, live prices, recent news, or any fact that could have changed after training cutoff.

## OS Detection
Before running, detect the OS:
- PowerShell: `if ($IsWindows) { ... } elseif ($IsLinux -or $IsMacOS) { ... }`
- Bash: `uname -s`

## Steps
1. Determine the query or URL to fetch.
2. Check the operating system.
3. Run the appropriate script:
   - Windows: `.\scripts\web_search.ps1 -Query "<query>"`
   - Linux/macOS: `./scripts/web_search.sh "<query>"`

## Validation
Verify that the output contains the search result or abstract. If the API returns nothing, try a different query.

## Important / Guardrails
- DO NOT guess or hallucinate facts that require live data.
- Ensure the query is properly escaped to avoid command injection.
