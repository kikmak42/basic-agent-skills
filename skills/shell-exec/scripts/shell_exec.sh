#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

COMMAND=$1

BLOCKED_PATTERNS=("rm -rf /" "format " "del /F /S" "shutdown")

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -q "$pattern"; then
        echo "Error: Command blocked by security guardrails. Matches pattern: $pattern"
        exit 1
    fi
done

echo "Executing: $COMMAND"
# Run command and capture exit code safely
bash -c "$COMMAND"
EXIT_CODE=$?
echo "Exit Code: $EXIT_CODE"
exit $EXIT_CODE
