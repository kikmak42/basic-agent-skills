#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <read|list|exists|write> <path> [content]"
    exit 1
fi

OP=$1
PATH_ARG=$2
CONTENT=${3:-}

case "$OP" in
    "read")
        if [ -f "$PATH_ARG" ]; then
            cat "$PATH_ARG"
        else
            echo "File does not exist: $PATH_ARG"
        fi
        ;;
    "list")
        if [ -d "$PATH_ARG" ]; then
            ls -la "$PATH_ARG"
        else
            echo "Directory does not exist: $PATH_ARG"
        fi
        ;;
    "exists")
        if [ -e "$PATH_ARG" ]; then
            echo "True"
        else
            echo "False"
        fi
        ;;
    "write")
        DIR=$(dirname "$PATH_ARG")
        if [ ! -d "$DIR" ]; then
            mkdir -p "$DIR"
        fi
        echo "$CONTENT" > "$PATH_ARG"
        echo "File written to $PATH_ARG"
        ;;
    *)
        echo "Unknown operation: $OP"
        exit 1
        ;;
esac
