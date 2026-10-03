"""
shared/skill_runner.py — OS-aware script runner for basic-agent-skills.
"""
import platform
import subprocess
from pathlib import Path
from typing import Union, List, Optional

# Resolve skills root relative to this file (integrations/frameworks/shared/ -> repo root / skills)
SKILLS_ROOT = Path(__file__).parent.parent.parent.parent / "skills"

def run_skill(
    skill: str,
    script_stem: str,
    ps1_args: Optional[List[str]] = None,
    sh_args: Optional[List[str]] = None,
    timeout: int = 30,
) -> str:
    """
    Run the appropriate helper script for the given skill.
    Selects .ps1 on Windows (via pwsh), .sh on Linux/macOS (via bash).
    Returns stripped stdout. Raises RuntimeError on non-zero exit.
    """
    ps1_args = ps1_args or []
    sh_args = sh_args or []
    
    is_windows = platform.system().lower() == "windows"
    skill_dir = SKILLS_ROOT / skill / "scripts"
    
    if is_windows:
        script_path = skill_dir / f"{script_stem}.ps1"
        cmd = ["pwsh", "-NoProfile", "-File", str(script_path)] + ps1_args
    else:
        script_path = skill_dir / f"{script_stem}.sh"
        cmd = ["bash", str(script_path)] + sh_args
        
    if not script_path.exists():
        raise FileNotFoundError(f"Skill script not found: {script_path}")
        
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Skill execution failed with exit code {e.returncode}:\n{e.stderr.strip()}")
    except subprocess.TimeoutExpired as e:
        raise RuntimeError(f"Skill execution timed out after {timeout} seconds.")
