import sys, os
from typing import Optional

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))  # for shared import
from shared.skill_runner import run_skill
from llama_index.core.tools import FunctionTool

def get_date() -> str:
    """Get the real current date and time from the OS clock. Always use this instead of guessing."""
    return run_skill("get-date", "get_date")

def random_number(min_val: float, max_val: float, count: int = 1, num_type: str = "int") -> str:
    """Generate random numbers."""
    return run_skill(
        "random-number", "random_number", 
        ["-Min", str(min_val), "-Max", str(max_val), "-Count", str(count), "-Type", num_type], 
        ["--min", str(min_val), "--max", str(max_val), "--count", str(count), "--type", num_type]
    )

def basic_math(expression: str) -> str:
    """Evaluate a mathematical expression safely."""
    return run_skill("basic-math", "calculate", ["-Expression", expression], [expression])

def web_search(query: str) -> str:
    """Perform a web search."""
    return run_skill("web-search", "web_search", ["-Query", query], ["--query", query])

def file_ops(operation: str, path: str, content: Optional[str] = None) -> str:
    """Perform file operations like read, list, exists, write."""
    ps1_args = ["-Operation", operation, "-Path", path]
    sh_args = ["--operation", operation, "--path", path]
    if content:
        ps1_args.extend(["-Content", content])
        sh_args.extend(["--content", content])
    return run_skill("file-ops", "file_ops", ps1_args, sh_args)

def run_tests(path: Optional[str] = None) -> str:
    """Run tests in the specified directory."""
    ps1_args = ["-Path", path] if path else []
    sh_args = ["--path", path] if path else []
    return run_skill("run-tests", "run_tests", ps1_args, sh_args)

def shell_exec(command: str) -> str:
    """Execute a shell command."""
    return run_skill("shell-exec", "shell_exec", ["-Command", command], ["--command", command])

def uuid_gen(uuid_type: str = "uuid", length: Optional[int] = None, count: int = 1) -> str:
    """Generate UUIDs or random tokens."""
    ps1_args = ["-Type", uuid_type, "-Count", str(count)]
    sh_args = ["--type", uuid_type, "--count", str(count)]
    if length:
        ps1_args.extend(["-Length", str(length)])
        sh_args.extend(["--length", str(length)])
    return run_skill("uuid-gen", "uuid_gen", ps1_args, sh_args)

def convert(value: float, from_unit: str, to_unit: str) -> str:
    """Convert between units."""
    return run_skill(
        "convert", "convert", 
        ["-Value", str(value), "-From", from_unit, "-To", to_unit], 
        ["--value", str(value), "--from", from_unit, "--to", to_unit]
    )

def env_vars(name: Optional[str] = None, prefix: Optional[str] = None) -> str:
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

get_date_tool = FunctionTool.from_defaults(fn=get_date)
random_number_tool = FunctionTool.from_defaults(fn=random_number)
basic_math_tool = FunctionTool.from_defaults(fn=basic_math)
web_search_tool = FunctionTool.from_defaults(fn=web_search)
file_ops_tool = FunctionTool.from_defaults(fn=file_ops)
run_tests_tool = FunctionTool.from_defaults(fn=run_tests)
shell_exec_tool = FunctionTool.from_defaults(fn=shell_exec)
uuid_gen_tool = FunctionTool.from_defaults(fn=uuid_gen)
convert_tool = FunctionTool.from_defaults(fn=convert)
env_vars_tool = FunctionTool.from_defaults(fn=env_vars)

ALL_TOOLS = [
    get_date_tool, random_number_tool, basic_math_tool, web_search_tool, file_ops_tool,
    run_tests_tool, shell_exec_tool, uuid_gen_tool, convert_tool, env_vars_tool
]
