#!/usr/bin/env bash
set -euo pipefail

operation="encode"
input_string=""
file_path=""
no_padding=0
url_safe=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --operation) operation="$2"; shift 2 ;;
    --input) input_string="$2"; shift 2 ;;
    --file) file_path="$2"; shift 2 ;;
    --no-padding) no_padding=1; shift 1 ;;
    --url-safe) url_safe=1; shift 1 ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

if [[ -z "$input_string" && -z "$file_path" ]]; then
  echo "Must provide either --input or --file" >&2
  exit 1
fi

python3 -c "
import base64, sys

op = '$operation'
input_str = '$input_string'
file_path = '$file_path'
url_safe = $url_safe
no_padding = $no_padding

data = b''
if file_path:
    with open(file_path, 'rb' if op == 'encode' else 'r') as f:
        data_in = f.read()
        if op == 'encode':
            data = data_in
        else:
            input_str = data_in.decode('utf-8').strip()

if op == 'encode':
    if not file_path:
        data = input_str.encode('utf-8')
    if url_safe:
        b64 = base64.urlsafe_b64encode(data).decode('ascii')
    else:
        b64 = base64.b64encode(data).decode('ascii')
    
    if no_padding:
        b64 = b64.rstrip('=')
    print(b64)
else:
    if url_safe:
        input_str = input_str.replace('-', '+').replace('_', '/')
    
    pad = len(input_str) % 4
    if pad:
        input_str += '=' * (4 - pad)
        
    decoded = base64.b64decode(input_str).decode('utf-8')
    print(decoded, end='')
"
