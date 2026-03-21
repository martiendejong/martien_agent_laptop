#!/usr/bin/env python3
"""
Temporal Analysis Engine for Continuous Retrospective

Applies time-based weighting to session analysis:
- Recent sessions (< 7 days): 100% weight - reflects current reality
- Medium age (7-30 days): 70% weight - likely still relevant
- Old sessions (30-90 days): 40% weight - context for evolution
- Ancient (> 90 days): 10% weight - historical reference only

Prevents outdated patterns from polluting current system state.
"""

import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Tuple
from dataclasses import dataclass

@dataclass
class SessionMetadata:
    """Session metadata with temporal context"""
    session_id: str
    timestamp: datetime
    age_days: int
    weight: float
    category: str  # 'current', 'recent', 'old', 'ancient'
    relevance_score: float

class TemporalAnalyzer:
    """Time-aware session analysis"""

    # Temporal decay function
    WEIGHT_THRESHOLDS = {
        'current': (0, 7, 1.00),      # 0-7 days: 100% weight
        'recent': (7, 30, 0.70),       # 7-30 days: 70% weight
        'old': (30, 90, 0.40),         # 30-90 days: 40% weight
        'ancient': (90, float('inf'), 0.10)  # >90 days: 10% weight
    }

    def __init__(self, reference_date: datetime = None):
        self.reference_date = reference_date or datetime.now()

    def calculate_weight(self, session_date: datetime) -> Tuple[float, str]:
        """Calculate temporal weight for a session"""
        age_days = (self.reference_date - session_date).days

        for category, (min_days, max_days, weight) in self.WEIGHT_THRESHOLDS.items():
            if min_days <= age_days < max_days:
                return weight, category

        # Fallback for future dates (shouldn't happen)
        return 0.0, 'invalid'

    def analyze_session(self, session_path: Path) -> SessionMetadata:
        """Extract metadata with temporal context"""
        try:
            with open(session_path) as f:
                data = json.load(f)

            # Extract timestamp (adapt to actual session format)
            timestamp = datetime.fromtimestamp(data.get('createdAt', 0) / 1000)
            age_days = (self.reference_date - timestamp).days
            weight, category = self.calculate_weight(timestamp)

            # Calculate relevance score (weight × content quality)
            relevance_score = weight * self._assess_content_quality(data)

            return SessionMetadata(
                session_id=data.get('sessionId', 'unknown'),
                timestamp=timestamp,
                age_days=age_days,
                weight=weight,
                category=category,
                relevance_score=relevance_score
            )
        except Exception as e:
            print(f"Error analyzing {session_path}: {e}")
            return None

    def _assess_content_quality(self, session_data: Dict) -> float:
        """Assess content quality independent of age"""
        # Heuristics:
        # - Has explicit learnings? +0.3
        # - Contains code changes? +0.2
        # - Has error resolution? +0.3
        # - Has user feedback? +0.2

        quality = 0.5  # Base quality

        title = session_data.get('title', '').lower()

        # Positive indicators
        if any(kw in title for kw in ['fix', 'implement', 'create', 'add']):
            quality += 0.2
        if any(kw in title for kw in ['error', 'bug', 'issue']):
            quality += 0.1

        return min(quality, 1.0)

    def categorize_sessions(self, sessions: List[SessionMetadata]) -> Dict[str, List[SessionMetadata]]:
        """Group sessions by temporal category"""
        categories = {cat: [] for cat in self.WEIGHT_THRESHOLDS.keys()}

        for session in sessions:
            if session:
                categories[session.category].append(session)

        return categories

    def generate_temporal_report(self, sessions: List[SessionMetadata]) -> str:
        """Generate markdown report with temporal breakdown"""
        categorized = self.categorize_sessions(sessions)

        report = ["# Temporal Session Analysis\n"]
        report.append(f"**Analysis Date:** {self.reference_date.strftime('%Y-%m-%d %H:%M')}\n")
        report.append(f"**Total Sessions:** {len(sessions)}\n")

        for category in ['current', 'recent', 'old', 'ancient']:
            sessions_in_cat = categorized[category]
            if not sessions_in_cat:
                continue

            min_days, max_days, weight = self.WEIGHT_THRESHOLDS[category]
            count = len(sessions_in_cat)
            avg_relevance = sum(s.relevance_score for s in sessions_in_cat) / count

            report.append(f"\n## {category.upper()} Sessions")
            report.append(f"**Age Range:** {min_days}-{max_days if max_days != float('inf') else '∞'} days")
            report.append(f"**Weight:** {weight*100:.0f}%")
            report.append(f"**Count:** {count}")
            report.append(f"**Avg Relevance:** {avg_relevance:.2f}")

            # Interpretation
            if category == 'current':
                report.append(f"\n*These sessions reflect CURRENT REALITY. Trust fully.*")
            elif category == 'recent':
                report.append(f"\n*Likely still relevant but verify against current state.*")
            elif category == 'old':
                report.append(f"\n*Context for evolution. Check if patterns still apply.*")
            else:  # ancient
                report.append(f"\n*Historical reference ONLY. Do not apply directly.*")

            # Top sessions by relevance
            top_sessions = sorted(sessions_in_cat, key=lambda s: s.relevance_score, reverse=True)[:5]
            report.append(f"\n**Top Sessions:**")
            for s in top_sessions:
                report.append(f"- {s.session_id} ({s.timestamp.strftime('%Y-%m-%d')}) - Relevance: {s.relevance_score:.2f}")

        return "\n".join(report)

def apply_temporal_filter(patterns: List[Dict], session_metadata: List[SessionMetadata]) -> List[Dict]:
    """
    Apply temporal weighting to discovered patterns

    Returns patterns with adjusted confidence based on temporal relevance:
    - Pattern from current sessions: confidence unchanged
    - Pattern from old sessions: confidence * 0.4
    - Pattern from ancient sessions: flagged as HISTORICAL_REFERENCE_ONLY
    """
    session_lookup = {s.session_id: s for s in session_metadata if s}

    weighted_patterns = []
    for pattern in patterns:
        session_ids = pattern.get('source_sessions', [])

        # Calculate weighted confidence
        total_weight = 0
        total_confidence = 0

        for sid in session_ids:
            session = session_lookup.get(sid)
            if session:
                total_weight += session.weight
                total_confidence += pattern.get('confidence', 0.5) * session.weight

        if total_weight > 0:
            weighted_confidence = total_confidence / total_weight
        else:
            weighted_confidence = 0.0

        # Determine if pattern is current or historical
        most_recent_session = max(
            (session_lookup[sid] for sid in session_ids if sid in session_lookup),
            key=lambda s: s.timestamp,
            default=None
        )

        if most_recent_session:
            pattern['weighted_confidence'] = weighted_confidence
            pattern['temporal_category'] = most_recent_session.category
            pattern['most_recent_occurrence'] = most_recent_session.timestamp.isoformat()

            # Flag ancient patterns
            if most_recent_session.category == 'ancient':
                pattern['warning'] = 'HISTORICAL_REFERENCE_ONLY - Verify before applying'
            elif most_recent_session.category == 'old':
                pattern['warning'] = 'OLD_PATTERN - Check if still relevant'

        weighted_patterns.append(pattern)

    return weighted_patterns

if __name__ == "__main__":
    # Example usage
    analyzer = TemporalAnalyzer()

    # Example session data
    example_session = Path("C:/Users/HP/AppData/Roaming/Claude/claude-code-sessions/71319c61-117c-49e7-bd12-1e218acf4350/3ddef1f7-6baf-4921-8897-927dbf7b2643/local_7a6da0a0-49f0-4c68-a075-cead120b9449.json")

    if example_session.exists():
        metadata = analyzer.analyze_session(example_session)
        print(f"Session: {metadata.session_id}")
        print(f"Age: {metadata.age_days} days")
        print(f"Category: {metadata.category}")
        print(f"Weight: {metadata.weight}")
        print(f"Relevance: {metadata.relevance_score}")
