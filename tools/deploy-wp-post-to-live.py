"""
Deploy WordPress Post to LIVE martiendejong.nl
"""
import requests
import base64

# Live site
wp_url = "https://martiendejong.nl"
username = "admin"
app_password = "uaJjyn3ZiwJls3yEwkG0QcdJ"

# Read the article HTML
with open(r'C:\scripts\blog-engine\output\30-jaar-gescheiden-wordpress.html', 'r', encoding='utf-8') as f:
    content = f.read()

# WordPress REST API endpoint
api_url = f"{wp_url}/wp-json/wp/v2/posts"

# Authentication
credentials = f"{username}:{app_password}"
token = base64.b64encode(credentials.encode()).decode('utf-8')
headers = {
    'Authorization': f'Basic {token}',
    'Content-Type': 'application/json'
}

# Post data
post_data = {
    'title': '30 Jaar Gescheiden van Je Gezin: Een Mensenleven in de Marge van het Systeem',
    'content': content,
    'excerpt': 'Een man, volledig geïntegreerd in Nederland, heeft 30 jaar zijn vrouw en kinderen niet kunnen zien. Elk jaar: visum afgewezen. Dit is wat er gebeurt terwijl wij wegkijken.',
    'status': 'publish',
    'comment_status': 'open',
    'ping_status': 'open'
}

print(f"Publishing to LIVE: {wp_url}")
print(f"Title: {post_data['title']}")
print(f"Content length: {len(content)} chars")
print()

try:
    response = requests.post(api_url, headers=headers, json=post_data, timeout=30)

    if response.status_code in [200, 201]:
        post_info = response.json()
        post_id = post_info['id']
        post_url = post_info['link']
        print(f"SUCCESS!")
        print(f"Post ID: {post_id}")
        print(f"URL: {post_url}")
        print(f"Edit: {wp_url}/wp-admin/post.php?post={post_id}&action=edit")
    else:
        print(f"ERROR: {response.status_code}")
        print(f"Response: {response.text}")
except Exception as e:
    print(f"EXCEPTION: {e}")
