import pytest
import yaml
import os

with open(os.path.join(os.path.dirname(__file__), '../fixtures/basic-math.yaml')) as f:
    fixture = yaml.safe_load(f)

@pytest.mark.parametrize("case", fixture['cases'], ids=[c['id'] for c in fixture['cases']])
def test_basic_math(case, run_script, os_platform, skills_root):
    """Tests the basic math script"""
    script_ext = '.ps1' if os_platform == 'windows' else '.sh'
    script_path = os.path.join(skills_root, 'basic-math', 'scripts', f'calculate{script_ext}')
    
    if not os.path.exists(script_path):
        pytest.skip(f"Script {script_path} not found")
        
    args = case.get('args', [])
    stdout, stderr, rc = run_script(script_path, args)
    assert rc == 0
    
    val = float(stdout.strip())
    assert val == pytest.approx(case['assertions']['result'])
