# Basic Agent Skills Guardrails

Guardrails are safety constraints that prevent agents from performing harmful, unauthorized, or incorrect actions when using skills. They act as a defensive layer between the AI agent's intent and the actual execution of a script on the host system.

## Guardrail Categories

1. **Input Validation**
   - Validate all inputs before passing them to execution scripts.
   - Prevent injection attacks (expression injection, path traversal, command injection).
   - Ensure inputs conform to expected formats and lengths.

2. **Secret Redaction**
   - Never output raw secret values.
   - Any output scanning must redact values where the key suggests a secret (e.g., keys containing `SECRET`, `TOKEN`, `PASSWORD`, `CREDENTIAL`, `AUTH`, `API_KEY`).

3. **Scope Limiting**
   - Each skill must operate strictly within its defined scope.
   - Examples: `file-ops` cannot execute code, `math` cannot access the network or filesystem.

4. **Command Safety**
   - `shell-exec` must validate commands against a predefined blocklist before execution.
   - Prevent destructive commands (e.g., `rm -rf /`, formatting drives) and system shutdowns.

5. **Fail Safe**
   - If any script or validation fails, report the error explicitly.
   - Agents must never guess or hallucinate an answer when a skill execution fails.

6. **Transparency**
   - Always show the user what command will be run before executing destructive or side-effectful operations.
   - Maintain clear logs of executed commands.

## Skill Guardrail Matrix

| Skill | Input Validation | Secret Redaction | Scope Limiting | Command Safety | Fail Safe | Transparency |
|-------|------------------|------------------|----------------|----------------|-----------|--------------|
| math (calculate) | Yes (Expression injection) | No | Yes (No system access) | No | Yes | No |
| file-ops | Yes (Path traversal) | Yes (Content scan) | Yes (Filesystem only) | No | Yes | Yes (Writes) |
| shell-exec | Yes (Injection) | Yes | No | Yes (Blocklist) | Yes | Yes |
| env-vars | No | Yes (Redact values) | Yes (Read-only) | No | Yes | No |

## Extending Guardrails

When adding new skills:
1. Identify potential risks (e.g., can this skill access sensitive data, modify system state, or run arbitrary code?).
2. Apply the relevant categories from the matrix above.
3. Add or update validation scripts in the `guardrails/scripts/` directory to enforce the new constraints.
4. Update this document to reflect the new skill and its guardrails.
