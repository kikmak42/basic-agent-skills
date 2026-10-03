#!/usr/bin/env bash
set -euo pipefail

NAME=""
PREFIX=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      NAME="$2"
      shift 2
      ;;
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1"
      exit 1
      ;;
  esac
done

SECRET_PATTERN="KEY|SECRET|TOKEN|PASSWORD|PASS|CREDENTIAL|AUTH|API"

process_vars() {
  while IFS='=' read -r key value; do
    if [ -z "$key" ]; then continue; fi
    if echo "$key" | grep -iE "($SECRET_PATTERN)" >/dev/null 2>&1; then
      echo "${key}=[REDACTED]"
    else
      echo "${key}=${value}"
    fi
  done
}

if [ -n "$NAME" ]; then
  env | grep "^${NAME}=" | process_vars
elif [ -n "$PREFIX" ]; then
  env | grep "^${PREFIX}" | process_vars
else
  env | process_vars
fi
