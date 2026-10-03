#!/bin/bash

EXPRESSION="$1"

if [ -z "$EXPRESSION" ]; then
    echo "Error: No expression provided."
    exit 1
fi

BLOCKED_PATTERNS=(
    "import "
    "os\."
    "subprocess"
    "sys\."
    "open("
    "eval("
    "exec("
    "system("
    ";"
    "&"
    "|"
    "\$"
    "\`"
    ">"
    "<"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$EXPRESSION" | grep -qE "$pattern"; then
        echo "Expression validation failed: Blocked pattern '$pattern' detected."
        exit 1
    fi
done

echo "Expression is safe."
exit 0
