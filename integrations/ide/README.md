# IDE Integrations for Basic Agent Skills

These files teach your AI IDEs (Claude, Cursor, VS Code, Windsurf, Antigravity) to delegate specific tasks (math, dates, etc.) to deterministic scripts rather than hallucinating answers.

## Supported IDEs

| Platform | File | Where to put it | Notes |
|----------|------|-----------------|-------|
| Claude | `CLAUDE.md` | Project root | Plain markdown instructions for Claude Desktop |
| Cursor | `.cursor/rules/basic-agent-skills.mdc` | Project root | YAML frontmatter + markdown rules |
| VS Code | `.github/copilot-instructions.md` | Project root | Standard Copilot workspace instructions |
| Windsurf | `.windsurfrules` | Project root | XML-based semantic rules |
| Antigravity | `skills/` | `.agents/` | Copy the skills directory into `.agents/` for native Antigravity support |

## Copy-paste Instructions
- **Claude:** Copy `claude/CLAUDE.md` to your project root.
- **Cursor:** Copy the `cursor/.cursor` folder to your project root.
- **VS Code:** Copy the `vscode/.github` folder to your project root.
- **Windsurf:** Copy `windsurf/.windsurfrules` to your project root.
- **Antigravity:** Copy the root `skills/` directory into your project's `.agents/` directory.
