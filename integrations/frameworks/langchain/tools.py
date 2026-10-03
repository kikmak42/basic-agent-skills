# Note: Uses relative imports from ..shared.skill_runner. Adjust to absolute if moving this file.
from langchain_core.tools import tool
from typing import Optional
from ..shared.skill_runner import run_skill

@tool
def get_date() -> str:
    """Get the real current date and time from the OS clock. Use this instead of guessing."""
    return run_skill("get-date", "get_date")

@tool
def generate_random_number(min_val: float, max_val: float, count: int = 1, num_type: str = "int") -> str:
    """Generate random numbers between min_val and max_val."""
    return run_skill("random-number", "random_number",
                     ps1_args=["-Min", str(min_val), "-Max", str(max_val), "-Count", str(count), "-Type", num_type],
                     sh_args=["--min", str(min_val), "--max", str(max_val), "--count", str(count), "--type", num_type])

@tool
def calculate(expression: str) -> str:
    """Evaluate a math expression precisely. Supports +,-,*,/,**,sqrt,log,etc. Use instead of computing mentally."""
    return run_skill("basic-math", "calculate",
                     ps1_args=["-Expression", expression],
                     sh_args=[expression])

@tool
def search_web(query: str) -> str:
    """Perform a web search for a given query."""
    return run_skill("web-search", "web_search",
                     ps1_args=["-Query", query],
                     sh_args=["--query", query])

@tool
def file_operations(operation: str, path: str, content: Optional[str] = None) -> str:
    """Perform file operations like read, list, exists, or write."""
    ps1_args = ["-Operation", operation, "-Path", path]
    sh_args = ["--operation", operation, "--path", path]
    if content:
        ps1_args.extend(["-Content", content])
        sh_args.extend(["--content", content])
    return run_skill("file-ops", "file_ops", ps1_args=ps1_args, sh_args=sh_args)

@tool
def run_tests(path: Optional[str] = None) -> str:
    """Run tests in a given directory or the default location."""
    ps1_args = ["-Path", path] if path else []
    sh_args = ["--path", path] if path else []
    return run_skill("run-tests", "run_tests", ps1_args=ps1_args, sh_args=sh_args)

@tool
def execute_shell(command: str) -> str:
    """Execute a shell command safely."""
    return run_skill("shell-exec", "shell_exec",
                     ps1_args=["-Command", command],
                     sh_args=["--command", command])

@tool
def generate_uuid(uuid_type: str = "uuid", length: Optional[int] = None, count: Optional[int] = None) -> str:
    """Generate UUIDs or tokens."""
    ps1_args = ["-Type", uuid_type]
    sh_args = ["--type", uuid_type]
    if length:
        ps1_args.extend(["-Length", str(length)])
        sh_args.extend(["--length", str(length)])
    if count:
        ps1_args.extend(["-Count", str(count)])
        sh_args.extend(["--count", str(count)])
    return run_skill("uuid-gen", "uuid_gen", ps1_args=ps1_args, sh_args=sh_args)

@tool
def convert_units(value: float, from_unit: str, to_unit: str) -> str:
    """Convert a value from one unit to another."""
    return run_skill("convert", "convert",
                     ps1_args=["-Value", str(value), "-From", from_unit, "-To", to_unit],
                     sh_args=["--value", str(value), "--from", from_unit, "--to", to_unit])

@tool
def get_env_vars(name: Optional[str] = None, prefix: Optional[str] = None) -> str:
    """Get environment variables by name or prefix."""
    ps1_args = []
    sh_args = []
    if name:
        ps1_args.extend(["-Name", name])
        sh_args.extend(["--name", name])
    if prefix:
        ps1_args.extend(["-Prefix", prefix])
        sh_args.extend(["--prefix", prefix])
    return run_skill("env-vars", "env_vars", ps1_args=ps1_args, sh_args=sh_args)

ALL_TOOLS = [
    get_date, generate_random_number, calculate, search_web,
    file_operations, run_tests, execute_shell, generate_uuid,
    convert_units, get_env_vars
]
