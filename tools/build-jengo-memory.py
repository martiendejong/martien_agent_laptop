#!/usr/bin/env python3
"""
Build Jengo Memory - RAG system for conversation retrieval

Embeds logged conversations and stores them in a local vector database.
Enables retrieval of similar past conversations for few-shot learning.

Usage:
    python build-jengo-memory.py              # Process all conversations
    python build-jengo-memory.py --rebuild    # Rebuild entire index
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any

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
TRAINING_DATA_DIR = Path("E:/jengo/training-data/conversations")
VECTOR_DB_DIR = Path("E:/jengo/training-data/vector-db")
OPENAI_API_KEY_PATH = Path("C:/scripts/_machine/openai-api-key.txt")

# Initialize OpenAI client
def get_openai_client():
    """Load OpenAI API key and return client"""
    if not OPENAI_API_KEY_PATH.exists():
        print(f"[ERROR] OpenAI API key not found at: {OPENAI_API_KEY_PATH}")
        print("Create the file with your API key (first line only)")
        sys.exit(1)

    api_key = OPENAI_API_KEY_PATH.read_text().strip().split('\n')[0]
    return OpenAI(api_key=api_key)

# Initialize ChromaDB
def get_chroma_client():
    """Initialize and return ChromaDB client"""
    VECTOR_DB_DIR.mkdir(parents=True, exist_ok=True)

    client = chromadb.PersistentClient(
        path=str(VECTOR_DB_DIR),
        settings=Settings(anonymized_telemetry=False)
    )
    return client

def load_conversations() -> List[Dict[str, Any]]:
    """Load all conversation JSON files"""
    if not TRAINING_DATA_DIR.exists():
        print(f"[ERROR] Training data directory not found: {TRAINING_DATA_DIR}")
        return []

    conversations = []
    for json_file in TRAINING_DATA_DIR.glob("*.json"):
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                conv = json.load(f)
                conv['_source_file'] = str(json_file)
                conversations.append(conv)
        except Exception as e:
            print(f"[WARNING] Failed to load {json_file}: {e}")

    return conversations

def create_embedding_text(conv: Dict[str, Any]) -> str:
    """Create text representation of conversation for embedding"""
    parts = []

    # Mode and task
    parts.append(f"Mode: {conv.get('mode', 'unknown')}")
    parts.append(f"Task: {conv.get('task_description', 'no description')}")

    # Project
    if conv.get('project'):
        parts.append(f"Project: {conv['project']}")

    # Tools used
    if conv.get('tools_used'):
        parts.append(f"Tools: {', '.join(conv['tools_used'])}")

    # Decisions
    if conv.get('decisions'):
        decisions_text = []
        for d in conv['decisions']:
            decisions_text.append(f"{d.get('decision', '')} - {d.get('reasoning', '')}")
        parts.append(f"Decisions: {'; '.join(decisions_text)}")

    # Outcome
    parts.append(f"Outcome: {conv.get('outcome', 'unknown')}")

    # Lessons
    if conv.get('lessons_learned'):
        parts.append(f"Lessons: {'; '.join(conv['lessons_learned'])}")

    # Conversation messages (if available)
    messages = []
    for msg in conv.get('conversation', {}).get('user_messages', [])[:3]:  # First 3 user messages
        messages.append(f"User: {msg}")
    for msg in conv.get('conversation', {}).get('agent_messages', [])[:3]:  # First 3 agent messages
        messages.append(f"Agent: {msg}")

    if messages:
        parts.append("Conversation sample: " + " | ".join(messages[:6]))

    return "\n".join(parts)

def generate_embeddings(texts: List[str], client: OpenAI) -> List[List[float]]:
    """Generate embeddings using OpenAI API"""
    response = client.embeddings.create(
        input=texts,
        model="text-embedding-3-small"  # Cost-effective, 1536 dimensions
    )
    return [item.embedding for item in response.data]

def build_index(rebuild: bool = False):
    """Build or update the vector index"""
    print("[INFO] Building Jengo Memory index...")

    # Load conversations
    conversations = load_conversations()
    if not conversations:
        print("[WARNING] No conversations found. Use jengo-conversation-logger.ps1 to create some.")
        return

    print(f"[INFO] Loaded {len(conversations)} conversation(s)")

    # Initialize clients
    openai_client = get_openai_client()
    chroma_client = get_chroma_client()

    # Get or create collection
    collection_name = "jengo_conversations"

    if rebuild:
        try:
            chroma_client.delete_collection(collection_name)
            print("[INFO] Deleted existing collection (rebuild mode)")
        except:
            pass

    collection = chroma_client.get_or_create_collection(
        name=collection_name,
        metadata={"description": "Jengo conversation logs for RAG retrieval"}
    )

    # Check which conversations are already indexed
    existing_ids = set(collection.get()['ids'])

    # Filter to only new conversations
    new_conversations = [c for c in conversations if c['session_id'] not in existing_ids or rebuild]

    if not new_conversations:
        print("[INFO] All conversations already indexed. Use --rebuild to rebuild entire index.")
        return

    print(f"[INFO] Embedding {len(new_conversations)} new conversation(s)...")

    # Create embedding texts
    embedding_texts = [create_embedding_text(c) for c in new_conversations]

    # Generate embeddings (batch)
    embeddings = generate_embeddings(embedding_texts, openai_client)

    # Prepare metadata
    metadatas = []
    for conv in new_conversations:
        metadata = {
            "mode": conv.get('mode', 'unknown'),
            "project": conv.get('project', ''),
            "outcome": conv.get('outcome', 'unknown'),
            "timestamp": conv.get('timestamp_start', ''),
            "tools_used": ','.join(conv.get('tools_used', [])),
            "has_pr": 'yes' if conv.get('artifacts', {}).get('pr_url') else 'no'
        }
        metadatas.append(metadata)

    # Add to collection
    collection.add(
        ids=[c['session_id'] for c in new_conversations],
        embeddings=embeddings,
        documents=embedding_texts,
        metadatas=metadatas
    )

    # Update conversation JSONs to mark as embedded
    for conv in new_conversations:
        conv['embeddings_generated'] = True
        source_file = conv.pop('_source_file')
        with open(source_file, 'w', encoding='utf-8') as f:
            json.dump(conv, f, indent=2, ensure_ascii=False)

    print(f"[SUCCESS] Indexed {len(new_conversations)} conversation(s)")
    print(f"[INFO] Total conversations in index: {len(collection.get()['ids'])}")

if __name__ == "__main__":
    rebuild = "--rebuild" in sys.argv
    build_index(rebuild=rebuild)
