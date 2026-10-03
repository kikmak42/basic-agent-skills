---
name: run-tests
description: Execute the project's test suite and return real pass/fail results.
---

# run-tests

## When to Activate
Activate this skill when the user asks to run tests, check if tests pass, or verify code correctness via tests.

## OS Detection
Before running, detect the OS:
- PowerShell: `if ($IsWindows) { ... } elseif ($IsLinux -or $IsMacOS) { ... }`
- Bash: `uname -s`

## Steps
1. Navigate to the project root.
2. Check the operating system.
3. Run the appropriate script:
   - Windows: `.\scripts\run_tests.ps1`
   - Linux/macOS: `./scripts/run_tests.sh`

## Validation
The script auto-detects the test framework. Verify that the output clearly shows the test summary (pass/fail).

## Important / Guardrails
- NEVER predict test results; always run them.
- If the framework cannot be detected, prompt the user for the appropriate test command.
