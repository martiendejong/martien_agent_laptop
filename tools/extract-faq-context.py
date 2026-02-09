import json, sys, re

session_id = sys.argv[1] if len(sys.argv) > 1 else "200cfb54-62f1-4ad1-9f7f-7f79325604d1"
pattern = sys.argv[2] if len(sys.argv) > 2 else "faq|FAQ"

path = f"C:/Users/HP/.claude/projects/C--scripts/{session_id}.jsonl"

with open(path, 'r', encoding='utf-8', errors='replace') as f:
    for i, line in enumerate(f):
        if not re.search(pattern, line, re.IGNORECASE):
            continue
        try:
            obj = json.loads(line)
            msg_type = obj.get('type', '')

            if msg_type == 'assistant':
                content = obj.get('message', {}).get('content', '')
                if isinstance(content, list):
                    for block in content:
                        if block.get('type') == 'text' and re.search(pattern, block.get('text', ''), re.IGNORECASE):
                            text = block['text']
                            # Find match position and extract context
                            m = re.search(pattern, text, re.IGNORECASE)
                            if m:
                                start = max(0, m.start() - 300)
                                end = min(len(text), m.end() + 300)
                                print(f"\n=== LINE {i} ASSISTANT ===")
                                print(text[start:end])
                        elif block.get('type') == 'tool_use':
                            inp = json.dumps(block.get('input', {}), ensure_ascii=False)
                            if re.search(pattern, inp, re.IGNORECASE):
                                print(f"\n=== LINE {i} TOOL: {block['name']} ===")
                                print(inp[:500])
            elif msg_type in ('user', 'human'):
                content = obj.get('message', {}).get('content', '')
                if isinstance(content, str) and re.search(pattern, content, re.IGNORECASE):
                    print(f"\n=== LINE {i} USER ===")
                    print(content[:500])
        except:
            pass
