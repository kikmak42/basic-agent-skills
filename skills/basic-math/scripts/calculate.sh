#!/usr/bin/env bash
# calculate.sh — Evaluates a mathematical expression using python3 or bc.
#
# Usage:
#   ./calculate.sh "<expression>"
#
# Supported syntax (Python-style):
#   +, -, *, /, //, %, **, abs(), sqrt(), log(), round(), etc.
#
# Examples:
#   ./calculate.sh "17 * 83"
#   ./calculate.sh "2 ** 32"
#   ./calculate.sh "(123 + 456) / 7 - 89"
#   ./calculate.sh "0.15 * 847"
#   ./calculate.sh "import math; math.sqrt(2)"

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 \"<expression>\"" >&2
    exit 1
fi

EXPRESSION="$*"

# Prefer python3 for full math support
if command -v python3 &>/dev/null; then
    python3 -c "
import math

# Expose common math functions at top level for convenience
sqrt  = math.sqrt
log   = math.log
log10 = math.log10
log2  = math.log2
sin   = math.sin
cos   = math.cos
tan   = math.tan
pi    = math.pi
e     = math.e
ceil  = math.ceil
floor = math.floor

result = eval('''${EXPRESSION}''')
# Print without trailing zeros where possible
if isinstance(result, float) and result == int(result):
    print(int(result))
else:
    print(result)
"
elif command -v bc &>/dev/null; then
    # Fallback: bc with basic math library
    echo "scale=15; ${EXPRESSION}" | bc -l
else
    echo "Error: neither python3 nor bc is available." >&2
    exit 1
fi
