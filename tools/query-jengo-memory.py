#!/usr/bin/env python3
"""
Query Jengo Memory - Retrieve similar past conversations

Finds relevant past conversations based on semantic similarity.
Used to inject few-shot examples into Jengo's context.

Usage:
    python query-jengo-memory.py "Fix DI bug in client-manager"
    python query-jengo-memory.py "Create PR for feature" --top-k 5
    python query-jengo-memory.py "Debug build error" --mode Debug
"""

import json
import sys
from pathlib import Path
from typing import List, Dict, Any, Optional

try:
    import chromadb
    from chromadb.config import Settings
except ImportError:
    print("[ERROR] chromadb not installed. Run: pip install chromadb")
    sys.exit(1)

try:
    from openai import OpenAI
except ImportError:
    print("[ERROR] openai not installed. Run: pip install openai")
    sys.exit(1)

# Configuration
VECTOR_DB_DIR = Path("E:/jengo/training-data/vector-db")
OPENAI_API_KEY_PATH = Path("C:/scripts/_machine/openai-api-key.txt")
TRAINING_DATA_DIR = Path("E:/jengo/training-data/conversations")

def get_openai_client():
    """Load OpenAI API key and return client"""
    if not OPENAI_API_KEY_PATH.exists():
        print(f"[ERROR] OpenAI API key not found at: {OPENAI_API_KEY_PATH}")
        sys.exit(1)

    api_key = OPENAI_API_KEY_PATH.read_text().strip().split('\n')[0]
    return OpenAI(api_key=api_key)

def get_chroma_client():
    """Initialize and return ChromaDB client"""
    if not VECTOR_DB_DIR.exists():
        print("[ERROR] Vector database not found. Run: python build-jengo-memory.py")
        sys.exit(1)

    client = chromadb.PersistentClient(
        path=str(VECTOR_DB_DIR),
        settings=Settings(anonymized_telemetry=False)
    )
    return client

def query_similar_conversations(
    query_text: str,
    top_k: int = 3,
    mode_filter: Optional[str] = None,
    outcome_filter: Optional[str] = None
) -> List[Dict[str, Any]]:
    """Query for similar conversations"""

    # Initialize clients
    openai_client = get_openai_client()
    chroma_client = get_chroma_client()

    # Get collection
    try:
        collection = chroma_client.get_collection("jengo_conversations")
    except:
        print("[ERROR] Collection 'jengo_conversations' not found. Run: python build-jengo-memory.py")
        sys.exit(1)

    # Generate query embedding
    response = openai_client.embeddings.create(
        input=[query_text],
        model="text-embedding-3-small"
    )
    query_embedding = response.data[0].embedding

    # Build filter
    where_filter = {}
    if mode_filter:
        where_filter["mode"] = mode_filter
    if outcome_filter:
        where_filter["outcome"] = outcome_filter

    # Query collection
    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=top_k,
        where=where_filter if where_filter else None
    )

    # Format results
    conversations = []
    for i in range(len(results['ids'][0])):
        session_id = results['ids'][0][i]
        distance = results['distances'][0][i]
        metadata = results['metadatas'][0][i]
        document = results['documents'][0][i]

        # Load full conversation JSON
        json_path = TRAINING_DATA_DIR / f"{session_id}.json"
        full_conv = None
        if json_path.exists():
            with open(json_path, 'r', encoding='utf-8') as f:
                full_conv = json.load(f)

        conversations.append({
            'session_id': session_id,
            'similarity_score': 1 - distance,  # Convert distance to similarity
            'metadata': metadata,
            'summary': document,
            'full_conversation': full_conv
        })

    return conversations

def print_results(conversations: List[Dict[str, Any]], verbose: bool = False):
    """Pretty print query results"""
    if not conversations:
        print("\n[INFO] No matching conversations found.")
        return

    print(f"\n=== Found {len(conversations)} similar conversation(s) ===\n")

    for i, conv in enumerate(conversations, 1):
        print(f"[{i}] {conv['session_id']}")
        print(f"    Similarity: {conv['similarity_score']:.3f}")
        print(f"    Mode: {conv['metadata']['mode']}")
        print(f"    Project: {conv['metadata']['project'] or 'N/A'}")
        print(f"    Outcome: {conv['metadata']['outcome']}")
        print(f"    Tools: {conv['metadata']['tools_used'] or 'N/A'}")
        print(f"    Timestamp: {conv['metadata']['timestamp']}")

        if verbose and conv['full_conversation']:
            full = conv['full_conversation']
            print(f"\n    Task: {full.get('task_description', 'N/A')}")

            if full.get('decisions'):
                print(f"\n    Decisions:")
                for d in full['decisions']:
                    print(f"      - {d.get('decision', '')}")
                    print(f"        Reason: {d.get('reasoning', '')}")

            if full.get('lessons_learned'):
                print(f"\n    Lessons:")
                for lesson in full['lessons_learned']:
                    print(f"      - {lesson}")

            if full.get('artifacts', {}).get('pr_url'):
                print(f"\n    PR: {full['artifacts']['pr_url']}")

        print()

def export_for_prompt(conversations: List[Dict[str, Any]], output_file: str):
    """Export conversations as few-shot examples for prompt injection"""
    examples = []

    for conv in conversations:
        if not conv['full_conversation']:
            continue

        full = conv['full_conversation']
        example = {
            'task': full.get('task_description', ''),
            'mode': full.get('mode', ''),
            'approach': []
        }

        # Add decisions as approach steps
        for d in full.get('decisions', []):
            example['approach'].append({
                'decision': d.get('decision', ''),
                'reasoning': d.get('reasoning', '')
            })

        # Add tools used
        example['tools_used'] = full.get('tools_used', [])

        # Add outcome and lessons
        example['outcome'] = full.get('outcome', '')
        example['lessons'] = full.get('lessons_learned', [])

        examples.append(example)

    # Save as JSON
    output_path = Path(output_file)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(examples, f, indent=2, ensure_ascii=False)

    print(f"[SUCCESS] Exported {len(examples)} example(s) to: {output_path}")
    print("\nYou can inject these into system prompt as few-shot examples.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python query-jengo-memory.py <query> [--top-k N] [--mode MODE] [--outcome OUTCOME] [--verbose] [--export FILE]")
        print("\nExamples:")
        print("  python query-jengo-memory.py 'Fix DI bug'")
        print("  python query-jengo-memory.py 'Create PR' --top-k 5 --mode Feature")
        print("  python query-jengo-memory.py 'Debug error' --verbose")
        print("  python query-jengo-memory.py 'Build issue' --export examples.json")
        sys.exit(1)

    # Parse arguments
    query = sys.argv[1]
    top_k = 3
    mode_filter = None
    outcome_filter = None
    verbose = False
    export_file = None

    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg == "--top-k" and i + 1 < len(sys.argv):
            top_k = int(sys.argv[i + 1])
            i += 2
        elif arg == "--mode" and i + 1 < len(sys.argv):
            mode_filter = sys.argv[i + 1]
            i += 2
        elif arg == "--outcome" and i + 1 < len(sys.argv):
            outcome_filter = sys.argv[i + 1]
            i += 2
        elif arg == "--verbose":
            verbose = True
            i += 1
        elif arg == "--export" and i + 1 < len(sys.argv):
            export_file = sys.argv[i + 1]
            i += 2
        else:
            i += 1

    # Execute query
    results = query_similar_conversations(query, top_k, mode_filter, outcome_filter)

    # Display results
    print_results(results, verbose=verbose)

    # Export if requested
    if export_file:
        export_for_prompt(results, export_file)
