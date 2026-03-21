#!/usr/bin/env python3
"""
Verify that all emails are properly represented in facts with full context.
Checks for missing context (e.g., appointments without stating their purpose).
"""

import os
import re
import email
from email import policy
from email.parser import BytesParser
from pathlib import Path
from datetime import datetime

def parse_eml_file(eml_path):
    """Parse an EML file and extract headers + full body."""
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

    # Extract FULL body (including reply chain for context)
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

def find_fact_in_files(filename, facts_dir):
    """Find if email is represented in facts files."""
    # Search all fact files
    fact_files = sorted(Path(facts_dir).glob('*_feiten.txt'))

    for fact_file in fact_files:
        with open(fact_file, 'r', encoding='utf-8') as f:
            content = f.read()
            if f"BRON: {filename}" in content:
                # Extract the fact entry
                pattern = f"={'{80}'}\nDATUM:.*?BRON: {re.escape(filename)}\n={'{80}'}\n\n(.*?)\n\n"
                match = re.search(pattern, content, re.DOTALL)
                if match:
                    return {
                        'found': True,
                        'file': fact_file.name,
                        'content': match.group(1).strip()
                    }

    return {'found': False}

def extract_context_from_subject(subject):
    """Extract context clues from subject line."""
    subject_lower = subject.lower()

    contexts = []

    # Appointment types
    if 'afspraak' in subject_lower or 'appointment' in subject_lower:
        contexts.append('AFSPRAAK')

    # Request types
    if 'verklaring' in subject_lower or 'certificate' in subject_lower:
        contexts.append('VERKLARING')
    if 'huwelijk' in subject_lower or 'trouwen' in subject_lower or 'marriage' in subject_lower:
        contexts.append('HUWELIJK')
    if 'legalisatie' in subject_lower or 'legalization' in subject_lower:
        contexts.append('LEGALISATIE')
    if 'geboortecertificaat' in subject_lower or 'birth certificate' in subject_lower:
        contexts.append('GEBOORTE')
    if 'burgerlijke staat' in subject_lower or 'civil status' in subject_lower:
        contexts.append('BURGERLIJKE_STAAT')
    if 'impediment' in subject_lower:
        contexts.append('NO_IMPEDIMENT')

    # Action types
    if 'aanvraag' in subject_lower or 'verzoek' in subject_lower or 'request' in subject_lower:
        contexts.append('AANVRAAG')
    if 'bevestiging' in subject_lower or 'confirmation' in subject_lower:
        contexts.append('BEVESTIGING')
    if 'herinnering' in subject_lower or 'reminder' in subject_lower:
        contexts.append('HERINNERING')
    if 'annulering' in subject_lower or 'wijziging' in subject_lower:
        contexts.append('WIJZIGING')
    if 'weigering' in subject_lower or 'refusal' in subject_lower:
        contexts.append('WEIGERING')
    if 'ingebrekestelling' in subject_lower:
        contexts.append('INGEBREKESTELLING')

    return contexts

def extract_context_from_body(body, subject):
    """Extract key context information from body."""
    contexts = []

    body_lower = body.lower()

    # Look for specific requests or statements
    if 'verklaring van huwelijksbevoegdheid' in body_lower:
        contexts.append('Verklaring van huwelijksbevoegdheid')
    if 'certificate of no impediment' in body_lower:
        contexts.append('Certificate of No Impediment')
    if 'geboortecertificaat' in body_lower:
        contexts.append('Geboortecertificaat')
    if 'burgerzaken' in body_lower:
        contexts.append('Burgerzaken')

    # Appointment purposes from body
    if 'intakegesprek' in body_lower:
        contexts.append('Intakegesprek')
    if 'documenten overleggen' in body_lower:
        contexts.append('Documenten overleggen')
    if 'legalisatie' in body_lower:
        contexts.append('Legalisatie documenten')

    # Extract date/time if mentioned
    date_pattern = r'\b(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})\b'
    time_pattern = r'\b(\d{1,2}:\d{2})\b'

    dates = re.findall(date_pattern, body)
    times = re.findall(time_pattern, body)

    if dates:
        contexts.append(f"Datum: {dates[0]}")
    if times:
        contexts.append(f"Tijd: {times[0]}")

    return contexts

def check_fact_completeness(email_data, fact_data):
    """Check if fact has sufficient context."""
    issues = []

    subject = email_data['subject']
    body = email_data['body']
    fact_content = fact_data.get('content', '') if fact_data.get('found') else ''

    # Get context from subject
    subject_contexts = extract_context_from_subject(subject)
    body_contexts = extract_context_from_body(body, subject)

    # Check if it's an appointment
    if 'AFSPRAAK' in subject_contexts or 'BEVESTIGING' in subject_contexts:
        # Check if purpose is mentioned in fact
        if not any(ctx in fact_content for ctx in [
            'huwelijk', 'trouwen', 'marriage',
            'verklaring', 'certificate',
            'legalisatie', 'documenten',
            'intakegesprek', 'burgerzaken'
        ]):
            # Try to find purpose in original email
            purpose_contexts = [c for c in body_contexts if c not in ['Datum:', 'Tijd:']]
            if purpose_contexts:
                issues.append({
                    'type': 'MISSING_CONTEXT',
                    'description': f'Afspraak zonder doel. Context uit email: {", ".join(purpose_contexts)}',
                    'suggested_addition': f'\n[CONTEXT: Afspraak betreft: {", ".join(purpose_contexts)}]'
                })
            else:
                issues.append({
                    'type': 'MISSING_CONTEXT',
                    'description': 'Afspraak zonder duidelijk doel',
                    'suggested_addition': f'\n[CONTEXT: Onderwerp: {subject}]'
                })

    # Check if it's a request without clear subject
    if 'AANVRAAG' in subject_contexts or 'verzoek' in subject.lower():
        if len(fact_content) < 100:  # Very short fact
            if body_contexts:
                issues.append({
                    'type': 'INSUFFICIENT_DETAIL',
                    'description': f'Verzoek te kort beschreven. Context: {", ".join(body_contexts)}',
                    'suggested_addition': f'\n[CONTEXT: {", ".join(body_contexts)}]'
                })

    # Check automated messages
    if 'ontvangstbevestiging' in subject.lower() or 'automatic' in body.lower():
        if fact_data.get('found'):
            issues.append({
                'type': 'AUTOMATED_MESSAGE',
                'description': 'Geautomatiseerd bericht in feiten (mogelijk niet relevant)',
                'suggested_addition': ''
            })

    return issues

def main():
    """Main execution."""
    email_dir = r'E:\projects\huwelijksaanvraag\emails\TOTAAL'
    facts_dir = r'E:\projects\huwelijksaanvraag\feiten'

    # Find all EML files
    eml_files = sorted(Path(email_dir).glob('*.eml'))

    print(f"Verifying {len(eml_files)} emails...")
    print()

    results = {
        'in_facts': 0,
        'not_in_facts': 0,
        'missing_context': 0,
        'insufficient_detail': 0,
        'automated': 0
    }

    issues_list = []

    for eml_path in eml_files:
        try:
            # Parse email
            email_data = parse_eml_file(str(eml_path))
            filename = email_data['filename']

            # Find in facts
            fact_data = find_fact_in_files(filename, facts_dir)

            if fact_data['found']:
                results['in_facts'] += 1

                # Check completeness
                issues = check_fact_completeness(email_data, fact_data)

                if issues:
                    for issue in issues:
                        if issue['type'] == 'MISSING_CONTEXT':
                            results['missing_context'] += 1
                        elif issue['type'] == 'INSUFFICIENT_DETAIL':
                            results['insufficient_detail'] += 1
                        elif issue['type'] == 'AUTOMATED_MESSAGE':
                            results['automated'] += 1

                        issues_list.append({
                            'filename': filename,
                            'subject': email_data['subject'],
                            'date': email_data['date'].strftime('%Y-%m-%d %H:%M') if email_data['date'] else 'Unknown',
                            'fact_file': fact_data['file'],
                            'issue': issue
                        })

                        print(f"[ISSUE] {filename}")
                        print(f"  Subject: {email_data['subject']}")
                        print(f"  Issue: {issue['description']}")
                        print(f"  Suggestie: {issue['suggested_addition']}")
                        print()
            else:
                results['not_in_facts'] += 1
                print(f"[NOT_IN_FACTS] {filename}")
                print(f"  Subject: {email_data['subject']}")
                print()

        except Exception as e:
            print(f"[ERROR] {eml_path.name}: {e}")
            print()

    # Summary
    print()
    print("="*80)
    print("SAMENVATTING")
    print("="*80)
    print(f"Totaal emails: {len(eml_files)}")
    print(f"In feiten: {results['in_facts']}")
    print(f"Niet in feiten: {results['not_in_facts']}")
    print()
    print("KWALITEITSISSUES:")
    print(f"  Missing context (afspraken zonder doel): {results['missing_context']}")
    print(f"  Insufficient detail (te weinig info): {results['insufficient_detail']}")
    print(f"  Automated messages (mogelijk niet relevant): {results['automated']}")
    print()

    # Generate report
    if issues_list:
        report_path = os.path.join(facts_dir, 'VERIFICATIE_RAPPORT.txt')
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("VERIFICATIERAPPORT FEITEN\n")
            f.write(f"Gegenereerd: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
            f.write("="*80 + "\n\n")

            f.write(f"Totaal geverifieerde emails: {len(eml_files)}\n")
            f.write(f"Emails in feiten: {results['in_facts']}\n")
            f.write(f"Emails niet in feiten: {results['not_in_facts']}\n\n")

            f.write("GEVONDEN ISSUES:\n")
            f.write(f"  - Missing context: {results['missing_context']}\n")
            f.write(f"  - Insufficient detail: {results['insufficient_detail']}\n")
            f.write(f"  - Automated messages: {results['automated']}\n\n")

            f.write("="*80 + "\n\n")

            for item in issues_list:
                f.write(f"BESTAND: {item['filename']}\n")
                f.write(f"DATUM: {item['date']}\n")
                f.write(f"ONDERWERP: {item['subject']}\n")
                f.write(f"FEITENBESTAND: {item['fact_file']}\n")
                f.write(f"PROBLEEM: {item['issue']['description']}\n")
                f.write(f"SUGGESTIE: {item['issue']['suggested_addition']}\n")
                f.write("\n" + "="*80 + "\n\n")

        print(f"Rapport opgeslagen: {report_path}")
        print()

    print("Verificatie compleet!")

if __name__ == '__main__':
    main()
