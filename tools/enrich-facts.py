#!/usr/bin/env python3
"""
Enrich facts with missing context and add missing emails.
Based on verification report, adds context to incomplete facts.
"""

import os
import re
import email
from email import policy
from email.parser import BytesParser
from pathlib import Path
from datetime import datetime
from collections import defaultdict

def parse_eml_file(eml_path):
    """Parse an EML file and extract headers + body."""
    with open(eml_path, 'rb') as f:
        msg = BytesParser(policy=policy.default).parse(f)

    # Extract headers
    date_str = msg.get('Date', '')
    subject = msg.get('Subject', '')
    from_addr = msg.get('From', '')
    to_addr = msg.get('To', '')

    # Parse date
    try:
        if date_str:
            date_obj = email.utils.parsedate_to_datetime(date_str)
        else:
            date_obj = None
    except:
        date_obj = None

    # Extract FULL body (including reply chain for context extraction)
    body = ""
    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            if content_type == 'text/plain':
                try:
                    body = part.get_content()
                    break
                except:
                    pass
            elif content_type == 'text/html' and not body:
                try:
                    html = part.get_content()
                    # Strip HTML tags (basic)
                    body = re.sub(r'<[^>]+>', '', html)
                except:
                    pass
    else:
        try:
            body = msg.get_content()
        except:
            body = ""

    return {
        'date': date_obj,
        'subject': subject,
        'from': from_addr,
        'to': to_addr,
        'body': body,
        'filename': os.path.basename(eml_path)
    }

def strip_reply_chain(body):
    """Strip reply chain but preserve enough for context."""
    if not body:
        return ""

    # Common reply indicators
    reply_patterns = [
        r'^[\s]*On .+ wrote:',
        r'^[\s]*Van:',
        r'^[\s]*From:',
        r'^[\s]*-----Original Message-----',
        r'^[\s]*>+',
        r'^[\s]*_{5,}',
        r'^[\s]*Sent:',
        r'^[\s]*Verzonden:',
        r'^[\s]*Date:',
        r'^[\s]*Subject:',
        r'^[\s]*Onderwerp:',
    ]

    lines = body.split('\n')
    new_message_lines = []
    in_reply = False

    for line in lines:
        is_reply_start = any(re.match(pattern, line, re.IGNORECASE) for pattern in reply_patterns)

        if is_reply_start:
            in_reply = True
            break

        if not in_reply:
            new_message_lines.append(line)

    result = '\n'.join(new_message_lines).strip()
    result = re.sub(r'\n{3,}', '\n\n', result)

    return result

def extract_appointment_context(email_data):
    """Extract context for appointments from full email body."""
    body = email_data['body']
    subject = email_data['subject']

    contexts = []

    # Look for appointment purpose in body or subject
    purpose_keywords = {
        'huwelijk': 'Afspraak m.b.t. huwelijk/trouwen',
        'trouwen': 'Afspraak m.b.t. huwelijk/trouwen',
        'marriage': 'Afspraak m.b.t. huwelijk/trouwen',
        'verklaring huwelijksbevoegdheid': 'Afspraak m.b.t. verklaring van huwelijksbevoegdheid',
        'certificate of no impediment': 'Afspraak m.b.t. Certificate of No Impediment',
        'legalisatie': 'Afspraak m.b.t. legalisatie documenten',
        'documenten overleggen': 'Afspraak voor overleggen documenten',
        'intakegesprek': 'Intakegesprek',
        'burgerzaken': 'Afspraak bij Burgerzaken',
    }

    body_lower = body.lower()
    subject_lower = subject.lower()

    for keyword, description in purpose_keywords.items():
        if keyword in body_lower or keyword in subject_lower:
            if description not in contexts:
                contexts.append(description)

    # Extract date/time from body
    # Look for patterns like "11 januari 2024" or "11-01-2024"
    date_patterns = [
        r'\b(\d{1,2}\s+(?:januari|februari|maart|april|mei|juni|juli|augustus|september|oktober|november|december)\s+\d{4})\b',
        r'\b(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})\b'
    ]

    for pattern in date_patterns:
        match = re.search(pattern, body, re.IGNORECASE)
        if match:
            contexts.append(f"Datum afspraak: {match.group(1)}")
            break

    # Extract time
    time_match = re.search(r'\b(\d{1,2}:\d{2})\b', body)
    if time_match:
        contexts.append(f"Tijd: {time_match.group(1)}")

    # If no context found, use subject as fallback
    if not contexts:
        contexts.append(f"Doel: zie onderwerp '{subject}'")

    return contexts

def extract_request_context(email_data):
    """Extract context for requests."""
    body = email_data['body']
    subject = email_data['subject']

    contexts = []

    # Key documents/topics
    document_keywords = {
        'verklaring van huwelijksbevoegdheid': 'Verklaring van huwelijksbevoegdheid',
        'certificate of no impediment': 'Certificate of No Impediment',
        'geboortecertificaat': 'Geboortecertificaat',
        'birth certificate': 'Birth Certificate',
        'burgerlijke staat': 'Verklaring burgerlijke staat',
        'legalisatie': 'Legalisatie buitenlandse documenten',
        'apostille': 'Apostille/legalisatie',
    }

    body_lower = body.lower()

    for keyword, description in document_keywords.items():
        if keyword in body_lower:
            if description not in contexts:
                contexts.append(description)

    # Countries
    if 'kenia' in body_lower or 'kenya' in body_lower:
        contexts.append('Huwelijk in Kenia')
    if 'nederland' in body_lower:
        contexts.append('Huwelijk in Nederland')

    return contexts

def create_enriched_fact(email_data, context_info):
    """Create enriched fact entry with context."""
    new_content = strip_reply_chain(email_data['body'])

    date_str = email_data['date'].strftime('%Y-%m-%d %H:%M') if email_data['date'] else 'Onbekende datum'

    # Build context note
    context_note = ""
    if context_info:
        context_note = "\n[CONTEXT: " + " | ".join(context_info) + "]\n"

    entry = f"""
{'='*80}
DATUM: {date_str}
VAN: {email_data['from']}
AAN: {email_data['to']}
ONDERWERP: {email_data['subject']}
BRON: {email_data['filename']}
{'='*80}
{context_note}
{new_content}

"""
    return entry

def get_period_key(date_obj):
    """Get period key (YYYY-MM) for grouping facts."""
    if not date_obj:
        return 'unknown'
    return date_obj.strftime('%Y-%m')

def main():
    """Main execution."""
    email_dir = r'E:\projects\huwelijksaanvraag\emails\TOTAAL'
    facts_dir = r'E:\projects\huwelijksaanvraag\feiten'
    backup_dir = os.path.join(facts_dir, 'backup')

    # Create backup directory
    os.makedirs(backup_dir, exist_ok=True)

    # Backup existing fact files
    print("Creating backup of existing fact files...")
    fact_files = list(Path(facts_dir).glob('*_feiten.txt'))
    for fact_file in fact_files:
        backup_path = os.path.join(backup_dir, fact_file.name + '.backup')
        import shutil
        shutil.copy2(fact_file, backup_path)
    print(f"Backed up {len(fact_files)} files to {backup_dir}")
    print()

    # Read verification report to find issues
    report_path = os.path.join(facts_dir, 'VERIFICATIE_RAPPORT.txt')

    files_needing_enrichment = set()
    files_not_in_facts = set()

    if os.path.exists(report_path):
        with open(report_path, 'r', encoding='utf-8') as f:
            content = f.read()

            # Extract filenames with issues
            for match in re.finditer(r'BESTAND: (.+?\.eml)', content):
                files_needing_enrichment.add(match.group(1))

            # Extract filenames not in facts
            for match in re.finditer(r'\[NOT_IN_FACTS\] (.+?\.eml)', content):
                files_not_in_facts.add(match.group(1))

    print(f"Files needing enrichment: {len(files_needing_enrichment)}")
    print(f"Files not in facts: {len(files_not_in_facts)}")
    print()

    # Process all emails
    eml_files = sorted(Path(email_dir).glob('*.eml'))

    enriched_facts = defaultdict(list)
    stats = {
        'enriched': 0,
        'added': 0,
        'skipped': 0
    }

    for eml_path in eml_files:
        try:
            email_data = parse_eml_file(str(eml_path))
            filename = email_data['filename']

            # Determine if we need to process this email
            needs_processing = (
                filename in files_needing_enrichment or
                filename in files_not_in_facts
            )

            if not needs_processing:
                stats['skipped'] += 1
                continue

            # Extract context based on email type
            context_info = []

            subject_lower = email_data['subject'].lower()

            # Appointments
            if 'afspraak' in subject_lower or 'appointment' in subject_lower:
                context_info.extend(extract_appointment_context(email_data))

            # Requests
            if 'verzoek' in subject_lower or 'aanvraag' in subject_lower or 'request' in subject_lower:
                context_info.extend(extract_request_context(email_data))

            # General context
            if not context_info:
                context_info.extend(extract_request_context(email_data))

            # Create enriched fact
            enriched_fact = create_enriched_fact(email_data, context_info)

            period = get_period_key(email_data['date'])
            enriched_facts[period].append({
                'date': email_data['date'],
                'entry': enriched_fact,
                'filename': filename
            })

            if filename in files_not_in_facts:
                stats['added'] += 1
                print(f"[ADDED] {filename} -> {period}")
            else:
                stats['enriched'] += 1
                print(f"[ENRICHED] {filename} -> {period}")

        except Exception as e:
            print(f"[ERROR] {eml_path.name}: {e}")
            stats['skipped'] += 1

    print()
    print(f"Enriched: {stats['enriched']}")
    print(f"Added: {stats['added']}")
    print(f"Skipped: {stats['skipped']}")
    print()

    # Merge with existing facts
    print("Merging enriched facts with existing fact files...")

    for period in sorted(enriched_facts.keys()):
        fact_file_path = os.path.join(facts_dir, f"{period}_feiten.txt")

        # Read existing content
        existing_facts = {}
        if os.path.exists(fact_file_path):
            with open(fact_file_path, 'r', encoding='utf-8') as f:
                content = f.read()

                # Extract existing facts by source filename
                pattern = r'BRON: (.+?\.eml)\n={80}\n(.*?)(?=\n={80}\n|$)'
                for match in re.finditer(pattern, content, re.DOTALL):
                    source_file = match.group(1)
                    fact_content = match.group(2)
                    existing_facts[source_file] = fact_content

        # Combine with enriched facts
        all_facts = []

        # Add enriched/new facts
        for fact_data in enriched_facts[period]:
            all_facts.append(fact_data)

        # Sort by date
        all_facts.sort(key=lambda f: f['date'] if f['date'] else datetime.min)

        # Write updated fact file
        with open(fact_file_path, 'w', encoding='utf-8') as f:
            f.write(f"FEITEN - PERIODE {period}\n")
            f.write(f"Gegenereerd: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
            f.write(f"Aantal feiten: {len(all_facts)}\n")
            f.write(f"\n{'='*80}\n")

            for fact_data in all_facts:
                f.write(fact_data['entry'])

        print(f"Updated: {period}_feiten.txt ({len(all_facts)} feiten)")

    print()
    print("Enrichment complete!")
    print(f"Backup saved in: {backup_dir}")

if __name__ == '__main__':
    main()
