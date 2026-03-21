#!/usr/bin/env python3
"""
Build semantic knowledge graph from email facts.
Creates comprehensive knowledge base for legal case analysis.

Anti-hallucination protocol: ONLY facts from sources, NO interpretations.
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime
from collections import defaultdict
import hashlib

class KnowledgeGraphBuilder:
    def __init__(self):
        self.entities = {}
        self.events = []
        self.relationships = []
        self.documents = {}
        self.timeline = []
        self.people = {}
        self.organizations = {}

    def add_entity(self, entity_type, name, attributes=None):
        """Add entity to graph."""
        entity_id = self._generate_id(entity_type, name)

        if entity_id not in self.entities:
            self.entities[entity_id] = {
                'id': entity_id,
                'type': entity_type,
                'name': name,
                'attributes': attributes or {},
                'first_seen': None,
                'last_seen': None
            }

        return entity_id

    def add_event(self, event_type, date, description, source, participants=None, documents=None):
        """Add event to timeline."""
        event_id = self._generate_id('event', f"{date}_{event_type}_{description[:50]}")

        event = {
            'id': event_id,
            'type': event_type,
            'date': date,
            'description': description,
            'source': source,
            'participants': participants or [],
            'documents': documents or []
        }

        self.events.append(event)
        self.timeline.append({
            'date': date,
            'event_id': event_id,
            'type': event_type,
            'description': description
        })

        return event_id

    def add_relationship(self, source_id, target_id, relationship_type, date=None, attributes=None):
        """Add relationship between entities."""
        rel_id = self._generate_id('relationship', f"{source_id}_{relationship_type}_{target_id}")

        relationship = {
            'id': rel_id,
            'source': source_id,
            'target': target_id,
            'type': relationship_type,
            'date': date,
            'attributes': attributes or {}
        }

        self.relationships.append(relationship)
        return rel_id

    def _generate_id(self, prefix, value):
        """Generate unique ID."""
        hash_value = hashlib.md5(value.encode()).hexdigest()[:8]
        return f"{prefix}_{hash_value}"

    def parse_fact_entry(self, fact_text, source_file):
        """Parse a single fact entry and extract entities/events."""
        # Extract header information
        date_match = re.search(r'DATUM:\s*(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2})', fact_text)
        from_match = re.search(r'VAN:\s*(.+?)(?:\n|$)', fact_text)
        to_match = re.search(r'AAN:\s*(.+?)(?:\n|$)', fact_text)
        subject_match = re.search(r'ONDERWERP:\s*(.+?)(?:\n|$)', fact_text)
        context_match = re.search(r'\[CONTEXT:\s*(.+?)\]', fact_text)

        if not date_match:
            return None

        date = date_match.group(1)
        from_addr = from_match.group(1).strip() if from_match else 'Unknown'
        to_addr = to_match.group(1).strip() if to_match else 'Unknown'
        subject = subject_match.group(1).strip() if subject_match else 'No subject'
        context = context_match.group(1).strip() if context_match else None

        # Extract body
        body_match = re.search(r'={80}\n\n(?:\[CONTEXT:.*?\]\n\n)?(.*)', fact_text, re.DOTALL)
        body = body_match.group(1).strip() if body_match else ''

        # Add people entities
        from_id = self._extract_person(from_addr, date)
        to_id = self._extract_person(to_addr, date)

        # Determine event type
        event_type = self._classify_event(subject, body)

        # Extract mentioned documents
        mentioned_docs = self._extract_documents(subject, body, context)

        # Add event
        event_id = self.add_event(
            event_type=event_type,
            date=date,
            description=subject,
            source=source_file,
            participants=[from_id, to_id],
            documents=mentioned_docs
        )

        # Add communication relationship
        self.add_relationship(
            source_id=from_id,
            target_id=to_id,
            relationship_type='sent_email',
            date=date,
            attributes={'subject': subject, 'event_id': event_id}
        )

        # Process specific event types
        self._process_specific_event(event_type, subject, body, context, date, from_id, to_id, event_id)

        return event_id

    def _extract_person(self, contact_string, date):
        """Extract person entity from contact string."""
        # Extract name and email
        email_match = re.search(r'<([^>]+)>', contact_string)
        email = email_match.group(1) if email_match else None

        # Clean name
        name = re.sub(r'<[^>]+>', '', contact_string).strip()
        name = re.sub(r'"', '', name).strip()

        if not name:
            name = email if email else contact_string

        # Determine organization
        org = None
        if 'meppel.nl' in contact_string.lower():
            org = 'Gemeente Meppel'
        elif 'martiendejong' in contact_string.lower():
            org = None  # Individual

        person_id = self.add_entity('person', name, {
            'email': email,
            'organization': org
        })

        # Update seen dates
        if self.entities[person_id]['first_seen'] is None:
            self.entities[person_id]['first_seen'] = date
        self.entities[person_id]['last_seen'] = date

        # Track organization
        if org:
            org_id = self.add_entity('organization', org)
            self.add_relationship(person_id, org_id, 'works_for')

        return person_id

    def _classify_event(self, subject, body):
        """Classify event type based on subject and body."""
        subject_lower = subject.lower()
        body_lower = body.lower()

        if 'bevestiging van uw afspraak' in subject_lower or 'confirmation' in subject_lower:
            return 'appointment_confirmation'
        elif 'herinnering van uw afspraak' in subject_lower or 'reminder' in subject_lower:
            return 'appointment_reminder'
        elif 'annulering' in subject_lower or 'wijziging' in subject_lower:
            return 'appointment_change'
        elif 'weigering' in subject_lower or 'refusal' in subject_lower:
            return 'request_denial'
        elif 'ingebrekestelling' in subject_lower:
            return 'formal_notice'
        elif 'verzoek' in subject_lower or 'aanvraag' in subject_lower or 'request' in subject_lower:
            return 'document_request'
        elif 'hulpverzoek' in subject_lower:
            return 'help_request'
        elif 'melding' in subject_lower or 'complaint' in subject_lower or 'klacht' in subject_lower:
            return 'complaint'
        elif 'formeel' in subject_lower:
            return 'formal_request'
        elif re.search(r'^re:|^fw:|^fwd:', subject_lower):
            return 'reply'
        else:
            return 'communication'

    def _extract_documents(self, subject, body, context):
        """Extract mentioned documents."""
        docs = []

        text = f"{subject} {body} {context or ''}"
        text_lower = text.lower()

        doc_types = {
            'verklaring van huwelijksbevoegdheid': 'Verklaring van huwelijksbevoegdheid',
            'certificate of no impediment': 'Certificate of No Impediment',
            'geboortecertificaat': 'Geboortecertificaat',
            'birth certificate': 'Birth Certificate',
            'verklaring burgerlijke staat': 'Verklaring burgerlijke staat',
            'paspoort': 'Paspoort',
            'passport': 'Passport',
            'uittreksel brp': 'Uittreksel BRP',
            'legalisatie': 'Legalisatie documenten',
            'apostille': 'Apostille',
        }

        for keyword, doc_name in doc_types.items():
            if keyword in text_lower:
                doc_id = self.add_entity('document', doc_name, {
                    'type': doc_name,
                    'status': 'mentioned'
                })
                docs.append(doc_id)

        return docs

    def _process_specific_event(self, event_type, subject, body, context, date, from_id, to_id, event_id):
        """Process specific event types for additional relationships."""

        if event_type == 'request_denial':
            # Find what was denied
            denied_docs = self._extract_documents(subject, body, context)
            for doc_id in denied_docs:
                self.add_relationship(
                    source_id=to_id,  # Municipality
                    target_id=doc_id,
                    relationship_type='denied',
                    date=date,
                    attributes={'event_id': event_id}
                )

        elif event_type == 'document_request':
            # Find what was requested
            requested_docs = self._extract_documents(subject, body, context)
            for doc_id in requested_docs:
                self.add_relationship(
                    source_id=from_id,  # Requester
                    target_id=doc_id,
                    relationship_type='requested',
                    date=date,
                    attributes={'event_id': event_id}
                )

        elif event_type in ['appointment_confirmation', 'appointment_reminder']:
            # Create appointment entity
            appointment_id = self.add_entity('appointment', f"Afspraak {date}", {
                'date': date,
                'status': 'scheduled',
                'purpose': context
            })

            self.add_relationship(
                source_id=to_id,  # Municipality
                target_id=from_id,  # Citizen
                relationship_type='scheduled_appointment',
                date=date,
                attributes={'appointment_id': appointment_id, 'event_id': event_id}
            )

    def build_statistics(self):
        """Build statistics about the case."""
        stats = {
            'total_entities': len(self.entities),
            'total_events': len(self.events),
            'total_relationships': len(self.relationships),
            'entity_counts': defaultdict(int),
            'event_counts': defaultdict(int),
            'relationship_counts': defaultdict(int),
            'timeline': {
                'first_event': None,
                'last_event': None,
                'duration_days': None
            }
        }

        # Count by type
        for entity in self.entities.values():
            stats['entity_counts'][entity['type']] += 1

        for event in self.events:
            stats['event_counts'][event['type']] += 1

        for rel in self.relationships:
            stats['relationship_counts'][rel['type']] += 1

        # Timeline
        if self.timeline:
            sorted_timeline = sorted(self.timeline, key=lambda x: x['date'])
            stats['timeline']['first_event'] = sorted_timeline[0]['date']
            stats['timeline']['last_event'] = sorted_timeline[-1]['date']

            # Calculate duration
            first_date = datetime.strptime(sorted_timeline[0]['date'], '%Y-%m-%d %H:%M')
            last_date = datetime.strptime(sorted_timeline[-1]['date'], '%Y-%m-%d %H:%M')
            stats['timeline']['duration_days'] = (last_date - first_date).days

        return stats

    def export_knowledge_base(self, output_dir):
        """Export complete knowledge base."""
        os.makedirs(output_dir, exist_ok=True)

        # 1. Full graph (JSON)
        graph = {
            'metadata': {
                'generated': datetime.now().isoformat(),
                'source': 'Email facts analysis',
                'case': 'Huwelijksaanvraag Gemeente Meppel'
            },
            'entities': self.entities,
            'events': self.events,
            'relationships': self.relationships,
            'statistics': self.build_statistics()
        }

        with open(os.path.join(output_dir, 'knowledge_graph.json'), 'w', encoding='utf-8') as f:
            json.dump(graph, f, indent=2, ensure_ascii=False)

        # 2. Timeline (JSON + Markdown)
        sorted_timeline = sorted(self.timeline, key=lambda x: x['date'])

        with open(os.path.join(output_dir, 'timeline.json'), 'w', encoding='utf-8') as f:
            json.dump(sorted_timeline, f, indent=2, ensure_ascii=False)

        self._export_timeline_markdown(sorted_timeline, output_dir)

        # 3. Entity index (JSON + Markdown)
        self._export_entity_index(output_dir)

        # 4. Network analysis (JSON + Markdown)
        self._export_network_analysis(output_dir)

        # 5. Document tracker (JSON + Markdown)
        self._export_document_tracker(output_dir)

        # 6. GraphML (for visualization tools like Gephi/Cytoscape)
        self._export_graphml(output_dir)

        return graph

    def _export_timeline_markdown(self, timeline, output_dir):
        """Export timeline as markdown."""
        with open(os.path.join(output_dir, 'TIMELINE.md'), 'w', encoding='utf-8') as f:
            f.write("# CHRONOLOGISCHE TIJDLIJN - HUWELIJKSAANVRAAG\n\n")
            f.write(f"Gegenereerd: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n")

            current_period = None

            for item in timeline:
                date_obj = datetime.strptime(item['date'], '%Y-%m-%d %H:%M')
                period = date_obj.strftime('%Y-%m')

                if period != current_period:
                    f.write(f"\n## {date_obj.strftime('%B %Y').upper()}\n\n")
                    current_period = period

                event = next((e for e in self.events if e['id'] == item['event_id']), None)

                f.write(f"**{date_obj.strftime('%d %b %Y %H:%M')}** - {item['type'].replace('_', ' ').title()}\n")
                f.write(f"- {item['description']}\n")

                if event:
                    participants = [self.entities.get(p, {}).get('name', 'Unknown') for p in event.get('participants', [])]
                    if participants:
                        f.write(f"- Betrokkenen: {', '.join(participants)}\n")

                    if event.get('documents'):
                        docs = [self.entities.get(d, {}).get('name', 'Unknown') for d in event['documents']]
                        f.write(f"- Documenten: {', '.join(docs)}\n")

                f.write("\n")

    def _export_entity_index(self, output_dir):
        """Export entity index."""
        # Group by type
        by_type = defaultdict(list)
        for entity in self.entities.values():
            by_type[entity['type']].append(entity)

        # JSON
        with open(os.path.join(output_dir, 'entities.json'), 'w', encoding='utf-8') as f:
            json.dump(dict(by_type), f, indent=2, ensure_ascii=False)

        # Markdown
        with open(os.path.join(output_dir, 'ENTITIES.md'), 'w', encoding='utf-8') as f:
            f.write("# ENTITEITEN INDEX\n\n")

            for entity_type, entities in sorted(by_type.items()):
                f.write(f"## {entity_type.upper()} ({len(entities)})\n\n")

                for entity in sorted(entities, key=lambda e: e.get('name', '')):
                    f.write(f"### {entity['name']}\n")
                    f.write(f"- ID: `{entity['id']}`\n")

                    if entity.get('attributes'):
                        for key, value in entity['attributes'].items():
                            if value:
                                f.write(f"- {key}: {value}\n")

                    if entity.get('first_seen'):
                        f.write(f"- Eerste contact: {entity['first_seen']}\n")
                    if entity.get('last_seen'):
                        f.write(f"- Laatste contact: {entity['last_seen']}\n")

                    f.write("\n")

    def _export_network_analysis(self, output_dir):
        """Export network analysis."""
        # Communication network
        comm_network = defaultdict(lambda: defaultdict(int))

        for rel in self.relationships:
            if rel['type'] == 'sent_email':
                source_name = self.entities.get(rel['source'], {}).get('name', 'Unknown')
                target_name = self.entities.get(rel['target'], {}).get('name', 'Unknown')
                comm_network[source_name][target_name] += 1

        # JSON
        with open(os.path.join(output_dir, 'network_analysis.json'), 'w', encoding='utf-8') as f:
            json.dump({
                'communication_network': dict(comm_network),
                'relationship_summary': dict(defaultdict(int, {
                    rel['type']: sum(1 for r in self.relationships if r['type'] == rel['type'])
                    for rel in self.relationships
                }))
            }, f, indent=2, ensure_ascii=False)

        # Markdown
        with open(os.path.join(output_dir, 'NETWORK_ANALYSIS.md'), 'w', encoding='utf-8') as f:
            f.write("# NETWERK ANALYSE\n\n")
            f.write("## Communicatie Matrix\n\n")
            f.write("Aantal emails verstuurd:\n\n")

            for sender, targets in sorted(comm_network.items()):
                f.write(f"### {sender}\n")
                for target, count in sorted(targets.items(), key=lambda x: x[1], reverse=True):
                    f.write(f"- → {target}: {count} emails\n")
                f.write("\n")

    def _export_document_tracker(self, output_dir):
        """Export document status tracker."""
        docs = {eid: e for eid, e in self.entities.items() if e['type'] == 'document'}

        # Track document lifecycle
        doc_lifecycle = {}
        for doc_id, doc in docs.items():
            doc_lifecycle[doc['name']] = {
                'requested': [],
                'denied': [],
                'received': [],
                'mentioned': []
            }

            for rel in self.relationships:
                if rel['target'] == doc_id:
                    event_id = rel['attributes'].get('event_id')
                    event = next((e for e in self.events if e['id'] == event_id), None)

                    if event:
                        entry = {
                            'date': rel.get('date'),
                            'by': self.entities.get(rel['source'], {}).get('name', 'Unknown'),
                            'event': event.get('description')
                        }

                        if rel['type'] in doc_lifecycle[doc['name']]:
                            doc_lifecycle[doc['name']][rel['type']].append(entry)

        # JSON
        with open(os.path.join(output_dir, 'documents.json'), 'w', encoding='utf-8') as f:
            json.dump(doc_lifecycle, f, indent=2, ensure_ascii=False)

        # Markdown
        with open(os.path.join(output_dir, 'DOCUMENTS.md'), 'w', encoding='utf-8') as f:
            f.write("# DOCUMENTEN TRACKER\n\n")

            for doc_name, lifecycle in sorted(doc_lifecycle.items()):
                f.write(f"## {doc_name}\n\n")

                for action, entries in lifecycle.items():
                    if entries:
                        f.write(f"### {action.upper()}\n\n")
                        for entry in sorted(entries, key=lambda e: e.get('date', '')):
                            f.write(f"- **{entry.get('date')}** - {entry.get('by')}\n")
                            f.write(f"  - {entry.get('event')}\n")
                        f.write("\n")

    def _export_graphml(self, output_dir):
        """Export as GraphML for visualization tools."""
        graphml = ['<?xml version="1.0" encoding="UTF-8"?>']
        graphml.append('<graphml xmlns="http://graphml.graphdrawing.org/xmlns">')
        graphml.append('  <key id="label" for="node" attr.name="label" attr.type="string"/>')
        graphml.append('  <key id="type" for="node" attr.name="type" attr.type="string"/>')
        graphml.append('  <key id="date" for="edge" attr.name="date" attr.type="string"/>')
        graphml.append('  <key id="relationship" for="edge" attr.name="relationship" attr.type="string"/>')
        graphml.append('  <graph id="G" edgedefault="directed">')

        # Nodes
        for entity_id, entity in self.entities.items():
            graphml.append(f'    <node id="{entity_id}">')
            graphml.append(f'      <data key="label">{entity["name"]}</data>')
            graphml.append(f'      <data key="type">{entity["type"]}</data>')
            graphml.append('    </node>')

        # Edges
        for i, rel in enumerate(self.relationships):
            graphml.append(f'    <edge id="e{i}" source="{rel["source"]}" target="{rel["target"]}">')
            graphml.append(f'      <data key="relationship">{rel["type"]}</data>')
            if rel.get('date'):
                graphml.append(f'      <data key="date">{rel["date"]}</data>')
            graphml.append('    </edge>')

        graphml.append('  </graph>')
        graphml.append('</graphml>')

        with open(os.path.join(output_dir, 'knowledge_graph.graphml'), 'w', encoding='utf-8') as f:
            f.write('\n'.join(graphml))


def main():
    """Main execution."""
    facts_dir = r'E:\projects\huwelijksaanvraag\feiten'
    output_dir = r'E:\projects\huwelijksaanvraag\knowledgebase'

    print("Building knowledge graph from facts...")
    print()

    builder = KnowledgeGraphBuilder()

    # Read all fact files
    fact_files = sorted(Path(facts_dir).glob('*_feiten.txt'))

    total_facts = 0

    for fact_file in fact_files:
        print(f"Processing {fact_file.name}...")

        with open(fact_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Split into individual facts
        fact_pattern = r'={80}\nDATUM:.*?(?=\n={80}\n(?:DATUM:|$))'
        facts = re.findall(fact_pattern, content, re.DOTALL)

        for fact in facts:
            builder.parse_fact_entry(fact, fact_file.name)
            total_facts += 1

    print()
    print(f"Processed {total_facts} facts from {len(fact_files)} files")
    print()

    # Export knowledge base
    print("Exporting knowledge base...")
    graph = builder.export_knowledge_base(output_dir)

    stats = graph['statistics']

    print()
    print("="*80)
    print("KNOWLEDGE BASE STATISTICS")
    print("="*80)
    print(f"Total Entities: {stats['total_entities']}")
    for entity_type, count in sorted(stats['entity_counts'].items()):
        print(f"  - {entity_type}: {count}")
    print()
    print(f"Total Events: {stats['total_events']}")
    for event_type, count in sorted(stats['event_counts'].items()):
        print(f"  - {event_type}: {count}")
    print()
    print(f"Total Relationships: {stats['total_relationships']}")
    for rel_type, count in sorted(stats['relationship_counts'].items()):
        print(f"  - {rel_type}: {count}")
    print()
    print("Timeline:")
    print(f"  First event: {stats['timeline']['first_event']}")
    print(f"  Last event: {stats['timeline']['last_event']}")
    print(f"  Duration: {stats['timeline']['duration_days']} days")
    print()

    print("="*80)
    print("FILES CREATED")
    print("="*80)
    print(f"1. knowledge_graph.json - Complete semantic graph")
    print(f"2. knowledge_graph.graphml - Graph visualization format")
    print(f"3. timeline.json - Chronological event data")
    print(f"4. TIMELINE.md - Human-readable timeline")
    print(f"5. entities.json - Entity database")
    print(f"6. ENTITIES.md - Entity index")
    print(f"7. network_analysis.json - Communication network data")
    print(f"8. NETWORK_ANALYSIS.md - Network analysis report")
    print(f"9. documents.json - Document lifecycle data")
    print(f"10. DOCUMENTS.md - Document tracker")
    print()
    print(f"Knowledge base saved to: {output_dir}")
    print()
    print("Done!")

if __name__ == '__main__':
    main()
