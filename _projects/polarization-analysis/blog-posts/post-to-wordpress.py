#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Post all 12 blog articles from The Narcissism Pandemic series to WordPress
"""

import sys
import io
import requests
import os
import re
from base64 import b64encode
from getpass import getpass

# Fix Windows encoding issues
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# WordPress site configuration
WP_SITE = "https://martiendejong.nl"
WP_API_URL = f"{WP_SITE}/wp-json/wp/v2"

# Post metadata
posts = [
    {"num": "01", "title": "You're Not Crazy, The System Is", "file": "01-youre-not-crazy"},
    {"num": "02", "title": "The Narcissism You Can't See (Because You're In It)", "file": "02-narcissism-you-cant-see"},
    {"num": "03", "title": "How Social Media Gave Us All Narcissistic Personality Disorder", "file": "03-social-media-npd-factory"},
    {"num": "04", "title": "The Eight Feedback Loops Destroying Society", "file": "04-eight-feedback-loops"},
    {"num": "05", "title": "Why Fact-Checking Failed (And What That Tells Us)", "file": "05-why-fact-checking-failed"},
    {"num": "06", "title": "The Three-Layer Solution (Or: How To Fight Fire With Fire)", "file": "06-three-layer-solution"},
    {"num": "07", "title": "The Algorithm War: Building Tech That Heals Instead of Harms", "file": "07-algorithm-war"},
    {"num": "08", "title": "The Regulatory Blitz: How To Make Big Tech Bend", "file": "08-regulatory-blitz"},
    {"num": "09", "title": "The Narrative Offensive: Making Bridge-Building Cool", "file": "09-narrative-offensive"},
    {"num": "10", "title": "The App That Deprograms You (In Real-Time)", "file": "10-depolarization-toolkit"},
    {"num": "11", "title": "The Implementation Blueprint: How We Coordinate", "file": "11-implementation-blueprint"},
    {"num": "12", "title": "The Two Futures: Choose Wisely", "file": "12-two-futures"},
]

def get_credentials():
    """Get WordPress credentials from environment or prompt"""
    username = os.environ.get('WP_USERNAME')
    app_password = os.environ.get('WP_APP_PASSWORD')

    if not username:
        username = input("WordPress username: ").strip()

    if not app_password:
        print("\nEnter WordPress Application Password (no spaces):")
        print("Generate one at: https://martiendejong.nl/wp-admin/profile.php")
        app_password = getpass("Application Password: ").strip().replace(" ", "")

    return username, app_password

def create_auth_header(username, app_password):
    """Create Basic Auth header for WordPress REST API"""
    credentials = f"{username}:{app_password}"
    token = b64encode(credentials.encode()).decode('utf-8')
    return {'Authorization': f'Basic {token}'}

def extract_html_content(html_file_path):
    """Extract the article content from HTML file"""
    with open(html_file_path, 'r', encoding='utf-8') as f:
        html = f.read()

    # Extract content between <article> tags
    match = re.search(r'<article>(.*?)</article>', html, re.DOTALL)
    if match:
        return match.group(1).strip()
    return None

def create_wordpress_post(post_data, headers, category_id=None, status='draft'):
    """Create a WordPress post via REST API"""

    payload = {
        'title': post_data['title'],
        'content': post_data['content'],
        'status': status,  # 'draft' or 'publish'
        'excerpt': post_data.get('excerpt', ''),
        'format': 'standard',
    }

    if category_id:
        payload['categories'] = [category_id]

    # Add tags
    if 'tags' in post_data:
        payload['tags'] = post_data['tags']

    response = requests.post(
        f"{WP_API_URL}/posts",
        json=payload,
        headers=headers
    )

    return response

def get_or_create_category(category_name, headers):
    """Get category ID or create new category"""
    # Search for existing category
    response = requests.get(
        f"{WP_API_URL}/categories",
        params={'search': category_name},
        headers=headers
    )

    if response.status_code == 200:
        categories = response.json()
        if categories:
            return categories[0]['id']

    # Create new category
    response = requests.post(
        f"{WP_API_URL}/categories",
        json={'name': category_name, 'slug': category_name.lower().replace(' ', '-')},
        headers=headers
    )

    if response.status_code == 201:
        return response.json()['id']

    return None

def main():
    """Main execution function"""
    print("=" * 60)
    print("WordPress Article Poster")
    print("The Narcissism Pandemic Series (12 posts)")
    print("=" * 60)
    print()

    # Get credentials
    username, app_password = get_credentials()
    headers = create_auth_header(username, app_password)

    # Test authentication
    print("\nTesting authentication...")
    test_response = requests.get(f"{WP_API_URL}/users/me", headers=headers)
    if test_response.status_code != 200:
        print("❌ Authentication failed!")
        print(f"Error: {test_response.status_code} - {test_response.text}")
        return

    print("✅ Authentication successful!")
    user_data = test_response.json()
    print(f"Logged in as: {user_data['name']} (@{user_data['slug']})")

    # Get or create category
    print("\nSetting up category...")
    category_id = get_or_create_category("The Narcissism Pandemic", headers)
    if category_id:
        print(f"✅ Category ID: {category_id}")

    # Ask for status
    print("\n" + "=" * 60)
    status_input = input("Post as DRAFT or PUBLISH? (draft/publish) [draft]: ").strip().lower()
    status = 'publish' if status_input == 'publish' else 'draft'
    print(f"Will post as: {status.upper()}")
    print("=" * 60)
    print()

    # Process each post
    results = []
    for i, post in enumerate(posts, 1):
        print(f"\n[{i}/12] Processing: {post['title']}...")

        html_path = f"html/{post['file']}.html"

        if not os.path.exists(html_path):
            print(f"  ❌ File not found: {html_path}")
            results.append({'post': post, 'status': 'failed', 'error': 'File not found'})
            continue

        # Extract content
        content = extract_html_content(html_path)
        if not content:
            print(f"  ❌ Could not extract content from HTML")
            results.append({'post': post, 'status': 'failed', 'error': 'Content extraction failed'})
            continue

        # Prepare post data
        full_title = f"Part {post['num']}: {post['title']}"
        post_data = {
            'title': full_title,
            'content': content,
            'excerpt': f"Part {post['num']} of 12: The Narcissism Pandemic Series"
        }

        # Create post
        response = create_wordpress_post(post_data, headers, category_id, status)

        if response.status_code == 201:
            post_url = response.json()['link']
            print(f"  ✅ SUCCESS: {post_url}")
            results.append({'post': post, 'status': 'success', 'url': post_url})
        else:
            print(f"  ❌ FAILED: {response.status_code}")
            print(f"     Error: {response.text[:200]}")
            results.append({'post': post, 'status': 'failed', 'error': response.text[:200]})

    # Summary
    print("\n" + "=" * 60)
    print("POSTING COMPLETE")
    print("=" * 60)

    successful = [r for r in results if r['status'] == 'success']
    failed = [r for r in results if r['status'] == 'failed']

    print(f"\n✅ Successful: {len(successful)}/12")
    print(f"❌ Failed: {len(failed)}/12")

    if successful:
        print("\n📝 Successfully posted articles:")
        for r in successful:
            print(f"  • {r['post']['title']}")
            print(f"    {r['url']}")

    if failed:
        print("\n❌ Failed articles:")
        for r in failed:
            print(f"  • {r['post']['title']}: {r.get('error', 'Unknown error')}")

    print("\n" + "=" * 60)
    print(f"All posts created as: {status.upper()}")
    if status == 'draft':
        print("Go to https://martiendejong.nl/wp-admin/edit.php to review and publish.")
    print("=" * 60)

if __name__ == "__main__":
    main()
