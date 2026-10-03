#!/bin/bash

INPUT_TEXT="$1"

if [ -z "$INPUT_TEXT" ]; then
    INPUT_TEXT=$(cat)
fi

SECRET_KEYS="SECRET|TOKEN|PASSWORD|PASS|KEY|CREDENTIAL|AUTH|API_KEY"

echo "$INPUT_TEXT" | \
    sed -E "s/([a-zA-Z0-9_]*($SECRET_KEYS)[a-zA-Z0-9_]*)=.*/\1=[REDACTED]/gi" | \
    sed -E "s/(['\"]?)([a-zA-Z0-9_]*($SECRET_KEYS)[a-zA-Z0-9_]*)(['\"]?)[[:space:]]*:[[:space:]]*(['\"]).*?(['\"])/\1\2\4: \5[REDACTED]\6/gi"
