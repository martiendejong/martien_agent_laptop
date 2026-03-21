import mysql.connector

# Read HTML content
with open(r'C:\scripts\blog-engine\output\30-jaar-gescheiden-wordpress.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Connect to MySQL
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='',
    database='martiendejong'
)

cursor = conn.cursor()

# Update post
cursor.execute("""
    UPDATE wp_posts
    SET post_content = %s
    WHERE ID = 84
""", (content,))

conn.commit()

print(f"SUCCESS: Post 84 updated with {len(content)} characters")
print(f"URL: http://localhost/?p=84")
print(f"Edit: http://localhost/wp-admin/post.php?post=84&action=edit")

cursor.close()
conn.close()
