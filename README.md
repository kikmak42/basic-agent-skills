# 🤖 Basic Agent Skills

A collection of **OS-agnostic** skills that patch well-known LLM blind spots — things the model cannot do reliably on its own and must delegate to real tools or scripts.

> **Cross-platform:** Every skill ships a PowerShell script (`.ps1`) for Windows and a Bash script (`.sh`) for Linux/macOS. Each skill's `SKILL.md` instructs the agent to **detect the OS first** and run the correct script automatically.

---

## Why This Exists

LLMs are trained on static snapshots of the world. They have no clock, no source of entropy, and no guaranteed arithmetic precision. This repo teaches the agent the correct procedure for each of these tasks so it **always reaches for the right tool** instead of hallucinating an answer.

---

## Skill Registry

| # | Skill | Folder | OS Support | Status | Description |
|---|-------|--------|------------|--------|-------------|
| 1 | **Get Today's Date** | `skills/get-date/` | 🪟 Win + 🐧 Unix | ✅ Done | Fetch the real current date/time via the OS clock — never guess. |
| 2 | **Generate Random Number** | `skills/random-number/` | 🪟 Win + 🐧 Unix | ✅ Done | Produce a cryptographically-seeded random number using OS entropy. |
| 3 | **Basic Math** | `skills/basic-math/` | 🪟 Win + 🐧 Unix | ✅ Done | Evaluate arithmetic expressions with a real calculator to avoid rounding errors. |
| 4 | **Web Search / Live Data** | `skills/web-search/` | 🪟 Win + 🐧 Unix | 🔜 Planned | Retrieve up-to-date facts the model's training data doesn't contain. |
| 5 | **File System Operations** | `skills/file-ops/` | 🪟 Win + 🐧 Unix | 🔜 Planned | Reliable read/write/list operations without guessing paths or contents. |
| 6 | **Run Unit Tests** | `skills/run-tests/` | 🪟 Win + 🐧 Unix | 🔜 Planned | Execute the project's test suite and surface results instead of predicting them. |
| 7 | **Execute Shell Command** | `skills/shell-exec/` | 🪟 Win + 🐧 Unix | 🔜 Planned | Run arbitrary shell commands and return real stdout/stderr. |
| 8 | **UUID / Token Generation** | `skills/uuid-gen/` | 🪟 Win + 🐧 Unix | 🔜 Planned | Generate valid UUIDs or secure tokens — not made-up strings. |
| 9 | **Currency / Unit Conversion** | `skills/convert/` | 🪟 Win + 🐧 Unix | 🔜 Planned | Live conversion rates or precise unit math via a dedicated script. |
| 10 | **Read Environment Variables** | `skills/env-vars/` | 🪟 Win + 🐧 Unix | 🔜 Planned | Inspect real runtime env vars instead of assuming defaults. |

---

## Status Legend

| Badge | Meaning |
|-------|---------|
| ✅ Done | Skill created and ready to use |
| 🚧 WIP | Skill in progress |
| 🔜 Planned | On the roadmap, not yet built |
| ❌ Blocked | Blocked by a dependency or decision |

---

## OS Detection

Each skill's `SKILL.md` instructs the agent to detect the OS before running a script. The standard pattern used across all skills:

**In PowerShell:**
```powershell
if ($IsWindows) { <run .ps1> }
elseif ($IsLinux -or $IsMacOS) { bash <run .sh> }
```

**In Bash:**
```bash
case "$(uname -s)" in
  Linux|Darwin) bash ./skills/<name>/scripts/<script>.sh ;;
  MINGW*|CYGWIN*) pwsh ./skills/<name>/scripts/<script>.ps1 ;;
esac
```

---

## Structure

```
skills/
├── get-date/
│   ├── SKILL.md
│   └── scripts/
│       ├── get_date.ps1      # Windows (PowerShell)
│       └── get_date.sh       # Linux / macOS (Bash)
├── random-number/
│   ├── SKILL.md
│   └── scripts/
│       ├── random_number.ps1 # Windows (PowerShell)
│       └── random_number.sh  # Linux / macOS (Bash)
└── basic-math/
    ├── SKILL.md
    └── scripts/
        ├── calculate.ps1     # Windows (PowerShell / .NET Math)
        └── calculate.sh      # Linux / macOS (python3 or bc)
```

---

## Using Skills in Another Agent / Project

These skills are designed to be dropped into **any** Antigravity workspace:

1. Copy the `skills/` folder into your project's `.agents/` directory:
   ```
   your-project/
   └── .agents/
       └── skills/
           ├── get-date/
           ├── random-number/
           └── basic-math/
   ```
2. Antigravity will auto-discover them and make them available to the agent.
3. The agent reads each skill's `SKILL.md` and will use the OS-appropriate
   script automatically.

---

## Contributing a New Skill

1. Create a folder under `skills/<skill-name>/`.
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`).
3. Add **both** a `.ps1` (Windows) and a `.sh` (Linux/macOS) script under `scripts/`.
4. Include OS detection instructions in `SKILL.md`.
5. Update the **Skill Registry** table above with its status.
