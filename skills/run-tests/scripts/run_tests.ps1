param()

$ErrorActionPreference = "Continue"

Write-Output "Detecting test framework..."

if (Test-Path "package.json") {
    Write-Output "Found package.json. Running npm test (jest/mocha etc.)..."
    npm test
} elseif (Test-Path "requirements.txt" -or Test-Path "setup.py" -or Test-Path "pyproject.toml") {
    Write-Output "Found Python project. Running pytest..."
    pytest
} elseif (Get-ChildItem -Filter "*.csproj" -ErrorAction SilentlyContinue) {
    Write-Output "Found .csproj. Running dotnet test..."
    dotnet test
} elseif (Test-Path "go.mod") {
    Write-Output "Found go.mod. Running go test..."
    go test ./...
} elseif (Test-Path "Cargo.toml") {
    Write-Output "Found Cargo.toml. Running cargo test..."
    cargo test
} else {
    Write-Output "No supported test framework detected."
}
