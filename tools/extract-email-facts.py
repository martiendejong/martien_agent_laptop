#!/usr/bin/env python3
"""
Extract facts from emails for legal documentation.
Anti-hallucination protocol: EXACT quotes only, NO interpretations.
"""

import os
import re
import email
from email import policy
from email.parser import BytesParser
from datetime import datetime
from pathlib import Path
from collections import defaultdict
import shutil

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

    # Extract body (prefer plain text, fallback to HTML)
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
    """
    Strip reply chain from email body.
    Keep ONLY the new message, remove quoted previous emails.
    """
    if not body:
        return ""

    # Common reply indicators
    reply_patterns = [
        r'^[\s]*On .+ wrote:',  # "On Mon, 25 Feb 2026, X wrote:"
        r'^[\s]*Van:',  # "Van: Name <email>"
        r'^[\s]*From:',  # "From: Name <email>"
        r'^[\s]*-----Original Message-----',
        r'^[\s]*>+',  # Quoted lines starting with >
        r'^[\s]*_{5,}',  # Horizontal line separators
        r'^[\s]*Sent:',  # Outlook-style headers
        r'^[\s]*Verzonden:',  # Dutch Outlook
        r'^[\s]*Date:',
        r'^[\s]*Subject:',
        r'^[\s]*Onderwerp:',
    ]

    lines = body.split('\n')
    new_message_lines = []
    in_reply = False

    for line in lines:
        # Check if this line starts a reply chain
        is_reply_start = any(re.match(pattern, line, re.IGNORECASE) for pattern in reply_patterns)

        if is_reply_start:
            in_reply = True
            break  # Stop at first reply indicator

        if not in_reply:
            new_message_lines.append(line)

    # Clean up: remove excessive blank lines
    result = '\n'.join(new_message_lines).strip()

    # Remove multiple consecutive blank lines
    result = re.sub(r'\n{3,}', '\n\n', result)

    return result

def is_relevant_fact(email_data):
    """
    Determine if email contains a relevant fact.

    Relevant = substantive information (not just "OK" or "Thanks")
    """
    body = email_data.get('body', '').strip()
    subject = email_data.get('subject', '').strip()

    # Skip if no body
    if not body or len(body) < 20:
        return False

    # Skip automated messages
    automated_indicators = [
        'automatisch antwoord',
        'automatic reply',
        'out of office',
        'buiten kantoor',
        'ontvangstbevestiging',
        'delivery status notification',
    ]

    if any(indicator in subject.lower() for indicator in automated_indicators):
        return False

    # Skip very short messages (likely just "OK", "Thanks", etc)
    if len(body) < 50:
        # Check if it's just pleasantries
        trivial_patterns = [
            r'^\s*(ok|bedankt|thanks|dank|groet)\s*$',
            r'^\s*(mvg|met vriendelijke groet)\s*$',
        ]
        if any(re.match(pattern, body, re.IGNORECASE | re.DOTALL) for pattern in trivial_patterns):
            return False

    return True

def extract_fact(email_data):
    """
    Extract fact from email.
    Returns dict with structured fact information.
    """
    # Strip reply chain to get only new content
    new_content = strip_reply_chain(email_data['body'])

    if not new_content or len(new_content.strip()) < 20:
        return None

    return {
        'date': email_data['date'],
        'subject': email_data['subject'],
        'from': email_data['from'],
        'to': email_data['to'],
        'content': new_content,
        'source_file': email_data['filename']
    }

def get_period_key(date_obj):
    """Get period key (YYYY-MM) for grouping facts."""
    if not date_obj:
        return 'unknown'
    return date_obj.strftime('%Y-%m')

def format_fact_entry(fact):
    """Format fact as text entry with exact quotes and source."""
    if not fact:
        return ""

    date_str = fact['date'].strftime('%Y-%m-%d %H:%M') if fact['date'] else 'Onbekende datum'

    # Create fact entry
    entry = f"""
{'='*80}
DATUM: {date_str}
VAN: {fact['from']}
AAN: {fact['to']}
ONDERWERP: {fact['subject']}
BRON: {fact['source_file']}
{'='*80}

{fact['content']}

"""
    return entry

def copy_pdf_with_prefix(pdf_path, output_dir):
    """Copy PDF document with date prefix."""
    filename = os.path.basename(pdf_path)

    # Get file modification time as fallback for date
    mtime = os.path.getmtime(pdf_path)
    date_obj = datetime.fromtimestamp(mtime)

    # Create prefix: yy_mm_dd_
    prefix = date_obj.strftime('%y_%m_%d_')

    # Check if already has prefix
    if re.match(r'^\d{2}_\d{2}_\d{2}_', filename):
        new_filename = filename
    else:
        new_filename = prefix + filename

    # Copy to output directory
    output_path = os.path.join(output_dir, new_filename)
    shutil.copy2(pdf_path, output_path)

    return new_filename

def main():
    """Main execution."""
    # Paths
    email_dir = r'E:\projects\huwelijksaanvraag\emails\TOTAAL'
    output_dir = r'E:\projects\huwelijksaanvraag\feiten'

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)

    # Find all EML files
    eml_files = sorted(Path(email_dir).glob('*.eml'))

    print(f"Found {len(eml_files)} EML files")
    print(f"Output directory: {output_dir}")
    print()

    # Process emails and group by period
    facts_by_period = defaultdict(list)
    processed = 0
    skipped = 0

    for eml_path in eml_files:
        try:
            # Parse email
            email_data = parse_eml_file(str(eml_path))

            # Check if relevant
            if not is_relevant_fact(email_data):
                skipped += 1
                print(f"[SKIP] {email_data['filename']} - niet relevant")
                continue

            # Extract fact
            fact = extract_fact(email_data)

            if fact:
                period = get_period_key(fact['date'])
                facts_by_period[period].append(fact)
                processed += 1
                print(f"[OK] {email_data['filename']} -> {period}")
            else:
                skipped += 1
                print(f"[SKIP] {email_data['filename']} - geen substantiële inhoud na strippen")

        except Exception as e:
            print(f"[ERROR] {eml_path.name}: {e}")
            skipped += 1

    print()
    print(f"Processed: {processed}")
    print(f"Skipped: {skipped}")
    print()

    # Write facts to period files
    for period in sorted(facts_by_period.keys()):
        facts = facts_by_period[period]

        # Sort facts by date within period
        facts.sort(key=lambda f: f['date'] if f['date'] else datetime.min)

        # Create filename: YYYY-MM_feiten.txt
        output_filename = f"{period}_feiten.txt"
        output_path = os.path.join(output_dir, output_filename)

        # Write facts
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(f"FEITEN - PERIODE {period}\n")
            f.write(f"Gegenereerd: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
            f.write(f"Aantal feiten: {len(facts)}\n")
            f.write(f"\n{'='*80}\n")

            for fact in facts:
                f.write(format_fact_entry(fact))

        print(f"Created: {output_filename} ({len(facts)} feiten)")

    # Copy PDF documents with prefix
    print()
    print("Processing PDF documents...")
    pdf_files = list(Path(email_dir).glob('*.pdf'))

    for pdf_path in pdf_files:
        try:
            new_filename = copy_pdf_with_prefix(str(pdf_path), output_dir)
            print(f"[OK] {pdf_path.name} -> {new_filename}")
        except Exception as e:
            print(f"[ERROR] {pdf_path.name}: {e}")

    print()
    print(f"Total PDF files copied: {len(pdf_files)}")
    print()
    print("Done!")

if __name__ == '__main__':
    main()
