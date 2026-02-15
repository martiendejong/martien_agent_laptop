#!/usr/bin/env python3
"""
Inject Jengo Examples - Add few-shot examples to system prompt

Retrieves relevant past conversations and formats them as few-shot examples
for injection into Jengo's system prompt.

Usage:
    python inject-jengo-examples.py "Fix DI bug in client-manager"
    python inject-jengo-examples.py "Create PR for social media feature" --output examples.md
"""

import json
import sys
from pathlib import Path
from typing import List, Dict, Any

# Import query functionality
sys.path.insert(0, str(Path(__file__).parent))
try:
    from query_jengo_memory import query_similar_conversations
except ImportError:
    # If running standalone, inline the import
    pass

def format_as_few_shot_example(conv: Dict[str, Any]) -> str:
    """Format a conversation as a few-shot example for prompt injection"""
    if not conv.get('full_conversation'):
        return ""

    full = conv['full_conversation']
    parts = []

    # Header
    parts.append(f"### Example: {full.get('task_description', 'Task')}")
    parts.append(f"**Mode:** {full.get('mode', 'unknown')}")
    if full.get('project'):
        parts.append(f"**Project:** {full['project']}")
    parts.append("")

    # Approach taken
    if full.get('decisions'):
        parts.append("**Approach:**")
        for i, d in enumerate(full['decisions'], 1):
            parts.append(f"{i}. **{d.get('decision', 'Decision')}**")
            parts.append(f"   - Reasoning: {d.get('reasoning', 'No reasoning provided')}")
        parts.append("")

    # Tools used
    if full.get('tools_used'):
        parts.append(f"**Tools:** {', '.join(full['tools_used'])}")
        parts.append("")

    # Outcome
    parts.append(f"**Outcome:** {full.get('outcome', 'unknown')}")

    # Lessons learned
    if full.get('lessons_learned'):
        parts.append("")
        parts.append("**Lessons:**")
        for lesson in full['lessons_learned']:
            parts.append(f"- {lesson}")

    # Artifacts
    artifacts = full.get('artifacts', {})
    artifact_list = []
    if artifacts.get('pr_url'):
        artifact_list.append(f"PR: {artifacts['pr_url']}")
    if artifacts.get('clickup_task'):
        artifact_list.append(f"Task: {artifacts['clickup_task']}")

    if artifact_list:
        parts.append("")
        parts.append("**Artifacts:** " + ", ".join(artifact_list))

    return "\n".join(parts)

def generate_prompt_injection(query: str, top_k: int = 3) -> str:
    """Generate prompt injection text with few-shot examples"""
    # Import by exec since it's a script, not module
    import sys
    import importlib.util
    spec = importlib.util.spec_from_file_location("query_jengo_memory", Path(__file__).parent / "query-jengo-memory.py")
    query_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(query_module)
    query_similar_conversations = query_module.query_similar_conversations

    # Query for similar conversations
    conversations = query_similar_conversations(query, top_k=top_k)

    if not conversations:
        return "# No relevant past examples found.\n"

    # Build prompt section
    lines = []
    lines.append("# Relevant Past Examples")
    lines.append("")
    lines.append("The following are relevant past sessions showing how similar tasks were handled:")
    lines.append("")

    for i, conv in enumerate(conversations, 1):
        example = format_as_few_shot_example(conv)
        if example:
            lines.append(f"## Example {i} (Similarity: {conv['similarity_score']:.2f})")
            lines.append("")
            lines.append(example)
            lines.append("")
            lines.append("---")
            lines.append("")

    lines.append("# Current Task")
    lines.append("")
    lines.append(f"Apply the patterns and lessons from the above examples to the current task: **{query}**")
    lines.append("")

    return "\n".join(lines)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python inject-jengo-examples.py <query> [--output FILE] [--top-k N]")
        print("\nExamples:")
        print("  python inject-jengo-examples.py 'Fix DI bug'")
        print("  python inject-jengo-examples.py 'Create PR' --output examples.md")
        print("  python inject-jengo-examples.py 'Debug build error' --top-k 5")
        sys.exit(1)

    # Parse arguments
    query = sys.argv[1]
    output_file = None
    top_k = 3

    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg == "--output" and i + 1 < len(sys.argv):
            output_file = sys.argv[i + 1]
            i += 2
        elif arg == "--top-k" and i + 1 < len(sys.argv):
            top_k = int(sys.argv[i + 1])
            i += 2
        else:
            i += 1

    # Generate injection text
    print(f"[INFO] Querying for: '{query}'")
    print(f"[INFO] Retrieving top {top_k} examples...")

    prompt_injection = generate_prompt_injection(query, top_k=top_k)

    # Output
    if output_file:
        output_path = Path(output_file)
        output_path.write_text(prompt_injection, encoding='utf-8')
        print(f"\n[SUCCESS] Prompt injection saved to: {output_path}")
        print("\nCopy the contents and add to your system prompt before starting the session.")
    else:
        print("\n" + "="*80)
        print(prompt_injection)
        print("="*80)
        print("\nCopy the above and add to your system prompt.")
