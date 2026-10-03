# Evals

This framework tests the actual helper scripts (not the LLM), verifying they produce correct output. This follows the inspect-ai / standard pytest convention.

## What it tests
These are "script evals" — they test the tool layer, not the LLM layer. It ensures the underlying scripts that skills delegate to are functioning as expected.

## Installation
`pip install -r evals/requirements.txt`

## Running Evals
`pytest evals/tests/ -v` or `python evals/run_evals.py`

## Reading Results
Outputs pass/fail per case, with a final scoring summary.

## Adding New Evals
Add a YAML fixture in `evals/fixtures/` and a corresponding test in `evals/tests/`.
