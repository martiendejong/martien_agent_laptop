"""
Fix series page: remove nn + softer background
"""
from ftplib import FTP
import time
import requests
import re

# Better styled series page (darker background)
series_content = """<div class="serie-header" style="margin-bottom: 40px;"><h1>Serie: Trouwen en de Gemeente</h1><p class="serie-subtitle" style="font-size: 1.2em; color: #666;">Over bureaucratische onmenselijkheid, systemen die mensen kapotmaken, en de strijd voor menselijke waardigheid</p></div><div class="serie-intro" style="background: #2a2a2a; color: #fff; padding: 30px; margin: 30px 0; border-left: 4px solid #666;"><p>Deze serie documenteert verhalen van mensen die kapot worden gemaakt door bureaucratische systemen. Van mijn eigen strijd met Gemeente Meppel om te mogen trouwen, tot verhalen van anderen die vastlopen in onmenselijke procedures.</p><p><strong>Het gaat over:</strong></p><ul><li>Systemen die draaien maar nergens heen gaan</li><li>Mensen die alles goed proberen te doen, maar toch worden tegengewerkt</li><li>De vraag: waarom accepteren wij dit?</li></ul></div><h2>Artikelen in deze serie</h2><div class="serie-articles"><article class="serie-article" style="background: #fafafa; border-left: 4px solid #1a1a1a; padding: 20px; margin: 30px 0;"><h3><a href="https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/">30 Jaar Gescheiden van Je Gezin: Een Mensenleven in de Marge van het Systeem</a></h3><p class="article-meta" style="color: #666; font-size: 0.9em;">17 maart 2026</p><p>Een man, volledig geïntegreerd in Nederland, heeft 30 jaar zijn vrouw en kinderen niet kunnen zien. Elk jaar opnieuw: visumaanvraag afgewezen. Dit is wat er gebeurt terwijl wij wegkijken.</p><p><strong>Thema's:</strong> IND, gezinshereniging, immigratiesysteem, 30 jaar wachten</p><p><a href="https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/" style="font-weight: 600;">Lees artikel →</a></p></article><article class="serie-article coming-soon" style="background: #fafafa; border-left: 4px solid #ccc; padding: 20px; margin: 30px 0; opacity: 0.7;"><h3>Het Verzameldossier: Drie Jaar Tegenwerking Gedocumenteerd</h3><p class="article-meta" style="color: #666; font-size: 0.9em;">Binnenkort</p><p>Mijn eigen verhaal: drie jaar lang systematisch tegengewerkt door Gemeente Meppel in mijn poging te trouwen met mijn Keniaanse partner. Complete documentatie van obstructiepatronen.</p><p><strong>Thema's:</strong> Gemeente Meppel, trouwen, obstructie, shifting goalposts</p></article><article class="serie-article coming-soon" style="background: #fafafa; border-left: 4px solid #ccc; padding: 20px; margin: 30px 0; opacity: 0.7;"><h3>De Anatomie van Obstructie: Hoe Systemen Mensen Kapotmaken</h3><p class="article-meta" style="color: #666; font-size: 0.9em;">Binnenkort</p><p>Analyse van bureaucratische patronen die mensen kapotmaken: shifting goalposts, approval-retraction, catch-22's, communication fragmentation, en character assassination. Met concrete voorbeelden en hoe je ze herkent.</p><p><strong>Thema's:</strong> Bureaucratie, obstructiepatronen, systemen, analyse</p></article></div><div class="serie-footer" style="background: #1a1a1a; color: #fff; padding: 30px; margin: 50px 0;"><h3 style="color: #fff;">Heb jij ook zo'n verhaal?</h3><p>Ken jij verhalen van mensen die kapot worden gemaakt door bureaucratische onmenselijkheid? Of heb je zelf zo'n ervaring? Laat het me weten.</p><p><a href="https://martiendejong.nl/#contact" style="color: #fff; font-weight: 600; text-decoration: underline;">Contact opnemen →</a></p></div><div class="about-author" style="margin: 40px 0;"><h3>Over Martien de Jong</h3><p>Martien de Jong is technologie-entrepreneur, AI-architect, en schrijver. Hij bouwt systemen die mensen dienen in plaats van mensen gebruiken. Deze serie is persoonlijk: het gaat over zijn eigen strijd en die van anderen om menselijke waardigheid te behouden binnen bureaucratische processen.</p><p><a href="https://martiendejong.nl/">Meer over Martien →</a></p></div>"""

# Also update article footer with better background
article_footer = """<hr><div class="serie-info" style="background: #fafafa; padding: 20px; border-left: 4px solid #1a1a1a; margin: 40px 0;"><p><strong>Serie: Trouwen en de Gemeente</strong></p><p>Dit artikel is onderdeel van een serie over bureaucratische onmenselijkheid, systemen die mensen kapotmaken, en de strijd voor menselijke waardigheid.</p><p><strong>Artikelen in deze serie:</strong></p><ol><li><strong>30 Jaar Gescheiden van Je Gezin</strong> (dit artikel)</li><li><em>Coming: Het Verzameldossier: Drie Jaar Tegenwerking</em></li><li><em>Coming: De Anatomie van Obstructie</em></li></ol><p><a href="https://martiendejong.nl/serie-trouwen-en-de-gemeente/" style="font-weight: 600; color: #1a1a1a;">→ Bekijk alle artikelen in deze serie</a></p></div><p><strong>Over de auteur:</strong> Martien de Jong schrijft over bureaucratie, systemen en de mensen die daar tussen vallen.</p><p><em>Heb jij een verhaal over bureaucratische onmenselijkheid? <a href="https://martiendejong.nl/#contact">Laat het me weten</a>.</em></p>"""

# Get article content
response = requests.get("https://martiendejong.nl/wp-json/wp/v2/posts/3154")
article_content = response.json()['content']['rendered']
cut_point = article_content.find('<p>En dat is te lang om te doen alsof we het niet zien.</p>')
article_content = article_content[:cut_point + len('<p>En dat is te lang om te doen alsof we het niet zien.</p>')] + article_footer

# PHP scripts
php_update_page = f'''<?php
require_once('wp-load.php');
wp_update_post(array('ID' => 3159, 'post_content' => {repr(series_content)}));
echo "SERIES_PAGE_UPDATED";
?>'''

php_update_article = f'''<?php
require_once('wp-load.php');
wp_update_post(array('ID' => 3154, 'post_content' => {repr(article_content)}));
echo "ARTICLE_UPDATED";
?>'''

print("Uploading fixes...")

ftp = FTP()
ftp.connect("martiendejong.nl")
ftp.login("admin@martiendejong.nl", "4mrkD8yqGxDaxqfPaqjW")
ftp.cwd('public_html')

from io import BytesIO
script1 = f'fix_series_{int(time.time())}.php'
script2 = f'fix_article_{int(time.time())}.php'

ftp.storbinary(f'STOR {script1}', BytesIO(php_update_page.encode('utf-8')))
ftp.storbinary(f'STOR {script2}', BytesIO(php_update_article.encode('utf-8')))
ftp.quit()

print("Executing...")
r1 = requests.get(f"https://martiendejong.nl/{script1}", timeout=30)
r2 = requests.get(f"https://martiendejong.nl/{script2}", timeout=30)

print(f"Series page: {r1.text}")
print(f"Article: {r2.text}")

# Cleanup
ftp = FTP()
ftp.connect("martiendejong.nl")
ftp.login("admin@martiendejong.nl", "4mrkD8yqGxDaxqfPaqjW")
ftp.cwd('public_html')
ftp.delete(script1)
ftp.delete(script2)
ftp.quit()

print("\nDONE!")
print("Series page (no more nn, better colors): https://martiendejong.nl/serie-trouwen-en-de-gemeente/")
print("Article (softer background): https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/")
