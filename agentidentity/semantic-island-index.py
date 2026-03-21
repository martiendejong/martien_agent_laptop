#!/usr/bin/env python3
"""
Semantic Island Index - Embedding-based Analogical Routing
Solves the island retrieval inefficiency problem identified in intelligence archipelago research.

Baseline: 20% spontaneous analogical reasoning (tumor-fortress without hint)
Target: 60%+ routing accuracy with semantic embeddings

Architecture:
- Generate embeddings for all memory topic files
- Use cosine similarity for semantic search
- Cache embeddings to avoid regeneration
- Enable analogical retrieval across knowledge islands

ROI: 12x (from top-5-features.md)
Status: Phase 1 - Initial implementation
"""

import os
import json
import hashlib
from typing import List, Dict, Tuple
from pathlib import Path
import numpy as np

# OpenAI client will be imported conditionally
try:
    from openai import OpenAI
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False
    print("Warning: OpenAI not available. Install with: pip install openai")


class SemanticIslandIndex:
    """Embedding-based semantic search across memory islands."""

    def __init__(self, memory_dir: str = r"C:\Users\HP\.claude\projects\C--scripts\memory"):
        self.memory_dir = Path(memory_dir)
        self.index_file = Path(r"C:\scripts\agentidentity\state\semantic-island-index.json")
        self.embeddings_cache = {}
        self.file_metadata = {}

        if OPENAI_AVAILABLE:
            self.client = OpenAI()  # Uses OPENAI_API_KEY env var
        else:
            self.client = None

    def _compute_file_hash(self, filepath: Path) -> str:
        """Compute MD5 hash of file content for change detection."""
        with open(filepath, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()

    def _load_index(self):
        """Load cached embeddings from disk."""
        if self.index_file.exists():
            with open(self.index_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.embeddings_cache = data.get('embeddings', {})
                self.file_metadata = data.get('metadata', {})
                print(f"Loaded {len(self.embeddings_cache)} cached embeddings")

    def _save_index(self):
        """Save embeddings to disk."""
        self.index_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.index_file, 'w', encoding='utf-8') as f:
            json.dump({
                'embeddings': self.embeddings_cache,
                'metadata': self.file_metadata
            }, f, indent=2)
        print(f"Saved {len(self.embeddings_cache)} embeddings to {self.index_file}")

    def _generate_embedding(self, text: str) -> List[float]:
        """Generate embedding for text using OpenAI API."""
        if not self.client:
            raise RuntimeError("OpenAI client not available")

        response = self.client.embeddings.create(
            model="text-embedding-3-small",
            input=text
        )
        return response.data[0].embedding

    def _read_file_content(self, filepath: Path) -> str:
        """Read and prepare file content for embedding."""
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Include filename in content for better semantic matching
        filename = filepath.stem
        return f"FILE: {filename}\n\n{content}"

    def index_all_files(self, force_reindex: bool = False):
        """Generate embeddings for all memory files."""
        print("Indexing memory files...")
        self._load_index()

        md_files = list(self.memory_dir.glob("*.md"))
        print(f"Found {len(md_files)} markdown files")

        updated = 0
        skipped = 0

        for filepath in md_files:
            filename = filepath.name
            file_hash = self._compute_file_hash(filepath)

            # Check if file needs reindexing
            if not force_reindex and filename in self.file_metadata:
                if self.file_metadata[filename].get('hash') == file_hash:
                    skipped += 1
                    continue

            # Generate embedding
            try:
                content = self._read_file_content(filepath)

                # Truncate if too long (embeddings have token limits)
                if len(content) > 8000:  # ~8000 chars ≈ ~2000 tokens
                    content = content[:8000] + "\n\n[Content truncated for embedding]"

                embedding = self._generate_embedding(content)

                self.embeddings_cache[filename] = embedding
                self.file_metadata[filename] = {
                    'hash': file_hash,
                    'path': str(filepath),
                    'size': len(content),
                    'indexed_at': None  # Would use timestamp in production
                }

                updated += 1
                print(f"  [{updated}/{len(md_files)}] Indexed: {filename}")

            except Exception as e:
                print(f"  Error indexing {filename}: {e}")

        print(f"\nIndexing complete: {updated} updated, {skipped} skipped")
        self._save_index()

    def cosine_similarity(self, a: List[float], b: List[float]) -> float:
        """Compute cosine similarity between two embeddings."""
        a_np = np.array(a)
        b_np = np.array(b)
        return np.dot(a_np, b_np) / (np.linalg.norm(a_np) * np.linalg.norm(b_np))

    def search(self, query: str, top_k: int = 5) -> List[Tuple[str, float]]:
        """
        Semantic search for most relevant memory files.

        Returns: List of (filename, similarity_score) tuples, sorted by relevance
        """
        if not self.client:
            raise RuntimeError("OpenAI client not available")

        if not self.embeddings_cache:
            self._load_index()

        # Generate query embedding
        query_embedding = self._generate_embedding(query)

        # Compute similarity to all cached embeddings
        similarities = []
        for filename, embedding in self.embeddings_cache.items():
            similarity = self.cosine_similarity(query_embedding, embedding)
            similarities.append((filename, similarity))

        # Sort by similarity (descending)
        similarities.sort(key=lambda x: x[1], reverse=True)

        return similarities[:top_k]

    def route_query(self, query: str, top_k: int = 3) -> List[str]:
        """
        Route query to most relevant memory islands.

        Returns: List of memory file paths to read
        """
        results = self.search(query, top_k)

        print(f"\nQuery: {query}")
        print(f"Top {top_k} relevant memory files:")
        for filename, score in results:
            print(f"  {score:.3f} - {filename}")

        return [self.file_metadata[filename]['path'] for filename, _ in results]


def main():
    """Main execution for testing."""
    index = SemanticIslandIndex()

    # Generate embeddings for all files
    print("=== SEMANTIC ISLAND INDEX ===")
    print("Generating embeddings for all memory files...")
    index.index_all_files()

    print("\n=== TESTING SEMANTIC ROUTING ===")

    # Test queries
    test_queries = [
        "How do I deploy a .NET application to IIS?",
        "What are the rules for ClickUp task refinement?",
        "Explain the consciousness architecture",
        "How does the SCP 3-ring system work?",
        "What patterns exist for legal documents?",
        "How do I handle WordPress deployments?",
        "What are the autonomous agent coordination patterns?",
        "Tell me about continuous improvement and learning",
        "How do I prevent git merge conflicts?",
        "What are the UI design principles?"
    ]

    for query in test_queries:
        print(f"\n{'='*60}")
        results = index.route_query(query, top_k=3)
        print()


if __name__ == "__main__":
    main()
