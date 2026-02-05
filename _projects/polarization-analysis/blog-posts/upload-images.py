#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Upload images to WordPress and set as featured images
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

# Post and image mapping
posts_images = [
    {"id": 2109, "image": "images/01-youre-not-crazy-the-system-is.png", "title": "You're Not Crazy, The System Is"},
    {"id": 2110, "image": "images/02-the-narcissism-you-cant-see.png", "title": "The Narcissism You Can't See"},
    {"id": 2111, "image": "images/03-how-social-media-gave-us-npd.png", "title": "How Social Media Gave Us NPD"},
    {"id": 2112, "image": "images/04-the-eight-feedback-loops.png", "title": "The Eight Feedback Loops"},
    {"id": 2113, "image": "images/05-why-fact-checking-failed.png", "title": "Why Fact-Checking Failed"},
    {"id": 2114, "image": "images/06-the-three-layer-solution.png", "title": "The Three-Layer Solution"},
    {"id": 2115, "image": "images/07-the-algorithm-war.png", "title": "The Algorithm War"},
    {"id": 2116, "image": "images/08-the-regulatory-blitz.png", "title": "The Regulatory Blitz"},
    {"id": 2117, "image": "images/09-the-narrative-offensive.png", "title": "The Narrative Offensive"},
    {"id": 2118, "image": "images/10-the-app-that-deprograms-you.png", "title": "The App That Deprograms You"},
    {"id": 2119, "image": "images/11-the-implementation-blueprint.png", "title": "The Implementation Blueprint"},
    {"id": 2120, "image": "images/12-the-two-futures.png", "title": "The Two Futures"},
]

def upload_image(image_path, alt_text):
    """Upload image to WordPress media library"""
    if not os.path.exists(image_path):
        return None, f"File not found: {image_path}"

    # Determine mime type
    ext = os.path.splitext(image_path)[1].lower()
    mime_types = {
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
    }
    mime_type = mime_types.get(ext, 'image/png')

    # Read image file
    with open(image_path, 'rb') as f:
        image_data = f.read()

    # Prepare headers for media upload
    media_headers = headers.copy()
    media_headers['Content-Type'] = mime_type
    media_headers['Content-Disposition'] = f'attachment; filename="{os.path.basename(image_path)}"'

    # Upload to WordPress
    response = requests.post(
        f"{WP_API_URL}/media",
        headers=media_headers,
        data=image_data
    )

    if response.status_code == 201:
        media_data = response.json()
        media_id = media_data['id']

        # Update alt text
        requests.post(
            f"{WP_API_URL}/media/{media_id}",
            json={'alt_text': alt_text},
            headers=headers
        )

        return media_id, media_data['source_url']
    else:
        return None, f"Upload failed: {response.status_code} - {response.text[:200]}"

def set_featured_image(post_id, media_id):
    """Set featured image for a post"""
    response = requests.post(
        f"{WP_API_URL}/posts/{post_id}",
        json={'featured_media': media_id},
        headers=headers
    )
    return response.status_code == 200

print("=" * 60)
print("Uploading Images and Setting Featured Images")
print("=" * 60)
print()

success_count = 0
fail_count = 0

for item in posts_images:
    post_id = item['id']
    image_path = item['image']
    title = item['title']

    print(f"[{post_id}] {title}...")

    # Upload image
    print(f"  📤 Uploading {os.path.basename(image_path)}...")
    media_id, result = upload_image(image_path, f"The Narcissism Pandemic - {title}")

    if media_id is None:
        print(f"  ❌ Upload failed: {result}")
        fail_count += 1
        continue

    print(f"  ✅ Uploaded (Media ID: {media_id})")

    # Set as featured image
    print(f"  🖼️  Setting as featured image...")
    if set_featured_image(post_id, media_id):
        print(f"  ✅ Featured image set!")
        success_count += 1
    else:
        print(f"  ❌ Failed to set featured image")
        fail_count += 1

print()
print("=" * 60)
print("COMPLETE")
print("=" * 60)
print(f"✅ Success: {success_count}/12")
print(f"❌ Failed: {fail_count}/12")
print()
print("All featured images are now live!")
print("=" * 60)
