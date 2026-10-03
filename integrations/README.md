# Integrations Overview

The `basic-agent-skills` repository is designed to be easily pluggable into any agent environment. All our implementations are built around a core philosophy: **"Thin wrappers around the same scripts — one fix fixes all."** Whether you use a GUI IDE, a CLI code assistant, or a custom Python agent framework, the core logic stays inside the `.ps1` and `.sh` scripts.

## Philosophy

By keeping the business logic out of Python/JS wrappers and storing it purely in OS-level scripts, we ensure:
- Portability across platforms (Windows & Unix).
- Singular source of truth (bug fixes apply universally to all integrations).
- Simple debugging and extensibility.

## IDE & Coding Assistants

| Platform | Integration Type | File | Quick Start |
|----------|------------------|------|-------------|
| **Antigravity** | Native SKILL.md | `skills/` | Copy to `.agents/skills/` |
| **Claude Code** | CLAUDE.md | `integrations/ide/claude/CLAUDE.md` | Copy to project root |
| **Cursor** | .mdc rules | `integrations/ide/cursor/.cursor/` | Copy `.cursor/` to project root |
| **VS Code Copilot** | Instructions | `integrations/ide/vscode/.github/` | Copy `.github/` to project root |
| **Windsurf** | .windsurfrules | `integrations/ide/windsurf/` | Copy `.windsurfrules` to project root |
| **Any MCP client** | MCP Server | `integrations/mcp/server.py` | pip install + configure |

## Agent Frameworks

| Framework | Package | Quick Start |
|-----------|---------|-------------|
| **LangChain** | `langchain-core` | `from integrations.frameworks.langchain.tools import ALL_TOOLS` |
| **AWS Strands** | `strands-agents` | `from integrations.frameworks.strands.tools import ALL_TOOLS` |
| **CrewAI** | `crewai` | `from integrations.frameworks.crewai.tools import ALL_TOOLS` |
| **AutoGen** | `autogen-agentchat` | `from integrations.frameworks.autogen.tools import ALL_TOOLS` |
| **LlamaIndex** | `llama-index-core` | `from integrations.frameworks.llamaindex.tools import ALL_TOOLS` |

Explore the respective directories for more details!
