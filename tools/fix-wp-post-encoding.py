"""
Fix WordPress post encoding + add featured image
"""
import requests
import base64
import html

# Credentials
wp_url = "https://martiendejong.nl"
username = "admin"
app_password = "uaJjyn3ZiwJls3yEwkG0QcdJ"

# Auth
credentials = f"{username}:{app_password}"
token = base64.b64encode(credentials.encode()).decode('utf-8')
headers = {
    'Authorization': f'Basic {token}',
    'Content-Type': 'application/json'
}

# Read correct HTML (UTF-8)
with open(r'C:\scripts\blog-engine\output\30-jaar-gescheiden-wordpress.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Get post ID
print("Finding post...")
response = requests.get(f"{wp_url}/wp-json/wp/v2/posts?search=30+Jaar+Gescheiden", headers=headers)
posts = response.json()

if not posts:
    print("ERROR: Post not found")
    exit(1)

post_id = posts[0]['id']
print(f"Post ID: {post_id}")

# Update post with correct content
print("Fixing encoding...")
update_data = {
    'content': content
}

response = requests.post(f"{wp_url}/wp-json/wp/v2/posts/{post_id}", headers=headers, json=update_data)

if response.status_code == 200:
    print("SUCCESS: Encoding fixed")
    print(f"URL: {response.json()['link']}")
else:
    print(f"ERROR: {response.status_code}")
    print(response.text)
