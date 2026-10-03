#!/bin/bash

COMMAND="$1"

if [ -z "$COMMAND" ]; then
    echo "Error: No command provided."
    exit 1
fi

BLOCKED_COMMANDS=(
    "rm -rf /"
    "mkfs"
    "dd if="
    "shutdown"
    "halt"
    "reboot"
)

BLOCKED_PATTERNS=(
    ":\(\)\{ :\|:& \};:"
    "mkfs\."
)

for cmd in "${BLOCKED_COMMANDS[@]}"; do
    if echo "$COMMAND" | grep -qE "^\s*${cmd}"; then
        echo "Command validation failed: Command '$cmd' is blocked."
        exit 1
    fi
done

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern"; then
        echo "Command validation failed: Pattern '$pattern' is blocked."
        exit 1
    fi
done

echo "Command is safe."
exit 0
