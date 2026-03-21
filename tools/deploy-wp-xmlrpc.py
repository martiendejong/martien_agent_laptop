"""
Deploy via WordPress XML-RPC
"""
from wordpress_xmlrpc import Client, WordPressPost
from wordpress_xmlrpc.methods.posts import NewPost

# Read article
with open(r'C:\scripts\blog-engine\output\30-jaar-gescheiden-wordpress.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Connect
wp = Client('https://martiendejong.nl/xmlrpc.php', 'admin', 'gSDs XMoM Vmkc 6rQy 2e1i YAro')

# Create post
post = WordPressPost()
post.title = '30 Jaar Gescheiden van Je Gezin: Een Mensenleven in de Marge van het Systeem'
post.content = content
post.excerpt = 'Een man, volledig geïntegreerd in Nederland, heeft 30 jaar zijn vrouw en kinderen niet kunnen zien. Elk jaar: visum afgewezen. Dit is wat er gebeurt terwijl wij wegkijken.'
post.post_status = 'publish'
post.comment_status = 'open'
post.ping_status = 'open'

print("Publishing to LIVE site via XML-RPC...")
print(f"Title: {post.title}")
print()

try:
    post_id = wp.call(NewPost(post))
    print(f"SUCCESS!")
    print(f"Post ID: {post_id}")
    print(f"URL: https://martiendejong.nl/?p={post_id}")
    print(f"Check: https://martiendejong.nl/")
except Exception as e:
    print(f"ERROR: {e}")
