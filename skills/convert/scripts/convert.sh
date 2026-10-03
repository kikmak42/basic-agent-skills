#!/usr/bin/env bash
set -euo pipefail

VALUE=""
FROM=""
TO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --value)
      VALUE="$2"
      shift 2
      ;;
    --from)
      FROM="$2"
      shift 2
      ;;
    --to)
      TO="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1"
      exit 1
      ;;
  esac
done

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required for accurate unit conversion." >&2
  exit 1
fi

python3 -c "
import sys

val = float('$VALUE')
frm = '$FROM'.lower()
to = '$TO'.lower()

res = None

if frm == 'c' and to == 'f': res = (val * 9/5) + 32
elif frm == 'f' and to == 'c': res = (val - 32) * 5/9
elif frm == 'c' and to == 'k': res = val + 273.15
elif frm == 'k' and to == 'c': res = val - 273.15
elif frm == 'f' and to == 'k': res = (val - 32) * 5/9 + 273.15
elif frm == 'k' and to == 'f': res = (val - 273.15) * 9/5 + 32
else:
    length = {'km': 1000, 'm': 1, 'cm': 0.01, 'mi': 1609.344, 'ft': 0.3048, 'in': 0.0254}
    weight = {'kg': 1, 'g': 0.001, 'lb': 0.45359237, 'oz': 0.028349523125}
    volume = {'l': 1, 'ml': 0.001, 'gal': 3.78541, 'fl_oz': 0.0295735}
    speed = {'mps': 1, 'kph': 0.277778, 'mph': 0.44704}
    data = {'b': 1, 'kb': 1024, 'mb': 1048576, 'gb': 1073741824, 'tb': 1099511627776}

    if frm in length and to in length: res = (val * length[frm]) / length[to]
    elif frm in weight and to in weight: res = (val * weight[frm]) / weight[to]
    elif frm in volume and to in volume: res = (val * volume[frm]) / volume[to]
    elif frm in speed and to in speed: res = (val * speed[frm]) / speed[to]
    elif frm in data and to in data: res = (val * data[frm]) / data[to]

if res is not None:
    print(f'{res} {to}')
else:
    print(f'Unsupported conversion from {frm} to {to}', file=sys.stderr)
    sys.exit(1)
"
