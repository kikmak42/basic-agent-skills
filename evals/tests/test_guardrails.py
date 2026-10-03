import pytest
import os

@pytest.mark.parametrize("script,args,expected_rc", [
    ("validate_expression", ["1+1"], 0),
    ("validate_expression", ["import os; os.system('ls')"], 1),
    ("validate_path", ["."], 0),
    ("validate_command", ["echo hello"], 0),
], ids=["validate_expression::safe", "validate_expression::unsafe", "validate_path::safe", "validate_command::safe"])
def test_guardrails(script, args, expected_rc, run_script, os_platform, guardrails_root):
    """Tests guardrails scripts"""
    script_ext = '.ps1' if os_platform == 'windows' else '.sh'
    script_path = os.path.join(guardrails_root, f'{script}{script_ext}')
    
    if not os.path.exists(script_path):
        pytest.skip(f"Script {script_path} not found")
        
    stdout, stderr, rc = run_script(script_path, args)
    assert rc == expected_rc
