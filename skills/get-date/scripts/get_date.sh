#!/usr/bin/env bash
# get_date.sh — Returns the current date/time with full timezone support.
#
# Requires python3 (3.9+) for IANA timezone handling via the `zoneinfo` module.
# Falls back to the `date` command with TZ= for basic timezone queries.
#
# Usage:
#   ./get_date.sh [--timezone TZ] [--format FORMAT] [--compare TZ1,TZ2,...]
#                 [--list-timezones]
#
# Options:
#   --timezone   IANA timezone name (e.g. "America/New_York", "UTC", "Asia/Kolkata")
#                Default: system local timezone
#   --format     long (default) | short | iso | unix | all
#   --compare    Comma-separated list of IANA timezones for world clock
#   --list-timezones   Print all available IANA timezone names
#
# Examples:
#   ./get_date.sh
#   ./get_date.sh --timezone "America/New_York"
#   ./get_date.sh --format all
#   ./get_date.sh --compare "UTC,America/New_York,Europe/London,Asia/Kolkata"
#   ./get_date.sh --list-timezones

set -euo pipefail

TIMEZONE=""
FORMAT="long"
COMPARE=""
LIST_TIMEZONES="false"

# ─── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --timezone)        TIMEZONE="$2";       shift 2 ;;
        --format)          FORMAT="$2";         shift 2 ;;
        --compare)         COMPARE="$2";        shift 2 ;;
        --list-timezones)  LIST_TIMEZONES="true"; shift ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

# ─── Python helper (handles IANA timezones correctly) ─────────────────────────
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 is required for timezone support." >&2
    echo "Fallback — local time only:" >&2
    date "+%A, %B %d %Y  %H:%M:%S %Z (UTC%z)"
    echo "ISO 8601: $(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S%z')"
    exit 0
fi

python3 - <<PYEOF
import sys
import datetime

# zoneinfo is stdlib in Python 3.9+; fall back to pytz if available
try:
    from zoneinfo import ZoneInfo, available_timezones
    HAS_ZONEINFO = True
except ImportError:
    HAS_ZONEINFO = False
    try:
        import pytz
    except ImportError:
        print("Error: Python 3.9+ or the 'pytz' package is required for timezone support.", file=sys.stderr)
        sys.exit(1)

LIST_TIMEZONES = "${LIST_TIMEZONES}" == "true"
TIMEZONE       = "${TIMEZONE}"
FORMAT         = "${FORMAT}"
COMPARE        = "${COMPARE}"

# ── List timezones ─────────────────────────────────────────────────────────
if LIST_TIMEZONES:
    if HAS_ZONEINFO:
        for tz in sorted(available_timezones()):
            print(tz)
    else:
        for tz in sorted(pytz.all_timezones):
            print(tz)
    sys.exit(0)

# ── Resolve a timezone object ──────────────────────────────────────────────
def resolve_tz(name):
    if not name or name.lower() in ("local", ""):
        return datetime.datetime.now().astimezone().tzinfo
    if HAS_ZONEINFO:
        try:
            return ZoneInfo(name)
        except Exception:
            # Fuzzy search
            matches = [z for z in available_timezones() if name.lower() in z.lower()]
            if matches:
                best = sorted(matches, key=len)[0]
                print(f"[info] Unknown timezone '{name}', using '{best}'", file=sys.stderr)
                return ZoneInfo(best)
            print(f"Error: unknown timezone '{name}'. Use --list-timezones to see options.", file=sys.stderr)
            sys.exit(1)
    else:
        try:
            return pytz.timezone(name)
        except pytz.UnknownTimeZoneError:
            matches = [z for z in pytz.all_timezones if name.lower() in z.lower()]
            if matches:
                return pytz.timezone(matches[0])
            print(f"Error: unknown timezone '{name}'", file=sys.stderr)
            sys.exit(1)

# ── Format helpers ─────────────────────────────────────────────────────────
def get_abbr(dt):
    return dt.strftime("%Z") or "???"

def utc_offset_str(dt):
    off = dt.utcoffset()
    if off is None:
        return "+00:00"
    total = int(off.total_seconds())
    sign  = "+" if total >= 0 else "-"
    total = abs(total)
    h, m  = divmod(total // 60, 60)
    return f"{sign}{h:02d}:{m:02d}"

def is_dst(dt):
    # zoneinfo stores fold info; pytz has dst()
    try:
        return bool(dt.dst() and dt.dst().total_seconds() != 0)
    except Exception:
        return False

def format_output(dt, fmt):
    abbr    = get_abbr(dt)
    offstr  = utc_offset_str(dt)
    dst_tag = " [DST active]" if is_dst(dt) else ""

    if fmt == "short":
        return f"{dt.strftime('%Y-%m-%d %H:%M')}  ({abbr}  UTC{offstr}{dst_tag})"
    elif fmt == "iso":
        return dt.strftime('%Y-%m-%dT%H:%M:%S') + offstr
    elif fmt == "unix":
        utc_epoch = datetime.datetime(1970, 1, 1, tzinfo=datetime.timezone.utc)
        return str(int((dt.astimezone(datetime.timezone.utc) - utc_epoch).total_seconds()))
    elif fmt == "all":
        utc_now   = dt.astimezone(datetime.timezone.utc)
        utc_epoch = datetime.datetime(1970, 1, 1, tzinfo=datetime.timezone.utc)
        unix_ts   = int((utc_now - utc_epoch).total_seconds())
        lines = [
            f"Timezone   : {TIMEZONE or 'local'}",
            f"Local time : {dt.strftime('%A, %B %d %Y  %H:%M:%S')}",
            f"Abbrev     : {abbr}{dst_tag}",
            f"UTC offset : UTC{offstr}",
            f"ISO 8601   : {dt.strftime('%Y-%m-%dT%H:%M:%S')}{offstr}",
            f"UTC time   : {utc_now.strftime('%Y-%m-%d %H:%M:%S')}",
            f"Unix epoch : {unix_ts}",
        ]
        return "\n".join(lines)
    else:  # long
        return f"{dt.strftime('%A, %B %d %Y  %H:%M:%S')}  {abbr}  UTC{offstr}{dst_tag}"

now_utc = datetime.datetime.now(datetime.timezone.utc)

# ── Compare / World Clock mode ─────────────────────────────────────────────
if COMPARE:
    zones = [z.strip() for z in COMPARE.split(",") if z.strip()]
    print("=" * 60)
    print(f"  World Clock  —  UTC: {now_utc.strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    for tz_name in zones:
        tz = resolve_tz(tz_name)
        dt = now_utc.astimezone(tz)
        output = format_output(dt, "short")
        label = (tz_name + ":").ljust(30)
        print(f"{label} {output}")
    sys.exit(0)

# ── Single timezone output ─────────────────────────────────────────────────
tz = resolve_tz(TIMEZONE)
dt = now_utc.astimezone(tz)
print(format_output(dt, FORMAT))
PYEOF
