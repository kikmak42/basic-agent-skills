import pytest
import yaml
import os

with open(os.path.join(os.path.dirname(__file__), '../fixtures/run-tests.yaml')) as f:
    fixture = yaml.safe_load(f)

@pytest.mark.parametrize("case", fixture['cases'], ids=[c['id'] for c in fixture['cases']])
def test_run_tests(case):
    """Tests run-tests"""
    if case.get('skip'):
        pytest.skip(case.get('reason', 'Skipped'))
