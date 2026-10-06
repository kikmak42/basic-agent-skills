import os
import re

tests_dir = 'evals/tests'
mapping = {
    'test_basic_math.py': ('basic-math', 'calculate'),
    'test_get_date.py': ('get-date', 'get_date'),
    'test_random_number.py': ('random-number', 'random_number'),
    'test_uuid_gen.py': ('uuid-gen', 'uuid_gen'),
    'test_convert.py': ('convert', 'convert'),
    'test_env_vars.py': ('env-vars', 'env_vars'),
    'test_file_ops.py': ('file-ops', 'file_ops'),
    'test_run_tests.py': ('run-tests', 'run_tests'),
    'test_shell_exec.py': ('shell-exec', 'shell_exec'),
    'test_web_search.py': ('web-search', 'web_search'),
}

for f, (folder, script) in mapping.items():
    p = os.path.join(tests_dir, f)
    with open(p, 'r') as file:
        content = file.read()
    
    new_content = re.sub(
        r"script_path = os\.path\.join\(skills_root, .*?, f'.*?\{script_ext\}'\)",
        f"script_path = os.path.join(skills_root, '{folder}', 'scripts', f'{script}{{script_ext}}')",
        content
    )
    with open(p, 'w') as file:
        file.write(new_content)
    print(f'Updated {f}')
