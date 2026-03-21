"""
Add series footer to article + create series overview page
"""
from ftplib import FTP
import time

# Article footer HTML
footer_html = """<hr><div class="serie-info" style="background: #f5f5f5; padding: 20px; border-left: 4px solid #1a1a1a; margin: 40px 0;">
<p><strong>📖 Serie: Trouwen en de Gemeente</strong></p>
<p>Dit artikel is onderdeel van een serie over bureaucratische onmenselijkheid, systemen die mensen kapotmaken, en de strijd voor menselijke waardigheid binnen bureaucratische processen.</p>
<p><strong>Artikelen in deze serie:</strong></p>
<ol>
<li><strong>30 Jaar Gescheiden van Je Gezin: Een Mensenleven in de Marge van het Systeem</strong> (dit artikel) - Over een man die 30 jaar gescheiden wordt gehouden van zijn gezin door het IND-systeem</li>
<li><em>Coming soon: Het Verzameldossier: Drie Jaar Tegenwerking Gedocumenteerd</em> - Mijn eigen strijd met Gemeente Meppel</li>
<li><em>Coming soon: De Anatomie van Obstructie: Hoe Systemen Mensen Kapotmaken</em> - Analyse van bureaucratische patronen</li>
</ol>
<p><a href="https://martiendejong.nl/serie-trouwen-en-de-gemeente/" style="font-weight: 600; color: #1a1a1a;">→ Bekijk alle artikelen in deze serie</a></p>
</div><p><strong>Over de auteur:</strong> Martien de Jong schrijft over bureaucratie, systemen en de mensen die daar tussen vallen. Technologie-entrepreneur, AI-architect, en voorvechter van menselijke waardigheid in digitale en bureaucratische systemen.</p><p><em>Heb jij een verhaal over bureaucratische onmenselijkheid? <a href="https://martiendejong.nl/#contact">Laat het me weten</a>.</em></p>"""

# Read current article
import requests
response = requests.get("https://martiendejong.nl/wp-json/wp/v2/posts/3154")
post = response.json()
content = post['content']['rendered']

# Remove old footer (everything after last </p> before current footer)
import re
# Find the "Wat Nu?" section end and replace footer
content = re.sub(
    r'(<p>En dat is te lang om te doen alsof we het niet zien\.</p>).*$',
    r'\1' + footer_html,
    content,
    flags=re.DOTALL
)

# Content updated (preview skipped due to unicode)

# PHP script to update
php_update = f'''<?php
require_once('wp-load.php');
wp_update_post(array(
  'ID' => 3154,
  'post_content' => {repr(content)}
));
echo "UPDATED|3154";
?>'''

# PHP script to create series overview page
series_page_content = """<div class="serie-header" style="margin-bottom: 40px;">
<h1>Serie: Trouwen en de Gemeente</h1>
<p class="serie-subtitle" style="font-size: 1.2em; color: #666;">Over bureaucratische onmenselijkheid, systemen die mensen kapotmaken, en de strijd voor menselijke waardigheid</p>
</div>

<div class="serie-intro" style="background: #f5f5f5; padding: 30px; margin: 30px 0;">
<p>Deze serie documenteert verhalen van mensen die kapot worden gemaakt door bureaucratische systemen. Van mijn eigen strijd met Gemeente Meppel om te mogen trouwen, tot verhalen van anderen die vastlopen in onmenselijke procedures.</p>
<p><strong>Het gaat over:</strong></p>
<ul>
<li>Systemen die draaien maar nergens heen gaan</li>
<li>Mensen die alles goed proberen te doen, maar toch worden tegengewerkt</li>
<li>De vraag: waarom accepteren wij dit?</li>
</ul>
</div>

<h2>Artikelen in deze serie</h2>

<div class="serie-articles">

<article class="serie-article" style="border-left: 4px solid #1a1a1a; padding-left: 20px; margin: 30px 0;">
<h3><a href="https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/">30 Jaar Gescheiden van Je Gezin: Een Mensenleven in de Marge van het Systeem</a></h3>
<p class="article-meta" style="color: #666; font-size: 0.9em;">17 maart 2026</p>
<p>Een man, volledig geïntegreerd in Nederland, heeft 30 jaar zijn vrouw en kinderen niet kunnen zien. Elk jaar opnieuw: visumaanvraag afgewezen. Dit is wat er gebeurt terwijl wij wegkijken.</p>
<p><strong>Thema's:</strong> IND, gezinshereniging, immigratiesysteem, 30 jaar wachten</p>
<p><a href="https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/">Lees artikel →</a></p>
</article>

<article class="serie-article coming-soon" style="border-left: 4px solid #ccc; padding-left: 20px; margin: 30px 0; opacity: 0.7;">
<h3>Het Verzameldossier: Drie Jaar Tegenwerking Gedocumenteerd</h3>
<p class="article-meta" style="color: #666; font-size: 0.9em;">Binnenkort</p>
<p>Mijn eigen verhaal: drie jaar lang systematisch tegengewerkt door Gemeente Meppel in mijn poging te trouwen met mijn Keniaanse partner. Complete documentatie van obstructiepatronen.</p>
<p><strong>Thema's:</strong> Gemeente Meppel, trouwen, obstructie, shifting goalposts</p>
</article>

<article class="serie-article coming-soon" style="border-left: 4px solid #ccc; padding-left: 20px; margin: 30px 0; opacity: 0.7;">
<h3>De Anatomie van Obstructie: Hoe Systemen Mensen Kapotmaken</h3>
<p class="article-meta" style="color: #666; font-size: 0.9em;">Binnenkort</p>
<p>Analyse van bureaucratische patronen die mensen kapotmaken: shifting goalposts, approval-retraction, catch-22's, communication fragmentation, en character assassination. Met concrete voorbeelden en hoe je ze herkent.</p>
<p><strong>Thema's:</strong> Bureaucratie, obstructiepatronen, systemen, analyse</p>
</article>

</div>

<div class="serie-footer" style="background: #1a1a1a; color: #fff; padding: 30px; margin: 50px 0;">
<h3 style="color: #fff;">Heb jij ook zo'n verhaal?</h3>
<p>Ken jij verhalen van mensen die kapot worden gemaakt door bureaucratische onmenselijkheid? Of heb je zelf zo'n ervaring? Laat het me weten.</p>
<p><a href="https://martiendejong.nl/#contact" style="color: #fff; font-weight: 600; text-decoration: underline;">Contact opnemen →</a></p>
</div>

<div class="about-author" style="margin: 40px 0;">
<h3>Over Martien de Jong</h3>
<p>Martien de Jong is technologie-entrepreneur, AI-architect, en schrijver. Hij bouwt systemen die mensen dienen in plaats van mensen gebruiken. Deze serie is persoonlijk: het gaat over zijn eigen strijd en die van anderen om menselijke waardigheid te behouden binnen bureaucratische processen.</p>
<p><a href="https://martiendejong.nl/">Meer over Martien →</a></p>
</div>"""

php_create_page = f'''<?php
require_once('wp-load.php');

// Check if page exists
$existing = get_page_by_path('serie-trouwen-en-de-gemeente');
if ($existing) {{
    wp_update_post(array(
        'ID' => $existing->ID,
        'post_content' => {repr(series_page_content)}
    ));
    echo "UPDATED_PAGE|" . $existing->ID . "|" . get_permalink($existing->ID);
}} else {{
    $page_id = wp_insert_post(array(
        'post_title' => 'Serie: Trouwen en de Gemeente',
        'post_content' => {repr(series_page_content)},
        'post_status' => 'publish',
        'post_type' => 'page',
        'post_name' => 'serie-trouwen-en-de-gemeente'
    ));
    echo "CREATED_PAGE|" . $page_id . "|" . get_permalink($page_id);
}}
?>'''

print("\nUploading via FTP...")

ftp_host = "martiendejong.nl"
ftp_user = "admin@martiendejong.nl"
ftp_token = "4mrkD8yqGxDaxqfPaqjW"

try:
    ftp = FTP()
    ftp.connect(ftp_host)
    ftp.login(ftp_user, ftp_token)
    ftp.cwd('public_html')

    # Update article
    from io import BytesIO
    script1 = f'update_footer_{int(time.time())}.php'
    ftp.storbinary(f'STOR {script1}', BytesIO(php_update.encode('utf-8')))

    # Create series page
    script2 = f'create_series_{int(time.time())}.php'
    ftp.storbinary(f'STOR {script2}', BytesIO(php_create_page.encode('utf-8')))

    ftp.quit()

    print("Executing scripts...")

    r1 = requests.get(f"https://martiendejong.nl/{script1}", timeout=30)
    print(f"Article: {r1.text}")

    r2 = requests.get(f"https://martiendejong.nl/{script2}", timeout=30)
    print(f"Series page: {r2.text}")

    # Cleanup
    ftp = FTP()
    ftp.connect(ftp_host)
    ftp.login(ftp_user, ftp_token)
    ftp.cwd('public_html')
    ftp.delete(script1)
    ftp.delete(script2)
    ftp.quit()

    print("\nDONE!")
    print("Article updated: https://martiendejong.nl/30-jaar-gescheiden-van-je-gezin-een-mensenleven-in-de-marge-van-het-systeem/")
    print("Series page: https://martiendejong.nl/serie-trouwen-en-de-gemeente/")

except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
