#!/usr/bin/env python3
"""
Start Fine-Tuning Job on Anthropic

Creates a fine-tuning job for the uploaded Jengo dataset.

Usage:
    python start-fine-tuning.py
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
API_KEY_PATH = Path("C:/scripts/_machine/openai-api-key.txt")
DATASET_ID_PATH = Path("E:/jengo/training-data/dataset-id.txt")
JOB_ID_PATH = Path("E:/jengo/training-data/job-id.txt")

# Fine-tuning hyperparameters
HYPERPARAMETERS = {
    "learning_rate": 1e-5,  # Conservative for stability
    "num_epochs": 3,         # Typical range: 1-5
    "batch_size": 4          # Adjust based on dataset size
}

def main():
    print("\n=== Starting Jengo Fine-Tuning Job ===\n")

    # Load API key
    if not API_KEY_PATH.exists():
        print(f"[ERROR] API key not found: {API_KEY_PATH}")
        return 1

    api_key = API_KEY_PATH.read_text().strip()

    # Load dataset ID
    if not DATASET_ID_PATH.exists():
        print(f"[ERROR] Dataset ID not found: {DATASET_ID_PATH}")
        print("Run: python upload-training-dataset.py first")
        return 1

    dataset_id = DATASET_ID_PATH.read_text().strip()
    print(f"[INFO] Using dataset: {dataset_id}")

    # Initialize client
    print("[INFO] Initializing Anthropic client...")
    client = Anthropic(api_key=api_key)

    # Create fine-tuning job
    print("[INFO] Creating fine-tuning job...")
    print(f"[INFO] Base model: claude-3-5-sonnet-20241022")
    print(f"[INFO] Hyperparameters: {HYPERPARAMETERS}")

    try:
        job = client.fine_tuning.jobs.create(
            dataset_id=dataset_id,
            model="claude-3-5-sonnet-20241022",
            name="jengo-v1",
            hyperparameters=HYPERPARAMETERS
        )

        print(f"\n[SUCCESS] Fine-tuning job started!")
        print(f"Job ID: {job.id}")
        print(f"Status: {job.status}")

        # Save job ID
        JOB_ID_PATH.write_text(job.id)
        print(f"\n[INFO] Job ID saved to: {JOB_ID_PATH}")

        print("\nJob Details:")
        print(f"  Name: {job.name}")
        print(f"  Base Model: claude-3-5-sonnet-20241022")
        print(f"  Status: {job.status}")

        print("\n[INFO] Training typically takes 2-6 hours")
        print("\nMonitor progress:")
        print("  python C:\\scripts\\tools\\check-fine-tuning-status.py")

        return 0

    except Exception as e:
        print(f"\n[ERROR] Job creation failed: {e}")
        print("\nPossible issues:")
        print("  - Dataset still processing (wait a few minutes)")
        print("  - Insufficient API credits")
        print("  - Invalid hyperparameters")
        return 1

if __name__ == "__main__":
    sys.exit(main())
