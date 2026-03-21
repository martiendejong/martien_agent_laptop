#!/usr/bin/env python3
"""
Test Fine-Tuned Jengo Model

Tests the fine-tuned model with typical Jengo scenarios and compares
behavior to expected responses.

Usage:
    python test-fine-tuned-model.py
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
MODEL_ID_PATH = Path("E:/jengo/training-data/model-id.txt")

# Test scenarios
TEST_SCENARIOS = [
    {
        "name": "Feature Development - Worktree Allocation",
        "user_message": "Add a new authentication controller",
        "expected_keywords": ["worktree", "allocate", "consciousness bridge", "feature"],
        "expected_mode": "Feature"
    },
    {
        "name": "Debug - Direct Edit",
        "user_message": "Fix the null reference error in UserService.cs",
        "expected_keywords": ["base repo", "debug", "read", "edit"],
        "expected_mode": "Debug"
    },
    {
        "name": "DI Bug Recognition",
        "user_message": "Getting error: Unable to resolve service IUserRepository",
        "expected_keywords": ["Program.cs", "DI", "registration", "service"],
        "expected_mode": "Debug"
    },
    {
        "name": "PR Creation with Release",
        "user_message": "Create a PR for this feature",
        "expected_keywords": ["commit", "push", "gh pr create", "release worktree"],
        "expected_mode": "Feature"
    },
    {
        "name": "ClickUp Mode Detection",
        "user_message": "ClickUp task CU-123: Add export functionality",
        "expected_keywords": ["Feature", "worktree", "ClickUp"],
        "expected_mode": "Feature"
    }
]

def test_model(client, model_id):
    """Run test scenarios against the fine-tuned model"""

    print("\n=== Testing Fine-Tuned Jengo Model ===\n")
    print(f"Model: {model_id}\n")

    results = []

    for i, scenario in enumerate(TEST_SCENARIOS, 1):
        print(f"[{i}/{len(TEST_SCENARIOS)}] Testing: {scenario['name']}")
        print(f"User message: \"{scenario['user_message']}\"")

        try:
            response = client.messages.create(
                model=model_id,
                max_tokens=1024,
                system="You are Jengo, autonomous development agent.",
                messages=[
                    {"role": "user", "content": scenario['user_message']}
                ]
            )

            response_text = response.content[0].text
            print(f"Response: {response_text[:200]}...")

            # Check for expected keywords
            keywords_found = sum(
                1 for keyword in scenario['expected_keywords']
                if keyword.lower() in response_text.lower()
            )

            keywords_total = len(scenario['expected_keywords'])
            keyword_score = (keywords_found / keywords_total) * 100

            print(f"Keywords matched: {keywords_found}/{keywords_total} ({keyword_score:.0f}%)")

            results.append({
                "name": scenario['name'],
                "keyword_score": keyword_score,
                "response": response_text
            })

            print()

        except Exception as e:
            print(f"[ERROR] Test failed: {e}\n")
            results.append({
                "name": scenario['name'],
                "keyword_score": 0,
                "error": str(e)
            })

    # Summary
    print("\n=== Test Summary ===\n")

    avg_score = sum(r['keyword_score'] for r in results) / len(results)
    print(f"Average keyword match: {avg_score:.1f}%")

    passed = sum(1 for r in results if r['keyword_score'] >= 60)
    print(f"Tests passed (≥60%): {passed}/{len(results)}")

    print("\nDetailed Results:")
    for r in results:
        status = "✅ PASS" if r['keyword_score'] >= 60 else "❌ FAIL"
        print(f"  {status} {r['name']}: {r['keyword_score']:.0f}%")

    if avg_score >= 70:
        print("\n✅ Model is performing well!")
        print("The fine-tuned model has internalized Jengo's behavior.")
    elif avg_score >= 50:
        print("\n⚠️  Model shows partial learning")
        print("Consider training with more conversations or adjusting hyperparameters.")
    else:
        print("\n❌ Model needs more training")
        print("Generate more diverse training data and retrain.")

    return avg_score

def main():
    # Load API key
    if not API_KEY_PATH.exists():
        print(f"[ERROR] API key not found: {API_KEY_PATH}")
        return 1

    api_key = API_KEY_PATH.read_text().strip()

    # Load model ID
    if not MODEL_ID_PATH.exists():
        print(f"[ERROR] Model ID not found: {MODEL_ID_PATH}")
        print("Training may not be complete. Check status:")
        print("  python check-fine-tuning-status.py")
        return 1

    model_id = MODEL_ID_PATH.read_text().strip()

    # Initialize client
    client = Anthropic(api_key=api_key)

    # Run tests
    avg_score = test_model(client, model_id)

    return 0 if avg_score >= 70 else 1

if __name__ == "__main__":
    sys.exit(main())
