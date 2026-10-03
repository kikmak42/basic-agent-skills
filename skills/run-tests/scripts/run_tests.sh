#!/usr/bin/env bash
set -euo pipefail

echo "Detecting test framework..."

if [ -f "package.json" ]; then
    echo "Found package.json. Running npm test..."
    npm test
elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    echo "Found Python project. Running pytest..."
    pytest
elif ls *.csproj 1> /dev/null 2>&1; then
    echo "Found .csproj. Running dotnet test..."
    dotnet test
elif [ -f "go.mod" ]; then
    echo "Found go.mod. Running go test..."
    go test ./...
elif [ -f "Cargo.toml" ]; then
    echo "Found Cargo.toml. Running cargo test..."
    cargo test
else
    echo "No supported test framework detected."
fi
