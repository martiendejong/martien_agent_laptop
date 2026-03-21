"""
Deploy to LIVE WordPress via direct login + post creation
"""
import requests
from bs4 import BeautifulSoup
import re

# Live site
wp_url = "https://martiendejong.nl"
username = "admin"
password = "gSDs XMoM Vmkc 6rQy 2e1i YAro"

# Read article
with open(r'C:\scripts\blog-engine\output\30-jaar-gescheiden-wordpress.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Create session
session = requests.Session()

print(f"Logging into {wp_url}/wp-login.php...")

# Get login page to get nonce
login_page = session.get(f"{wp_url}/wp-login.php")

# Login
login_data = {
    'log': username,
    'pwd': password,
    'wp-submit': 'Log In',
    'redirect_to': f'{wp_url}/wp-admin/',
    'testcookie': '1'
}

response = session.post(f"{wp_url}/wp-login.php", data=login_data)

if 'wp-admin' in response.url or response.status_code == 200:
    print("SUCCESS: Logged in!")

    # Get new post page
    print("Getting new post page...")
    new_post_page = session.get(f"{wp_url}/wp-admin/post-new.php")

    # Extract nonce
    soup = BeautifulSoup(new_post_page.text, 'html.parser')
    nonce = None
    for input_tag in soup.find_all('input'):
        if input_tag.get('name') == '_wpnonce':
            nonce = input_tag.get('value')
            break

    if nonce:
        print(f"Nonce: {nonce}")

        # Create post
        post_data = {
            'post_title': '30 Jaar Gescheiden van Je Gezin: Een Mensenleven in de Marge van het Systeem',
            'content': content,
            'excerpt': 'Een man, volledig geïntegreerd in Nederland, heeft 30 jaar zijn vrouw en kinderen niet kunnen zien. Elk jaar: visum afgewezen. Dit is wat er gebeurt terwijl wij wegkijken.',
            'post_status': 'publish',
            'post_type': 'post',
            '_wpnonce': nonce,
            'action': 'editpost'
        }

        print("Creating post...")
        create_response = session.post(f"{wp_url}/wp-admin/post.php", data=post_data)

        # Try to extract post ID from redirect
        if 'post=' in create_response.url:
            post_id = re.search(r'post=(\d+)', create_response.url)
            if post_id:
                print(f"SUCCESS! Post created!")
                print(f"Post ID: {post_id.group(1)}")
                print(f"URL: {wp_url}/?p={post_id.group(1)}")
        else:
            print(f"Response URL: {create_response.url}")
            print("Check if post was created manually")
    else:
        print("ERROR: Could not find nonce")
else:
    print(f"ERROR: Login failed")
    print(f"Response: {response.status_code}")
    print(f"URL: {response.url}")
