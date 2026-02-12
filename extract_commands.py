import json

with open(r'C:\Users\HP\.claude\projects\C--scripts\11f27fe7-d906-4d21-9e2d-28d8ea15a134.jsonl', 'r', encoding='utf-8') as f:
    lines = f.readlines()

out = open(r'C:\scripts\session_subagent_commands.txt', 'w', encoding='utf-8')

for idx in range(len(lines)):
    try:
        obj = json.loads(lines[idx])
        if obj.get('type') != 'progress':
            continue

        data = obj.get('data', {})
        if not isinstance(data, dict):
            continue

        msg = data.get('message', {})
        if not isinstance(msg, dict):
            continue

        msg_type = msg.get('type', '')
        parent_tool = obj.get('parentToolUseID', '')
        agent_id = data.get('agentId', '')
        ts = obj.get('timestamp', '')

        inner_msg = msg.get('message', {})
        if not isinstance(inner_msg, dict):
            continue

        content = inner_msg.get('content', [])
        if not isinstance(content, list):
            continue

        for block in content:
            if not isinstance(block, dict):
                continue
            if block.get('type') == 'tool_use' and block.get('name') == 'Bash':
                cmd = block.get('input', {}).get('command', '')
                if cmd:
                    out.write(f'LINE {idx+1} | ts={ts} | agent={agent_id} | parentTool={parent_tool}\n')
                    out.write(f'CMD: {cmd}\n\n')
            elif block.get('type') == 'tool_result':
                content_str = block.get('content', '')
                if isinstance(content_str, str) and len(content_str) > 20:
                    lower = content_str.lower()
                    if any(kw in lower for kw in ['5123', '52872', '52873', 'service', 'error', 'fail', 'crash', 'stop', 'kill', 'running', 'hazina']):
                        out.write(f'LINE {idx+1} | ts={ts} | RESULT (relevant):\n')
                        out.write(f'{content_str[:1200]}\n\n')
    except Exception as e:
        pass

out.close()
print('Done')
