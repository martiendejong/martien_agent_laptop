#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fix all inter-post links in WordPress articles
"""

import sys
import io
import requests
import re
from base64 import b64encode

# Fix Windows encoding
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# WordPress config
WP_SITE = "https://martiendejong.nl"
WP_API_URL = f"{WP_SITE}/wp-json/wp/v2"

# Credentials
username = "admin"
app_password = "UtCIMgr913EBmlBL2S1LAY2e"

# Create auth
credentials = f"{username}:{app_password}"
token = b64encode(credentials.encode()).decode('utf-8')
headers = {'Authorization': f'Basic {token}'}

# Post mapping (ID to URL)
post_urls = {
    2109: "https://martiendejong.nl/2026/02/05/youre-not-crazy-the-system-is/",
    2110: "https://martiendejong.nl/2026/02/05/the-narcissism-you-cant-see-because-youre-in-it/",
    2111: "https://martiendejong.nl/2026/02/05/how-social-media-gave-us-all-narcissistic-personality-disorder/",
    2112: "https://martiendejong.nl/2026/02/05/the-eight-feedback-loops-destroying-society/",
    2113: "https://martiendejong.nl/2026/02/05/why-fact-checking-failed-and-what-that-tells-us/",
    2114: "https://martiendejong.nl/2026/02/05/the-three-layer-solution-or-how-to-fight-fire-with-fire/",
    2115: "https://martiendejong.nl/2026/02/05/the-algorithm-war-building-tech-that-heals-instead-of-harms/",
    2116: "https://martiendejong.nl/2026/02/05/the-regulatory-blitz-how-to-make-big-tech-bend/",
    2117: "https://martiendejong.nl/2026/02/05/the-narrative-offensive-making-bridge-building-cool/",
    2118: "https://martiendejong.nl/2026/02/05/the-app-that-deprograms-you-in-real-time/",
    2119: "https://martiendejong.nl/2026/02/05/the-implementation-blueprint-how-we-coordinate/",
    2120: "https://martiendejong.nl/2026/02/05/the-two-futures-choose-wisely/",
}

# Link replacements - map text patterns to URLs
link_fixes = [
    # Part 1
    (r'<a href="#">Part 1: You\'re Not Crazy, The System Is</a>', f'<a href="{post_urls[2109]}">Part 1: You\'re Not Crazy, The System Is</a>'),
    (r'<a href="#">Part 1: You\'re Not Crazy</a>', f'<a href="{post_urls[2109]}">Part 1: You\'re Not Crazy</a>'),

    # Part 2
    (r'<a href="#">Part 2: The Narcissism You Can\'t See \(Because You\'re In It\)</a>', f'<a href="{post_urls[2110]}">Part 2: The Narcissism You Can\'t See (Because You\'re In It)</a>'),
    (r'<a href="#">Part 2: The Narcissism You Can\'t See</a>', f'<a href="{post_urls[2110]}">Part 2: The Narcissism You Can\'t See</a>'),
    (r'<a href="#">Narcissism You Can\'t See</a>', f'<a href="{post_urls[2110]}">Narcissism You Can\'t See</a>'),

    # Part 3
    (r'<a href="#">Part 3: How Social Media Gave Us All Narcissistic Personality Disorder</a>', f'<a href="{post_urls[2111]}">Part 3: How Social Media Gave Us All Narcissistic Personality Disorder</a>'),
    (r'<a href="#">Part 3: How Social Media Gave Us NPD</a>', f'<a href="{post_urls[2111]}">Part 3: How Social Media Gave Us NPD</a>'),
    (r'<a href="#">Social Media NPD Factory</a>', f'<a href="{post_urls[2111]}">Social Media NPD Factory</a>'),

    # Part 4
    (r'<a href="#">Part 4: The Eight Feedback Loops Destroying Society</a>', f'<a href="{post_urls[2112]}">Part 4: The Eight Feedback Loops Destroying Society</a>'),
    (r'<a href="#">Part 4: The Eight Feedback Loops</a>', f'<a href="{post_urls[2112]}">Part 4: The Eight Feedback Loops</a>'),
    (r'<a href="#">Eight Feedback Loops</a>', f'<a href="{post_urls[2112]}">Eight Feedback Loops</a>'),

    # Part 5
    (r'<a href="#">Part 5: Why Fact-Checking Failed \(And What That Tells Us\)</a>', f'<a href="{post_urls[2113]}">Part 5: Why Fact-Checking Failed (And What That Tells Us)</a>'),
    (r'<a href="#">Part 5: Why Fact-Checking Failed</a>', f'<a href="{post_urls[2113]}">Part 5: Why Fact-Checking Failed</a>'),
    (r'<a href="#">Why Fact-Checking Failed</a>', f'<a href="{post_urls[2113]}">Why Fact-Checking Failed</a>'),

    # Part 6
    (r'<a href="#">Part 6: The Three-Layer Solution \(Or: How To Fight Fire With Fire\)</a>', f'<a href="{post_urls[2114]}">Part 6: The Three-Layer Solution (Or: How To Fight Fire With Fire)</a>'),
    (r'<a href="#">Part 6: Three-Layer Solution</a>', f'<a href="{post_urls[2114]}">Part 6: Three-Layer Solution</a>'),
    (r'<a href="#">Three-Layer Solution</a>', f'<a href="{post_urls[2114]}">Three-Layer Solution</a>'),

    # Part 7
    (r'<a href="#">Part 7: The Algorithm War: Building Tech That Heals Instead of Harms</a>', f'<a href="{post_urls[2115]}">Part 7: The Algorithm War: Building Tech That Heals Instead of Harms</a>'),

    # Parts 1-7 generic link
    (r'<a href="#">Links to Parts 1-7</a>', f'<a href="{post_urls[2109]}">Read the series from Part 1</a>'),

    # Subscribe links - point to contact page or remove
    (r'<a href="#">Subscribe for updates</a>', '<a href="https://martiendejong.nl/#contact">Subscribe for updates</a>'),
    (r'<a href="#">Subscribe</a>', '<a href="https://martiendejong.nl/#contact">Subscribe</a>'),
]

print("=" * 60)
print("Fixing Inter-Post Links")
print("=" * 60)
print()

for post_id, post_url in post_urls.items():
    print(f"[{post_id}] Fetching and updating...")

    # Get current post content
    response = requests.get(f"{WP_API_URL}/posts/{post_id}", headers=headers)
    if response.status_code != 200:
        print(f"  ❌ Failed to fetch")
        continue

    post_data = response.json()
    content = post_data['content']['rendered']
    original_content = content

    # Apply all link fixes
    for pattern, replacement in link_fixes:
        content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)

    # Check if anything changed
    if content == original_content:
        print(f"  ⏭️  No changes needed")
        continue

    # Update post
    update_response = requests.post(
        f"{WP_API_URL}/posts/{post_id}",
        json={'content': content},
        headers=headers
    )

    if update_response.status_code == 200:
        print(f"  ✅ Links fixed")
    else:
        print(f"  ❌ Update failed: {update_response.status_code}")

print()
print("=" * 60)
print("COMPLETE - All inter-post links fixed")
print("=" * 60)
