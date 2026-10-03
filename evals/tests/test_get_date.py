import pytest
import yaml
import os
import re

with open(os.path.join(os.path.dirname(__file__), '../fixtures/get-date.yaml')) as f:
    fixture = yaml.safe_load(f)

@pytest.mark.parametrize("case", fixture['cases'], ids=[c['id'] for c in fixture['cases']])
def test_get_date(case, run_script, os_platform, skills_root):
    """Tests the get_date script"""
    script_ext = '.ps1' if os_platform == 'windows' else '.sh'
    script_path = os.path.join(skills_root, 'get_date', f'get_date{script_ext}')
    
    if not os.path.exists(script_path):
        pytest.skip(f"Script {script_path} not found")
        
    stdout, stderr, rc = run_script(script_path)
    assert rc == 0
    
    if case['assertions'].get('not_empty'):
        assert stdout.strip() != ''
    if case['assertions'].get('contains_year'):
        assert re.search(r'202[0-9]|2030', stdout)
    if case['assertions'].get('contains_day_or_month'):
        assert re.search(r'[A-Za-z]+', stdout)
