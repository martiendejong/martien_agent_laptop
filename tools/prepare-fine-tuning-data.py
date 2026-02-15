#!/usr/bin/env python3
"""
Prepare Fine-Tuning Data - Convert Jengo conversations to Anthropic training format

Converts logged conversation JSONs to JSONL format for Anthropic fine-tuning API.

Usage:
    python prepare-fine-tuning-data.py                    # All conversations
    python prepare-fine-tuning-data.py --min-quality 0.8  # Filter by quality
    python prepare-fine-tuning-data.py --success-only     # Only successful outcomes
"""

import json
import sys
from pathlib import Path
from typing import List, Dict, Any

# Configuration
CONVERSATIONS_DIR = Path("E:/jengo/training-data/conversations")
OUTPUT_FILE = Path("E:/jengo/training-data/fine-tuning-dataset.jsonl")
SYSTEM_PROMPT_FILE = Path("C:/scripts/CLAUDE.md")

def load_system_prompt() -> str:
    """Load the Jengo system prompt from CLAUDE.md"""
    if not SYSTEM_PROMPT_FILE.exists():
        print(f"[WARNING] CLAUDE.md not found at {SYSTEM_PROMPT_FILE}")
        print("Using minimal system prompt")
        return "You are Jengo, an autonomous development agent."

    return SYSTEM_PROMPT_FILE.read_text(encoding='utf-8')

def load_conversations(success_only: bool = False, min_quality: float = 0.0) -> List[Dict[str, Any]]:
    """Load and filter conversations"""
    if not CONVERSATIONS_DIR.exists():
        print(f"[ERROR] Conversations directory not found: {CONVERSATIONS_DIR}")
        return []

    conversations = []
    for conv_file in CONVERSATIONS_DIR.glob("*.json"):
        try:
            conv = json.loads(conv_file.read_text(encoding='utf-8'))

            # Filter by outcome
            if success_only and conv.get('outcome') != 'Success':
                continue

            # Filter by quality (if we have a quality score)
            quality = conv.get('quality_score', 1.0)
            if quality < min_quality:
                continue

            # Skip if no conversation messages
            if not conv.get('conversation', {}).get('user_messages'):
                print(f"[SKIP] {conv_file.name} - No conversation messages")
                continue

            conversations.append(conv)

        except Exception as e:
            print(f"[WARNING] Failed to load {conv_file}: {e}")

    return conversations

def convert_to_training_example(conv: Dict[str, Any], system_prompt: str) -> Dict[str, Any]:
    """Convert a conversation to Anthropic training format"""

    # Start with system message
    messages = [{"role": "system", "content": system_prompt}]

    user_msgs = conv['conversation'].get('user_messages', [])
    agent_msgs = conv['conversation'].get('agent_messages', [])

    # Interleave user and agent messages
    max_length = max(len(user_msgs), len(agent_msgs))
    for i in range(max_length):
        if i < len(user_msgs):
            messages.append({
                "role": "user",
                "content": user_msgs[i]
            })
        if i < len(agent_msgs):
            messages.append({
                "role": "assistant",
                "content": agent_msgs[i]
            })

    return {"messages": messages}

def analyze_dataset(examples: List[Dict[str, Any]]):
    """Analyze dataset statistics"""
    total_examples = len(examples)
    total_messages = sum(len(ex['messages']) for ex in examples)
    total_tokens_estimate = sum(
        len(' '.join([m['content'] for m in ex['messages']])) // 4  # Rough token estimate
        for ex in examples
    )

    print("\n=== Dataset Statistics ===")
    print(f"Total examples: {total_examples}")
    print(f"Total messages: {total_messages}")
    print(f"Avg messages per example: {total_messages / total_examples:.1f}")
    print(f"Est. total tokens: {total_tokens_estimate:,}")
    print(f"Est. training cost: ${total_tokens_estimate / 1_000_000 * 10:.2f} (rough)")

def main():
    # Parse arguments
    success_only = "--success-only" in sys.argv
    min_quality = 0.0
    for i, arg in enumerate(sys.argv):
        if arg == "--min-quality" and i + 1 < len(sys.argv):
            min_quality = float(sys.argv[i + 1])

    print("[INFO] Preparing fine-tuning dataset...")

    # Load system prompt
    system_prompt = load_system_prompt()
    print(f"[INFO] System prompt loaded ({len(system_prompt)} chars)")

    # Load conversations
    print(f"[INFO] Loading conversations from {CONVERSATIONS_DIR}")
    if success_only:
        print("[INFO] Filtering to successful outcomes only")
    if min_quality > 0:
        print(f"[INFO] Filtering to quality >= {min_quality}")

    conversations = load_conversations(success_only=success_only, min_quality=min_quality)

    if not conversations:
        print("[ERROR] No conversations found or all filtered out")
        print("\nTry:")
        print("  1. Log conversations: jengo-conversation-logger.ps1 -Interactive")
        print("  2. Remove filters: python prepare-fine-tuning-data.py")
        return 1

    print(f"[INFO] Loaded {len(conversations)} conversation(s)")

    # Convert to training examples
    training_examples = []
    for conv in conversations:
        try:
            example = convert_to_training_example(conv, system_prompt)
            training_examples.append(example)
        except Exception as e:
            print(f"[WARNING] Failed to convert {conv.get('session_id', 'unknown')}: {e}")

    if not training_examples:
        print("[ERROR] No training examples generated")
        return 1

    # Analyze dataset
    analyze_dataset(training_examples)

    # Minimum dataset size check
    if len(training_examples) < 50:
        print("\n[WARNING] Dataset is small (<50 examples)")
        print("Fine-tuning may not be effective with this little data.")
        print("Recommendation: Collect at least 100 conversations before fine-tuning.")
        print("\nContinue anyway? (y/n)")
        if input().lower() != 'y':
            print("Aborted. Collect more data and try again.")
            return 0

    # Write JSONL
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        for example in training_examples:
            f.write(json.dumps(example, ensure_ascii=False) + '\n')

    print(f"\n[SUCCESS] Training dataset created: {OUTPUT_FILE}")
    print(f"Format: JSONL (Anthropic fine-tuning API compatible)")
    print(f"\nNext steps:")
    print("  1. Review the JSONL file manually (spot check quality)")
    print("  2. Upload to Anthropic: python upload-training-data.py")
    print("  3. Start fine-tuning job: python start-fine-tuning.py")

    return 0

if __name__ == "__main__":
    sys.exit(main())
