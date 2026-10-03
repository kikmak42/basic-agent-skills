# Framework Integrations

Welcome to the framework adapters for `basic-agent-skills`. These integrations allow you to quickly consume native bash/PowerShell skills as Python tools within popular Agent frameworks.

## Introduction
Agent frameworks have different ways of defining tools (e.g. `FunctionTool`, `@tool` decorators, etc.). This directory provides ready-made Python wrappers that convert simple function calls into cross-platform OS subprocess calls using the underlying agent scripts. 

## Architecture Diagram

```
User Prompt
    │
    ▼
Framework Agent
    │
    ▼
Tool Call (Python)
    │
    ▼
skill_runner.py (OS Detection)
    │
    ├──────── Windows ───────► powershell.exe -File script.ps1
    │
    └──────── Unix/Mac ──────► bash script.sh
                                  │
                                  ▼
                            Result (stdout)
                                  │
                                  ▼
                           Framework Agent
```

## Supported Frameworks

| Framework | Package | tools.py | Example | Min Python Version |
|-----------|---------|----------|---------|--------------------|
| AutoGen   | `autogen-agentchat` | `autogen/tools.py` | `autogen/example.py` | 3.8+ |
| LlamaIndex| `llama-index-core` | `llamaindex/tools.py` | `llamaindex/example.py` | 3.8+ |

## Quick Starts

### AutoGen
```bash
pip install -r autogen/requirements.txt
python -m autogen.example
```

### LlamaIndex
```bash
pip install -r llamaindex/requirements.txt
python -m llamaindex.example
```

## How it works

The core of the execution is handled by `shared/skill_runner.py`. This utility file performs automatic OS detection. If it detects Windows, it delegates the tool execution to the corresponding PowerShell (`.ps1`) script. If it detects a Unix-like system (Linux/macOS), it delegates to the Bash (`.sh`) script. This allows true cross-platform capabilities without rewriting logic natively in Python.

## Adding a new skill

1. Create the base scripts in the main `skills/` directory (`script.ps1` and `script.sh`).
2. Add a new wrapper function in `<framework>/tools.py` calling `run_skill("skill-name", "script_name", ps1_args, sh_args)`.
3. Wrap it in the framework-specific tool class (e.g., `FunctionTool`).
4. Append it to `ALL_TOOLS`.
