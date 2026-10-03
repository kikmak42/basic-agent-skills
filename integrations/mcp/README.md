# Basic Agent Skills MCP Server

This directory contains a FastMCP server that exposes all 10 basic agent skills to any Model Context Protocol (MCP) compatible client (e.g., Claude Desktop, Cursor, VS Code with Cline/Continue).

## Installation

Install the required dependencies:
```bash
pip install -r integrations/mcp/requirements.txt
```

## Running the Server

You can run the server directly:
```bash
python integrations/mcp/server.py
```

## Configuring Claude Desktop

1. Open your Claude Desktop configuration file:
   - **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
   - **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
2. Add the MCP server configuration provided in `claude_desktop_config.example.json`.
3. Restart Claude Desktop.

## Configuring Cursor

1. Open **Cursor Settings**.
2. Navigate to the **MCP** section.
3. Add a new MCP server.
4. Set the command to run `python` with the absolute path to `server.py`.

## Exposed Tools

1. `get_date`: Get current date and time.
2. `random_number`: Generate random numbers within a range.
3. `basic_math`: Evaluate mathematical expressions.
4. `web_search`: Perform a web search.
5. `file_ops`: Read, list, exist check, or write files.
6. `run_tests`: Run tests in a specified directory.
7. `shell_exec`: Execute a shell command safely.
8. `uuid_gen`: Generate UUIDs or secure tokens.
9. `convert`: Convert units (e.g., temperatures, distances).
10. `env_vars`: Read environment variables securely.
