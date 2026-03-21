"""
WordPress Article Publisher
Publishes markdown article to WordPress via REST API
"""
import requests
import json
import base64
from datetime import datetime

def publish_to_wordpress(
    article_path,
    wp_url="http://localhost",
    username="admin",
    app_password="uaJjyn3ZiwJls3yEwkG0QcdJ",
    status="draft"  # draft or publish
):
    """Publish markdown article to WordPress"""

    # Read the article
    with open(article_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Parse frontmatter
    if content.startswith('---'):
        parts = content.split('---', 2)
        frontmatter = parts[1].strip()
        article_content = parts[2].strip()

        # Parse YAML-like frontmatter
        metadata = {}
        for line in frontmatter.split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                key = key.strip()
                value = value.strip().strip('"')
                metadata[key] = value

        title = metadata.get('title', 'Untitled')
        excerpt = metadata.get('meta_description', '')
    else:
        # No frontmatter
        title = "Untitled Article"
        excerpt = ""
        article_content = content

    # Convert markdown headers to HTML (basic conversion)
    html_content = article_content
    html_content = html_content.replace('# ', '<h1>').replace('\n\n', '</h1>\n\n')
    html_content = html_content.replace('## ', '<h2>').replace('\n\n', '</h2>\n\n')
    html_content = html_content.replace('### ', '<h3>').replace('\n\n', '</h3>\n\n')
    html_content = html_content.replace('\n\n', '</p>\n<p>')
    html_content = f'<p>{html_content}</p>'

    # WordPress REST API endpoint
    api_url = f"{wp_url}/wp-json/wp/v2/posts"

    # Create authentication header
    credentials = f"{username}:{app_password}"
    token = base64.b64encode(credentials.encode()).decode('utf-8')
    headers = {
        'Authorization': f'Basic {token}',
        'Content-Type': 'application/json'
    }

    # Post data
    post_data = {
        'title': title,
        'content': html_content,
        'excerpt': excerpt,
        'status': status,
        'categories': [],  # Add category IDs if needed
        'tags': [],  # Add tag IDs if needed
    }

    # Make request
    print(f"Publishing '{title}' to {wp_url}...")
    print(f"Status: {status}")

    response = requests.post(api_url, headers=headers, json=post_data)

    if response.status_code in [200, 201]:
        post_info = response.json()
        post_id = post_info['id']
        post_url = post_info['link']
        print(f"✓ Success! Post ID: {post_id}")
        print(f"✓ URL: {post_url}")
        print(f"✓ Edit: {wp_url}/wp-admin/post.php?post={post_id}&action=edit")
        return post_id, post_url
    else:
        print(f"✗ Error: {response.status_code}")
        print(f"✗ Response: {response.text}")
        return None, None

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python wp-post-article.py <article_path> [status]")
        print("Status: draft (default) or publish")
        sys.exit(1)

    article_path = sys.argv[1]
    status = sys.argv[2] if len(sys.argv) > 2 else "draft"

    publish_to_wordpress(article_path, status=status)
