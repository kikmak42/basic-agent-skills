#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <query>"
    exit 1
fi

QUERY=$1
# urlencode query
ENCODED_QUERY=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$QUERY")
URL="https://api.duckduckgo.com/?q=${ENCODED_QUERY}&format=json&no_html=1&skip_disambig=1"

RESPONSE=$(curl -sSL "$URL")
if ! command -v python3 &> /dev/null; then
    echo "python3 is required to parse JSON"
    exit 1
fi

python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    if data.get('AbstractText'):
        print(data['AbstractText'])
    elif data.get('RelatedTopics') and len(data['RelatedTopics']) > 0:
        print(data['RelatedTopics'][0].get('Text', ''))
    else:
        print('No results found.')
except Exception as e:
    print(f'Error parsing JSON: {e}')
" <<< "$RESPONSE"
