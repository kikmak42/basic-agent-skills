#!/usr/bin/env bash
# memory.sh — Persistent key-value memory store for agents.
#
# Stores named memories in ~/.agent-memory.json (or $AGENT_MEMORY_PATH).
# Requires python3 (stdlib only — no extra packages needed).
#
# Operations: set | get | list | delete | search | clear | export | import | tag | note
#
# Usage:
#   ./memory.sh --operation set --key "api.base_url" --value "https://example.com" --tags "api,config" --note "Prod API"
#   ./memory.sh --operation get --key "api.base_url"
#   ./memory.sh --operation list
#   ./memory.sh --operation list --tags "api"
#   ./memory.sh --operation search --query "api"
#   ./memory.sh --operation delete --key "api.base_url"
#   ./memory.sh --operation clear --confirm
#   ./memory.sh --operation export
#   ./memory.sh --operation import --file /path/to/backup.json

set -euo pipefail

OPERATION=""
KEY=""
VALUE=""
QUERY=""
TAGS=""
NOTE=""
FILE=""
STORE_PATH="${AGENT_MEMORY_PATH:-$HOME/.agent-memory.json}"
CONFIRM="false"

# ─── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --operation) OPERATION="$2"; shift 2 ;;
        --key)       KEY="$2";       shift 2 ;;
        --value)     VALUE="$2";     shift 2 ;;
        --query)     QUERY="$2";     shift 2 ;;
        --tags)      TAGS="$2";      shift 2 ;;
        --note)      NOTE="$2";      shift 2 ;;
        --file)      FILE="$2";      shift 2 ;;
        --store-path) STORE_PATH="$2"; shift 2 ;;
        --confirm)   CONFIRM="true"; shift ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$OPERATION" ]]; then
    echo "❌ --operation is required" >&2
    echo "   Valid operations: set | get | list | delete | search | clear | export | import | tag | note" >&2
    exit 1
fi

# ─── Python engine ────────────────────────────────────────────────────────────
PYTHON_BIN=""
if command -v python3 &>/dev/null && python3 -c "import sys" &>/dev/null; then
    PYTHON_BIN="python3"
elif command -v python &>/dev/null && python -c "import sys" &>/dev/null; then
    PYTHON_BIN="python"
else
    echo "Error: Python 3 is required for the memory skill." >&2
    exit 1
fi

"$PYTHON_BIN" - <<PYEOF
import json
import os
import sys
from datetime import datetime, timezone

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# ── Config ────────────────────────────────────────────────────────────────────
OPERATION  = "${OPERATION}"
KEY        = """${KEY}"""
VALUE      = """${VALUE}"""
QUERY      = "${QUERY}"
TAGS_STR   = "${TAGS}"
NOTE       = """${NOTE}"""
FILE_PATH  = "${FILE}"
STORE_PATH = "${STORE_PATH}"
CONFIRM    = "${CONFIRM}" == "true"

SEP = "─" * 54

def now_ts():
    return datetime.now().astimezone().isoformat(timespec="seconds")

def parse_tags(tag_str):
    if not tag_str.strip():
        return []
    return [t.strip() for t in tag_str.split(",") if t.strip()]

# ── Load store ────────────────────────────────────────────────────────────────
def load_store():
    if not os.path.exists(STORE_PATH):
        return {"version": "1.0", "memories": {}}
    with open(STORE_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

# ── Save store ────────────────────────────────────────────────────────────────
def save_store(store):
    os.makedirs(os.path.dirname(os.path.abspath(STORE_PATH)), exist_ok=True)
    with open(STORE_PATH, "w", encoding="utf-8") as f:
        json.dump(store, f, indent=2, ensure_ascii=False)
        f.write("\n")

store = load_store()
mems  = store.setdefault("memories", {})

# ══════════════════════════════════════════════════════════════════════════════
#  Operations
# ══════════════════════════════════════════════════════════════════════════════

if OPERATION == "set":
    if not KEY:   print("❌ --key is required for 'set'",   file=sys.stderr); sys.exit(1)
    if not VALUE: print("❌ --value is required for 'set'", file=sys.stderr); sys.exit(1)

    is_update   = KEY in mems
    created     = mems[KEY]["created"] if is_update else now_ts()
    parsed_tags = parse_tags(TAGS_STR) if TAGS_STR else (mems[KEY]["tags"] if is_update else [])
    parsed_note = NOTE if NOTE else (mems[KEY].get("note", "") if is_update else "")

    mems[KEY] = {
        "value":   VALUE,
        "tags":    parsed_tags,
        "note":    parsed_note,
        "created": created,
        "updated": now_ts(),
    }
    save_store(store)

    action = "Updated" if is_update else "Saved"
    print(f"✅ {action}: {KEY}")
    print(f"   Value : {VALUE}")
    if parsed_tags: print(f"   Tags  : {', '.join(parsed_tags)}")
    if parsed_note: print(f"   Note  : {parsed_note}")
    print(f"   Saved : {now_ts()}")

elif OPERATION == "get":
    if not KEY: print("❌ --key is required for 'get'", file=sys.stderr); sys.exit(1)
    if KEY not in mems:
        print(f"❌ Key not found: {KEY}")
        print("   Run --operation list to see all stored keys.")
        sys.exit(1)
    m = mems[KEY]
    print(f"Key    : {KEY}")
    print(f"Value  : {m['value']}")
    if m.get("tags"): print(f"Tags   : {', '.join(m['tags'])}")
    if m.get("note"): print(f"Note   : {m['note']}")
    print(f"Created: {m['created']}")
    print(f"Updated: {m['updated']}")

elif OPERATION == "list":
    filter_tag = parse_tags(TAGS_STR)[0] if TAGS_STR else None
    entries = sorted(mems.items())
    if filter_tag:
        entries = [(k, v) for k, v in entries if filter_tag in v.get("tags", [])]
    tag_label = f" [tag: {filter_tag}]" if filter_tag else ""
    plural = "entry" if len(entries) == 1 else "entries"
    print(f"📦 Memory store — {len(entries)} {plural}{tag_label}  ({STORE_PATH})")
    print(SEP)
    if not entries:
        print("  (empty)")
    else:
        for k, v in entries:
            tag_str  = f"  [{', '.join(v['tags'])}]" if v.get("tags") else ""
            note_str = f"  — {v['note']}" if v.get("note") else ""
            print(f"  {k:<28}{tag_str}{note_str}")

elif OPERATION == "delete":
    if not KEY: print("❌ --key is required for 'delete'", file=sys.stderr); sys.exit(1)
    if KEY not in mems:
        print(f"❌ Key not found: {KEY}")
        sys.exit(1)
    del mems[KEY]
    save_store(store)
    print(f"🗑️  Deleted: {KEY}")

elif OPERATION == "search":
    if not QUERY: print("❌ --query is required for 'search'", file=sys.stderr); sys.exit(1)
    q = QUERY.lower()
    matches = [
        (k, v) for k, v in sorted(mems.items())
        if q in k.lower()
        or q in v["value"].lower()
        or q in v.get("note", "").lower()
        or any(q in t.lower() for t in v.get("tags", []))
    ]
    plural = "" if len(matches) == 1 else "es"
    print(f"🔍 Search results for \"{QUERY}\" — {len(matches)} match{plural}")
    print(SEP)
    if not matches:
        print("  No matches found.")
    else:
        for k, v in matches:
            print(f"  {k:<28} {v['value']}")

elif OPERATION == "clear":
    if not CONFIRM:
        print(f"⚠️  WARNING: This will permanently delete ALL memories in {STORE_PATH}")
        print("   Re-run with --confirm to proceed:")
        print("   ./memory.sh --operation clear --confirm")
        sys.exit(0)
    count = len(mems)
    store["memories"] = {}
    save_store(store)
    plural = "memory" if count == 1 else "memories"
    print(f"🧹 Cleared {count} {plural} from {STORE_PATH}")

elif OPERATION == "export":
    if not os.path.exists(STORE_PATH):
        print("# Store is empty — nothing to export.")
        sys.exit(0)
    with open(STORE_PATH, "r", encoding="utf-8") as f:
        print(f.read(), end="")

elif OPERATION == "import":
    if not FILE_PATH: print("❌ --file is required for 'import'", file=sys.stderr); sys.exit(1)
    if not os.path.exists(FILE_PATH):
        print(f"❌ File not found: {FILE_PATH}", file=sys.stderr); sys.exit(1)
    with open(FILE_PATH, "r", encoding="utf-8") as f:
        imported = json.load(f)
    added = updated = 0
    for k, v in imported.get("memories", {}).items():
        is_update = k in mems
        mems[k] = {
            "value":   v["value"],
            "tags":    v.get("tags", []),
            "note":    v.get("note", ""),
            "created": mems[k]["created"] if is_update else v.get("created", now_ts()),
            "updated": now_ts(),
        }
        if is_update: updated += 1
        else:         added += 1
    save_store(store)
    print(f"📥 Import complete: {added} added, {updated} updated")

elif OPERATION == "tag":
    if not KEY:      print("❌ --key is required for 'tag'",   file=sys.stderr); sys.exit(1)
    if not TAGS_STR: print("❌ --tags is required for 'tag'",  file=sys.stderr); sys.exit(1)
    if KEY not in mems:
        print(f"❌ Key not found: {KEY}", file=sys.stderr); sys.exit(1)
    mems[KEY]["tags"]    = parse_tags(TAGS_STR)
    mems[KEY]["updated"] = now_ts()
    save_store(store)
    print(f"🏷️  Tags updated for '{KEY}': {', '.join(mems[KEY]['tags'])}")

elif OPERATION == "note":
    if not KEY:  print("❌ --key is required for 'note'",  file=sys.stderr); sys.exit(1)
    if not NOTE: print("❌ --note is required for 'note'", file=sys.stderr); sys.exit(1)
    if KEY not in mems:
        print(f"❌ Key not found: {KEY}", file=sys.stderr); sys.exit(1)
    mems[KEY]["note"]    = NOTE
    mems[KEY]["updated"] = now_ts()
    save_store(store)
    print(f"📝 Note updated for '{KEY}'")

else:
    print(f"❌ Unknown operation: {OPERATION}", file=sys.stderr)
    sys.exit(1)
PYEOF
