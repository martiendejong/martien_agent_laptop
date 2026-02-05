#!/usr/bin/env python3
"""
Semantic Context Search - Round 5
Uses sentence transformers for embedding-based search
"""

import sys
import json
from pathlib import Path
from sentence_transformers import SentenceTransformer
import numpy as np

# Configuration
CONTEXT_DIR = Path("C:/scripts/_machine")
EMBEDDINGS_CACHE = CONTEXT_DIR / "embeddings-cache.npz"
MODEL_NAME = "all-MiniLM-L6-v2"  # Fast, good quality

class SemanticContextSearch:
    def __init__(self):
        print("Loading sentence transformer model...", file=sys.stderr)
        self.model = SentenceTransformer(MODEL_NAME)
        self.documents = []
        self.embeddings = None

    def index_documents(self, doc_paths):
        """Generate embeddings for all context documents"""
        print(f"Indexing {len(doc_paths)} documents...", file=sys.stderr)

        self.documents = []
        texts = []

        for path in doc_paths:
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    self.documents.append({
                        'path': str(path),
                        'content': content[:500]  # Preview
                    })
                    texts.append(content[:5000])  # Embed first 5k chars
            except Exception as e:
                print(f"Error reading {path}: {e}", file=sys.stderr)

        print("Generating embeddings...", file=sys.stderr)
        self.embeddings = self.model.encode(texts, show_progress_bar=True)

        # Cache embeddings
        np.savez(EMBEDDINGS_CACHE,
                 embeddings=self.embeddings,
                 documents=self.documents)
        print(f"Cached embeddings to {EMBEDDINGS_CACHE}", file=sys.stderr)

    def search(self, query, top_k=5):
        """Search for documents similar to query"""
        if self.embeddings is None:
            print("No embeddings loaded!", file=sys.stderr)
            return []

        query_embedding = self.model.encode([query])[0]

        # Compute cosine similarities
        similarities = np.dot(self.embeddings, query_embedding) / (
            np.linalg.norm(self.embeddings, axis=1) * np.linalg.norm(query_embedding)
        )

        # Get top-k results
        top_indices = np.argsort(similarities)[::-1][:top_k]

        results = []
        for idx in top_indices:
            results.append({
                'path': self.documents[idx]['path'],
                'score': float(similarities[idx]),
                'preview': self.documents[idx]['content']
            })

        return results

def main():
    if len(sys.argv) < 2:
        print("Usage: Search-SemanticContext.py <query>")
        print("   or: Search-SemanticContext.py --index")
        sys.exit(1)

    searcher = SemanticContextSearch()

    if sys.argv[1] == '--index':
        # Index all markdown and yaml files
        doc_paths = list(CONTEXT_DIR.glob("**/*.md"))
        doc_paths.extend(CONTEXT_DIR.glob("**/*.yaml"))
        searcher.index_documents(doc_paths)
    else:
        # Load cached embeddings
        if EMBEDDINGS_CACHE.exists():
            cache = np.load(EMBEDDINGS_CACHE, allow_pickle=True)
            searcher.embeddings = cache['embeddings']
            searcher.documents = cache['documents'].tolist()

        query = ' '.join(sys.argv[1:])
        results = searcher.search(query)

        print(json.dumps(results, indent=2))

if __name__ == '__main__':
    main()
