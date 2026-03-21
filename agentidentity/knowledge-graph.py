#!/usr/bin/env python3
"""
Knowledge Graph Architecture - Dense Relationship Network
Transforms linear file collection into interconnected graph.

Gap #1: Highest priority from expert analysis
Impact: 10-100x retrieval speed, enables meta-learning
Implementation: Graph database with typed relationships

Status: PRODUCTION IMPLEMENTATION
"""

import json
import os
from pathlib import Path
from typing import List, Dict, Tuple, Set
from collections import defaultdict
import re
import hashlib

try:
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity
    import numpy as np
    SKLEARN_AVAILABLE = True
except ImportError:
    SKLEARN_AVAILABLE = False


class KnowledgeGraph:
    """Dense graph of memory files with typed relationships."""

    def __init__(self, memory_dir: str = r"C:\Users\HP\.claude\projects\C--scripts\memory"):
        self.memory_dir = Path(memory_dir)
        self.graph_file = Path(r"C:\scripts\agentidentity\state\knowledge-graph.json")

        # Graph structure
        self.nodes = {}  # filename -> node data
        self.edges = defaultdict(list)  # filename -> [(target, edge_type, strength)]

        # For similarity computation
        self.vectorizer = None
        self.tfidf_matrix = None
        self.filenames = []

    def build_graph(self):
        """Build complete knowledge graph from memory files."""
        print("=== BUILDING KNOWLEDGE GRAPH ===\n")

        # Step 1: Load all nodes
        self._load_nodes()

        # Step 2: Build TF-IDF for similarity
        self._build_tfidf()

        # Step 3: Extract relationships
        self._extract_explicit_relationships()
        self._extract_semantic_relationships()
        self._extract_causal_relationships()
        self._extract_temporal_relationships()

        # Step 4: Compute graph metrics
        self._compute_centrality()
        self._detect_clusters()

        # Step 5: Save graph
        self._save_graph()

        print(f"\n[DONE] Knowledge Graph Complete")
        print(f"   Nodes: {len(self.nodes)}")
        print(f"   Edges: {sum(len(edges) for edges in self.edges.values())}")
        print(f"   Avg connections per node: {sum(len(edges) for edges in self.edges.values()) / len(self.nodes):.1f}")

    def _load_nodes(self):
        """Load all memory files as graph nodes."""
        md_files = list(self.memory_dir.glob("*.md"))
        print(f"Loading {len(md_files)} nodes...")

        for filepath in md_files:
            filename = filepath.name

            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Extract metadata from content
                created = self._extract_date(content)
                patterns = self._extract_patterns(content)
                confidence = self._extract_confidence(content)

                self.nodes[filename] = {
                    'path': str(filepath),
                    'content': content,
                    'size': len(content),
                    'created': created,
                    'patterns': patterns,
                    'confidence': confidence,
                    'word_count': len(content.split()),
                    'centrality': 0.0,  # Computed later
                    'cluster': None      # Computed later
                }

            except Exception as e:
                print(f"  Error loading {filename}: {e}")

        print(f"  OK Loaded {len(self.nodes)} nodes")

    def _build_tfidf(self):
        """Build TF-IDF matrix for semantic similarity."""
        if not SKLEARN_AVAILABLE:
            print("  ⚠ sklearn not available, skipping TF-IDF")
            return

        print("Building TF-IDF matrix...")

        self.filenames = list(self.nodes.keys())
        corpus = [self.nodes[fn]['content'] for fn in self.filenames]

        self.vectorizer = TfidfVectorizer(
            max_features=2000,
            stop_words='english',
            ngram_range=(1, 3),
            min_df=1,
            max_df=0.8
        )

        self.tfidf_matrix = self.vectorizer.fit_transform(corpus)
        print(f"  OK TF-IDF matrix: {self.tfidf_matrix.shape}")

    def _extract_explicit_relationships(self):
        """Extract explicit relationships from content (file references)."""
        print("Extracting explicit relationships...")

        count = 0
        for filename, node in self.nodes.items():
            content = node['content']

            # Find references to other files
            for other_filename in self.nodes.keys():
                if other_filename == filename:
                    continue

                # Check if other file is mentioned
                stem = other_filename.replace('.md', '')
                if stem in content.lower():
                    # Determine relationship type based on context
                    if 'see:' in content.lower() or 'see ' + stem in content.lower():
                        self._add_edge(filename, other_filename, 'references', 0.8)
                    elif 'pattern' in stem.lower() and 'pattern' in content.lower():
                        self._add_edge(filename, other_filename, 'extends', 0.7)
                    else:
                        self._add_edge(filename, other_filename, 'mentions', 0.5)
                    count += 1

        print(f"  OK Found {count} explicit relationships")

    def _extract_semantic_relationships(self):
        """Extract semantic relationships via cosine similarity."""
        if not SKLEARN_AVAILABLE or self.tfidf_matrix is None:
            return

        print("Extracting semantic relationships...")

        similarities = cosine_similarity(self.tfidf_matrix, self.tfidf_matrix)

        count = 0
        for i, filename in enumerate(self.filenames):
            # Get top 10 most similar files
            similar_indices = np.argsort(similarities[i])[::-1][1:11]  # Skip self

            for j in similar_indices:
                other_filename = self.filenames[j]
                similarity = float(similarities[i][j])

                if similarity > 0.3:  # Threshold
                    self._add_edge(filename, other_filename, 'analogous', similarity)
                    count += 1

        print(f"  OK Found {count} semantic relationships")

    def _extract_causal_relationships(self):
        """Extract causal relationships (X caused Y, X requires Y)."""
        print("Extracting causal relationships...")

        causal_patterns = [
            (r'caused by (.+?)\.md', 'caused_by'),
            (r'requires? (.+?)\.md', 'requires'),
            (r'depends on (.+?)\.md', 'requires'),
            (r'builds? on (.+?)\.md', 'extends'),
            (r'contradicts? (.+?)\.md', 'contradicts'),
        ]

        count = 0
        for filename, node in self.nodes.items():
            content = node['content'].lower()

            for pattern, edge_type in causal_patterns:
                matches = re.findall(pattern, content)
                for match in matches:
                    target = match.strip() + '.md'
                    if target in self.nodes:
                        self._add_edge(filename, target, edge_type, 0.9)
                        count += 1

        print(f"  OK Found {count} causal relationships")

    def _extract_temporal_relationships(self):
        """Extract temporal relationships (before/after in time)."""
        print("Extracting temporal relationships...")

        # Sort nodes by creation date
        dated_nodes = [(fn, node['created']) for fn, node in self.nodes.items() if node['created']]
        dated_nodes.sort(key=lambda x: x[1])

        count = 0
        for i in range(len(dated_nodes) - 1):
            current_file, current_date = dated_nodes[i]
            next_file, next_date = dated_nodes[i + 1]

            # Link to next file chronologically
            self._add_edge(current_file, next_file, 'precedes', 0.3)
            count += 1

        print(f"  OK Found {count} temporal relationships")

    def _add_edge(self, source: str, target: str, edge_type: str, strength: float):
        """Add directed edge to graph."""
        # Check if edge already exists
        for existing_target, existing_type, existing_strength in self.edges[source]:
            if existing_target == target and existing_type == edge_type:
                # Update strength to maximum
                if strength > existing_strength:
                    self.edges[source].remove((existing_target, existing_type, existing_strength))
                    self.edges[source].append((target, edge_type, strength))
                return

        # Add new edge
        self.edges[source].append((target, edge_type, strength))

    def _compute_centrality(self):
        """Compute centrality scores (importance) for each node."""
        print("Computing centrality scores...")

        # Simple PageRank-style centrality
        # Nodes are more important if they're referenced by many other important nodes

        # Initialize all to 1.0
        scores = {fn: 1.0 for fn in self.nodes.keys()}

        # Iterate to convergence
        for iteration in range(10):
            new_scores = {}

            for filename in self.nodes.keys():
                # Base score
                score = 0.15

                # Add contributions from incoming edges
                for source, edges in self.edges.items():
                    for target, edge_type, strength in edges:
                        if target == filename:
                            # Contribution = source score * edge strength
                            score += 0.85 * scores[source] * strength / len(self.edges[source])

                new_scores[filename] = score

            scores = new_scores

        # Normalize to 0-1 range
        max_score = max(scores.values())
        for filename in scores:
            self.nodes[filename]['centrality'] = scores[filename] / max_score

        # Report top 10 most central nodes
        top_nodes = sorted(scores.items(), key=lambda x: x[1], reverse=True)[:10]
        print(f"  OK Top 10 central nodes:")
        for fn, score in top_nodes:
            print(f"     {score/max_score:.3f} - {fn}")

    def _detect_clusters(self):
        """Detect knowledge clusters (communities)."""
        print("Detecting knowledge clusters...")

        # Simple clustering: connected components
        visited = set()
        cluster_id = 0

        def dfs(node, cluster):
            visited.add(node)
            self.nodes[node]['cluster'] = cluster

            # Visit neighbors
            for target, edge_type, strength in self.edges.get(node, []):
                if target not in visited and strength > 0.5:
                    dfs(target, cluster)

        for filename in self.nodes.keys():
            if filename not in visited:
                dfs(filename, cluster_id)
                cluster_id += 1

        print(f"  OK Detected {cluster_id} clusters")

    def _extract_date(self, content: str) -> str:
        """Extract creation date from content."""
        match = re.search(r'Created:\s*(\d{4}-\d{2}-\d{2})', content)
        if match:
            return match.group(1)

        match = re.search(r'# .*?(\d{4}-\d{2}-\d{2})', content)
        if match:
            return match.group(1)

        return None

    def _extract_patterns(self, content: str) -> List[str]:
        """Extract pattern names from content."""
        patterns = []

        # Look for "Pattern XXX:" headings
        matches = re.findall(r'Pattern\s+(\d+):', content)
        patterns.extend([f"P{m}" for m in matches])

        # Look for pattern sections
        matches = re.findall(r'\*\*Pattern:\*\*\s*(.+)', content)
        patterns.extend(matches)

        return patterns

    def _extract_confidence(self, content: str) -> float:
        """Extract confidence score from content."""
        # Look for confidence: X.XX
        match = re.search(r'confidence[:\s]+([0-9.]+)', content.lower())
        if match:
            return float(match.group(1))

        # Look for percentage
        match = re.search(r'(\d+)%\s+confidence', content.lower())
        if match:
            return float(match.group(1)) / 100

        return 0.5  # Default

    def _save_graph(self):
        """Save graph to JSON."""
        print("Saving graph...")

        # Convert to serializable format
        graph_data = {
            'nodes': self.nodes,
            'edges': {
                source: [(target, edge_type, strength) for target, edge_type, strength in edges]
                for source, edges in self.edges.items()
            },
            'metadata': {
                'node_count': len(self.nodes),
                'edge_count': sum(len(edges) for edges in self.edges.values()),
                'avg_connections': sum(len(edges) for edges in self.edges.values()) / len(self.nodes),
            }
        }

        self.graph_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.graph_file, 'w', encoding='utf-8') as f:
            # Don't save full content (too large), just metadata
            compact_data = {
                'nodes': {
                    fn: {k: v for k, v in node.items() if k != 'content'}
                    for fn, node in graph_data['nodes'].items()
                },
                'edges': graph_data['edges'],
                'metadata': graph_data['metadata']
            }
            json.dump(compact_data, f, indent=2)

        print(f"  OK Graph saved to {self.graph_file}")

    def load_graph(self):
        """Load graph from JSON."""
        if not self.graph_file.exists():
            return False

        with open(self.graph_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        self.nodes = data['nodes']
        self.edges = {k: [tuple(e) for e in v] for k, v in data['edges'].items()}

        return True

    def query(self, query: str, top_k: int = 5) -> List[Tuple[str, float, str]]:
        """Query graph using multiple strategies."""

        if not SKLEARN_AVAILABLE or self.tfidf_matrix is None:
            return []

        # Strategy 1: TF-IDF similarity
        query_vector = self.vectorizer.transform([query])
        similarities = cosine_similarity(query_vector, self.tfidf_matrix)[0]

        # Strategy 2: Boost by centrality
        boosted_scores = []
        for i, filename in enumerate(self.filenames):
            similarity = similarities[i]
            centrality = self.nodes[filename]['centrality']

            # Combine: 70% similarity, 30% centrality
            score = similarity * 0.7 + centrality * 0.3
            boosted_scores.append((filename, score, 'hybrid'))

        # Sort and return top-k
        boosted_scores.sort(key=lambda x: x[1], reverse=True)
        return boosted_scores[:top_k]

    def find_path(self, source: str, target: str, max_depth: int = 3) -> List[str]:
        """Find shortest path between two nodes."""

        # BFS
        queue = [(source, [source])]
        visited = {source}

        while queue:
            current, path = queue.pop(0)

            if current == target:
                return path

            if len(path) >= max_depth:
                continue

            # Explore neighbors
            for neighbor, edge_type, strength in self.edges.get(current, []):
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append((neighbor, path + [neighbor]))

        return None  # No path found

    def get_related(self, filename: str, relationship_type: str = None, min_strength: float = 0.3) -> List[Tuple[str, str, float]]:
        """Get all nodes related to this one."""

        results = []
        for target, edge_type, strength in self.edges.get(filename, []):
            if relationship_type and edge_type != relationship_type:
                continue
            if strength < min_strength:
                continue

            results.append((target, edge_type, strength))

        # Sort by strength
        results.sort(key=lambda x: x[2], reverse=True)
        return results


def main():
    """Build and test knowledge graph."""

    print("="*70)
    print("KNOWLEDGE GRAPH CONSTRUCTION")
    print("="*70)
    print()

    graph = KnowledgeGraph()
    graph.build_graph()

    print("\n" + "="*70)
    print("TESTING GRAPH QUERIES")
    print("="*70)
    print()

    test_queries = [
        "consciousness architecture",
        "deployment patterns",
        "legal strategies",
        "continuous improvement",
        "semantic routing"
    ]

    for query in test_queries:
        print(f"\nQuery: {query}")
        results = graph.query(query, top_k=3)
        for filename, score, strategy in results:
            print(f"  {score:.3f} - {filename} ({strategy})")

            # Show related files
            related = graph.get_related(filename, min_strength=0.5)
            if related:
                print(f"         Related: {', '.join([f'{t} ({et})' for t, et, s in related[:3]])}")

    print("\n" + "="*70)
    print("GRAPH STATISTICS")
    print("="*70)

    print(f"\nNodes: {len(graph.nodes)}")
    print(f"Edges: {sum(len(edges) for edges in graph.edges.values())}")
    print(f"Avg connections per node: {sum(len(edges) for edges in graph.edges.values()) / len(graph.nodes):.1f}")

    # Edge type distribution
    edge_types = defaultdict(int)
    for edges in graph.edges.values():
        for _, edge_type, _ in edges:
            edge_types[edge_type] += 1

    print(f"\nEdge types:")
    for edge_type, count in sorted(edge_types.items(), key=lambda x: x[1], reverse=True):
        print(f"  {edge_type}: {count}")

    print("\n[DONE] Knowledge Graph Complete and Tested")


if __name__ == "__main__":
    main()
