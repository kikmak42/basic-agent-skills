# GitHub Copilot Instructions for Basic Agent Skills

## Core Principle
LLMs have no clock, entropy, or calculator. Always delegate tasks requiring current date/time, randomness, arithmetic, system operations, web searches, etc., to the provided basic-agent-skills scripts instead of hallucinating or guessing.

## OS Detection
Always check the OS before running a script:
- Windows: Run `.ps1` via `pwsh -File <script.ps1>`
- Unix (Linux/macOS): Run `.sh` via `bash <script.sh>`

## Skills
1. **get-date**: `get_date.ps1` | `get_date.sh`
2. **random-number**: `random_number.ps1 -Min X -Max Y -Count N -Type int|float` | `random_number.sh --min X --max Y --count N --type int|float`
3. **basic-math**: `calculate.ps1 -Expression "expr"` | `calculate.sh "expr"`
4. **web-search**: `web_search.ps1 -Query "q"` | `web_search.sh --query "q"`
5. **file-ops**: `file_ops.ps1 -Operation read|list|exists|write -Path "p"` | `file_ops.sh --operation read|list|exists|write --path "p"`
6. **run-tests**: `run_tests.ps1 -Path "dir"` | `run_tests.sh --path "dir"`
7. **shell-exec**: `shell_exec.ps1 -Command "cmd"` | `shell_exec.sh --command "cmd"`
8. **uuid-gen**: `uuid_gen.ps1 -Type uuid|token` | `uuid_gen.sh --type uuid|token`
9. **convert**: `convert.ps1 -Value N -From unit -To unit` | `convert.sh --value N --from unit --to unit`
10. **env-vars**: `env_vars.ps1 -Name "VAR"` | `env_vars.sh --name "VAR"`

## Guardrails
- Validate mathematical expressions before passing to basic-math.
- Redact secrets when extracting environment variables.
- Validate commands before passing them to shell-exec to prevent harmful operations.
