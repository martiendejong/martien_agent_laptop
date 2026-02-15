#!/usr/bin/env python3
"""
Verify Jengo Training Setup

Checks if all dependencies and configuration are in place.

Usage:
    python verify-jengo-training-setup.py
"""

import sys
from pathlib import Path

def check(condition, message):
    """Check a condition and print result"""
    if condition:
        print(f"[OK] {message}")
        return True
    else:
        print(f"[FAIL] {message}")
        return False

def main():
    checks_passed = 0
    checks_total = 0

    print("\n=== Jengo Training System Setup Verification ===\n")

    # Python version
    checks_total += 1
    if check(sys.version_info >= (3, 8), f"Python version: {sys.version.split()[0]}"):
        checks_passed += 1
    else:
        print("      Need Python 3.8 or higher")

    # chromadb package
    checks_total += 1
    try:
        import chromadb
        if check(True, f"chromadb installed (version: {chromadb.__version__})"):
            checks_passed += 1
    except ImportError:
        check(False, "chromadb installed")
        print("      Run: pip install chromadb")

    # openai package
    checks_total += 1
    try:
        import openai
        if check(True, f"openai installed"):
            checks_passed += 1
    except ImportError:
        check(False, "openai installed")
        print("      Run: pip install openai")

    # OpenAI API key
    checks_total += 1
    api_key_path = Path("C:/scripts/_machine/openai-api-key.txt")
    if check(api_key_path.exists(), "OpenAI API key found"):
        checks_passed += 1
        # Validate format
        api_key = api_key_path.read_text().strip().split('\n')[0]
        if api_key.startswith('sk-'):
            print("      Key format looks valid")
        else:
            print("      WARNING: Key doesn't start with 'sk-' - might be invalid")
    else:
        print(f"      Create file: {api_key_path}")
        print("      Content: your OpenAI API key (first line)")

    # Training data directory
    checks_total += 1
    training_dir = Path("E:/jengo/training-data/conversations")
    if check(training_dir.exists(), "Training data directory exists"):
        checks_passed += 1
    else:
        print(f"      Will be created automatically on first run")

    # Conversation files
    checks_total += 1
    if training_dir.exists():
        conversation_files = list(training_dir.glob("*.json"))
        if check(len(conversation_files) > 0, f"{len(conversation_files)} conversation(s) found"):
            checks_passed += 1
        else:
            print("      Run: jengo-conversation-logger.ps1 -Interactive")
    else:
        print("[SKIP] No training directory yet")

    # Vector DB directory
    vector_db_dir = Path("E:/jengo/training-data/vector-db")
    if vector_db_dir.exists():
        print(f"[INFO] Vector database exists (embedded conversations ready)")
    else:
        print(f"[INFO] Vector database will be created on first embedding")

    # Summary
    print(f"\n=== Summary: {checks_passed}/{checks_total} checks passed ===\n")

    if checks_passed == checks_total:
        print("[READY] System is ready for embedding generation!")
        print("\nNext step:")
        print("  python C:\\scripts\\tools\\build-jengo-memory.py")
        return 0
    else:
        print("[NOT READY] Fix the issues above before proceeding")
        print("\nQuick fixes:")
        if checks_passed < checks_total:
            print("  1. Install packages: pip install chromadb openai")
            print("  2. Add API key to C:\\scripts\\_machine\\openai-api-key.txt")
            print("  3. Log a conversation: jengo-conversation-logger.ps1 -Interactive")
        return 1

if __name__ == "__main__":
    sys.exit(main())
