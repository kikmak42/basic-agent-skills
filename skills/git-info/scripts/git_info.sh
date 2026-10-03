#!/usr/bin/env bash
set -euo pipefail

SHOW="all"
REPO_PATH="."
COUNT=10

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--show) SHOW="$2"; shift ;;
        -p|--path) REPO_PATH="$2"; shift ;;
        -c|--count) COUNT="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if ! command -v git &> /dev/null; then
    echo "Error: git is not available on this system." >&2
    exit 1
fi

if ! git -C "$REPO_PATH" rev-parse --git-dir &>/dev/null; then
    echo "Directory '$REPO_PATH' is not a git repository."
    exit 0
fi

case "$SHOW" in
    all)
        echo "--- Branch ---"
        git -C "$REPO_PATH" branch --show-current || echo "(detached)"
        echo "--- Status ---"
        git -C "$REPO_PATH" status -sb
        echo "--- Recent Commits ---"
        git -C "$REPO_PATH" log -n 5 --oneline
        ;;
    branch)
        git -C "$REPO_PATH" branch --show-current || echo "(detached)"
        git -C "$REPO_PATH" status -sb | head -n 1
        ;;
    status)
        git -C "$REPO_PATH" status --short
        ;;
    log)
        git -C "$REPO_PATH" log -n "$COUNT"
        ;;
    remotes)
        git -C "$REPO_PATH" remote -v
        ;;
    stash)
        git -C "$REPO_PATH" stash list
        ;;
    diff-stat)
        git -C "$REPO_PATH" diff --stat HEAD
        ;;
    *)
        echo "Invalid value for --show: $SHOW" >&2
        exit 1
        ;;
esac
