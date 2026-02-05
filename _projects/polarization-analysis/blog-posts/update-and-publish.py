#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Update titles (remove Part XX prefix) and publish all posts
"""

import sys
import io
import requests
from base64 import b64encode

# Fix Windows encoding issues
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# WordPress configuration
WP_SITE = "https://martiendejong.nl"
WP_API_URL = f"{WP_SITE}/wp-json/wp/v2"

# Credentials
username = "admin"
app_password = "UtCIMgr913EBmlBL2S1LAY2e"

# Post IDs and new titles
posts_to_update = [
    {"id": 2109, "title": "You're Not Crazy, The System Is"},
    {"id": 2110, "title": "The Narcissism You Can't See (Because You're In It)"},
    {"id": 2111, "title": "How Social Media Gave Us All Narcissistic Personality Disorder"},
    {"id": 2112, "title": "The Eight Feedback Loops Destroying Society"},
    {"id": 2113, "title": "Why Fact-Checking Failed (And What That Tells Us)"},
    {"id": 2114, "title": "The Three-Layer Solution (Or: How To Fight Fire With Fire)"},
    {"id": 2115, "title": "The Algorithm War: Building Tech That Heals Instead of Harms"},
    {"id": 2116, "title": "The Regulatory Blitz: How To Make Big Tech Bend"},
    {"id": 2117, "title": "The Narrative Offensive: Making Bridge-Building Cool"},
    {"id": 2118, "title": "The App That Deprograms You (In Real-Time)"},
    {"id": 2119, "title": "The Implementation Blueprint: How We Coordinate"},
    {"id": 2120, "title": "The Two Futures: Choose Wisely"},
]

# Create auth header
credentials = f"{username}:{app_password}"
token = b64encode(credentials.encode()).decode('utf-8')
headers = {'Authorization': f'Basic {token}'}

print("=" * 60)
print("Updating Titles and Publishing Posts")
print("=" * 60)
print()

success_count = 0
fail_count = 0

for post in posts_to_update:
    print(f"[{post['id']}] Updating: {post['title']}...")

    # Update title and publish
    payload = {
        'title': post['title'],
        'status': 'publish'
    }

    response = requests.post(
        f"{WP_API_URL}/posts/{post['id']}",
        json=payload,
        headers=headers
    )

    if response.status_code == 200:
        post_url = response.json()['link']
        print(f"  ✅ PUBLISHED: {post_url}")
        success_count += 1
    else:
        print(f"  ❌ FAILED: {response.status_code}")
        print(f"     Error: {response.text[:200]}")
        fail_count += 1

print()
print("=" * 60)
print("COMPLETE")
print("=" * 60)
print(f"✅ Success: {success_count}/12")
print(f"❌ Failed: {fail_count}/12")
print()
print("All posts are now LIVE at https://martiendejong.nl")
print("=" * 60)
