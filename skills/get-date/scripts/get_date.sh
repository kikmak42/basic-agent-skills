#!/usr/bin/env bash
# get_date.sh — Returns the current date and time from the OS clock.
#
# Usage:
#   ./get_date.sh
#
# Output:
#   Human-readable:  Saturday, October 03 2026 01:16:35 IST
#   ISO 8601:        ISO 8601: 2026-10-03T01:16:35+05:30

set -euo pipefail

# Human-readable format
date "+%A, %B %d %Y %H:%M:%S %Z"

# ISO 8601
echo "ISO 8601: $(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S%z')"
