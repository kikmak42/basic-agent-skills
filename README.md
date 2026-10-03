# 🤖 Basic Agent Skills

A collection of **OS-agnostic** skills that patch well-known LLM blind spots — things the model cannot do reliably on its own and must delegate to real tools or scripts.

> **Cross-platform:** Every skill ships a PowerShell script (`.ps1`) for Windows and a Bash script (`.sh`) for Linux/macOS. Each skill's `SKILL.md` instructs the agent to **detect the OS first** and run the correct script automatically.

---

## Why This Exists

LLMs are trained on static snapshots of the world. They have no clock, no source of entropy, no arithmetic guarantees, and no access to live data or the file system. This repo teaches agents the correct procedure for each of these tasks so they **always reach for the right tool** instead of hallucinating an answer.

---

## Skill Registry

| # | Skill | Folder | OS Support | Status | Description |
|---|-------|--------|------------|--------|-------------|
| 1 | **Get Today's Date** | `skills/get-date/` | 🪟 Win + 🐧 Unix | ✅ Done | Fetch the real current date/time via the OS clock — never guess. |
| 2 | **Generate Random Number** | `skills/random-number/` | 🪟 Win + 🐧 Unix | ✅ Done | Produce a cryptographically-seeded random number using OS entropy. |
| 3 | **Basic Math** | `skills/basic-math/` | 🪟 Win + 🐧 Unix | ✅ Done | Evaluate arithmetic expressions with a real calculator to avoid rounding errors. |
| 4 | **Web Search / Live Data** | `skills/web-search/` | 🪟 Win + 🐧 Unix | ✅ Done | Fetch live facts from the web that the model's training data doesn't contain. |
| 5 | **File System Operations** | `skills/file-ops/` | 🪟 Win + 🐧 Unix | ✅ Done | Reliable read/write/list/exists operations — never guess file contents or paths. |
| 6 | **Run Unit Tests** | `skills/run-tests/` | 🪟 Win + 🐧 Unix | ✅ Done | Auto-detect framework (pytest/jest/dotnet/go/cargo) and run the real test suite. |
| 7 | **Execute Shell Command** | `skills/shell-exec/` | 🪟 Win + 🐧 Unix | ✅ Done | Run commands safely with blocklist validation — return real stdout/stderr. |
| 8 | **UUID / Token Generation** | `skills/uuid-gen/` | 🪟 Win + 🐧 Unix | ✅ Done | Generate valid UUID v4s or secure random tokens — not made-up strings. |
| 9 | **Unit Conversion** | `skills/convert/` | 🪟 Win + 🐧 Unix | ✅ Done | Accurate conversion for length, weight, temperature, volume, speed, and data sizes. |
| 10 | **Read Environment Variables** | `skills/env-vars/` | 🪟 Win + 🐧 Unix | ✅ Done | Inspect real runtime env vars with automatic secret redaction. |

---

## Guardrails

All skills follow a shared set of **safety guardrails** defined in [`guardrails/GUARDRAILS.md`](./guardrails/GUARDRAILS.md). Six guardrail categories apply across all skills:

| Category | Description |
|----------|-------------|
| **Input Validation** | All inputs are sanitised before being passed to scripts (blocks injection, traversal, etc.) |
| **Secret Redaction** | Outputs containing secret-looking values are automatically redacted (`[REDACTED]`) |
| **Scope Limiting** | Each skill operates only within its defined domain — no cross-skill side effects |
| **Command Safety** | `shell-exec` validates every command against a blocklist before execution |
| **Fail Safe** | If a script errors, the agent reports the error — it never guesses a fallback answer |
| **Transparency** | For destructive operations, the agent shows the user what will run before running it |

Guardrail validation scripts live in [`guardrails/scripts/`](./guardrails/scripts/):

| Script | Purpose |
|--------|---------|
| `validate_expression.ps1` / `.sh` | Blocks dangerous .NET/system calls in math expressions |
| `validate_path.ps1` / `.sh` | Blocks path traversal and access to sensitive system files |
| `validate_command.ps1` / `.sh` | Enforces shell command blocklist before execution |
| `redact_secrets.ps1` / `.sh` | Redacts secret-looking key=value pairs in any output |

---

## Evals

The [`evals/`](./evals/) directory contains a **pytest-based evaluation framework** that tests the scripts directly (not the LLM), following the _inspect-ai_ / script-eval convention.

```bash
# Install dependencies
pip install -r evals/requirements.txt

# Run all evals
pytest evals/tests/ -v

# Run with scorecard summary
python evals/run_evals.py
```

Evals are organized per skill:

| Eval file | What it tests |
|-----------|--------------|
| `test_get_date.py` | Output is non-empty, contains year + day/month name, ISO 8601 present |
| `test_random_number.py` | Integers in range, correct count, floats in [0,1) |
| `test_basic_math.py` | Arithmetic correctness with `pytest.approx` float tolerance |
| `test_uuid_gen.py` | UUID v4 regex, token hex length, correct count |
| `test_convert.py` | Numeric accuracy within tolerance (km→mi, °C→°F, kg→lb, GB→MB) |
| `test_env_vars.py` | Secret redaction works; known var returns non-empty |
| `test_guardrails.py` | Validation scripts block bad inputs (exit 1) and pass good inputs (exit 0) |
| `test_web_search.py` | _(skipped — requires network)_ |
| `test_file_ops.py` | _(skipped — requires filesystem setup)_ |
| `test_run_tests.py` | _(skipped — requires project with test suite)_ |
| `test_shell_exec.py` | _(skipped — requires controlled environment)_ |

---

## OS Detection Pattern

Every skill detects the OS before running a script. The standard pattern used:

**PowerShell:**
```powershell
if ($IsWindows) {
    .\skills\<name>\scripts\<script>.ps1 [args]
} elseif ($IsLinux -or $IsMacOS) {
    bash ./skills/<name>/scripts/<script>.sh [args]
}
```

**Bash:**
```bash
case "$(uname -s)" in
  Linux|Darwin) bash ./skills/<name>/scripts/<script>.sh [args] ;;
  MINGW*|CYGWIN*) pwsh ./skills/<name>/scripts/<script>.ps1 [args] ;;
esac
```

---

## Repository Structure

```
basic-agent-skills/
├── README.md
├── skills/                        # 10 OS-agnostic agent skills
│   ├── get-date/
│   ├── random-number/
│   ├── basic-math/
│   ├── web-search/
│   ├── file-ops/
│   ├── run-tests/
│   ├── shell-exec/
│   ├── uuid-gen/
│   ├── convert/
│   └── env-vars/
│       ├── SKILL.md               # Agent instructions (OS detection + steps)
│       └── scripts/
│           ├── <script>.ps1       # Windows (PowerShell)
│           └── <script>.sh        # Linux / macOS (Bash)
├── guardrails/                    # Safety constraints for all skills
│   ├── GUARDRAILS.md
│   └── scripts/
│       ├── validate_expression.{ps1,sh}
│       ├── validate_path.{ps1,sh}
│       ├── validate_command.{ps1,sh}
│       └── redact_secrets.{ps1,sh}
└── evals/                         # pytest evaluation framework
    ├── README.md
    ├── requirements.txt
    ├── conftest.py
    ├── run_evals.py
    ├── fixtures/                  # YAML test case definitions (1 per skill)
    └── tests/                     # pytest test files (1 per skill)
```

---

## Integrations

The skills work with **every major AI coding assistant and agent framework** — not just Antigravity. The `integrations/` directory contains ready-to-use adapters for each.

> **Design philosophy:** Every integration is a thin wrapper around the same scripts. Fix a bug in a script and it's fixed everywhere — Claude, Cursor, LangChain, AutoGen, all of them.

### 🖥️ AI Coding Assistants / IDEs

| Platform | Integration Type | File to copy | Where it goes |
|----------|-----------------|-------------|---------------|
| **Antigravity** | Native `SKILL.md` discovery | `skills/` | `.agents/skills/` in your project |
| **Claude Code** | `CLAUDE.md` instructions | [`integrations/ide/claude/CLAUDE.md`](./integrations/ide/claude/CLAUDE.md) | Project root |
| **Cursor** | `.mdc` rule (`alwaysApply: true`) | [`integrations/ide/cursor/.cursor/`](./integrations/ide/cursor/.cursor/) | Project root |
| **VS Code Copilot** | Copilot instructions | [`integrations/ide/vscode/.github/`](./integrations/ide/vscode/.github/) | Project root |
| **Windsurf** | `.windsurfrules` | [`integrations/ide/windsurf/.windsurfrules`](./integrations/ide/windsurf/.windsurfrules) | Project root |
| **Any MCP client** | FastMCP server | [`integrations/mcp/server.py`](./integrations/mcp/server.py) | Run as a server process |

**MCP** (Model Context Protocol) is the most universal option — it works with Claude Desktop, Cursor's MCP support, VS Code extensions like Continue/Cline, and any other MCP-compatible client:

```bash
pip install -r integrations/mcp/requirements.txt
python integrations/mcp/server.py
```

Then point your client at the server using [`integrations/mcp/claude_desktop_config.example.json`](./integrations/mcp/claude_desktop_config.example.json) as a reference.

See [`integrations/ide/README.md`](./integrations/ide/README.md) for detailed setup instructions per IDE.

---

### 🐍 Agent Frameworks / SDKs

All adapters share a common [`integrations/frameworks/shared/skill_runner.py`](./integrations/frameworks/shared/skill_runner.py) that handles OS detection and subprocess execution.

| Framework | Package | Import |
|-----------|---------|--------|
| **LangChain** | `langchain-core>=0.3` | `from integrations.frameworks.langchain.tools import ALL_TOOLS` |
| **AWS Strands** | `strands-agents>=0.1` | `from integrations.frameworks.strands.tools import ALL_TOOLS` |
| **CrewAI** | `crewai>=0.80` | `from integrations.frameworks.crewai.tools import ALL_TOOLS` |
| **AutoGen** | `autogen-agentchat>=0.4` | `from integrations.frameworks.autogen.tools import ALL_TOOLS` |
| **LlamaIndex** | `llama-index-core>=0.11` | `from integrations.frameworks.llamaindex.tools import ALL_TOOLS` |

**LangChain quick start:**
```python
from langchain_openai import ChatOpenAI
from langchain.agents import create_tool_calling_agent, AgentExecutor
from integrations.frameworks.langchain.tools import ALL_TOOLS

llm = ChatOpenAI(model="gpt-4o")
executor = AgentExecutor(agent=create_tool_calling_agent(llm, ALL_TOOLS, prompt), tools=ALL_TOOLS)
executor.invoke({"input": "What is today's date and what is 17 * 83?"})
```

See [`integrations/frameworks/README.md`](./integrations/frameworks/README.md) for full examples per framework and [`integrations/README.md`](./integrations/README.md) for the complete integration map.

---

## Repository Structure

```
basic-agent-skills/
├── README.md
├── skills/                        # 10 OS-agnostic agent skills
│   └── <skill>/
│       ├── SKILL.md               # Agent instructions (OS detection + steps)
│       └── scripts/
│           ├── <script>.ps1       # Windows (PowerShell)
│           └── <script>.sh        # Linux / macOS (Bash)
├── guardrails/                    # Safety constraints for all skills
│   ├── GUARDRAILS.md
│   └── scripts/                   # validate_expression, validate_path, validate_command, redact_secrets
├── evals/                         # pytest evaluation framework
│   ├── fixtures/                  # YAML test cases (1 per skill)
│   └── tests/                     # pytest test files (1 per skill)
└── integrations/                  # Adapters for every AI platform
    ├── README.md
    ├── ide/                       # Drop-in files for coding assistants
    │   ├── claude/CLAUDE.md
    │   ├── cursor/.cursor/rules/
    │   ├── vscode/.github/
    │   └── windsurf/.windsurfrules
    ├── mcp/                       # FastMCP server (universal)
    │   └── server.py
    └── frameworks/                # Python SDK adapters
        ├── shared/skill_runner.py # OS-aware script runner (shared by all)
        ├── langchain/tools.py
        ├── strands/tools.py
        ├── crewai/tools.py
        ├── autogen/tools.py
        └── llamaindex/tools.py
```

---

## Contributing a New Skill

1. Create a folder under `skills/<skill-name>/`.
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`).
3. Add **both** a `.ps1` (Windows) and a `.sh` (Linux/macOS) script under `scripts/`.
4. Include OS detection instructions in `SKILL.md`.
5. Add YAML fixtures in `evals/fixtures/<skill-name>.yaml` and a test file in `evals/tests/test_<skill_name>.py`.
6. Add an `@tool` function to each `integrations/frameworks/*/tools.py`.
7. Add the skill to `integrations/mcp/server.py`.
8. Add instructions for the skill to all IDE rules files in `integrations/ide/`.
9. Review `guardrails/GUARDRAILS.md` and add skill-specific guardrail notes.
10. Update the **Skill Registry** table in this README.
