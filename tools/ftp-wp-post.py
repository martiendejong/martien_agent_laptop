"""
Upload post via FTP + execute PHP script to insert into database
"""
from ftplib import FTP
import time

# FTP credentials
ftp_host = "martiendejong.nl"
ftp_user = "admin@martiendejong.nl"
ftp_token = "4mrkD8yqGxDaxqfPaqjW"

# Read article content
with open(r'C:\scripts\blog-engine\output\30-jaar-gescheiden-wordpress.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Create PHP script to insert post
php_script = f'''<?php
require_once('wp-load.php');

$post_data = array(
  'post_title'    => '30 Jaar Gescheiden van Je Gezin: Een Mensenleven in de Marge van het Systeem',
  'post_content'  => {repr(content)},
  'post_status'   => 'publish',
  'post_author'   => 1,
  'post_excerpt'  => 'Een man, volledig geïntegreerd in Nederland, heeft 30 jaar zijn vrouw en kinderen niet kunnen zien. Elk jaar: visum afgewezen. Dit is wat er gebeurt terwijl wij wegkijken.',
  'comment_status' => 'open',
  'ping_status'    => 'open'
);

$post_id = wp_insert_post($post_data);

if ($post_id) {{
    echo "SUCCESS|" . $post_id . "|" . get_permalink($post_id);
}} else {{
    echo "ERROR|Failed to create post";
}}
?>'''

print(f"Connecting to FTP: {ftp_host}")
print(f"User: {ftp_user}")

try:
    # Connect to FTP
    ftp = FTP()
    ftp.connect(ftp_host)
    ftp.login(ftp_user, ftp_token)

    print(f"✓ Connected to FTP")
    print(f"Current directory: {ftp.pwd()}")

    # List files to see structure
    print("\nListing files:")
    ftp.retrlines('LIST')

    # Try to find public_html or similar
    try:
        ftp.cwd('public_html')
        print("\n✓ Changed to public_html")
    except:
        try:
            ftp.cwd('httpdocs')
            print("\n✓ Changed to httpdocs")
        except:
            print("\n! Using root directory")

    # Upload PHP script
    script_name = f'create_post_{int(time.time())}.php'
    print(f"\nUploading PHP script: {script_name}")

    from io import BytesIO
    ftp.storbinary(f'STOR {script_name}', BytesIO(php_script.encode('utf-8')))

    print(f"✓ Uploaded {script_name}")
    print(f"\nNow execute: https://martiendejong.nl/{script_name}")
    print("Then delete the file via FTP for security")

    ftp.quit()

    # Execute the script via HTTP
    import requests
    print(f"\nExecuting script...")
    response = requests.get(f"https://martiendejong.nl/{script_name}", timeout=30)
    print(f"Response: {response.text}")

    if "SUCCESS" in response.text:
        parts = response.text.split("|")
        print(f"\n✅ POST PUBLISHED!")
        print(f"Post ID: {parts[1]}")
        print(f"URL: {parts[2]}")

        # Clean up - delete the PHP script
        print(f"\nCleaning up...")
        ftp = FTP()
        ftp.connect(ftp_host)
        ftp.login(ftp_user, ftp_token)
        try:
            ftp.cwd('public_html')
        except:
            try:
                ftp.cwd('httpdocs')
            except:
                pass
        ftp.delete(script_name)
        ftp.quit()
        print(f"✓ Deleted {script_name}")

except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
