---
name: memory
description: >-
  Use this skill to store, retrieve, search, update, or delete persistent
  key-value memories that survive across agent sessions and conversations.
  Use it when the user wants to remember something for later (API endpoints,
  project notes, personal preferences, recurring snippets, configuration
  values) or when you need to recall something that was saved previously.
  LLMs have no built-in persistent memory — this skill provides it via a
  local JSON store (~/.agent-memory.json by default).
---

# Memory — Persistent Key-Value Store

LLMs forget everything between sessions. This skill provides a **persistent
memory store** backed by a local JSON file so that important information can
survive across conversations, projects, and agent restarts.

---

## When to Activate

- "Remember that the API base URL is https://api.example.com"
- "What was the database connection string I saved?"
- "Store my preferred code style settings"
- "List everything I've saved about this project"
- "Forget the old API key"
- "Search my memories for anything about 'auth'"
- "Save this snippet for later"
- Any request to remember, recall, store, retrieve, or forget information.

---

## Memory Store Location

| Priority | Location | When used |
|----------|----------|-----------|
| 1 (explicit) | `-StorePath` / `--store-path` flag | Always overrides |
| 2 (env var) | `$AGENT_MEMORY_PATH` | If set in environment |
| 3 (default) | `~/.agent-memory.json` | Fallback — cross-project |

---

## Steps

### 1 — Detect the Operating System

```powershell
# PowerShell
$IsWindows  # $true on Windows
$IsLinux    # $true on Linux
$IsMacOS    # $true on macOS
```
```bash
# Bash
uname -s   # Linux | Darwin | MINGW* (Windows/Git Bash)
```

### 2 — Identify the Operation and Parameters

| Operation | What it does | Required params |
|-----------|-------------|-----------------|
| `set` | Store or update a memory | `-Key`, `-Value` |
| `get` | Retrieve a specific memory | `-Key` |
| `list` | List all memories (optionally filtered by tag) | _(none)_ |
| `delete` | Remove a specific memory | `-Key` |
| `search` | Full-text search across keys, values, notes, tags | `-Query` |
| `clear` | ⚠️ Delete ALL memories (requires `-Confirm`) | `-Confirm` |
| `export` | Print entire store as formatted JSON | _(none)_ |
| `import` | Merge memories from a JSON file | `-File` |
| `tag` | Add or remove tags on an existing memory | `-Key`, `-Tags` |
| `note` | Add or update the description/note for a memory | `-Key`, `-Note` |

### 3 — Run the Correct Script

**Windows (PowerShell):**
```powershell
# Store a memory
.\skills\memory\scripts\memory.ps1 -Operation set -Key "api.base_url" -Value "https://api.example.com" -Note "Production API" -Tags "api,config"

# Retrieve a memory
.\skills\memory\scripts\memory.ps1 -Operation get -Key "api.base_url"

# List all memories
.\skills\memory\scripts\memory.ps1 -Operation list

# List by tag
.\skills\memory\scripts\memory.ps1 -Operation list -Tags "api"

# Search
.\skills\memory\scripts\memory.ps1 -Operation search -Query "api"

# Delete
.\skills\memory\scripts\memory.ps1 -Operation delete -Key "api.base_url"

# Export full store
.\skills\memory\scripts\memory.ps1 -Operation export

# Clear all (requires confirmation)
.\skills\memory\scripts\memory.ps1 -Operation clear -Confirm
```

**Linux / macOS (Bash):**
```bash
# Store a memory
bash ./skills/memory/scripts/memory.sh --operation set --key "api.base_url" --value "https://api.example.com" --note "Production API" --tags "api,config"

# Retrieve a memory
bash ./skills/memory/scripts/memory.sh --operation get --key "api.base_url"

# List all memories
bash ./skills/memory/scripts/memory.sh --operation list

# List by tag
bash ./skills/memory/scripts/memory.sh --operation list --tags "api"

# Search
bash ./skills/memory/scripts/memory.sh --operation search --query "api"

# Delete
bash ./skills/memory/scripts/memory.sh --operation delete --key "api.base_url"

# Export full store
bash ./skills/memory/scripts/memory.sh --operation export

# Clear all
bash ./skills/memory/scripts/memory.sh --operation clear --confirm
```

### 4 — Interpret Output

**`set` / `update`:**
```
✅ Saved: api.base_url
   Value : https://api.example.com
   Tags  : api, config
   Note  : Production API
   Saved : 2026-10-03T22:51:00+05:30
```

**`get`:**
```
Key    : api.base_url
Value  : https://api.example.com
Tags   : api, config
Note   : Production API
Created: 2026-10-03T22:51:00+05:30
Updated: 2026-10-03T22:51:00+05:30
```

**`list`:**
```
📦 Memory store — 3 entries  (~/.agent-memory.json)
──────────────────────────────────────────────────────
  api.base_url          [api, config]     Production API
  db.connection_string  [db, config]      Dev database
  code.style            [preferences]     Preferred formatting rules
```

**`search` "api":**
```
🔍 Search results for "api" — 2 matches
──────────────────────────────────────────────────────
  api.base_url          https://api.example.com
  auth.token_endpoint   https://api.example.com/auth
```

---

## Memory Store Format

The store is a plain JSON file — human-readable and portable:

```json
{
  "version": "1.0",
  "memories": {
    "api.base_url": {
      "value": "https://api.example.com",
      "tags": ["api", "config"],
      "note": "Production API base URL",
      "created": "2026-10-03T22:51:00+05:30",
      "updated": "2026-10-03T22:51:00+05:30"
    }
  }
}
```

You can back it up, version-control it, or share it across machines.

---

## Key Naming Conventions

Use dot-notation for namespacing, e.g.:
- `project.api_url` — project-specific API URL
- `db.dev.connection` — dev database connection
- `pref.code_style` — personal preference
- `snippet.auth_header` — reusable code snippet

---

## Validation

- `set` must print `✅ Saved: <key>` on success.
- `get` on an unknown key must print `❌ Key not found: <key>`.
- `list` must print entry count and file path.
- `search` must print match count (can be zero matches).
- `clear` without `-Confirm` must print a warning and NOT delete.

---

## ⚠️ Important

- **Do NOT** store secrets (passwords, API keys) in plain text — use a secrets manager for those.
- The `clear` operation is **irreversible** — always require explicit `-Confirm` / `--confirm`.
- If a key already exists, `set` **updates** it (preserves `created` timestamp, updates `updated`).
- The store file is created automatically on first `set` if it doesn't exist.
- The store is local to the machine — it does **not** sync to the cloud automatically.
