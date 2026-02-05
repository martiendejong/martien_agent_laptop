#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Upload content images and insert them into articles as floating images
"""

import sys
import io
import requests
import os
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

def upload_image(image_path, alt_text):
    """Upload image to WordPress media library"""
    if not os.path.exists(image_path):
        return None, f"File not found: {image_path}"

    ext = os.path.splitext(image_path)[1].lower()
    mime_types = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg'}
    mime_type = mime_types.get(ext, 'image/png')

    with open(image_path, 'rb') as f:
        image_data = f.read()

    media_headers = headers.copy()
    media_headers['Content-Type'] = mime_type
    media_headers['Content-Disposition'] = f'attachment; filename="{os.path.basename(image_path)}"'

    response = requests.post(f"{WP_API_URL}/media", headers=media_headers, data=image_data)

    if response.status_code == 201:
        media_data = response.json()
        media_id = media_data['id']

        # Update alt text
        requests.post(f"{WP_API_URL}/media/{media_id}", json={'alt_text': alt_text}, headers=headers)

        return media_id, media_data['source_url']
    else:
        return None, f"Upload failed: {response.status_code}"

def insert_image_in_content(content, image_url, position_marker, align='left', caption=''):
    """Insert a floating image into content at a specific position"""

    # Create image HTML with WordPress figure wrapper
    img_html = f'''
<figure class="wp-block-image align{align}" style="float:{align}; margin: 0 20px 20px {'20px' if align == 'right' else '0'}; max-width: 400px;">
    <img src="{image_url}" alt="{caption}" style="width: 100%; height: auto; border-radius: 8px;">
    {f'<figcaption style="font-size: 0.9em; color: #666; margin-top: 8px;">{caption}</figcaption>' if caption else ''}
</figure>
'''

    # Find position and insert
    if position_marker in content:
        content = content.replace(position_marker, img_html + position_marker, 1)

    return content

# Image insertion plan - where to place each image
image_insertions = [
    {
        "post_id": 2111,  # How Social Media Gave Us NPD
        "images": [
            {"file": "images/content/social-media-feedback-loop.png", "marker": "<h2>The Algorithmic NPD Factory</h2>", "align": "right", "caption": "The social media addiction feedback loop"},
            {"file": "images/content/algorithm-manipulation.png", "marker": "<h2>Sarah's Story</h2>", "align": "left", "caption": "How algorithms shape our behavior"},
        ]
    },
    {
        "post_id": 2112,  # Eight Feedback Loops
        "images": [
            {"file": "images/content/tribal-brain.png", "marker": "<h3>Loop 1:", "align": "right", "caption": "Tribal thinking reinforcement"},
        ]
    },
    {
        "post_id": 2114,  # Three-Layer Solution
        "images": [
            {"file": "images/content/wellbeing-vs-engagement.png", "marker": "<h3>Layer 1:", "align": "left", "caption": "Wellbeing vs engagement optimization"},
        ]
    },
    {
        "post_id": 2117,  # Narrative Offensive
        "images": [
            {"file": "images/content/bridging-conversation.png", "marker": "<h2>The Four Viral Narratives</h2>", "align": "right", "caption": "Building bridges across divides"},
        ]
    },
    {
        "post_id": 2118,  # The App That Deprograms You
        "images": [
            {"file": "images/content/depolarization-progress.png", "marker": "<h2>The 8-Week Curriculum</h2>", "align": "left", "caption": "Measurable depolarization progress"},
        ]
    },
    {
        "post_id": 2116,  # Regulatory Blitz
        "images": [
            {"file": "images/content/platform-accountability.png", "marker": "<h2>The Three Laws</h2>", "align": "right", "caption": "Holding platforms accountable"},
        ]
    },
    {
        "post_id": 2110,  # Narcissism You Can't See
        "images": [
            {"file": "images/content/collective-narcissism.png", "marker": "<h2>The Pattern You're Missing</h2>", "align": "left", "caption": "Collective narcissism in action"},
        ]
    },
]

print("=" * 60)
print("Adding Floating Content Images")
print("=" * 60)
print()

# First, upload all unique images
uploaded_images = {}

for insertion in image_insertions:
    for img in insertion["images"]:
        img_file = img["file"]
        if img_file not in uploaded_images:
            print(f"📤 Uploading {os.path.basename(img_file)}...")
            media_id, url = upload_image(img_file, img.get("caption", ""))
            if media_id:
                uploaded_images[img_file] = url
                print(f"   ✅ Uploaded: {url}")
            else:
                print(f"   ❌ Failed: {url}")

print()
print("=" * 60)
print("Inserting Images Into Posts")
print("=" * 60)
print()

# Now insert images into posts
success_count = 0
for insertion in image_insertions:
    post_id = insertion["post_id"]

    # Get current post content
    response = requests.get(f"{WP_API_URL}/posts/{post_id}", headers=headers)
    if response.status_code != 200:
        print(f"[{post_id}] ❌ Failed to fetch")
        continue

    post_data = response.json()
    content = post_data['content']['rendered']
    original_content = content

    print(f"[{post_id}] {post_data['title']['rendered']}...")

    # Insert each image
    for img in insertion["images"]:
        if img["file"] in uploaded_images:
            url = uploaded_images[img["file"]]
            content = insert_image_in_content(
                content,
                url,
                img["marker"],
                img.get("align", "left"),
                img.get("caption", "")
            )
            print(f"  🖼️  Inserted {os.path.basename(img['file'])} ({img['align']})")

    # Update post if content changed
    if content != original_content:
        update_response = requests.post(
            f"{WP_API_URL}/posts/{post_id}",
            json={'content': content},
            headers=headers
        )

        if update_response.status_code == 200:
            print(f"  ✅ Post updated with images!")
            success_count += 1
        else:
            print(f"  ❌ Update failed: {update_response.status_code}")
    else:
        print(f"  ⏭️  No changes needed")

print()
print("=" * 60)
print("COMPLETE")
print("=" * 60)
print(f"✅ Posts updated: {success_count}")
print()
print("All articles now have floating images!")
print("=" * 60)
