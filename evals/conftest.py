import os
import sys
import subprocess
import pytest

@pytest.fixture
def os_platform():
    return 'windows' if sys.platform.startswith('win') else 'unix'

@pytest.fixture
def skills_root():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'skills'))

@pytest.fixture
def guardrails_root():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'guardrails', 'scripts'))

@pytest.fixture
def run_script(os_platform):
    def _run(script_path, args=None, env=None):
        args = args or []
        env_vars = os.environ.copy()
        if env:
            env_vars.update(env)
        
        if os_platform == 'windows':
            cmd = ['pwsh', '-NoProfile', '-NonInteractive', '-Command', script_path] + args
        else:
            cmd = ['bash', script_path] + args
            
        result = subprocess.run(cmd, capture_output=True, text=True, env=env_vars)
        return result.stdout, result.stderr, result.returncode
    return _run
