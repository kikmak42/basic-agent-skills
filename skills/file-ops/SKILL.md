---
name: file-ops
description: Reliable file system operations — read file contents, list directory, check if path exists, write text to file.
---

# file-ops

## When to Activate
Activate this skill when the user asks to read a file, list a folder, check if something exists, or write content to a file.

## OS Detection
Before running, detect the OS:
- PowerShell: `if ($IsWindows) { ... } elseif ($IsLinux -or $IsMacOS) { ... }`
- Bash: `uname -s`

## Steps
1. Determine the operation: read, list, exists, or write.
2. Check the operating system.
3. Run the appropriate script:
   - Windows: `.\scripts\file_ops.ps1 -Operation <op> -Path <path> [-Content <content>]`
   - Linux/macOS: `./scripts/file_ops.sh <op> <path> [content]`

## Validation
Verify that the output matches the expected operation (e.g., file contents are printed, directory is listed).

## Important / Guardrails
- NEVER guess file contents or directory listings.
- When writing files, double check if the file already exists and if overwriting is intended.
