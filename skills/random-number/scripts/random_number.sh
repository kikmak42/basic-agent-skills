#!/usr/bin/env bash
# random_number.sh — Generates cryptographically-seeded random numbers.
#
# Usage:
#   ./random_number.sh [--min MIN] [--max MAX] [--count COUNT] [--type int|float]
#
# Defaults: --min 1 --max 100 --count 1 --type int
#
# Examples:
#   ./random_number.sh --min 1 --max 6            # dice roll
#   ./random_number.sh --min 1 --max 100 --count 3
#   ./random_number.sh --type float               # float in [0,1)

set -euo pipefail

MIN=1
MAX=100
COUNT=1
TYPE="int"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --min)   MIN="$2";   shift 2 ;;
        --max)   MAX="$2";   shift 2 ;;
        --count) COUNT="$2"; shift 2 ;;
        --type)  TYPE="$2";  shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

# Use /dev/urandom for OS-level entropy
generate_random_bytes() {
    od -An -N8 -tu8 /dev/urandom | tr -d ' \n'
}

for ((i = 0; i < COUNT; i++)); do
    RAND=$(generate_random_bytes)
    MAX_UINT64=18446744073709551615

    if [[ "$TYPE" == "float" ]]; then
        # Use python/awk for float arithmetic if available
        if command -v python3 &>/dev/null; then
            python3 -c "
min_val = float('${MIN}')
max_val = float('${MAX}')
rand = ${RAND}
max_u64 = ${MAX_UINT64}
fraction = rand / max_u64
print(min_val + fraction * (max_val - min_val))
"
        else
            awk -v rand="${RAND}" -v max_u64="${MAX_UINT64}" \
                -v min="${MIN}" -v max="${MAX}" \
                'BEGIN { fraction = rand / max_u64; print min + fraction * (max - min) }'
        fi
    else
        # Integer: map to [MIN, MAX] inclusive
        RANGE=$(( MAX - MIN + 1 ))
        RESULT=$(( (RAND % RANGE) + MIN ))
        echo "$RESULT"
    fi
done
