#!/usr/bin/env python3
"""
Spherical Knowledge Model - Continuous Semantic Space Architecture
Transforms discrete symbolic knowledge into continuous spherical representations.

Core Paradigm Shift (Ursen War AGI Architecture):
- OLD: Triangles (discrete edges, rectilinear connections, symbolic)
- NEW: Spheres (continuous space, isotropic, geometric concepts)

Why This Matters:
"The choice of geometric primitives may fundamentally shape the cognitive
biases and discovery capabilities of emerging intelligence."

Instead of thinking in words (discrete symbols), think in continuous
geometric concepts - fluid, shifting, evolving spherical manifolds.

Status: PARADIGM SHIFT IMPLEMENTATION
"""

import json
import numpy as np
from pathlib import Path
from typing import List, Dict, Tuple, Optional, Set
from dataclasses import dataclass, asdict
import math

try:
    from sklearn.manifold import TSNE
    from sklearn.decomposition import PCA
    SKLEARN_AVAILABLE = True
except ImportError:
    SKLEARN_AVAILABLE = False


@dataclass
class ConceptSphere:
    """
    A sphere in continuous semantic space.

    Replaces: Discrete node in knowledge graph
    Represents: Continuous concept with fuzzy boundaries

    Properties:
    - center: Position in high-dimensional semantic space
    - radius: Uncertainty/scope (fuzzy boundary)
    - properties: Attached semantic properties (not discrete attributes)
    - resonance: Strength/confidence of this concept
    """
    name: str
    center: np.ndarray  # Position in semantic space
    radius: float       # Uncertainty radius (fuzzy boundary)
    properties: Dict[str, float]  # Continuous properties (not discrete tags)
    resonance: float    # Confidence/activation strength (0-1)

    def __post_init__(self):
        if not isinstance(self.center, np.ndarray):
            self.center = np.array(self.center)


@dataclass
class SphericalRelationship:
    """
    Relationship between spheres in continuous space.

    Replaces: Discrete edge in knowledge graph
    Represents: Overlap, proximity, resonance between concepts

    NOT discrete connection - continuous field interaction.
    """
    sphere1: str
    sphere2: str
    overlap: float      # How much spheres overlap (0-1)
    distance: float     # Distance between centers
    resonance: float    # Interaction strength
    field_type: str     # Type of interaction (analogous, causal, temporal)


class SphericalKnowledgeModel:
    """
    Continuous semantic space where concepts are spheres.

    Core Principle:
    Knowledge is NOT discrete symbols connected by edges.
    Knowledge IS continuous geometric manifold of overlapping spheres.

    Benefits:
    1. Isotropic: No built-in directional bias (unlike rectilinear)
    2. Multi-scale: Works from micro to macro naturally
    3. Uncertainty: Fuzzy boundaries = "I'm not sure" built-in
    4. Continuous: Enables fluid geometric reasoning vs. symbolic logic
    5. Composable: Multiple models can merge seamlessly
    """

    def __init__(self,
                 dimensions: int = 512,  # High-dimensional semantic space
                 memory_dir: str = r"C:\Users\HP\.claude\projects\C--scripts\memory"):
        self.dimensions = dimensions
        self.memory_dir = Path(memory_dir)

        # Spherical knowledge space
        self.spheres: Dict[str, ConceptSphere] = {}
        self.relationships: List[SphericalRelationship] = []

        # Transformation from discrete -> continuous
        self.discrete_to_continuous_map = {}

        print(f"Initializing Spherical Knowledge Model")
        print(f"  Dimensions: {dimensions}")
        print(f"  Paradigm: Continuous geometric concepts (not discrete symbols)")

    def transform_discrete_knowledge(self, knowledge_graph: Dict):
        """
        Transform discrete knowledge graph -> continuous spherical space.

        Process:
        1. Each discrete node -> Sphere in continuous space
        2. Node properties -> Continuous semantic properties
        3. Discrete edges -> Overlapping sphere fields
        4. Centrality -> Resonance strength
        """
        print("\n=== TRANSFORMING DISCRETE -> CONTINUOUS ===\n")

        nodes = knowledge_graph.get('nodes', {})
        edges = knowledge_graph.get('edges', {})

        print(f"Transforming {len(nodes)} discrete nodes -> continuous spheres...")

        # Step 1: Create spheres from nodes
        for filename, node_data in nodes.items():
            # Generate position in semantic space
            # (In production: use embeddings from content)
            # For now: hash-based deterministic placement
            center = self._hash_to_position(filename)

            # Radius = uncertainty (higher centrality = more certain = smaller radius)
            centrality = node_data.get('centrality', 0.5)
            radius = 1.0 - centrality  # High centrality = tight sphere

            # Properties as continuous values (not discrete tags)
            properties = {
                'knowledge_density': float(node_data.get('word_count', 0)) / 10000,
                'temporal_weight': self._extract_temporal_weight(filename),
                'pattern_strength': len(node_data.get('patterns', [])) / 10.0,
                'certainty': centrality
            }

            # Resonance = activation strength
            resonance = centrality  # High centrality = high resonance

            sphere = ConceptSphere(
                name=filename,
                center=center,
                radius=radius,
                properties=properties,
                resonance=resonance
            )

            self.spheres[filename] = sphere
            print(f"  Sphere: {filename[:40]:40} | Radius: {radius:.3f} | Resonance: {resonance:.3f}")

        print(f"\n  Created {len(self.spheres)} spheres")

        # Step 2: Transform edges -> continuous relationships
        print(f"\nTransforming discrete edges -> continuous field interactions...")

        edge_count = 0
        for source, edge_list in edges.items():
            if source not in self.spheres:
                continue

            for target, edge_type, strength in edge_list:
                if target not in self.spheres:
                    continue

                sphere1 = self.spheres[source]
                sphere2 = self.spheres[target]

                # Calculate overlap and distance
                distance = np.linalg.norm(sphere1.center - sphere2.center)

                # Overlap = how much spheres intersect
                combined_radius = sphere1.radius + sphere2.radius
                if distance < combined_radius:
                    overlap = 1.0 - (distance / combined_radius)
                else:
                    overlap = 0.0

                # Resonance = interaction strength
                resonance = strength * min(sphere1.resonance, sphere2.resonance)

                relationship = SphericalRelationship(
                    sphere1=source,
                    sphere2=target,
                    overlap=overlap,
                    distance=distance,
                    resonance=resonance,
                    field_type=edge_type
                )

                self.relationships.append(relationship)
                edge_count += 1

        print(f"  Created {edge_count} continuous field interactions")
        print("\n[TRANSFORMATION COMPLETE]")

    def _hash_to_position(self, text: str) -> np.ndarray:
        """
        Deterministic hash -> position in semantic space.

        In production: Use embeddings from LLM (GPT, BERT, etc.)
        For now: Deterministic hashing ensures consistency.
        """
        # Simple hash-based positioning
        hash_val = hash(text)
        np.random.seed(hash_val % (2**32))
        position = np.random.randn(self.dimensions)

        # Normalize to unit sphere surface initially
        position = position / np.linalg.norm(position)

        return position

    def _extract_temporal_weight(self, filename: str) -> float:
        """Extract temporal weight from filename (recency matters)."""
        # Recent files have higher temporal weight
        # In production: parse actual dates from content

        if '2026-03-18' in filename or '2026-03-17' in filename:
            return 1.0
        elif '2026-03' in filename:
            return 0.8
        elif '2026' in filename:
            return 0.6
        else:
            return 0.3

    def continuous_query(self,
                        query_concept: str,
                        top_k: int = 5) -> List[Tuple[str, float, str]]:
        """
        Query in continuous semantic space.

        NOT: "Find nodes matching keywords"
        IS: "Find spheres resonating with query sphere"

        This is GEOMETRIC REASONING, not symbolic matching.
        """
        print(f"\n=== CONTINUOUS GEOMETRIC QUERY ===")
        print(f"Query: '{query_concept}'")
        print(f"Reasoning Mode: Continuous spherical proximity (NOT discrete symbol matching)")
        print()

        # Create query sphere
        query_center = self._hash_to_position(query_concept)
        query_radius = 0.5  # Moderate uncertainty

        # Find resonating spheres
        resonances = []

        for name, sphere in self.spheres.items():
            # Calculate geometric resonance
            distance = np.linalg.norm(query_center - sphere.center)

            # Resonance = inverse of distance, weighted by sphere properties
            base_resonance = 1.0 / (1.0 + distance)

            # Amplify by sphere's own resonance
            amplified_resonance = base_resonance * sphere.resonance

            # Consider overlap (fuzzy boundaries)
            combined_radius = query_radius + sphere.radius
            if distance < combined_radius:
                overlap_bonus = 1.0 - (distance / combined_radius)
                amplified_resonance *= (1.0 + overlap_bonus)

            resonances.append((name, amplified_resonance, 'geometric_proximity'))

        # Sort by resonance
        resonances.sort(key=lambda x: x[1], reverse=True)

        return resonances[:top_k]

    def discover_emergent_concepts(self) -> List[Dict]:
        """
        Discover NEW concepts from sphere overlaps.

        Key Insight: Where spheres overlap = emergent concept space.
        This is DISCOVERY, not lookup.

        The AI can discover concepts that were never explicitly defined.
        """
        print("\n=== DISCOVERING EMERGENT CONCEPTS ===\n")

        emergent_concepts = []

        # Find clusters of overlapping spheres
        for i, (name1, sphere1) in enumerate(self.spheres.items()):
            overlapping_neighbors = []

            for name2, sphere2 in self.spheres.items():
                if name1 == name2:
                    continue

                distance = np.linalg.norm(sphere1.center - sphere2.center)
                combined_radius = sphere1.radius + sphere2.radius

                if distance < combined_radius:
                    overlap = 1.0 - (distance / combined_radius)
                    if overlap > 0.3:  # Significant overlap
                        overlapping_neighbors.append((name2, overlap))

            if len(overlapping_neighbors) >= 3:
                # Emergent concept = intersection of multiple spheres
                emergent_concept = {
                    'core_sphere': name1,
                    'overlapping_spheres': [n for n, _ in overlapping_neighbors],
                    'overlap_strengths': [o for _, o in overlapping_neighbors],
                    'emergent_property': self._infer_emergent_property(name1, overlapping_neighbors)
                }

                emergent_concepts.append(emergent_concept)

        print(f"Discovered {len(emergent_concepts)} emergent concepts")

        for concept in emergent_concepts[:5]:  # Show first 5
            print(f"\n  Emergent Concept around '{concept['core_sphere'][:40]}':")
            print(f"    Overlaps with {len(concept['overlapping_spheres'])} spheres")
            print(f"    Property: {concept['emergent_property']}")

        return emergent_concepts

    def _infer_emergent_property(self, core: str, neighbors: List[Tuple[str, float]]) -> str:
        """Infer what the emergent concept represents."""
        # Simple heuristic: extract common themes from names
        neighbor_names = [n for n, _ in neighbors]

        # Common keywords
        all_words = set()
        for name in [core] + neighbor_names:
            words = name.lower().replace('.md', '').replace('-', ' ').split()
            all_words.update(words)

        # Filter common words
        meaningful_words = [w for w in all_words if len(w) > 4 and w not in ['project', 'system', 'patterns']]

        if meaningful_words:
            return f"Cluster theme: {', '.join(list(meaningful_words)[:3])}"
        else:
            return "Cross-domain intersection"

    def compose_with_external_model(self, external_model: 'SphericalKnowledgeModel'):
        """
        Compose this model with external model.

        Key Feature: Privacy-preserving knowledge sharing.
        Share spherical models (geometry) without sharing raw data (text).

        This enables collaborative intelligence across multiple AIs.
        """
        print("\n=== COMPOSING WITH EXTERNAL MODEL ===\n")

        initial_sphere_count = len(self.spheres)

        # Merge spheres
        for name, sphere in external_model.spheres.items():
            if name in self.spheres:
                # Sphere already exists - merge properties
                existing = self.spheres[name]

                # Merge by averaging centers (weighted by resonance)
                total_resonance = existing.resonance + sphere.resonance
                merged_center = (existing.center * existing.resonance +
                               sphere.center * sphere.resonance) / total_resonance

                # Merge radii (take minimum = more certainty)
                merged_radius = min(existing.radius, sphere.radius)

                # Merge properties
                merged_properties = existing.properties.copy()
                for key, value in sphere.properties.items():
                    if key in merged_properties:
                        merged_properties[key] = (merged_properties[key] + value) / 2
                    else:
                        merged_properties[key] = value

                # Update sphere
                existing.center = merged_center
                existing.radius = merged_radius
                existing.properties = merged_properties
                existing.resonance = total_resonance / 2  # Average
            else:
                # New sphere - add it
                self.spheres[name] = sphere

        # Merge relationships
        initial_rel_count = len(self.relationships)
        for rel in external_model.relationships:
            # Check if relationship already exists
            exists = any(r.sphere1 == rel.sphere1 and r.sphere2 == rel.sphere2
                        for r in self.relationships)
            if not exists:
                self.relationships.append(rel)

        print(f"Composition complete:")
        print(f"  Spheres: {initial_sphere_count} -> {len(self.spheres)} (+{len(self.spheres) - initial_sphere_count})")
        print(f"  Relationships: {initial_rel_count} -> {len(self.relationships)} (+{len(self.relationships) - initial_rel_count})")

    def visualize_semantic_space(self, output_path: str = r"C:\scripts\agentidentity\state\semantic-space-2d.json"):
        """
        Project high-dimensional spherical space -> 2D for visualization.

        This is purely for human understanding. The AI operates in full dimensional space.
        """
        if not SKLEARN_AVAILABLE:
            print("  sklearn not available, skipping visualization")
            return

        print("\n=== VISUALIZING SEMANTIC SPACE ===\n")

        # Collect all centers
        centers = np.array([sphere.center for sphere in self.spheres.values()])
        names = list(self.spheres.keys())

        # Project to 2D using t-SNE
        print("Projecting to 2D (t-SNE)...")
        tsne = TSNE(n_components=2, random_state=42)
        centers_2d = tsne.fit_transform(centers)

        # Save visualization data
        vis_data = {
            'spheres': [
                {
                    'name': names[i],
                    'x': float(centers_2d[i, 0]),
                    'y': float(centers_2d[i, 1]),
                    'radius': float(self.spheres[names[i]].radius),
                    'resonance': float(self.spheres[names[i]].resonance)
                }
                for i in range(len(names))
            ]
        }

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(vis_data, f, indent=2)

        print(f"2D projection saved: {output_path}")

    def save_model(self, filepath: str = r"C:\scripts\agentidentity\state\spherical-knowledge-model.json"):
        """Save spherical model to file."""

        # Convert to serializable format
        model_data = {
            'dimensions': self.dimensions,
            'spheres': {
                name: {
                    'name': sphere.name,
                    'center': sphere.center.tolist(),
                    'radius': sphere.radius,
                    'properties': sphere.properties,
                    'resonance': sphere.resonance
                }
                for name, sphere in self.spheres.items()
            },
            'relationships': [
                {
                    'sphere1': rel.sphere1,
                    'sphere2': rel.sphere2,
                    'overlap': rel.overlap,
                    'distance': rel.distance,
                    'resonance': rel.resonance,
                    'field_type': rel.field_type
                }
                for rel in self.relationships
            ],
            'metadata': {
                'paradigm': 'continuous_spherical_semantics',
                'sphere_count': len(self.spheres),
                'relationship_count': len(self.relationships)
            }
        }

        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(model_data, f, indent=2)

        print(f"\nModel saved: {filepath}")


def test_spherical_transformation():
    """Test transformation from discrete -> continuous."""

    print("="*70)
    print("SPHERICAL KNOWLEDGE MODEL TEST")
    print("Paradigm: Discrete Symbols -> Continuous Geometric Concepts")
    print("="*70)
    print()

    # Load existing knowledge graph (discrete)
    graph_file = Path(r"C:\scripts\agentidentity\state\knowledge-graph.json")

    if not graph_file.exists():
        print("ERROR: Knowledge graph not found. Run knowledge-graph.py first.")
        return

    with open(graph_file, 'r', encoding='utf-8') as f:
        knowledge_graph = json.load(f)

    # Create spherical model
    model = SphericalKnowledgeModel(dimensions=512)

    # Transform discrete -> continuous
    model.transform_discrete_knowledge(knowledge_graph)

    # Test continuous queries
    print("\n" + "="*70)
    print("TESTING CONTINUOUS QUERIES")
    print("="*70)

    test_queries = [
        "consciousness architecture",
        "deployment patterns",
        "hallucination detection"
    ]

    for query in test_queries:
        results = model.continuous_query(query, top_k=3)
        print(f"\nQuery: '{query}'")
        for name, resonance, mode in results:
            print(f"  {resonance:.3f} - {name[:50]}")

    # Discover emergent concepts
    emergent = model.discover_emergent_concepts()

    # Visualize
    model.visualize_semantic_space()

    # Save model
    model.save_model()

    print("\n" + "="*70)
    print("TEST COMPLETE")
    print("="*70)
    print()
    print("Next Steps:")
    print("1. Replace TF-IDF routing with spherical queries")
    print("2. Integrate spherical reasoning into IM2 layer")
    print("3. Enable continuous concept evolution (not discrete updates)")
    print("4. Build composable model ecosystem (multi-agent collaboration)")

    return model


if __name__ == "__main__":
    model = test_spherical_transformation()
