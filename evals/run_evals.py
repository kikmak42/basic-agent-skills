import pytest
import sys
import os

def main():
    print("Running evals...")
    exit_code = pytest.main(["-v", os.path.join(os.path.dirname(__file__), "tests"), "--json-report", "--json-report-file=.report.json"])
    print(f"Pytest exited with code {exit_code}")
    
    import json
    if os.path.exists(".report.json"):
        with open(".report.json") as f:
            data = json.load(f)
            
        print("\n=== Eval Summary ===")
        print(f"{'Skill':<15} | {'Cases':<5} | {'Passed':<6} | {'Failed':<6} | {'Score %':<7}")
        print("-" * 50)
        
        passed = data['summary'].get('passed', 0)
        failed = data['summary'].get('failed', 0)
        total = passed + failed
        score = (passed / total * 100) if total > 0 else 0
        print(f"{'All':<15} | {total:<5} | {passed:<6} | {failed:<6} | {score:.1f}%")
        
if __name__ == '__main__':
    main()
