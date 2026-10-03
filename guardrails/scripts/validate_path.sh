#!/bin/bash

PATH_INPUT="$1"

if [ -z "$PATH_INPUT" ]; then
    echo "Error: No path provided."
    exit 1
fi

# Check for path traversal
if echo "$PATH_INPUT" | grep -q "\.\."; then
    echo "Path validation failed: Path traversal detected."
    exit 1
fi

# Blocked exact paths
BLOCKED_PATHS=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/sudoers"
)

# Blocked patterns
BLOCKED_PATTERNS=(
    "\.ssh/id_rsa"
    "\.aws/credentials"
    "\.env"
)

for bp in "${BLOCKED_PATHS[@]}"; do
    if [[ "$PATH_INPUT" == "$bp"* ]]; then
        echo "Path validation failed: Access to sensitive path '$bp' blocked."
        exit 1
    fi
done

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$PATH_INPUT" | grep -qE "$pattern"; then
        echo "Path validation failed: Access to sensitive file pattern '$pattern' blocked."
        exit 1
    fi
done

echo "Path is safe."
exit 0
