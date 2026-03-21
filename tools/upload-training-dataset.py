#!/usr/bin/env python3
"""
Upload Training Dataset to Anthropic

Uploads the Jengo training dataset to Anthropic's fine-tuning API.

Usage:
    python upload-training-dataset.py
"""

import sys
from pathlib import Path

try:
    from anthropic import Anthropic
except ImportError:
    print("[ERROR] anthropic package not installed")
    print("Run: pip install anthropic")
    sys.exit(1)

# Configuration
API_KEY_PATH = Path("C:/scripts/_machine/openai-api-key.txt")  # Note: We'll use same key storage
DATASET_PATH = Path("E:/jengo/training-data/synthetic-conversations/jengo-training-dataset.jsonl")
OUTPUT_PATH = Path("E:/jengo/training-data/dataset-id.txt")

def main():
    print("\n=== Uploading Jengo Training Dataset to Anthropic ===\n")

    # Check dataset exists
    if not DATASET_PATH.exists():
        print(f"[ERROR] Dataset not found: {DATASET_PATH}")
        print("Run: python generate-jengo-training-data.py first")
        return 1

    # Load API key
    if not API_KEY_PATH.exists():
        print(f"[ERROR] API key not found: {API_KEY_PATH}")
        print("Add your Anthropic API key to this file")
        return 1

    api_key = API_KEY_PATH.read_text().strip()

    # Initialize client
    print("[INFO] Initializing Anthropic client...")
    client = Anthropic(api_key=api_key)

    # Upload dataset
    print(f"[INFO] Uploading dataset: {DATASET_PATH}")
    print(f"[INFO] Size: {DATASET_PATH.stat().st_size / 1024:.1f} KB")

    try:
        with open(DATASET_PATH, 'rb') as f:
            dataset = client.fine_tuning.datasets.create(
                name="jengo-training-v1",
                file=f
            )

        print(f"\n[SUCCESS] Dataset uploaded!")
        print(f"Dataset ID: {dataset.id}")
        print(f"Status: {dataset.status}")

        # Save dataset ID
        OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT_PATH.write_text(dataset.id)
        print(f"\n[INFO] Dataset ID saved to: {OUTPUT_PATH}")

        print("\nNext step:")
        print("  python C:\\scripts\\tools\\start-fine-tuning.py")

        return 0

    except Exception as e:
        print(f"\n[ERROR] Upload failed: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
