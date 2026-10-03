---
name: network-info
description: Get real network information - IP addresses, hostname, network interfaces.
---

# network-info

## When to Activate
Activate when the user asks for their IP address, machine hostname, what network interfaces are available, or their public IP.

## OS Detection
Before executing the script, detect the OS:
- **Windows**: Use `$IsWindows` in PowerShell
- **Linux/macOS**: Use `uname -s` in Bash

## Steps

### 1. Execute the appropriate script

**Windows**:
```powershell
pwsh -NoProfile -File .\scripts\network_info.ps1 -Show all
```

**Unix**:
```bash
bash ./scripts\network_info.sh --show external
```

## Validation
A valid output is the requested network information (IP addresses, interfaces list, hostname). 

## Important / Guardrails
**NEVER** guess IP addresses or hostnames. LLMs cannot know the actual machine's IP address, hostname, or network setup without running commands. Always execute the script.
