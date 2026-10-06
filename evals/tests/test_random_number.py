import pytest
import yaml
import os

with open(os.path.join(os.path.dirname(__file__), '../fixtures/random-number.yaml')) as f:
    fixture = yaml.safe_load(f)

@pytest.mark.parametrize("case", fixture['cases'], ids=[c['id'] for c in fixture['cases']])
def test_random_number(case, run_script, os_platform, skills_root):
    """Tests the random_number script"""
    script_ext = '.ps1' if os_platform == 'windows' else '.sh'
    script_path = os.path.join(skills_root, 'random-number', 'scripts', f'random_number{script_ext}')
    
    if not os.path.exists(script_path):
        pytest.skip(f"Script {script_path} not found")
        
    args = case.get('args', [])
    stdout, stderr, rc = run_script(script_path, args)
    assert rc == 0
    
    lines = [l for l in stdout.strip().split('\n') if l]
    
    if 'count' in case['assertions']:
        assert len(lines) == case['assertions']['count']
        
    for line in lines:
        if case['assertions'].get('type') == 'int':
            val = int(line)
        else:
            val = float(line)
            
        if 'min' in case['assertions']:
            assert val >= case['assertions']['min']
        if 'max' in case['assertions']:
            assert val <= case['assertions']['max']
