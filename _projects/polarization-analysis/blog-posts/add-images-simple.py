#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Add floating images to posts - simpler approach (insert after first paragraph)
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

# Additional images to insert (using already uploaded URLs)
additional_images = [
    {
        "post_id": 2111,  # How Social Media Gave Us NPD
        "image_url": "https://martiendejong.nl/wp-content/uploads/2026/02/social-media-feedback-loop.png",
        "caption": "The social media addiction feedback loop",
        "align": "right",
        "paragraph": 3  # Insert after 3rd paragraph
    },
    {
        "post_id": 2112,  # Eight Feedback Loops
        "image_url": "https://martiendejong.nl/wp-content/uploads/2026/02/tribal-brain.png",
        "caption": "Tribal thinking reinforcement",
        "align": "left",
        "paragraph": 2
    },
    {
        "post_id": 2114,  # Three-Layer Solution
        "image_url": "https://martiendejong.nl/wp-content/uploads/2026/02/wellbeing-vs-engagement.png",
        "caption": "Wellbeing vs engagement optimization",
        "align": "right",
        "paragraph": 3
    },
    {
        "post_id": 2118,  # The App
        "image_url": "https://martiendejong.nl/wp-content/uploads/2026/02/depolarization-progress.png",
        "caption": "Measurable depolarization progress",
        "align": "left",
        "paragraph": 2
    },
]

def insert_after_paragraph(content, image_url, paragraph_num, align, caption):
    """Insert image after Nth paragraph"""

    img_html = f'''
<figure class="wp-block-image align{align}" style="float:{align}; margin: {'0 0 20px 20px' if align == 'right' else '0 20px 20px 0'}; max-width: 450px;">
    <img src="{image_url}" alt="{caption}" style="width: 100%; height: auto; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    {f'<figcaption style="font-size: 0.85em; color: #666; margin-top: 8px; font-style: italic;">{caption}</figcaption>' if caption else ''}
</figure>
'''

    # Find all paragraph closing tags
    paragraphs = re.finditer(r'</p>', content)
    positions = [m.end() for m in paragraphs]

    if len(positions) >= paragraph_num:
        insert_pos = positions[paragraph_num - 1]
        content = content[:insert_pos] + '\n' + img_html + '\n' + content[insert_pos:]

    return content

print("=" * 60)
print("Adding Additional Floating Images")
print("=" * 60)
print()

success_count = 0

for item in additional_images:
    post_id = item["post_id"]

    # Get current post
    response = requests.get(f"{WP_API_URL}/posts/{post_id}", headers=headers)
    if response.status_code != 200:
        print(f"[{post_id}] ❌ Failed to fetch")
        continue

    post_data = response.json()
    content = post_data['content']['rendered']

    # Check if image already exists in content
    if item["image_url"] in content:
        print(f"[{post_id}] {post_data['title']['rendered']}")
        print(f"  ⏭️  Image already present")
        continue

    print(f"[{post_id}] {post_data['title']['rendered']}")

    # Insert image
    new_content = insert_after_paragraph(
        content,
        item["image_url"],
        item["paragraph"],
        item["align"],
        item.get("caption", "")
    )

    if new_content != content:
        # Update post
        update_response = requests.post(
            f"{WP_API_URL}/posts/{post_id}",
            json={'content': new_content},
            headers=headers
        )

        if update_response.status_code == 200:
            print(f"  ✅ Image inserted after paragraph {item['paragraph']}")
            success_count += 1
        else:
            print(f"  ❌ Update failed: {update_response.status_code}")
    else:
        print(f"  ⚠️  No insertion occurred")

print()
print("=" * 60)
print("COMPLETE")
print("=" * 60)
print(f"✅ Images added: {success_count}")
print("=" * 60)
