#!/usr/bin/env bash
set -euo pipefail

PATTERN=""
INPUT_STR=""
FILE=""
OPERATION="match"
REPLACEMENT=""
IGNORE_CASE=0
MULTILINE=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--pattern) PATTERN="$2"; shift ;;
        -i|--input) INPUT_STR="$2"; shift ;;
        -f|--file) FILE="$2"; shift ;;
        -o|--operation) OPERATION="$2"; shift ;;
        -r|--replacement) REPLACEMENT="$2"; shift ;;
        -I|--ignore-case) IGNORE_CASE=1 ;;
        -M|--multiline) MULTILINE=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$PATTERN" ]]; then
    echo "Error: --pattern is required." >&2
    exit 1
fi

if [[ -z "$INPUT_STR" && -z "$FILE" ]]; then
    echo "Error: Either --input or --file must be provided." >&2
    exit 1
fi

cat << 'EOF' > /tmp/regex_op.py
import sys, re, argparse

parser = argparse.ArgumentParser()
parser.add_argument('--pattern', required=True)
parser.add_argument('--input', default='')
parser.add_argument('--file', default='')
parser.add_argument('--operation', default='match')
parser.add_argument('--replacement', default='')
parser.add_argument('--ignore-case', type=int, default=0)
parser.add_argument('--multiline', type=int, default=0)

args = parser.parse_args()

flags = 0
if args.ignore_case: flags |= re.IGNORECASE
if args.multiline: flags |= re.MULTILINE

content = ""
if args.file:
    with open(args.file, 'r') as f:
        content = f.read()
else:
    content = args.input

try:
    regex = re.compile(args.pattern, flags)
except re.error as e:
    print(f"Invalid regex pattern: {e}")
    sys.exit(1)

if args.operation == 'match':
    match = regex.search(content)
    if match:
        print("MATCH")
        print(f"Value: {match.group(0)}")
        for i, g in enumerate(match.groups()):
            print(f"Group {i}: {g}")
    else:
        print("NO MATCH")
elif args.operation == 'findall':
    matches = regex.finditer(content)
    found = False
    for m in matches:
        found = True
        print(m.group(0))
    if not found:
        print("NO MATCHES")
elif args.operation == 'replace':
    print(regex.sub(args.replacement, content))
elif args.operation == 'split':
    for part in regex.split(content):
        print(part)
elif args.operation == 'count':
    print(f"Count: {len(regex.findall(content))}")
else:
    print(f"Invalid operation: {args.operation}")
    sys.exit(1)
EOF

python3 /tmp/regex_op.py --pattern "$PATTERN" \
  --input "$INPUT_STR" \
  --file "$FILE" \
  --operation "$OPERATION" \
  --replacement "$REPLACEMENT" \
  --ignore-case "$IGNORE_CASE" \
  --multiline "$MULTILINE"

rm /tmp/regex_op.py
