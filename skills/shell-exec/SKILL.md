---
name: shell-exec
description: Run arbitrary shell commands safely with guardrails.
---

# shell-exec

## When to Activate
Activate this skill when the user asks to run a command, execute a script, or check the output of a tool.

## OS Detection
Before running, detect the OS:
- PowerShell: `if ($IsWindows) { ... } elseif ($IsLinux -or $IsMacOS) { ... }`
- Bash: `uname -s`

## Steps
1. Formulate the command to run.
2. Check the operating system.
3. Show the command to the user (in conversation/thought) before running it.
4. Run the appropriate script:
   - Windows: `.\scripts\shell_exec.ps1 -Command "<command>"`
   - Linux/macOS: `./scripts/shell_exec.sh "<command>"`

## Validation
Verify that the output (stdout/stderr) and exit code are returned. 

## Important / Guardrails
- ALWAYS validate the command against blocked patterns before executing.
- ALWAYS show the user what command will be run before running it.
- NEVER run commands that could cause data loss or system damage.
- DO NOT predict output; rely on the script execution.
