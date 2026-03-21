"""
Fix WordPress post - make HTML completely compact
"""
from ftplib import FTP
import time
import re

# Read HTML
with open(r'C:\scripts\blog-engine\output\30-jaar-gescheiden-wordpress.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove comment header
content = re.sub(r'<!--.*?-->', '', content, flags=re.DOTALL)

# Remove ALL whitespace between tags
content = re.sub(r'>\s+<', '><', content)

# Remove leading/trailing whitespace
content = content.strip()

# Replace any remaining single newlines that might be in paragraphs
content = content.replace('\n', '')
content = content.replace('\r', '')

print("Cleaned content preview:")
print(content[:500])
print("\n...")

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

print("\nConnecting to FTP...")

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
    script_name = f'fix_compact_{int(time.time())}.php'
    print(f"Uploading {script_name}...")

    from io import BytesIO
    ftp.storbinary(f'STOR {script_name}', BytesIO(php_script.encode('utf-8')))
    ftp.quit()

    print("Executing...")
    import requests
    response = requests.get(f"https://martiendejong.nl/{script_name}", timeout=30)
    print(f"Response: {response.text}")

    if "SUCCESS" in response.text:
        print("\nSUCCESS!")
        parts = response.text.split("|")
        if len(parts) > 2:
            print(f"URL: {parts[2]}")
            print("\nCheck it now - NO MORE nn!")

    # Cleanup
    ftp = FTP()
    ftp.connect(ftp_host)
    ftp.login(ftp_user, ftp_token)
    ftp.cwd('public_html')
    ftp.delete(script_name)
    ftp.quit()

except Exception as e:
    print(f"ERROR: {e}")
