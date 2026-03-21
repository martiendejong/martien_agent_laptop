#!/usr/bin/env python3
"""
Check Fine-Tuning Status

Monitors the progress of the Jengo fine-tuning job.

Usage:
    python check-fine-tuning-status.py           # Check once
    python check-fine-tuning-status.py --watch   # Monitor continuously
"""

import sys
import time
from pathlib import Path

try:
    from anthropic import Anthropic
except ImportError:
    print("[ERROR] anthropic package not installed")
    print("Run: pip install anthropic")
    sys.exit(1)

# Configuration
API_KEY_PATH = Path("C:/scripts/_machine/openai-api-key.txt")
JOB_ID_PATH = Path("E:/jengo/training-data/job-id.txt")
MODEL_ID_PATH = Path("E:/jengo/training-data/model-id.txt")

def check_status(client, job_id):
    """Check job status once"""
    job = client.fine_tuning.jobs.retrieve(job_id)

    print(f"\n=== Fine-Tuning Job Status ===\n")
    print(f"Job ID: {job.id}")
    print(f"Name: {job.name}")
    print(f"Status: {job.status}")

    if hasattr(job, 'progress'):
        print(f"Progress: {job.progress}%")

    if hasattr(job, 'created_at'):
        print(f"Created: {job.created_at}")

    if hasattr(job, 'updated_at'):
        print(f"Updated: {job.updated_at}")

    if job.status == "completed":
        print(f"\n✅ Training complete!")
        print(f"Fine-tuned Model ID: {job.fine_tuned_model}")

        # Save model ID
        MODEL_ID_PATH.write_text(job.fine_tuned_model)
        print(f"\n[INFO] Model ID saved to: {MODEL_ID_PATH}")

        print("\nNext steps:")
        print("  1. Test the model: python test-fine-tuned-model.py")
        print("  2. Update agent config to use this model")

        return "completed"

    elif job.status == "failed":
        print(f"\n❌ Training failed")
        if hasattr(job, 'error'):
            print(f"Error: {job.error}")

        print("\nTroubleshooting:")
        print("  - Check dataset format (must be valid JSONL)")
        print("  - Verify API credits are sufficient")
        print("  - Review hyperparameters")

        return "failed"

    elif job.status in ["queued", "running"]:
        print(f"\n⏳ Training in progress...")
        print("This typically takes 2-6 hours")

        return job.status

    else:
        print(f"\n[INFO] Status: {job.status}")
        return job.status

def main():
    watch_mode = "--watch" in sys.argv

    # Load API key
    if not API_KEY_PATH.exists():
        print(f"[ERROR] API key not found: {API_KEY_PATH}")
        return 1

    api_key = API_KEY_PATH.read_text().strip()

    # Load job ID
    if not JOB_ID_PATH.exists():
        print(f"[ERROR] Job ID not found: {JOB_ID_PATH}")
        print("Run: python start-fine-tuning.py first")
        return 1

    job_id = JOB_ID_PATH.read_text().strip()

    # Initialize client
    client = Anthropic(api_key=api_key)

    if watch_mode:
        print("[INFO] Watching job status (checks every 60 seconds)")
        print("Press Ctrl+C to stop\n")

        try:
            while True:
                status = check_status(client, job_id)

                if status in ["completed", "failed"]:
                    break

                print("\n[INFO] Next check in 60 seconds...")
                time.sleep(60)

        except KeyboardInterrupt:
            print("\n\n[INFO] Monitoring stopped")
            return 0

    else:
        status = check_status(client, job_id)

        if status not in ["completed", "failed"]:
            print("\n[INFO] Use --watch to monitor continuously:")
            print("  python check-fine-tuning-status.py --watch")

    return 0

if __name__ == "__main__":
    sys.exit(main())
