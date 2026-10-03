import asyncio
import sys, os
from typing import Optional

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))  # for shared import
from shared.skill_runner import run_skill
from autogen_core.tools import FunctionTool

async def get_date() -> str:
    """Get the real current date and time from the OS clock."""
    return run_skill("get-date", "get_date")

async def random_number(min_val: float, max_val: float, count: int = 1, num_type: str = "int") -> str:
    """Generate random numbers."""
    return run_skill(
        "random-number", "random_number", 
        ["-Min", str(min_val), "-Max", str(max_val), "-Count", str(count), "-Type", num_type], 
        ["--min", str(min_val), "--max", str(max_val), "--count", str(count), "--type", num_type]
    )

async def basic_math(expression: str) -> str:
    """Evaluate a mathematical expression safely."""
    return run_skill("basic-math", "calculate", ["-Expression", expression], [expression])

async def web_search(query: str) -> str:
    """Perform a web search."""
    return run_skill("web-search", "web_search", ["-Query", query], ["--query", query])

async def file_ops(operation: str, path: str, content: Optional[str] = None) -> str:
    """Perform file operations like read, list, exists, write."""
    ps1_args = ["-Operation", operation, "-Path", path]
    sh_args = ["--operation", operation, "--path", path]
    if content:
        ps1_args.extend(["-Content", content])
        sh_args.extend(["--content", content])
    return run_skill("file-ops", "file_ops", ps1_args, sh_args)

async def run_tests(path: Optional[str] = None) -> str:
    """Run tests in the specified directory."""
    ps1_args = ["-Path", path] if path else []
    sh_args = ["--path", path] if path else []
    return run_skill("run-tests", "run_tests", ps1_args, sh_args)

async def shell_exec(command: str) -> str:
    """Execute a shell command."""
    return run_skill("shell-exec", "shell_exec", ["-Command", command], ["--command", command])

async def uuid_gen(uuid_type: str = "uuid", length: Optional[int] = None, count: int = 1) -> str:
    """Generate UUIDs or random tokens."""
    ps1_args = ["-Type", uuid_type, "-Count", str(count)]
    sh_args = ["--type", uuid_type, "--count", str(count)]
    if length:
        ps1_args.extend(["-Length", str(length)])
        sh_args.extend(["--length", str(length)])
    return run_skill("uuid-gen", "uuid_gen", ps1_args, sh_args)

async def convert(value: float, from_unit: str, to_unit: str) -> str:
    """Convert between units."""
    return run_skill(
        "convert", "convert", 
        ["-Value", str(value), "-From", from_unit, "-To", to_unit], 
        ["--value", str(value), "--from", from_unit, "--to", to_unit]
    )

async def env_vars(name: Optional[str] = None, prefix: Optional[str] = None) -> str:
    """Read environment variables."""
    ps1_args = []
    sh_args = []
    if name:
        ps1_args.extend(["-Name", name])
        sh_args.extend(["--name", name])
    if prefix:
        ps1_args.extend(["-Prefix", prefix])
        sh_args.extend(["--prefix", prefix])
    return run_skill("env-vars", "env_vars", ps1_args, sh_args)

get_date_tool = FunctionTool(get_date, description="Get the real current date and time")
random_number_tool = FunctionTool(random_number, description="Generate random numbers")
basic_math_tool = FunctionTool(basic_math, description="Evaluate a mathematical expression safely")
web_search_tool = FunctionTool(web_search, description="Perform a web search")
file_ops_tool = FunctionTool(file_ops, description="Perform file operations")
run_tests_tool = FunctionTool(run_tests, description="Run tests")
shell_exec_tool = FunctionTool(shell_exec, description="Execute a shell command")
uuid_gen_tool = FunctionTool(uuid_gen, description="Generate UUIDs or random tokens")
convert_tool = FunctionTool(convert, description="Convert between units")
env_vars_tool = FunctionTool(env_vars, description="Read environment variables")

ALL_TOOLS = [
    get_date_tool, random_number_tool, basic_math_tool, web_search_tool, file_ops_tool,
    run_tests_tool, shell_exec_tool, uuid_gen_tool, convert_tool, env_vars_tool
]
