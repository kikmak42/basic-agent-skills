from fastmcp import FastMCP
import subprocess, platform
from pathlib import Path
from typing import Optional

mcp = FastMCP("basic-agent-skills")
SKILLS_ROOT = Path(__file__).parent.parent.parent / "skills"

def run_script(skill: str, script_stem: str, args_ps: list[str], args_sh: list[str]) -> str:
    """Run .ps1 on Windows, .sh on Unix. Return stdout."""
    if platform.system() == "Windows":
        script = SKILLS_ROOT / skill / "scripts" / f"{script_stem}.ps1"
        cmd = ["pwsh", "-NoProfile", "-File", str(script)] + args_ps
    else:
        script = SKILLS_ROOT / skill / "scripts" / f"{script_stem}.sh"
        cmd = ["bash", str(script)] + args_sh
    
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    if result.returncode != 0:
        raise RuntimeError(f"Script failed: {result.stderr}")
    return result.stdout.strip()

@mcp.tool()
def get_date() -> str:
    """Get the current date and time."""
    return run_script("get-date", "get_date", [], [])

@mcp.tool()
def random_number(min_val: float, max_val: float, count: int = 1, num_type: str = "int") -> str:
    """Generate random numbers within a range."""
    ps_args = ["-Min", str(min_val), "-Max", str(max_val), "-Count", str(count), "-Type", num_type]
    sh_args = ["--min", str(min_val), "--max", str(max_val), "--count", str(count), "--type", num_type]
    return run_script("random-number", "random_number", ps_args, sh_args)

@mcp.tool()
def basic_math(expression: str) -> str:
    """Evaluate a mathematical expression safely."""
    ps_args = ["-Expression", expression]
    sh_args = [expression]
    return run_script("basic-math", "calculate", ps_args, sh_args)

@mcp.tool()
def web_search(query: str) -> str:
    """Perform a web search."""
    ps_args = ["-Query", query]
    sh_args = ["--query", query]
    return run_script("web-search", "web_search", ps_args, sh_args)

@mcp.tool()
def file_ops(operation: str, path: str, content: Optional[str] = None) -> str:
    """Perform file operations: read, list, exists, write."""
    ps_args = ["-Operation", operation, "-Path", path]
    sh_args = ["--operation", operation, "--path", path]
    if content:
        ps_args.extend(["-Content", content])
        sh_args.extend(["--content", content])
    return run_script("file-ops", "file_ops", ps_args, sh_args)

@mcp.tool()
def run_tests(path: Optional[str] = None) -> str:
    """Run tests in the specified directory."""
    ps_args = ["-Path", path] if path else []
    sh_args = ["--path", path] if path else []
    return run_script("run-tests", "run_tests", ps_args, sh_args)

@mcp.tool()
def shell_exec(command: str) -> str:
    """Execute a shell command safely."""
    ps_args = ["-Command", command]
    sh_args = ["--command", command]
    return run_script("shell-exec", "shell_exec", ps_args, sh_args)

@mcp.tool()
def uuid_gen(gen_type: str = "uuid", length: int = 32, count: int = 1) -> str:
    """Generate UUIDs or secure tokens."""
    ps_args = ["-Type", gen_type, "-Length", str(length), "-Count", str(count)]
    sh_args = ["--type", gen_type, "--length", str(length), "--count", str(count)]
    return run_script("uuid-gen", "uuid_gen", ps_args, sh_args)

@mcp.tool()
def convert(value: float, from_unit: str, to_unit: str) -> str:
    """Convert between units (e.g., C to F, km to mi)."""
    ps_args = ["-Value", str(value), "-From", from_unit, "-To", to_unit]
    sh_args = ["--value", str(value), "--from", from_unit, "--to", to_unit]
    return run_script("convert", "convert", ps_args, sh_args)

@mcp.tool()
def env_vars(name: Optional[str] = None, prefix: Optional[str] = None) -> str:
    """Read environment variables securely."""
    ps_args = []
    sh_args = []
    if name:
        ps_args.extend(["-Name", name])
        sh_args.extend(["--name", name])
    if prefix:
        ps_args.extend(["-Prefix", prefix])
        sh_args.extend(["--prefix", prefix])
    return run_script("env-vars", "env_vars", ps_args, sh_args)

if __name__ == "__main__":
    mcp.run()
