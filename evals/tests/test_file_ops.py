import pytest
import yaml
import os

with open(os.path.join(os.path.dirname(__file__), '../fixtures/file-ops.yaml')) as f:
    fixture = yaml.safe_load(f)

@pytest.mark.parametrize("case", fixture['cases'], ids=[c['id'] for c in fixture['cases']])
def test_file_ops(case):
    """Tests file-ops"""
    if case.get('skip'):
        pytest.skip(case.get('reason', 'Skipped'))
