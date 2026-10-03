import pytest
import yaml
import os
import re

with open(os.path.join(os.path.dirname(__file__), '../fixtures/uuid-gen.yaml')) as f:
    fixture = yaml.safe_load(f)

@pytest.mark.parametrize("case", fixture['cases'], ids=[c['id'] for c in fixture['cases']])
def test_uuid_gen(case, run_script, os_platform, skills_root):
    """Tests the uuid gen script"""
    script_ext = '.ps1' if os_platform == 'windows' else '.sh'
    script_path = os.path.join(skills_root, 'uuid_gen', f'uuid_gen{script_ext}')
    
    if not os.path.exists(script_path):
        pytest.skip(f"Script {script_path} not found")
        
    args = case.get('args', [])
    stdout, stderr, rc = run_script(script_path, args)
    assert rc == 0
    
    lines = [l for l in stdout.strip().split('\n') if l]
    
    if 'count' in case['assertions']:
        assert len(lines) == case['assertions']['count']
        
    if 'regex' in case['assertions']:
        for line in lines:
            assert re.match(case['assertions']['regex'], line, re.IGNORECASE)
            
    if 'token_length' in case['assertions']:
        for line in lines:
            assert len(line) == case['assertions']['token_length']
