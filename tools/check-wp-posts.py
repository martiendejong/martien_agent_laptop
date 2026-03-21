"""
Check what other posts have at the bottom
"""
import requests

# Get all posts
response = requests.get("https://martiendejong.nl/wp-json/wp/v2/posts?per_page=10")
posts = response.json()

print(f"Found {len(posts)} posts\n")

for post in posts[:3]:  # Check first 3
    print(f"\n{'='*80}")
    print(f"Post: {post['title']['rendered']}")
    print(f"URL: {post['link']}")
    print(f"\n--- LAST 500 CHARS OF CONTENT ---")
    content = post['content']['rendered']
    print(content[-500:])
    print()
