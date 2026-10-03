---
name: git-info
description: Get the actual current state of a git repository — branch, status, recent commits, remotes, stash.
---

# git-info

## When to Activate
Activate this skill when the user asks questions like:
- "What branch am I on?"
- "What files are modified in git?"
- "Show me recent commit history"
- "What is my git status?"
- "What's staged?"
- "What remotes exist for this repo?"

## OS Detection
Before running, detect the OS:
- **Windows**: Use `pwsh -NoProfile -File scripts\git_info.ps1`
- **Unix (Linux/macOS)**: Use `bash scripts/git_info.sh`

## Steps

### Windows
```powershell
pwsh -NoProfile -File c:\Users\Kaushik\Work\2026\basic-agent-skills\skills\git-info\scripts\git_info.ps1 -Show all -Path .
```

### Unix
```bash
bash /path/to/basic-agent-skills/skills/git-info/scripts/git_info.sh --show all --path .
```

## Validation
Valid output should include the requested git information (e.g., branch name, status list, recent commits). If the directory is not a git repository, the tool will output a clear message indicating so.

## Important / Guardrails
- **READ ONLY**: This skill is purely for reading state. NEVER run git commands that modify state (commit, push, checkout, reset) through this skill.
- **Why LLMs need this tool**: LLMs cannot know the actual state of a local git repository without running git commands.
