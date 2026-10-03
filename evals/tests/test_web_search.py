import pytest
import yaml
import os

with open(os.path.join(os.path.dirname(__file__), '../fixtures/web-search.yaml')) as f:
    fixture = yaml.safe_load(f)

@pytest.mark.parametrize("case", fixture['cases'], ids=[c['id'] for c in fixture['cases']])
def test_web_search(case):
    """Tests web-search"""
    if case.get('skip'):
        pytest.skip(case.get('reason', 'Skipped'))
