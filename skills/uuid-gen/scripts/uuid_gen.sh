#!/usr/bin/env bash
set -euo pipefail

TYPE="uuid"
LENGTH=32
COUNT=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      TYPE="$2"
      shift 2
      ;;
    --length)
      LENGTH="$2"
      shift 2
      ;;
    --count)
      COUNT="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1"
      exit 1
      ;;
  esac
done

for ((i=0; i<COUNT; i++)); do
  if [ "$TYPE" = "uuid" ]; then
    if command -v uuidgen >/dev/null 2>&1; then
      uuidgen | tr '[:upper:]' '[:lower:]'
    elif command -v python3 >/dev/null 2>&1; then
      python3 -c "import uuid; print(uuid.uuid4())"
    else
      echo "Error: uuidgen or python3 is required for UUID generation." >&2
      exit 1
    fi
  elif [ "$TYPE" = "token" ]; then
    BYTES=$((LENGTH / 2))
    if command -v xxd >/dev/null 2>&1; then
      head -c "$BYTES" /dev/urandom | xxd -p | tr -d '\n'
      echo ""
    else
      head -c "$BYTES" /dev/urandom | od -vAn -tx1 | tr -d ' \n'
      echo ""
    fi
  else
    echo "Unknown type: $TYPE" >&2
    exit 1
  fi
done
