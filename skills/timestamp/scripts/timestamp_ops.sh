#!/usr/bin/env bash
set -euo pipefail

timestamp=""
to_unix=0
date_str=""
timezone="UTC"
format="iso"
milliseconds=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --timestamp) timestamp="$2"; shift 2 ;;
    --to-unix) to_unix=1; shift 1 ;;
    --date) date_str="$2"; shift 2 ;;
    --timezone) timezone="$2"; shift 2 ;;
    --format) format="$2"; shift 2 ;;
    --milliseconds) milliseconds=1; shift 1 ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

python3 -c "
import sys, time
from datetime import datetime, timezone as dt_tz
try:
    from zoneinfo import ZoneInfo
except ImportError:
    print('Requires python 3.9+ for zoneinfo', file=sys.stderr)
    sys.exit(1)

to_unix = $to_unix
date_str = '$date_str'
ts_input = '$timestamp'
tz_name = '$timezone'
out_format = '$format'
is_ms = $milliseconds

if to_unix:
    if not date_str:
        print('Must provide --date when using --to-unix', file=sys.stderr)
        sys.exit(1)
    
    dt = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
    ts = int(dt.timestamp())
    if is_ms:
        ts = int(dt.timestamp() * 1000)
    print(ts)
    sys.exit(0)

if ts_input:
    ts = int(ts_input)
else:
    ts = int(time.time())

if is_ms:
    ts = ts // 1000

dt_utc = datetime.fromtimestamp(ts, dt_tz.utc)
try:
    tz = ZoneInfo(tz_name)
except Exception:
    print(f'Invalid timezone: {tz_name}', file=sys.stderr)
    sys.exit(1)

dt_local = dt_utc.astimezone(tz)

if out_format == 'iso':
    print(dt_local.isoformat())
elif out_format == 'human':
    print(dt_local.strftime('%Y-%m-%d %H:%M:%S %z'))
elif out_format == 'unix':
    print(ts)
elif out_format == 'all':
    print(f'UTC: {dt_utc.isoformat()}')
    print(f'Local ({tz_name}): {dt_local.strftime(\"%Y-%m-%d %H:%M:%S %z\")}')
    print(f'ISO: {dt_local.isoformat()}')
    print(f'Unix: {ts}')
    print(f'Day of week: {dt_local.strftime(\"%A\")}')
"
