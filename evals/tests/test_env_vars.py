import pytest
import yaml
import os

with open(os.path.join(os.path.dirname(__file__), '../fixtures/env-vars.yaml')) as f:
    fixture = yaml.safe_load(f)

@pytest.mark.parametrize("case", fixture['cases'], ids=[c['id'] for c in fixture['cases']])
def test_env_vars(case, run_script, os_platform, skills_root):
    """Tests the env vars script"""
    script_ext = '.ps1' if os_platform == 'windows' else '.sh'
    script_path = os.path.join(skills_root, 'env-vars', 'scripts', f'env_vars{script_ext}')
    
    if not os.path.exists(script_path):
        pytest.skip(f"Script {script_path} not found")
        
    args = case.get('args', [])
    env = case.get('env', {})
    
    stdout, stderr, rc = run_script(script_path, args, env=env)
    assert rc == 0
    
    if case['assertions'].get('not_empty'):
        assert stdout.strip() != ''
        
    if 'contains' in case['assertions']:
        assert case['assertions']['contains'] in stdout
