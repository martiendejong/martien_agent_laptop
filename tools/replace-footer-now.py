"""
Replace footer COMPLETELY
"""
from ftplib import FTP
import time
import requests

# Get current content
response = requests.get("https://martiendejong.nl/wp-json/wp/v2/posts/3154")
current_content = response.json()['content']['rendered']

# Find where to cut (after "En dat is te lang om te doen alsof we het niet zien.")
cut_point = current_content.find('<p>En dat is te lang om te doen alsof we het niet zien.</p>')
if cut_point == -1:
    print("ERROR: Could not find cut point")
    exit(1)

# Keep everything up to and including that paragraph
keep_content = current_content[:cut_point + len('<p>En dat is te lang om te doen alsof we het niet zien.</p>')]

# New footer
new_footer = '''<hr><div class="serie-info" style="background: #f5f5f5; padding: 20px; border-left: 4px solid #1a1a1a; margin: 40px 0;"><p><strong>Serie: Trouwen en de Gemeente</strong></p><p>Dit artikel is onderdeel van een serie over bureaucratische onmenselijkheid, systemen die mensen kapotmaken, en de strijd voor menselijke waardigheid.</p><p><strong>Artikelen in deze serie:</strong></p><ol><li><strong>30 Jaar Gescheiden van Je Gezin</strong> (dit artikel)</li><li><em>Coming: Het Verzameldossier: Drie Jaar Tegenwerking</em></li><li><em>Coming: De Anatomie van Obstructie</em></li></ol><p><a href="https://martiendejong.nl/serie-trouwen-en-de-gemeente/" style="font-weight: 600;">Bekijk alle artikelen in deze serie</a></p></div><p><strong>Over de auteur:</strong> Martien de Jong schrijft over bureaucratie, systemen en de mensen die daar tussen vallen.</p><p><em>Heb jij een verhaal over bureaucratische onmenselijkheid? <a href="https://martiendejong.nl/#contact">Laat het me weten</a>.</em></p>'''

# Complete new content
final_content = keep_content + new_footer

print(f"Content length: {len(final_content)} chars")
print(f"Footer preview: {new_footer[:200]}")

# PHP to update
php_script = f'''<?php
require_once('wp-load.php');
$result = wp_update_post(array(
  'ID' => 3154,
  'post_content' => {repr(final_content)}
));
if ($result && !is_wp_error($result)) {{
    echo "SUCCESS|3154|https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/";
}} else {{
    echo "ERROR|Update failed";
}}
?>'''

print("\nUploading...")

ftp = FTP()
ftp.connect("martiendejong.nl")
ftp.login("admin@martiendejong.nl", "4mrkD8yqGxDaxqfPaqjW")
ftp.cwd('public_html')

script_name = f'fix_footer_final_{int(time.time())}.php'
from io import BytesIO
ftp.storbinary(f'STOR {script_name}', BytesIO(php_script.encode('utf-8')))
ftp.quit()

print("Executing...")
response = requests.get(f"https://martiendejong.nl/{script_name}", timeout=30)
print(f"Result: {response.text}")

if "SUCCESS" in response.text:
    print("\nSUCCESS! Footer replaced!")
    print("Check: https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/")

# Cleanup
ftp = FTP()
ftp.connect("martiendejong.nl")
ftp.login("admin@martiendejong.nl", "4mrkD8yqGxDaxqfPaqjW")
ftp.cwd('public_html')
ftp.delete(script_name)
ftp.quit()
