#!/usr/bin/env bash
set -euo pipefail

input_string=""
file_path=""
algorithm="sha256"
encoding="utf8"

while [[ $# -gt 0 ]]; do
  case $1 in
    --input) input_string="$2"; shift 2 ;;
    --file) file_path="$2"; shift 2 ;;
    --algorithm) algorithm="$2"; shift 2 ;;
    --encoding) encoding="$2"; shift 2 ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

if [[ -z "$input_string" && -z "$file_path" ]]; then
  echo "Must provide either --input or --file" >&2
  exit 1
fi

python3 -c "
import sys, hashlib

alg = '$algorithm'.lower()
if alg not in ['sha256', 'sha512', 'sha1', 'md5']:
    print(f'Unsupported algorithm: {alg}', file=sys.stderr)
    sys.exit(1)

h = hashlib.new(alg)

file_path = '$file_path'
input_str = '$input_string'
encoding = '$encoding'

if file_path:
    with open(file_path, 'rb') as f:
        while chunk := f.read(8192):
            h.update(chunk)
else:
    if encoding == 'utf8':
        h.update(input_str.encode('utf-8'))
    elif encoding == 'ascii':
        h.update(input_str.encode('ascii'))
    elif encoding == 'hex':
        h.update(bytes.fromhex(input_str))

print(h.hexdigest())
"
