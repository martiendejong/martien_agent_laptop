import json, sys, re, os

sys.stdout.reconfigure(encoding='utf-8')

session_id = sys.argv[1] if len(sys.argv) > 1 else "200cfb54-62f1-4ad1-9f7f-7f79325604d1"
pattern = sys.argv[2] if len(sys.argv) > 2 else "faq"

path = f"C:/Users/HP/.claude/projects/C--scripts/{session_id}.jsonl"

with open(path, 'r', encoding='utf-8', errors='replace') as f:
    for i, line in enumerate(f):
        if not re.search(pattern, line, re.IGNORECASE):
            continue
        for m in re.finditer(pattern, line, re.IGNORECASE):
            start = max(0, m.start() - 200)
            end = min(len(line), m.end() + 200)
            snippet = line[start:end].replace('\\n', '\n').replace('\\r', '')
            print(f"--- Line {i}, pos {m.start()} ---")
            print(snippet)
            print()
            break
