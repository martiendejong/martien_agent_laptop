"""
Link article to marriage page and vice versa
"""
from ftplib import FTP
import time
import requests

# Get marriage page
response = requests.get("https://martiendejong.nl/wp-json/wp/v2/pages?slug=sofy-martien-huwelijksaanvraag")
marriage_page = response.json()[0]
marriage_id = marriage_page['id']
marriage_content = marriage_page['content']['rendered']

print(f"Marriage page ID: {marriage_id}")

# Add link to marriage page (at the end)
marriage_addition = """<hr><div style="background: #fafafa; padding: 20px; border-left: 4px solid #1a1a1a; margin: 40px 0;"><p><strong>📖 Nieuw artikel in deze serie</strong></p><p><strong><a href="https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/">30 Jaar Gescheiden van Je Gezin: Een Mensenleven in de Marge van het Systeem</a></strong></p><p>Over een man die 30 jaar gescheiden wordt gehouden van zijn gezin door het IND-systeem. Een schrijnend verhaal over bureaucratische onmenselijkheid.</p><p><em>17 maart 2026</em></p></div>"""

# Check if link already exists
if "30-jaar-gescheiden" not in marriage_content:
    marriage_content_updated = marriage_content + marriage_addition
else:
    marriage_content_updated = marriage_content
    print("Link already exists on marriage page")

# Update article footer - link to marriage page instead of serie page
article_footer = """<hr><div class="serie-info" style="background: #fafafa; padding: 20px; border-left: 4px solid #1a1a1a; margin: 40px 0;"><p><strong>📖 Serie: Trouwen en de Gemeente</strong></p><p>Dit artikel is onderdeel van een serie over bureaucratische onmenselijkheid en de strijd voor menselijke waardigheid binnen bureaucratische processen.</p><p><strong>Lees ook:</strong></p><ul><li><a href="https://martiendejong.nl/sofy-martien-huwelijksaanvraag/" style="font-weight: 600;">Sofy & Martien: Onze strijd om te mogen trouwen</a> - Drie jaar tegenwerking door Gemeente Meppel</li></ul><p style="margin-top: 15px;"><a href="https://martiendejong.nl/sofy-martien-huwelijksaanvraag/" style="font-weight: 600; color: #1a1a1a;">→ Bekijk het complete verhaal van Sofy & Martien</a></p></div><p><strong>Over de auteur:</strong> Martien de Jong schrijft over bureaucratie, systemen en de mensen die daar tussen vallen.</p><p><em>Heb jij een verhaal over bureaucratische onmenselijkheid? <a href="https://martiendejong.nl/#contact">Laat het me weten</a>.</em></p>"""

# Get article content
response = requests.get("https://martiendejong.nl/wp-json/wp/v2/posts/3154")
article_content = response.json()['content']['rendered']
cut_point = article_content.find('<p>En dat is te lang om te doen alsof we het niet zien.</p>')
article_content_updated = article_content[:cut_point + len('<p>En dat is te lang om te doen alsof we het niet zien.</p>')] + article_footer

# PHP scripts
php_update_marriage = f'''<?php
require_once('wp-load.php');
wp_update_post(array('ID' => {marriage_id}, 'post_content' => {repr(marriage_content_updated)}));
echo "MARRIAGE_PAGE_UPDATED";
?>'''

php_update_article = f'''<?php
require_once('wp-load.php');
wp_update_post(array('ID' => 3154, 'post_content' => {repr(article_content_updated)}));
echo "ARTICLE_UPDATED";
?>'''

print("Uploading...")

ftp = FTP()
ftp.connect("martiendejong.nl")
ftp.login("admin@martiendejong.nl", "4mrkD8yqGxDaxqfPaqjW")
ftp.cwd('public_html')

from io import BytesIO
script1 = f'link_marriage_{int(time.time())}.php'
script2 = f'link_article_{int(time.time())}.php'

ftp.storbinary(f'STOR {script1}', BytesIO(php_update_marriage.encode('utf-8')))
ftp.storbinary(f'STOR {script2}', BytesIO(php_update_article.encode('utf-8')))
ftp.quit()

print("Executing...")
r1 = requests.get(f"https://martiendejong.nl/{script1}", timeout=30)
r2 = requests.get(f"https://martiendejong.nl/{script2}", timeout=30)

print(f"Marriage page: {r1.text}")
print(f"Article: {r2.text}")

# Cleanup
ftp = FTP()
ftp.connect("martiendejong.nl")
ftp.login("admin@martiendejong.nl", "4mrkD8yqGxDaxqfPaqjW")
ftp.cwd('public_html')
ftp.delete(script1)
ftp.delete(script2)
ftp.quit()

print("\nDONE! Cross-linked:")
print(f"Article → Marriage page: https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/")
print(f"Marriage page → Article: https://martiendejong.nl/sofy-martien-huwelijksaanvraag/")
