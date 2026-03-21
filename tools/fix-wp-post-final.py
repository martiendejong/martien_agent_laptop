"""
Fix WordPress post - clean HTML and update
"""
from ftplib import FTP
import time

# Read and clean HTML
with open(r'C:\scripts\blog-engine\output\30-jaar-gescheiden-wordpress.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the HTML comment header and clean newlines
content = content.replace('<!-- WordPress Post Content - Copy and paste this into WordPress editor -->', '')
content = content.replace('\r\n', '\n')  # Normalize line endings
content = content.replace('\n\n', '\n')  # Remove double newlines
content = content.strip()

# PHP script to update post
php_script = f'''<?php
require_once('wp-load.php');

$post_id = 3154;

$post_data = array(
  'ID' => $post_id,
  'post_content' => {repr(content)}
);

$result = wp_update_post($post_data);

if ($result && !is_wp_error($result)) {{
    echo "SUCCESS|Updated post " . $post_id;
    echo "|" . get_permalink($post_id);
}} else {{
    echo "ERROR|Failed to update post";
}}
?>'''

print("Connecting to FTP...")

# FTP credentials
ftp_host = "martiendejong.nl"
ftp_user = "admin@martiendejong.nl"
ftp_token = "4mrkD8yqGxDaxqfPaqjW"

try:
    ftp = FTP()
    ftp.connect(ftp_host)
    ftp.login(ftp_user, ftp_token)
    ftp.cwd('public_html')

    # Upload PHP script
    script_name = f'update_post_{int(time.time())}.php'
    print(f"Uploading {script_name}...")

    from io import BytesIO
    ftp.storbinary(f'STOR {script_name}', BytesIO(php_script.encode('utf-8')))
    ftp.quit()

    print("Executing script...")
    import requests
    response = requests.get(f"https://martiendejong.nl/{script_name}", timeout=30)
    print(f"Response: {response.text}")

    if "SUCCESS" in response.text:
        print("\nSUCCESS: Post updated!")
        parts = response.text.split("|")
        if len(parts) > 2:
            print(f"URL: {parts[2]}")

    # Cleanup
    print("\nCleaning up...")
    ftp = FTP()
    ftp.connect(ftp_host)
    ftp.login(ftp_user, ftp_token)
    ftp.cwd('public_html')
    ftp.delete(script_name)
    ftp.quit()
    print("Done!")

except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
