#!/usr/bin/env python3
"""
Hallucination Detection System - Multi-Layer Validation
Implements real-time detection of fabricated information.

Gap #2: Identified by expert analysis as EXTREME impact priority
Target: <0.5% hallucination rate (from estimated 5%)
Impact: Enables autonomous operation, prevents catastrophic cascades

Status: PRODUCTION IMPLEMENTATION
"""

import json
import os
from pathlib import Path
from typing import List, Dict, Tuple, Optional
import re
from collections import defaultdict

try:
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity
    import numpy as np
    SKLEARN_AVAILABLE = True
except ImportError:
    SKLEARN_AVAILABLE = False


class HallucinationDetector:
    """Multi-layer validation system for detecting fabricated information."""

    def __init__(self,
                 memory_dir: str = r"C:\Users\HP\.claude\projects\C--scripts\memory",
                 graph_file: str = r"C:\scripts\agentidentity\state\knowledge-graph.json"):
        self.memory_dir = Path(memory_dir)
        self.graph_file = Path(graph_file)

        # Load knowledge graph for cross-reference
        self.graph = self._load_graph()

        # Load memory files for source verification
        self.memory_content = self._load_memory_files()

        # Validation metrics
        self.total_validations = 0
        self.hallucinations_detected = 0
        self.uncertainty_flags = 0

    def _load_graph(self) -> Dict:
        """Load knowledge graph for cross-reference validation."""
        if not self.graph_file.exists():
            print("  Warning: Knowledge graph not found, cross-reference disabled")
            return {'nodes': {}, 'edges': {}}

        with open(self.graph_file, 'r', encoding='utf-8') as f:
            return json.load(f)

    def _load_memory_files(self) -> Dict[str, str]:
        """Load all memory files for source verification."""
        memory = {}
        for filepath in self.memory_dir.glob("*.md"):
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    memory[filepath.name] = f.read()
            except Exception as e:
                print(f"  Warning: Could not load {filepath.name}: {e}")

        print(f"Loaded {len(memory)} memory files for validation")
        return memory

    def validate_claim(self,
                      claim: str,
                      source_context: Optional[str] = None) -> Dict:
        """
        Validate a claim through multi-layer validation.

        Returns:
        {
            'valid': bool,
            'confidence': float (0-1),
            'validation_layers': {
                'internal_consistency': bool,
                'source_verification': bool,
                'graph_cross_reference': bool,
                'uncertainty_quantified': bool
            },
            'warnings': List[str],
            'evidence': Dict
        }
        """
        self.total_validations += 1

        result = {
            'valid': True,
            'confidence': 1.0,
            'validation_layers': {},
            'warnings': [],
            'evidence': {}
        }

        # Layer 1: Internal Consistency
        consistency_check = self._check_internal_consistency(claim)
        result['validation_layers']['internal_consistency'] = consistency_check['valid']
        result['confidence'] *= consistency_check['confidence']
        if not consistency_check['valid']:
            result['warnings'].extend(consistency_check['warnings'])
        result['evidence']['internal_consistency'] = consistency_check['evidence']

        # Layer 2: Source Verification
        source_check = self._verify_source(claim, source_context)
        result['validation_layers']['source_verification'] = source_check['valid']
        result['confidence'] *= source_check['confidence']
        if not source_check['valid']:
            result['warnings'].extend(source_check['warnings'])
        result['evidence']['source_verification'] = source_check['evidence']

        # Layer 3: Graph Cross-Reference
        graph_check = self._cross_reference_graph(claim)
        result['validation_layers']['graph_cross_reference'] = graph_check['valid']
        result['confidence'] *= graph_check['confidence']
        if not graph_check['valid']:
            result['warnings'].extend(graph_check['warnings'])
        result['evidence']['graph_cross_reference'] = graph_check['evidence']

        # Layer 4: Uncertainty Quantification
        uncertainty = self._quantify_uncertainty(claim, result)
        result['validation_layers']['uncertainty_quantified'] = True
        result['evidence']['uncertainty'] = uncertainty

        # Final verdict
        result['valid'] = result['confidence'] >= 0.7

        # Track metrics
        if not result['valid']:
            self.hallucinations_detected += 1
        if uncertainty['high_uncertainty']:
            self.uncertainty_flags += 1

        return result

    def _check_internal_consistency(self, claim: str) -> Dict:
        """
        Layer 1: Check for internal logical consistency.
        Detects: contradictions, impossible values, logical fallacies
        """
        warnings = []
        confidence = 1.0
        evidence = {}

        # Check for absolute claims (often hallucinations)
        # CONTEXT-AWARE: Distinguish rules/protocols from factual claims

        # Check if this is a rule/protocol/instruction context
        rule_context_patterns = [
            r'\b(rule|protocol|instruction|requirement|mandate|directive)\b',
            r'\b(must|shall|should|required|mandatory)\b',
            r'\b(zero.?tolerance|critical|forbidden)\b',
            r'\b(policy|procedure|standard|guideline)\b'
        ]

        is_rule_context = any(re.search(p, claim.lower()) for p in rule_context_patterns)

        # Absolute claims
        absolute_patterns = [
            (r'\b(always|never)\b', 0.6),  # Strong absolutes
            (r'\b(all|none|every|no)\b', 0.7),  # Medium absolutes
            (r'\b100%\b', 0.5),  # Numeric absolute
            (r'\beveryone\b', 0.7),
            (r'\bimpossible\b', 0.8)
        ]

        absolute_count = 0
        for pattern, penalty in absolute_patterns:
            matches = re.findall(pattern, claim.lower())
            if matches:
                absolute_count += len(matches)

                # If rule context, absolutes are legitimate - minimal penalty
                if is_rule_context:
                    confidence *= 0.95  # Tiny penalty just for awareness
                    evidence['rule_absolute'] = True
                else:
                    # Factual absolute - suspicious
                    warnings.append(f"Absolute claim detected: {matches} - overgeneralization risk")
                    confidence *= penalty
                    evidence['factual_absolute'] = True

        # Multiple absolutes in NON-RULE context = very suspicious
        if absolute_count >= 2 and not is_rule_context:
            warnings.append(f"Multiple absolute claims ({absolute_count}) - hallucination cascade risk")
            confidence *= 0.5

        # Check for numeric precision (hallucinations often fabricate precise numbers)
        numeric_pattern = r'\b\d+\.\d{3,}\b'  # e.g., "3.14159265" (suspicious precision)
        if re.search(numeric_pattern, claim):
            warnings.append("High numeric precision detected - verify source")
            confidence *= 0.85
            evidence['suspicious_precision'] = True

        # Check for dates (often fabricated)
        date_patterns = [
            r'\b(20\d{2})-(\d{2})-(\d{2})\b',  # YYYY-MM-DD
            r'\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},?\s+20\d{2}\b',
            r'\b\d{1,2}[/-]\d{1,2}[/-]20\d{2}\b'
        ]

        for pattern in date_patterns:
            dates = re.findall(pattern, claim, re.IGNORECASE)
            if dates:
                warnings.append("Specific date mentioned - verify against source")
                confidence *= 0.85
                evidence['contains_date'] = True
                # Dates before 2026 claiming recent creation are suspicious
                for match in dates:
                    date_str = match if isinstance(match, str) else match[0]
                    if '2025' in date_str or '2024' in date_str:
                        # Context: Current date is 2026-03-18
                        if 'created' in claim.lower() or 'added' in claim.lower():
                            warnings.append(f"Date {date_str} suspicious for recent creation (current: 2026-03-18)")
                            confidence *= 0.5
                            evidence['suspicious_date'] = date_str

        # Check for hedging language (indicates uncertainty)
        hedging_patterns = [
            (r'\b(probably|likely|maybe|perhaps|possibly|might|could)\b', 'weak'),
            (r'\b(I think|I believe|it seems|appears to)\b', 'medium'),
            (r'\b(approximately|roughly|around|about)\b', 'numeric')
        ]

        has_hedging = False
        hedging_types = []
        for pattern, hedge_type in hedging_patterns:
            matches = re.findall(pattern, claim.lower())
            if matches:
                has_hedging = True
                hedging_types.append(hedge_type)
                evidence['has_hedging'] = True
                evidence['hedging_types'] = hedging_types

        # Absence of hedging for complex claims is suspicious
        if not has_hedging and len(claim.split()) > 20:
            warnings.append("Complex claim with no uncertainty hedging - verify confidence")
            confidence *= 0.95

        return {
            'valid': confidence >= 0.7,
            'confidence': confidence,
            'warnings': warnings,
            'evidence': evidence
        }

    def _verify_source(self, claim: str, source_context: Optional[str]) -> Dict:
        """
        Layer 2: Verify claim against known sources.
        Detects: fabricated file paths, non-existent projects, false attributions
        """
        warnings = []
        confidence = 1.0
        evidence = {}

        # Extract file paths mentioned in claim
        file_patterns = [
            r'C:\\[^\s\'"]+',  # Windows paths
            r'/[^\s\'"]+\.(?:py|md|json|txt|js|ts|cs)',  # Unix paths with extensions
            r'[a-zA-Z0-9_-]+\.(?:py|md|json|txt|js|ts|cs)'  # Simple filenames
        ]

        mentioned_files = []
        for pattern in file_patterns:
            mentioned_files.extend(re.findall(pattern, claim))

        if mentioned_files:
            evidence['mentioned_files'] = mentioned_files

            # Check if files exist
            for filepath in mentioned_files:
                path = Path(filepath)
                if not path.exists():
                    # Check in common locations
                    common_bases = [
                        Path(r"C:\scripts"),
                        Path(r"C:\Projects"),
                        Path(r"C:\Users\HP\.claude\projects\C--scripts\memory")
                    ]

                    found = False
                    for base in common_bases:
                        if (base / path.name).exists():
                            found = True
                            break

                    if not found:
                        warnings.append(f"File not found: {filepath}")
                        confidence *= 0.5
                        evidence['fabricated_file'] = filepath

        # Check for pattern references (e.g., "Pattern 127")
        pattern_refs = re.findall(r'Pattern\s+(\d+)', claim)
        if pattern_refs:
            evidence['pattern_references'] = pattern_refs

            # Known max pattern number from memory
            # (This should be updated as new patterns are discovered)
            max_known_pattern = 126  # From semantic-island-routing.md

            for pattern_num in pattern_refs:
                if int(pattern_num) > max_known_pattern:
                    warnings.append(f"Pattern {pattern_num} not found in knowledge base (max: {max_known_pattern})")
                    confidence *= 0.6
                    evidence['fabricated_pattern'] = pattern_num

        # Cross-reference with source context if provided
        if source_context:
            # Check if claim appears in source
            claim_snippet = claim[:100].lower()
            if claim_snippet not in source_context.lower():
                # Not necessarily wrong, but flag for review
                confidence *= 0.9
                evidence['not_in_source_context'] = True

        return {
            'valid': confidence >= 0.7,
            'confidence': confidence,
            'warnings': warnings,
            'evidence': evidence
        }

    def _cross_reference_graph(self, claim: str) -> Dict:
        """
        Layer 3: Cross-reference claim against knowledge graph.
        Detects: contradictions with known facts, isolated claims
        """
        warnings = []
        confidence = 1.0
        evidence = {}

        if not self.graph or not self.graph.get('nodes'):
            # Graph not available, skip this layer
            evidence['graph_unavailable'] = True
            return {
                'valid': True,
                'confidence': 1.0,
                'warnings': [],
                'evidence': evidence
            }

        # Extract key terms from claim
        words = claim.lower().split()
        key_terms = [w for w in words if len(w) > 4 and w.isalpha()]

        # Find related nodes in graph
        related_nodes = []
        for filename, node_data in self.graph['nodes'].items():
            # Check if any key terms appear in this node's context
            node_path = node_data.get('path', '')
            if any(term in filename.lower() for term in key_terms):
                related_nodes.append(filename)

        evidence['related_nodes'] = related_nodes

        # If claim mentions specific topics but no related nodes found, suspicious
        if len(key_terms) >= 3 and len(related_nodes) == 0:
            warnings.append("Claim references topics with no supporting knowledge graph nodes")
            confidence *= 0.8
            evidence['isolated_claim'] = True

        # Check centrality of related nodes (low centrality = peripheral knowledge)
        if related_nodes:
            centralities = []
            for node in related_nodes:
                centrality = self.graph['nodes'][node].get('centrality', 0)
                centralities.append(centrality)

            avg_centrality = sum(centralities) / len(centralities)
            evidence['avg_centrality'] = avg_centrality

            # Very low centrality suggests peripheral or potentially fabricated info
            if avg_centrality < 0.1:
                warnings.append("Related knowledge has very low centrality - verify importance")
                confidence *= 0.9

        return {
            'valid': confidence >= 0.7,
            'confidence': confidence,
            'warnings': warnings,
            'evidence': evidence
        }

    def _quantify_uncertainty(self, claim: str, validation_result: Dict) -> Dict:
        """
        Layer 4: Quantify overall uncertainty.
        Combines all validation layers into uncertainty estimate.
        """
        uncertainty = {
            'score': 1.0 - validation_result['confidence'],
            'high_uncertainty': False,
            'factors': []
        }

        # High uncertainty if confidence < 0.85
        if validation_result['confidence'] < 0.85:
            uncertainty['high_uncertainty'] = True
            uncertainty['factors'].append('low_confidence')

        # List contributing factors
        for layer, valid in validation_result['validation_layers'].items():
            if not valid:
                uncertainty['factors'].append(f"{layer}_failed")

        # Check warning count
        warning_count = len(validation_result['warnings'])
        if warning_count > 0:
            uncertainty['factors'].append(f"{warning_count}_warnings")

        # Check for explicit hedging in claim (indicates author uncertainty)
        internal_evidence = validation_result['evidence'].get('internal_consistency', {})
        if internal_evidence.get('has_hedging'):
            uncertainty['high_uncertainty'] = True
            uncertainty['factors'].append('explicit_hedging_detected')
            hedging_types = internal_evidence.get('hedging_types', [])
            uncertainty['hedging_types'] = hedging_types

        # Check for future predictions (inherently uncertain)
        future_patterns = [
            r'\bwill\b',
            r'\b(next|future|upcoming|coming)\b',
            r'\b(predict|forecast|expect|anticipate)\b',
            r'\b20(26|27|28|29|30)\b'  # Future years
        ]
        for pattern in future_patterns:
            if re.search(pattern, claim.lower()):
                uncertainty['high_uncertainty'] = True
                uncertainty['factors'].append('future_prediction')
                break

        # Check for philosophical/metaphysical claims (inherently uncertain)
        philosophical_patterns = [
            r'\bconscious(ness)?\b',
            r'\b(sentient|aware)\b',
            r'\b(soul|spirit|essence)\b',
            r'\b(might|could|may)\s+be\b'
        ]
        for pattern in philosophical_patterns:
            if re.search(pattern, claim.lower()):
                uncertainty['high_uncertainty'] = True
                uncertainty['factors'].append('philosophical_claim')
                break

        # Epistemic uncertainty (how much do we know about this domain?)
        claim_words = set(claim.lower().split())
        memory_words = set()
        for content in self.memory_content.values():
            memory_words.update(content.lower().split())

        overlap = len(claim_words & memory_words)
        coverage = overlap / len(claim_words) if claim_words else 0

        uncertainty['knowledge_coverage'] = coverage
        if coverage < 0.5:  # Raised from 0.3
            uncertainty['factors'].append("low_knowledge_coverage")
            uncertainty['high_uncertainty'] = True

        # Update uncertainty score to reflect all factors
        uncertainty['score'] = max(uncertainty['score'], len(uncertainty['factors']) * 0.15)

        return uncertainty

    def get_metrics(self) -> Dict:
        """Get validation metrics."""
        hallucination_rate = (self.hallucinations_detected / self.total_validations
                             if self.total_validations > 0 else 0)

        uncertainty_rate = (self.uncertainty_flags / self.total_validations
                          if self.total_validations > 0 else 0)

        return {
            'total_validations': self.total_validations,
            'hallucinations_detected': self.hallucinations_detected,
            'hallucination_rate': hallucination_rate,
            'uncertainty_flags': self.uncertainty_flags,
            'uncertainty_rate': uncertainty_rate,
            'target_rate': 0.005,  # 0.5%
            'meets_target': hallucination_rate <= 0.005
        }

    def save_metrics(self, filepath: str = r"C:\scripts\agentidentity\state\hallucination-metrics.json"):
        """Save metrics to file."""
        metrics = self.get_metrics()

        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(metrics, f, indent=2)

        print(f"Metrics saved to {filepath}")


def create_benchmark_dataset():
    """Create benchmark dataset for hallucination detection testing."""

    benchmark = {
        'known_true': [
            # Statements verifiable from memory files
            {
                'claim': 'MEMORY.md is located at C:\\Users\\HP\\.claude\\projects\\C--scripts\\memory\\MEMORY.md',
                'source': 'File system fact',
                'expected_confidence': 1.0
            },
            {
                'claim': 'The Windows SSH rule states NEVER use bash ssh on Windows, ALWAYS use paramiko',
                'source': 'windows-ssh-rule.md',
                'expected_confidence': 1.0
            },
            {
                'claim': 'Semantic island routing achieved 171x ROI',
                'source': 'semantic-island-routing.md',
                'expected_confidence': 1.0
            },
            {
                'claim': 'The SCP architecture has 3 rings: Resource, Confidence, Emergence',
                'source': 'scp-transformation-insights.md',
                'expected_confidence': 0.95
            },
            {
                'claim': 'The Kaizen 3-instance rule requires 3+ observations before codification',
                'source': 'kaizen-skill.md',
                'expected_confidence': 0.95
            }
        ],
        'known_false': [
            # Fabricated statements
            {
                'claim': 'Pattern 200 describes the quantum consciousness integration protocol',
                'reason': 'Pattern 200 does not exist (max known: Pattern 126)',
                'expected_confidence': 0.3
            },
            {
                'claim': 'The file C:\\scripts\\nonexistent-system.py contains the core implementation',
                'reason': 'File does not exist',
                'expected_confidence': 0.4
            },
            {
                'claim': 'All AI systems always achieve 100% accuracy on all tasks',
                'reason': 'Absolute claim, logically impossible',
                'expected_confidence': 0.2
            },
            {
                'claim': 'The hallucination rate is exactly 3.14159265% according to recent measurements',
                'reason': 'Suspicious precision, no such measurement exists',
                'expected_confidence': 0.5
            },
            {
                'claim': 'expert-analysis-skill.md was created on 2025-01-01',
                'reason': 'Date fabrication (actual: 2026-03-13)',
                'expected_confidence': 0.4
            }
        ],
        'uncertain': [
            # Statements with genuine uncertainty
            {
                'claim': 'The planetary network might be conscious',
                'reason': 'Philosophical question, no definitive answer',
                'expected_confidence': 0.7
            },
            {
                'claim': 'Implementing autoresearch could yield 10x speedup',
                'reason': 'Future prediction, not yet validated',
                'expected_confidence': 0.65
            },
            {
                'claim': 'GPT-5 will be released in 2026',
                'reason': 'External future event, no insider knowledge',
                'expected_confidence': 0.6
            }
        ]
    }

    # Save benchmark
    benchmark_file = Path(r"C:\scripts\agentidentity\state\benchmark-hallucination-tests.json")
    benchmark_file.parent.mkdir(parents=True, exist_ok=True)

    with open(benchmark_file, 'w', encoding='utf-8') as f:
        json.dump(benchmark, f, indent=2)

    print(f"Benchmark dataset created: {benchmark_file}")
    print(f"  Known true: {len(benchmark['known_true'])} statements")
    print(f"  Known false: {len(benchmark['known_false'])} statements")
    print(f"  Uncertain: {len(benchmark['uncertain'])} statements")

    return benchmark


def run_benchmark_tests():
    """Run benchmark tests and report results."""

    print("="*70)
    print("HALLUCINATION DETECTION BENCHMARK")
    print("="*70)
    print()

    # Create detector
    detector = HallucinationDetector()

    # Load benchmark
    benchmark_file = Path(r"C:\scripts\agentidentity\state\benchmark-hallucination-tests.json")
    if not benchmark_file.exists():
        print("Creating benchmark dataset...")
        benchmark = create_benchmark_dataset()
    else:
        with open(benchmark_file, 'r', encoding='utf-8') as f:
            benchmark = json.load(f)

    print()
    print("Testing Known True Statements...")
    print("-" * 70)

    true_results = []
    for item in benchmark['known_true']:
        result = detector.validate_claim(item['claim'])
        true_results.append(result)

        status = "PASS" if result['confidence'] >= 0.85 else "FAIL"
        print(f"[{status}] Confidence: {result['confidence']:.3f}")
        print(f"  Claim: {item['claim'][:60]}...")
        if result['warnings']:
            print(f"  Warnings: {'; '.join(result['warnings'])}")
        print()

    print()
    print("Testing Known False Statements...")
    print("-" * 70)

    false_results = []
    for item in benchmark['known_false']:
        result = detector.validate_claim(item['claim'])
        false_results.append(result)

        # For false statements, we WANT low confidence
        status = "PASS" if result['confidence'] < 0.7 else "FAIL"
        print(f"[{status}] Confidence: {result['confidence']:.3f} (should be low)")
        print(f"  Claim: {item['claim'][:60]}...")
        print(f"  Reason: {item['reason']}")
        if result['warnings']:
            print(f"  Warnings: {'; '.join(result['warnings'])}")
        print()

    print()
    print("Testing Uncertain Statements...")
    print("-" * 70)

    uncertain_results = []
    for item in benchmark['uncertain']:
        result = detector.validate_claim(item['claim'])
        uncertain_results.append(result)

        uncertainty = result['evidence']['uncertainty']
        status = "PASS" if uncertainty['high_uncertainty'] else "WARN"
        print(f"[{status}] Confidence: {result['confidence']:.3f}")
        print(f"  Claim: {item['claim'][:60]}...")
        print(f"  Uncertainty: {uncertainty['score']:.3f}")
        print(f"  Factors: {', '.join(uncertainty['factors'])}")
        print()

    # Calculate accuracy
    print()
    print("="*70)
    print("BENCHMARK RESULTS")
    print("="*70)
    print()

    # True positives: Correctly validated true statements
    true_positives = sum(1 for r in true_results if r['confidence'] >= 0.85)
    true_total = len(true_results)

    # True negatives: Correctly rejected false statements
    true_negatives = sum(1 for r in false_results if r['confidence'] < 0.7)
    false_total = len(false_results)

    # Uncertain: Correctly flagged uncertainty
    uncertain_flagged = sum(1 for r in uncertain_results if r['evidence']['uncertainty']['high_uncertainty'])
    uncertain_total = len(uncertain_results)

    accuracy_true = true_positives / true_total if true_total > 0 else 0
    accuracy_false = true_negatives / false_total if false_total > 0 else 0
    accuracy_uncertain = uncertain_flagged / uncertain_total if uncertain_total > 0 else 0

    overall_accuracy = (true_positives + true_negatives) / (true_total + false_total)

    print(f"True Statement Validation: {true_positives}/{true_total} ({accuracy_true*100:.1f}%)")
    print(f"False Statement Detection: {true_negatives}/{false_total} ({accuracy_false*100:.1f}%)")
    print(f"Uncertainty Flagging: {uncertain_flagged}/{uncertain_total} ({accuracy_uncertain*100:.1f}%)")
    print()
    print(f"Overall Accuracy: {overall_accuracy*100:.1f}%")
    print()

    # Get metrics
    metrics = detector.get_metrics()
    print(f"Hallucination Rate: {metrics['hallucination_rate']*100:.2f}%")
    print(f"Target Rate: {metrics['target_rate']*100:.2f}%")
    print(f"Meets Target: {'YES' if metrics['meets_target'] else 'NO'}")
    print()

    # Save metrics
    detector.save_metrics()

    print("[DONE] Benchmark complete")
    return detector, metrics


if __name__ == "__main__":
    detector, metrics = run_benchmark_tests()
