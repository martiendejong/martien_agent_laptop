<?php
if(($_GET['key']??'')!=='ar-batch-2026'){http_response_code(403);die('No.');}
header('Content-Type: application/json; charset=utf-8');
set_time_limit(120);
define('ABSPATH',__DIR__.'/');
require_once ABSPATH.'wp-load.php';

$action=$_GET['action']??'create';
$postNum=isset($_GET['post'])?absint($_GET['post']):0;

if($action==='status'){
    $posts=get_posts(['post_type'=>'post','post_status'=>['publish','future'],'posts_per_page'=>-1,'orderby'=>'date','order'=>'ASC']);
    $r=[];
    foreach($posts as $p){
        $faqs=get_post_meta($p->ID,'b2bk_qa_items',true);
        $r[]=['id'=>$p->ID,'title'=>$p->post_title,'date'=>$p->post_date,'status'=>$p->post_status,'faq_count'=>is_array($faqs)?count($faqs):0];
    }
    echo json_encode(['posts'=>$r,'total'=>count($r)],JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE);
    exit;
}

if($action==='cleanup'){@unlink(__FILE__);echo json_encode(['deleted'=>true]);exit;}

if(!$postNum||$postNum<1||$postNum>14){echo json_encode(['error'=>'Provide ?post=1 through ?post=14']);exit;}

// All 14 posts
$posts_data = [
1 => [
    'title'=>'Marcel Valsuani: The Son Who Preserved a Legacy',
    'slug'=>'marcel-valsuani-son-preserved-legacy',
    'date'=>'2026-02-17 09:00:00',
    'content'=>'<p>When Claude Valsuani died in 1923, the foundry he had built into one of Paris\'s most respected bronze ateliers faced an uncertain future. His son Marcel, barely in his twenties, stepped into a role that would have overwhelmed most young men. What followed was not merely a continuation — it was a reinvention that preserved and extended the Valsuani name for another half-century.</p>

<p>This article traces Marcel Valsuani\'s tenure at the helm of the family foundry through archival records, business documents, and the testimony of the bronzes themselves. The evidence reveals a figure far more significant than the footnote he has become in most art historical accounts.</p>

<h2>Inheriting an Institution</h2>

<p>By the time of Claude\'s death, the Valsuani foundry had established relationships with some of the most important sculptors of the early twentieth century. Marcel inherited not just a workshop but a network of artistic partnerships and a reputation for technical excellence. Contemporary business records indicate that the transition was remarkably smooth — suggesting that Marcel had been deeply involved in foundry operations well before his father\'s passing.</p>

<p>The stamp evidence supports this reading. As documented in our <a href="https://artrevisionist.com/valsuani/valsuani-bronze-authentication/">authentication guide</a>, the foundry\'s marks evolved during the transition period, but the quality of execution remained consistent. This continuity speaks to Marcel\'s competence and preparation.</p>

<h2>The Inter-War Period</h2>

<p>Under Marcel\'s direction, the foundry navigated the challenging inter-war years with strategic acumen. While some competitors contracted or closed, Valsuani maintained its output and even expanded its client base. Business records from the 1930s show new commissions from sculptors who had previously worked with rival foundries, including several who had been loyal to <a href="https://artrevisionist.com/valsuani/lost-wax-bronze-casting-the-valsuani-method/">Hébrard</a>.</p>

<p>Marcel\'s technical innovations during this period are often overlooked. He refined the lost-wax process to achieve even finer detail reproduction, and he introduced quality control measures that ensured consistency across large editions. These improvements are visible in the material characteristics of bronzes from this era — the patination is more uniform, the surface detail more crisp.</p>

<h2>The Post-War Challenge</h2>

<p>The Second World War disrupted Parisian foundry work, but Marcel ensured the survival of both the physical infrastructure and the institutional knowledge. After liberation, the foundry resumed operations with remarkable speed. Post-war bronzes show no decline in quality, a testament to Marcel\'s management during years of material scarcity.</p>

<p>Perhaps Marcel\'s most enduring contribution was his commitment to preserving the foundry\'s archives. Unlike many contemporaries who treated business records as disposable, Marcel maintained meticulous documentation. It is largely thanks to his record-keeping that researchers today can reconstruct the foundry\'s history — including the <a href="https://artrevisionist.com/marcello-valsuani-myth-debunked/">correction of the Marcello myth</a> that had already begun circulating during his lifetime.</p>

<h2>Legacy of the Second Generation</h2>

<p>Marcel Valsuani\'s contribution to art history extends beyond mere stewardship. He was an active participant in the evolution of bronze casting technique, a shrewd business operator who kept the foundry viable through decades of upheaval, and an unintentional archivist whose records now serve scholarship. As detailed in our overview of <a href="https://artrevisionist.com/valsuani/the-valsuani-legacy/">the Valsuani legacy</a>, the full story of this foundry cannot be told without acknowledging that it was, for most of its operational life, Marcel\'s foundry as much as Claude\'s.</p>

<p>That art history has largely reduced him to a transitional figure says more about the field\'s preference for origin stories than about Marcel\'s actual significance. The bronzes he produced speak for themselves.</p>'
],

2 => [
    'title'=>'Valsuani vs. Hébrard: Two Foundries, Two Philosophies of Bronze',
    'slug'=>'valsuani-vs-hebrard-foundries-compared',
    'date'=>'2026-02-18 09:00:00',
    'content'=>'<p>In the world of fine art bronze casting, two Parisian foundries stand above all others in reputation and historical significance: Valsuani and Hébrard. Both operated during the golden age of lost-wax casting, both worked with legendary sculptors, and both produced masterpieces that now reside in the world\'s greatest museums. Yet their approaches to the craft were fundamentally different.</p>

<p>This comparative analysis draws on primary source materials, surviving business records, and technical examination of bronzes from both foundries to illuminate how two workshops, operating in the same city during the same era, could produce such distinct results.</p>

<h2>Origins and Philosophy</h2>

<p>The Hébrard foundry, established by Adrien-Aurélien Hébrard in the late nineteenth century, positioned itself as a gallery-foundry hybrid. Hébrard was as much an art dealer as a founder, and his business model reflected this dual identity. He acquired exclusive casting rights, controlled edition sizes, and marketed finished works directly to collectors.</p>

<p>The Valsuani foundry, by contrast, was founded by <a href="https://artrevisionist.com/claude-valsuani-biography/">Claude Valsuani</a> as a service foundry. Valsuani cast what sculptors brought to him, maintaining technical excellence without seeking to control the commercial distribution of the works. As our research into <a href="https://artrevisionist.com/valsuani/who-founded-the-valsuani-foundry/">the foundry\'s origins</a> demonstrates, this service-oriented approach was rooted in Claude\'s training in the Italian metalworking tradition.</p>

<h2>Technical Differences</h2>

<p>Both foundries employed the lost-wax (<em>cire perdue</em>) technique, but their execution differed significantly. Hébrard bronzes tend toward a smoother, more polished finish. The foundry favored rich, dark patinas and meticulous chasing that sometimes softened the sculptor\'s original surface texture.</p>

<p>Valsuani bronzes, as documented in our <a href="https://artrevisionist.com/valsuani/lost-wax-bronze-casting-the-valsuani-method/">technical analysis</a>, preserve more of the original sculptural surface. Claude Valsuani\'s approach prioritized fidelity to the artist\'s model over decorative refinement. This made Valsuani the preferred foundry for sculptors who valued textural authenticity — including those working in more expressive, less polished styles.</p>

<h2>The Degas Question</h2>

<p>The most famous intersection of these two foundries involves Edgar Degas. After Degas\'s death in 1917, his heirs commissioned Hébrard to cast the posthumous bronze editions that would become some of the most valuable sculptures in existence. Yet Degas himself had never worked with Hébrard during his lifetime. The choice of foundry was the heirs\', not the artist\'s.</p>

<p>This raises a question that collectors and scholars continue to debate: would Degas have chosen differently? The technical evidence suggests that Valsuani\'s approach — less interventionist, more faithful to surface texture — might have better served Degas\'s experimental modeling technique. The wax originals were rough, spontaneous, and deliberately unfinished. Hébrard\'s polishing process, while producing beautiful objects, arguably transformed them into something Degas never intended.</p>

<h2>Market Implications</h2>

<p>For collectors and authenticators, understanding the philosophical differences between these foundries is not merely academic. As detailed in our <a href="https://artrevisionist.com/authenticate-valsuani-bronze/">authentication guide</a>, the technical choices each foundry made left distinctive physical signatures in the bronze. Confusing one foundry\'s characteristics for another\'s can lead to misattribution — a problem that persists in auction catalogs to this day.</p>

<p>The Valsuani-Hébrard comparison ultimately illuminates a fundamental tension in art production: between the commercial impulse to refine and the artistic imperative to preserve. Both foundries produced extraordinary work. But they did so in service of different values, and understanding those values is essential for anyone who seeks to understand the bronzes themselves.</p>'
],

3 => [
    'title'=>'The Degas Bronzes: Why the Valsuani Connection Matters',
    'slug'=>'degas-bronzes-valsuani-connection',
    'date'=>'2026-02-19 09:00:00',
    'content'=>'<p>The seventy-odd bronzes cast from Edgar Degas\'s original wax and clay models represent one of art history\'s most complex posthumous legacies. Universally attributed to the Hébrard foundry, they are among the most exhibited, most published, and most expensive sculptures of the modern era. What is less widely known — and what matters enormously for authentication and interpretation — is that the Valsuani foundry\'s connection to the Degas circle runs deeper than standard accounts acknowledge.</p>

<p>This article examines the documentary evidence for Valsuani\'s role in the broader Degas bronze story, and argues that understanding this connection is essential for accurate provenance research.</p>

<h2>The Standard Narrative</h2>

<p>The accepted history is straightforward: after Degas died in 1917, approximately 150 wax and clay sculptures were found in his studio. His heirs selected 73 for casting and contracted Adrien-Aurélien Hébrard to produce editions. The Hébrard foundry cast these between 1919 and 1937, producing sets lettered A through T, plus several additional sets for the family and the founder.</p>

<p>This narrative, while accurate in its broad strokes, obscures important complications. The casting process extended over nearly two decades, during which the foundry landscape in Paris shifted dramatically.</p>

<h2>The Valsuani Factor</h2>

<p>What archival research reveals is that <a href="https://artrevisionist.com/claude-valsuani-biography/">Claude Valsuani</a> and his foundry were not strangers to the Degas estate. Several sculptors in Degas\'s circle — artists who knew the master personally and understood his working methods — chose Valsuani over Hébrard for their own bronze editions. This was not coincidental.</p>

<p>The technical philosophy of the Valsuani foundry, as detailed in our analysis of <a href="https://artrevisionist.com/valsuani/lost-wax-bronze-casting-the-valsuani-method/">the Valsuani method</a>, emphasized minimal intervention in the casting process. For sculptors who valued raw, unfinished surfaces — as Degas demonstrably did — this approach was preferable to Hébrard\'s more interventionist finishing.</p>

<h2>Authentication Implications</h2>

<p>The practical significance of this history becomes clear in the context of authentication. Over the decades, unauthorized casts and outright forgeries of Degas bronzes have entered the market. Distinguishing legitimate Hébrard casts from later copies requires understanding exactly what technical signatures the original foundry left — and what they did not.</p>

<p>As outlined in our <a href="https://artrevisionist.com/authenticate-valsuani-bronze/">Valsuani authentication guide</a>, foundry identification depends on recognizing specific material characteristics. When these characteristics are misunderstood — when, for example, a less polished surface is taken as evidence of inferior quality rather than a different foundry tradition — authentication errors follow.</p>

<h2>Rewriting the Record</h2>

<p>The Degas-Valsuani connection also matters for how we understand the history of the <a href="https://artrevisionist.com/marcello-valsuani-myth-debunked/">Valsuani foundry</a> itself. A foundry trusted by artists in Degas\'s intimate circle was not a second-tier operation. It was a workshop whose technical standards were recognized by the most demanding practitioners of the era.</p>

<p>This revision is not about diminishing Hébrard\'s achievement — the Degas bronzes they produced are masterpieces of the founder\'s art. It is about restoring accuracy to a historical record that has been simplified to the point of distortion. For collectors, dealers, and scholars, the stakes are not merely academic. Every misattribution represents a failure of due diligence, and every corrected record strengthens the market\'s integrity.</p>'
],

4 => [
    'title'=>'Rembrandt Bugatti at Valsuani: The Animal Sculptor and His Foundry',
    'slug'=>'rembrandt-bugatti-valsuani-animal-sculptor',
    'date'=>'2026-02-20 09:00:00',
    'content'=>'<p>Rembrandt Bugatti\'s animal sculptures are among the most emotionally powerful and technically accomplished bronzes of the early twentieth century. His ability to capture the living essence of animals — their tension, their weight, their psychological presence — remains unmatched. What is often understated in accounts of his work is the crucial role played by the foundry that transformed his models into bronze: the atelier of <a href="https://artrevisionist.com/claude-valsuani-biography/">Claude Valsuani</a>.</p>

<p>This article examines the Bugatti-Valsuani partnership through surviving bronzes, foundry records, and the technical evidence preserved in the castings themselves.</p>

<h2>An Artist Who Needed His Founder</h2>

<p>Bugatti\'s working method was distinctive and demanding. He modeled directly from life, spending hours at the Antwerp Zoo observing animals before working in plasticine with extraordinary speed. His surfaces were deliberately rough, preserving finger marks and tool impressions as integral to the sculpture\'s expressiveness.</p>

<p>This approach required a foundry willing to reproduce these surfaces without "improving" them. Where a lesser foundry might have smoothed away the evidence of the artist\'s hand, Valsuani\'s philosophy — documented in our analysis of <a href="https://artrevisionist.com/valsuani/lost-wax-bronze-casting-the-valsuani-method/">the Valsuani casting method</a> — was to serve the sculptor\'s intention with maximum fidelity.</p>

<h2>Technical Evidence in the Bronzes</h2>

<p>Examination of authenticated Bugatti bronzes cast by Valsuani reveals several consistent characteristics. The lost-wax process captured even the subtlest surface textures — the grain of the plasticine, the pressure variations of the artist\'s fingers, the marks of his wooden modeling tools. The patinas, typically warm browns and greens, were applied to enhance rather than mask these surfaces.</p>

<p>The <a href="https://artrevisionist.com/valsuani/valsuani-bronze-authentication/">foundry stamps</a> on Bugatti bronzes follow the standard Valsuani conventions of their period, providing reliable dating evidence. Combined with edition numbers and the sculptor\'s signature, these marks constitute the primary authentication framework for Bugatti\'s oeuvre.</p>

<h2>The Market and Misattribution</h2>

<p>Bugatti bronzes command extraordinary prices at auction, which has inevitably attracted forgeries and misattributions. Understanding the specific technical characteristics of Valsuani casting is essential for anyone evaluating a purported Bugatti bronze. A casting that looks too smooth, too uniform, or too mechanically perfect is unlikely to be a genuine Valsuani product — regardless of what stamps it may bear.</p>

<p>The tragedy of Bugatti\'s short life — he died by suicide in 1916, at just thirty-one — adds emotional weight to these objects but should not cloud the technical analysis required for their authentication. Sentiment is not provenance.</p>

<h2>A Partnership of Principles</h2>

<p>The Bugatti-Valsuani relationship exemplifies what made the <a href="https://artrevisionist.com/topics/valsuani/">Valsuani foundry</a> distinctive: a commitment to serving the artist\'s vision rather than imposing the founder\'s aesthetic preferences. In an era when foundries increasingly saw themselves as collaborators or even co-creators, Valsuani maintained the discipline of technical service. For an artist as singular as Rembrandt Bugatti, this was exactly what was needed.</p>

<p>The bronzes that survive from this partnership are not just beautiful objects — they are documents of a working relationship built on mutual respect between an artist of extraordinary sensitivity and a founder of extraordinary skill.</p>'
],

5 => [
    'title'=>'How Auction Houses Get Valsuani Wrong: Common Catalog Errors',
    'slug'=>'auction-houses-valsuani-catalog-errors',
    'date'=>'2026-02-21 09:00:00',
    'content'=>'<p>In the course of our research into the Valsuani foundry, we have reviewed hundreds of auction catalogs spanning decades and continents. The pattern that emerges is troubling: the same errors appear again and again, copied from one catalog to the next, creating a self-reinforcing cycle of misinformation that inflates some attributions and undermines others.</p>

<p>This article documents the most common Valsuani-related errors found in major auction catalogs and explains why they matter — not as an exercise in criticism, but as a resource for collectors, dealers, and researchers who depend on catalog accuracy.</p>

<h2>Error #1: The Marcello Attribution</h2>

<p>The most pervasive error is the attribution of the foundry\'s founding to "Marcello Valsuani." As we have documented in detail in our <a href="https://artrevisionist.com/marcello-valsuani-myth-debunked/">investigation of the Marcello myth</a>, no primary source evidence supports this attribution. The foundry was established by Claude Valsuani, son of Carlo — not Marcello. Yet this error continues to appear in catalogs from major houses including Christie\'s, Sotheby\'s, and Bonhams, often word-for-word from previous entries.</p>

<p>The persistence of this error illustrates a systemic problem: catalog entries are frequently compiled by copying previous catalog entries rather than consulting primary sources. When the original entry contains an error, that error propagates indefinitely.</p>

<h2>Error #2: Conflated Periods</h2>

<p>A second common error involves the conflation of different operational periods. The foundry under <a href="https://artrevisionist.com/claude-valsuani-biography/">Claude Valsuani</a> (pre-1923) and under Marcel Valsuani (post-1923) used different stamps and had different artistic partnerships. Catalogs frequently describe bronzes from one period using language appropriate to the other, leading to inconsistencies between the physical evidence (stamps, patina) and the provenance narrative.</p>

<h2>Error #3: Stamp Misidentification</h2>

<p>Valsuani stamps evolved over the foundry\'s operational life. Our <a href="https://artrevisionist.com/valsuani/valsuani-bronze-authentication/">authentication research</a> has cataloged these variations in detail. Auction catalogs frequently misdate bronzes because they fail to account for these stamp variations, or because they apply knowledge of one stamp period to bronzes from another.</p>

<h2>Error #4: Edition Number Confusion</h2>

<p>Valsuani edition numbering follows conventions that differ from those of other foundries. Catalogs that apply Hébrard numbering conventions to Valsuani bronzes — or vice versa — generate misleading provenance information. This error is particularly consequential because edition numbers directly affect value.</p>

<h2>Error #5: Technique Descriptions</h2>

<p>Many catalogs describe the Valsuani <a href="https://artrevisionist.com/valsuani/lost-wax-bronze-casting-the-valsuani-method/">lost-wax technique</a> using generic language that could apply to any foundry. The specific characteristics of Valsuani casting — surface fidelity, patination approach, interior finishing — are rarely mentioned, even when they constitute the strongest evidence for attribution.</p>

<h2>Why This Matters</h2>

<p>Catalog errors are not harmless. They affect valuations, insurance assessments, museum attributions, and scholarly citations. A collector who purchases a bronze on the basis of an inaccurate catalog entry may be overpaying for a misattributed work or underpaying for a correctly attributed one that the catalog has failed to properly document.</p>

<p>The solution is not to distrust auction houses — they perform an essential market function — but to treat catalog entries as starting points for research rather than final authorities. Primary source evidence, technical examination, and consultation with specialists remain indispensable.</p>'
],

6 => [
    'title'=>'The Valsuani Stamp Guide: A Visual Timeline of Foundry Marks',
    'slug'=>'valsuani-stamp-guide-visual-timeline',
    'date'=>'2026-02-22 09:00:00',
    'content'=>'<p>For collectors, dealers, and authenticators, the foundry stamp is often the first piece of evidence examined when evaluating a Valsuani bronze. Yet despite its importance, no comprehensive public guide to Valsuani stamp variations has existed — until now. This article presents a systematic timeline of known Valsuani foundry marks, based on our examination of authenticated bronzes, archival photographs, and foundry records.</p>

<p>The stamps documented here represent the current state of our research. As with all aspects of <a href="https://artrevisionist.com/valsuani/valsuani-bronze-authentication/">Valsuani authentication</a>, this guide should be used as a framework for analysis, not as a substitute for hands-on examination by qualified experts.</p>

<h2>Early Period: Claude Valsuani (c. 1905–1923)</h2>

<p>The earliest known Valsuani stamps are relatively simple: the name "VALSUANI" in capital letters, sometimes accompanied by "CIRE PERDUE" (lost wax). These stamps tend to be smaller and more crisply struck than later versions. The incuse lettering (stamped into the bronze) is characteristic of this period.</p>

<p>Variations during the Claude period include differences in letter spacing, font weight, and the inclusion or exclusion of "PARIS" as a location identifier. These variations likely reflect different stamp dies rather than different periods, but they can assist in dating when combined with other evidence.</p>

<h2>Transition Period (c. 1923–1930)</h2>

<p>Following <a href="https://artrevisionist.com/claude-valsuani-biography/">Claude\'s death in 1923</a>, the foundry stamps underwent gradual changes under Marcel\'s direction. The transition was not abrupt — early Marcel-period bronzes sometimes bear stamps that are virtually identical to late Claude-period marks. This overlap complicates dating but is consistent with the documented continuity of operations.</p>

<h2>Marcel Period (c. 1930–1960s)</h2>

<p>The mature Marcel period saw the introduction of larger, more standardized stamps. The lettering became bolder, and the inclusion of edition numbers became more consistent. Some bronzes from this period also bear a circular cachet in addition to the linear stamp — a practice not documented in the Claude period.</p>

<h2>Late Period (c. 1960s–closure)</h2>

<p>The foundry\'s final operational decades produced stamps that are often less precisely struck, possibly reflecting wear on the stamp dies or changes in the stamping process. These late-period marks are the most commonly encountered in the market, as the foundry\'s later output was numerically larger than its earlier production.</p>

<h2>Red Flags</h2>

<p>Certain stamp characteristics suggest inauthenticity. Stamps that are too perfectly uniform may indicate modern reproduction. Stamps that combine elements from different periods — for example, a Claude-era font with Marcel-era formatting — are suspicious. As noted in our analysis of <a href="https://artrevisionist.com/auction-houses-valsuani-catalog-errors/">common catalog errors</a>, stamp evidence must always be evaluated in conjunction with other authentication criteria: patina, casting quality, provenance documentation, and stylistic analysis.</p>

<p>This guide will be updated as new evidence emerges. Authentication is an evolving discipline, and the Valsuani record — like all historical records — is subject to revision as new primary sources come to light. We encourage collectors and researchers to contact Art Revisionist with documentation of stamp variations not covered here.</p>'
],

7 => [
    'title'=>'Carlo Valsuani: The Forgotten Patriarch of a Bronze Dynasty',
    'slug'=>'carlo-valsuani-forgotten-patriarch',
    'date'=>'2026-02-23 09:00:00',
    'content'=>'<p>Behind every great foundry stands a founder — and behind the Valsuani foundry stands a figure that art history has almost entirely forgotten. Carlo Valsuani, father of <a href="https://artrevisionist.com/claude-valsuani-biography/">Claude</a> and true patriarch of the dynasty, has been erased from the historical record so thoroughly that even his name has been replaced by the fictitious "Marcello" in most published accounts.</p>

<p>This article presents the results of genealogical and archival research that restores Carlo Valsuani to his rightful place in the story of one of Paris\'s most important bronze foundries.</p>

<h2>The Archival Evidence</h2>

<p>The evidence for Carlo Valsuani\'s identity comes from Italian civil records — birth certificates, marriage documents, and municipal registers from Crescenzago, the small town near Milan where the family originated. These primary sources are unambiguous: Carlo Valsuani was born, married, and raised a family that included his son Claude, who would later establish the Parisian foundry.</p>

<p>As detailed in our <a href="https://artrevisionist.com/marcello-valsuani-myth-debunked/">investigation of the Marcello myth</a>, no document bearing the name "Marcello Valsuani" has been found in the relevant Italian archives. The name appears only in secondary sources — auction catalogs, museum notes, and art historical publications — all of which cite each other rather than primary evidence.</p>

<h2>Carlo\'s World</h2>

<p>Crescenzago in the late nineteenth century was a community with deep roots in metalworking and artisanal craftsmanship. The region\'s traditions of metal casting, bronze working, and decorative metalwork formed the cultural context in which Carlo raised his son. While we have no direct evidence that Carlo himself was a bronze worker, the environment in which Claude grew up was saturated with the skills and knowledge that would later define his career.</p>

<p>The passport records that document Claude\'s journey from Italy to France include the notation "figlio di Carlo" — son of Carlo. This administrative detail, mundane in its original context, becomes a crucial piece of evidence when set against decades of published misinformation.</p>

<h2>Why the Name Was Lost</h2>

<p>How did Carlo become "Marcello"? The most likely explanation is a simple transcription error, possibly in an early French administrative document or business record, that was subsequently copied and amplified by repetition. In an era before digital records and easy cross-referencing, such errors were common and almost impossible to correct once they entered circulation.</p>

<p>The transformation of Carlo into Marcello also reflects a broader pattern in art historical writing: the tendency to build narratives around a single founding figure, to mythologize origins, and to prefer compelling stories over documentary accuracy. "Marcello" sounds grander than "Carlo" — and in the absence of anyone checking the primary sources, the grander name prevailed.</p>

<h2>Restoring the Record</h2>

<p>The correction of Carlo Valsuani\'s name is not a trivial matter of genealogy. It is a test case for the standards we apply to art historical research more broadly. If a foundry\'s own founder can be misidentified for over a century — in published scholarship, in auction catalogs, in museum records — what other errors remain embedded in the historical record, unchallenged because unchecked?</p>

<p>At <a href="https://artrevisionist.com/topics/valsuani/">Art Revisionist</a>, we believe that accuracy is not optional in art history. Carlo Valsuani deserves to be remembered correctly — not because names matter more than bronzes, but because getting the names right is the minimum standard of scholarly integrity.</p>'
],

8 => [
    'title'=>'The Kponyungo Firespitter: Terror and Protection in Senufo Funerary Rites',
    'slug'=>'kponyungo-firespitter-senufo-funerary-rites',
    'date'=>'2026-02-24 09:00:00',
    'content'=>'<p>In the twilight hours of a Senufo funeral, a figure emerges from the bush that is designed to terrify. The Kponyungo — the "firespitter" mask — combines features of hyena, warthog, antelope, and chameleon into a single composite creature that embodies the dangerous forces that threaten the community. Far from being merely theatrical, this mask performs essential spiritual work: it escorts the deceased safely from the world of the living to the world of the ancestors.</p>

<p>This article examines the Kponyungo through the lens of Senufo cosmology and ritual practice, drawing on field research and the documented testimony of initiated Senufo elders.</p>

<h2>Anatomy of a Composite Being</h2>

<p>The Kponyungo is not a representation of any single animal. It is a deliberate fusion of dangerous creatures, each contributing specific symbolic attributes. The hyena jaw evokes the power of scavengers who mediate between death and life. The warthog tusks represent aggressive protection. The antelope horns symbolize the wild bush — the domain outside human society where spirits dwell.</p>

<p>This composite nature is central to the mask\'s function within the <a href="https://artrevisionist.com/senufo-hornbill/poro-initiation-spiritual-education-through-art/">Poro initiation system</a>. The Kponyungo represents forces that are real and present in Senufo cosmology — not mythological abstractions but active spiritual agents that must be managed through proper ritual.</p>

<h2>The Funeral Context</h2>

<p>Senufo funerary rites are elaborate multi-day ceremonies that mobilize the entire community. The Kponyungo appears at specific moments in these proceedings, typically at night, accompanied by percussive music and the participation of senior Poro members. Its role is dual: to frighten away malevolent spirits that might interfere with the soul\'s transition, and to demonstrate the community\'s spiritual authority over the forces of death.</p>

<p>The "firespitting" element — achieved through the concealed manipulation of burning materials — adds a visceral dimension to the performance. This is not stage magic but spiritual technology, a demonstration of power that reinforces the Poro society\'s authority within the community.</p>

<h2>Western Misreadings</h2>

<p>In Western museum contexts, the Kponyungo is typically displayed as a static object — stripped of its sound, its movement, its fire, and its night. As explored in our analysis of <a href="https://artrevisionist.com/senufo-hornbill/from-sacred-grove-to-western-gallery-cultural-translation-and-loss/">cultural translation and loss</a>, this decontextualization transforms a powerful ritual instrument into a curiosity. The mask\'s deliberate ugliness — its function is to terrify — becomes "expressive" or "primitive" in the language of Western art criticism.</p>

<p>Understanding the Kponyungo on its own terms requires abandoning the assumption that all art aspires to beauty. This mask aspires to power, to protection, to the safe passage of the dead. Judging it by aesthetic criteria is not just inappropriate — it fundamentally misunderstands the object.</p>

<h2>Preservation and Knowledge</h2>

<p>As <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-people-guardians-of-ancient-wisdom/">Senufo traditional knowledge</a> faces pressures from modernization and religious conversion, the ritual contexts that give the Kponyungo its meaning are increasingly endangered. The masks that survive in collections worldwide are material traces of a living spiritual practice — but without the knowledge of how they were used, they remain mute objects.</p>

<p>Documenting the Kponyungo\'s full context — its ritual function, its symbolic language, its relationship to the broader Poro system — is an act of cultural preservation as much as art historical research.</p>'
],

9 => [
    'title'=>'Senufo Blacksmiths: The Sacred Metalworkers Who Shape Society',
    'slug'=>'senufo-blacksmiths-sacred-metalworkers',
    'date'=>'2026-02-25 09:00:00',
    'content'=>'<p>In Senufo society, the blacksmith is not merely a craftsman — he is a figure of immense spiritual power, feared and respected in equal measure. The Fonombélé, as the blacksmith caste is known, occupy a unique position at the intersection of the physical and metaphysical worlds. They transform raw ore into tools, weapons, and ritual objects, and in doing so, they perform a kind of alchemy that is understood as fundamentally sacred.</p>

<p>This article examines the role of the Fonombélé in Senufo artistic production and spiritual life, and argues that understanding the blacksmith\'s position is essential for interpreting Senufo art correctly.</p>

<h2>Between Worlds</h2>

<p>The Senufo blacksmith\'s spiritual authority derives from his relationship with fire and metal — elements that belong to the bush, the wild space outside human settlement where dangerous spirits reside. By mastering these elements, the blacksmith demonstrates a capacity to navigate between the human world and the spirit world that sets him apart from ordinary community members.</p>

<p>This liminal position has practical consequences. Blacksmiths live in their own quarters, marry within their caste, and maintain specialized knowledge that is transmitted only within the Fonombélé lineage. Their children are born into their spiritual status — it cannot be acquired or renounced.</p>

<h2>Creators of Ritual Objects</h2>

<p>Many of the objects that define Senufo art in Western collections were made by blacksmiths. Iron staffs, ritual implements, and the metal components of masks and figures all pass through the blacksmith\'s forge. Even wooden carvings — including the <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-hornbill-sacred-symbol-of-creation/">sacred hornbill figures</a> — are traditionally commissioned and ritually activated with the blacksmith\'s participation.</p>

<p>The tools that woodcarvers use are themselves products of the forge, and the relationship between carver and blacksmith is governed by protocols that ensure the spiritual integrity of the finished object. A mask or figure that has not been properly sanctioned by the appropriate spiritual authorities — including the blacksmith — lacks the power that gives it meaning within the <a href="https://artrevisionist.com/senufo-hornbill/poro-initiation-spiritual-education-through-art/">Poro system</a>.</p>

<h2>The Forge as Sacred Space</h2>

<p>The blacksmith\'s forge is itself a ritual space, governed by taboos and protocols that regulate who may enter, when work may be performed, and what activities are forbidden in its proximity. The sounds of the forge — the rhythmic hammering, the hiss of quenching — are not just industrial noise but a kind of sacred music that announces the transformation of matter.</p>

<p>This understanding of the forge challenges Western assumptions about the distinction between "art" and "craft." In the Senufo context, there is no such distinction. The blacksmith who forges a hoe and the blacksmith who forges a ritual staff are performing fundamentally the same act — the sacred transformation of raw material into culturally meaningful form.</p>

<h2>Implications for Interpretation</h2>

<p>When Senufo metalwork appears in Western collections, the blacksmith\'s identity and spiritual role are almost never mentioned. The object is attributed to "Senufo peoples" as though it emerged spontaneously from a collective, rather than from the hands of a specific individual operating within a specific spiritual framework.</p>

<p>Recognizing the Fonombélé\'s role is not just an act of proper attribution — it is essential for understanding what these objects <em>are</em>. A Senufo iron staff is not a decorative object that happens to be made of iron. It is an expression of the blacksmith\'s sacred authority, materialized through a process that is simultaneously technical and spiritual.</p>'
],

10 => [
    'title'=>'Deble Rhythm Pounders: When Sculpture Becomes Sound',
    'slug'=>'deble-rhythm-pounders-sculpture-becomes-sound',
    'date'=>'2026-02-26 09:00:00',
    'content'=>'<p>Among the most visually striking objects in Senufo art are the Deble — tall, female figures carved from a single piece of wood, often exceeding human height, with elongated necks, stylized features, and a flat base designed to be lifted and struck against the ground. In Western museums, they stand silently on pedestals. In their original context, they were instruments of sound — percussion figures that transformed grief into rhythm during funeral ceremonies.</p>

<p>This article explores the Deble as both sculpture and musical instrument, arguing that the separation of these functions in Western presentation fundamentally distorts their meaning.</p>

<h2>Form Follows Function</h2>

<p>Every aspect of the Deble\'s form is determined by its dual purpose. The elongated proportions are not merely aesthetic choices — they create a resonant column of wood that produces a specific tonal quality when struck against packed earth. The flat base is not a sculptural convention but a functional surface designed for percussive impact. The overall weight and balance are calibrated for the rhythmic lifting and dropping that constitutes "playing" the instrument.</p>

<p>Understanding this functionality explains features that have puzzled Western art historians. The relative simplicity of surface detail, for example, is not a sign of less accomplished carving but a practical choice — elaborate surface texture would be damaged by repeated impact with the ground.</p>

<h2>The Funeral Performance</h2>

<p>Deble appear at Senufo funerals as part of the complex ceremonial sequence managed by the <a href="https://artrevisionist.com/senufo-hornbill/poro-initiation-spiritual-education-through-art/">Poro society</a>. Groups of initiated men lift and lower the heavy figures in coordinated rhythm, producing a deep, resonant sound that carries across the village. This sound accompanies specific phases of the funeral proceedings and is understood as a communication with the ancestor spirits who are receiving the deceased.</p>

<p>The physical effort required to "play" a Deble is considerable — these are heavy objects, sometimes weighing thirty kilograms or more. The endurance demonstrated by the performers is itself a form of tribute to the deceased, a physical expression of communal grief and solidarity.</p>

<h2>Gender and Representation</h2>

<p>Deble figures are consistently female in form, yet they are handled exclusively by men during ceremonies. This apparent contradiction reflects the complex gender dynamics of <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-people-guardians-of-ancient-wisdom/">Senufo society</a>, where female imagery often represents concepts of fertility, continuity, and the earth — themes directly relevant to funerary contexts where the community affirms its survival despite the loss of a member.</p>

<p>The female form of the Deble is not portraiture but cosmological symbolism. The figure represents the generative power that counterbalances death, the assurance that the community\'s life force continues.</p>

<h2>The Silent Museum</h2>

<p>A Deble in a museum is a contradiction in terms. Displayed as a visual object, it is denied its auditory dimension — the very dimension that defines its cultural function. As we have explored in our analysis of <a href="https://artrevisionist.com/senufo-hornbill/from-sacred-grove-to-western-gallery-cultural-translation-and-loss/">cultural translation</a>, this transformation from instrument to sculpture represents a fundamental loss of meaning that no amount of contextual wall text can fully restore.</p>

<p>The challenge for institutions that hold Deble figures is to find ways of communicating their sonic dimension — through recordings, through performance, through immersive presentation — without reducing them to mere spectacle. The sound of the Deble is not entertainment. It is a prayer.</p>'
],

11 => [
    'title'=>'Colonial Collectors and Senufo Art: A History of Misunderstanding',
    'slug'=>'colonial-collectors-senufo-art-misunderstanding',
    'date'=>'2026-02-27 09:00:00',
    'content'=>'<p>The first Senufo objects to reach European collections arrived not as art but as ethnographic specimens — curiosities gathered by colonial administrators, missionaries, and military officers who understood little about the cultures from which they took them. The categories imposed on these objects during the colonial period — "fetish," "idol," "primitive art" — have shaped Western perception of Senufo creativity for over a century, and their influence persists in subtle but consequential ways.</p>

<p>This article traces the history of Senufo art collecting from the colonial period to the present, documenting how the circumstances of acquisition have distorted the interpretation of the objects themselves.</p>

<h2>The Colonial Gaze</h2>

<p>French colonial presence in what is now Côte d\'Ivoire intensified in the late nineteenth century, and the first systematic collections of Senufo material culture date from this period. Colonial collectors operated within a framework that classified African societies on a scale from "primitive" to "civilized," and the objects they collected were understood as evidence for these classifications.</p>

<p>The sacred objects of the <a href="https://artrevisionist.com/senufo-hornbill/poro-initiation-spiritual-education-through-art/">Poro society</a> presented a particular challenge to colonial understanding. Their deliberate secrecy was interpreted as evidence of "superstition" rather than as a sophisticated system of knowledge management. Objects that were confiscated or purchased under duress were cataloged without reference to their ritual functions, establishing a pattern of decontextualization that continues to this day.</p>

<h2>The "Primitivism" Turn</h2>

<p>The early twentieth century saw a dramatic shift in European attitudes toward African art, driven by the avant-garde\'s "discovery" of its formal power. Artists including Picasso, Braque, and Modigliani found in African sculpture formal solutions to problems they were confronting in their own work. This engagement, while artistically productive, was fundamentally appropriative — it valued African objects for what they could offer European art, not for what they meant within their own cultural systems.</p>

<p>Senufo objects participated in this transformation. <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-hornbill-sacred-symbol-of-creation/">Hornbill figures</a>, masks, and figure sculptures were exhibited alongside European avant-garde work, implicitly positioning them as precursors to or raw material for Western modernism.</p>

<h2>The Market Era</h2>

<p>The post-independence period saw the emergence of a commercial market for Senufo art that introduced new forms of misunderstanding. Demand from Western collectors created incentives for the production of objects specifically for export — works that mimicked the forms of sacred objects but were created outside the ritual frameworks that gave originals their meaning.</p>

<p>This market dynamic has complicated authentication and interpretation ever since. As explored in our analysis of the <a href="https://artrevisionist.com/senufo-art-museums-fashion/">Yves Saint Laurent collection</a>, the prices paid for Senufo objects at major auctions reflect Western aesthetic judgments that may have little relationship to the objects\' cultural significance within Senufo society.</p>

<h2>Toward Honest Engagement</h2>

<p>Correcting the legacy of colonial collecting does not require abandoning the study of Senufo art in Western institutions. It requires honesty about the conditions under which objects were acquired, humility about the limits of outsider understanding, and a commitment to centering <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-people-guardians-of-ancient-wisdom/">Senufo voices</a> in the interpretation of Senufo objects.</p>

<p>The objects themselves are not diminished by honest reckoning with their histories. If anything, understanding the full story of how a Senufo mask traveled from a sacred grove to a museum vitrine makes it a more powerful and more interesting object — not less.</p>'
],

12 => [
    'title'=>'The Sandogo Society: Women\'s Power in Senufo Spiritual Life',
    'slug'=>'sandogo-society-womens-power-senufo',
    'date'=>'2026-02-28 09:00:00',
    'content'=>'<p>Western accounts of Senufo society have overwhelmingly focused on the Poro — the male initiation society that has been extensively documented and whose art objects dominate museum collections. But Senufo spiritual life is not solely a male domain. The Sandogo, a women\'s divination society, wields authority that complements and in some domains exceeds that of the Poro. Its near-total absence from art historical literature represents one of the most significant gaps in our understanding of Senufo culture.</p>

<p>This article examines the Sandogo society, its spiritual functions, its material culture, and the reasons for its scholarly neglect.</p>

<h2>The Divination Mandate</h2>

<p>The Sandogo\'s primary function is divination — the diagnosis of spiritual imbalances that cause illness, misfortune, and social discord. Sandogo diviners, exclusively women, are called to their vocation through spiritual election, often manifesting in illness or unusual experiences that are recognized by existing members as signs of calling.</p>

<p>The authority of Sandogo diviners is not subordinate to male authority. In matters of spiritual diagnosis, the Sandogo\'s word is final. Chiefs, elders, and even senior Poro members consult Sandogo diviners when confronting problems that resist other solutions. This represents a genuine form of female power within a society that Western observers have too often characterized as patriarchal.</p>

<h2>Material Culture</h2>

<p>The Sandogo produces its own category of material culture — divination instruments, figurative sculptures, and ritual objects that are distinct from Poro art in both form and function. These objects are rarely collected and even more rarely exhibited, partly because they are smaller and less visually dramatic than Poro masks, and partly because colonial-era collectors, overwhelmingly male, had limited access to women\'s ritual spaces.</p>

<p>The result is a profound collection bias. Museums that hold dozens of Poro masks may own not a single Sandogo object. This absence distorts our understanding of Senufo creativity, presenting it as exclusively male when it is in fact a dialogue between complementary gendered institutions.</p>

<h2>Complementary Power</h2>

<p>The relationship between Poro and Sandogo is not one of competition but of complementarity. The <a href="https://artrevisionist.com/senufo-hornbill/poro-initiation-spiritual-education-through-art/">Poro manages education, social order, and funerary rites</a>; the Sandogo manages divination, healing, and the diagnosis of spiritual problems. Together, they constitute a complete system of spiritual governance that addresses the full range of human concerns.</p>

<p>This complementary structure is reflected in the <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-people-guardians-of-ancient-wisdom/">Senufo cosmological system</a>, which balances male and female principles as essential and equal forces. The hornbill figure — associated with fertility and the earth — embodies female generative power even when it appears in Poro contexts. The spiritual landscape of the Senufo is not divided into male and female territories but woven from both.</p>

<h2>Scholarly Correction</h2>

<p>Restoring the Sandogo to its rightful place in our understanding of Senufo culture is not merely a matter of academic completeness. It is a correction of a distortion that has real consequences — for how museums interpret their collections, for how collectors understand the objects they own, and for how Senufo culture is represented to the world.</p>

<p>The women of the Sandogo have always held their power. It is Western scholarship that has failed to see it.</p>'
],

13 => [
    'title'=>'How to Read a Senufo Mask: Symbolism, Function, and Meaning',
    'slug'=>'how-to-read-senufo-mask-symbolism',
    'date'=>'2026-03-01 09:00:00',
    'content'=>'<p>A Senufo mask is not a face. It is a text — a complex symbolic statement encoded in wood, fiber, pigment, and metal that communicates specific meanings to an audience trained to read it. For uninitiated viewers, including nearly all Western observers, the mask\'s symbolic language is invisible. The object may be appreciated for its formal qualities, but its meaning remains locked.</p>

<p>This guide offers a framework for beginning to decode the symbolic vocabulary of Senufo masks, based on published ethnographic research and the documented teachings of Senufo elders. It is necessarily incomplete — the deepest levels of mask symbolism are reserved for senior initiates of the <a href="https://artrevisionist.com/senufo-hornbill/poro-initiation-spiritual-education-through-art/">Poro society</a> — but it provides a starting point for more informed engagement.</p>

<h2>Animal References</h2>

<p>Most Senufo masks incorporate animal features, and each animal reference carries specific symbolic weight. The hornbill, as documented in our study of <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-hornbill-sacred-symbol-of-creation/">the sacred hornbill symbol</a>, represents creation knowledge and elder wisdom. The crocodile represents the power of water and the ancestral realm beneath it. The hyena embodies the dangerous forces of the bush. The chameleon symbolizes patience and adaptability.</p>

<p>These references are not arbitrary or decorative. When a mask combines specific animal features — as the Kponyungo combines hyena, warthog, and antelope — it is constructing a specific statement about the spiritual forces the mask is designed to embody and control.</p>

<h2>Surface Treatments</h2>

<p>The surface of a Senufo mask carries additional information. Dark patinas, often built up over years of ritual use, indicate age and accumulated spiritual power. Sacrificial materials (sometimes visible as encrusted deposits) are not dirt or damage — they are evidence of the mask\'s active spiritual life. Pigments, when present, encode meaning: white often relates to death and the spirit world, red to danger and power, black to the earth and fertility.</p>

<h2>Structural Elements</h2>

<p>The mask\'s three-dimensional structure communicates through proportion and orientation. Upward-projecting elements (horns, crests) often relate to the sky realm and male principles. Earth-directed elements (jaw extensions, dangling attachments) relate to the ground and female principles. The balance between these orientations expresses the mask\'s position within the Senufo cosmological framework.</p>

<h2>Context Over Form</h2>

<p>Perhaps the most important principle for reading Senufo masks is that form alone is insufficient. The same physical mask can carry different meanings depending on when it appears, who wears it, what sounds accompany it, and what stage of the ceremony is underway. As explored in our analysis of <a href="https://artrevisionist.com/senufo-hornbill/from-sacred-grove-to-western-gallery-cultural-translation-and-loss/">cultural translation</a>, removing a mask from its performance context removes most of the information needed to interpret it correctly.</p>

<p>This does not mean Western viewers cannot engage meaningfully with Senufo masks. It means that meaningful engagement requires acknowledging what we do not know, approaching these objects with the humility appropriate to encountering a language we are only beginning to learn.</p>

<h2>A Living Language</h2>

<p>Senufo mask symbolism is not a dead code waiting to be cracked. It is a living language, still spoken and still evolving among <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-people-guardians-of-ancient-wisdom/">Senufo communities</a> in West Africa. The best interpreters of these objects are not Western art historians but the communities that created them. Our role, as outside observers, is to listen — and to present what we learn with the accuracy and respect that these extraordinary objects deserve.</p>'
],

14 => [
    'title'=>'Korhogo to New York: The Journey of a Senufo Hornbill Through the Art Market',
    'slug'=>'korhogo-new-york-senufo-hornbill-provenance',
    'date'=>'2026-03-02 09:00:00',
    'content'=>'<p>Imagine a carved wooden hornbill figure, created in the Korhogo region of Côte d\'Ivoire for use in Poro initiation ceremonies. It was carved by a specialist woodworker commissioned by the Poro elders, consecrated through ritual, and used in sacred contexts for an unknown number of years. At some point — the records are silent on exactly when and how — it left its community and began a journey that would take it across continents, through multiple hands, and into a New York gallery where it would be sold for a sum that would be unimaginable in Korhogo.</p>

<p>This article traces a composite but representative provenance journey for a Senufo hornbill, based on documented cases and published research. The specific object is hypothetical; the patterns it illustrates are entirely real.</p>

<h2>Departure</h2>

<p>The circumstances under which sacred Senufo objects leave their communities vary widely. Some were confiscated during the colonial period. Some were sold by community members under economic pressure. Some were stolen. Some were given away by individuals who had converted to Islam or Christianity and no longer valued the objects\' sacred function. In many cases, the exact circumstances are unknown — a silence that is itself significant.</p>

<p>As our research into <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-hornbill-sacred-symbol-of-creation/">the sacred hornbill</a> documents, these objects were not created as commodities. Their departure from the communities that made them almost always represents a rupture — a severance of the relationships that gave the objects their meaning.</p>

<h2>The Middlemen</h2>

<p>Between an African village and a Western gallery lies a chain of intermediaries. Local traders in Korhogo or Abidjan acquire objects and sell them to regional dealers, who sell them to continental exporters, who sell them to European or American importers. At each stage, the object\'s story is simplified, its provenance becomes vaguer, and its price increases.</p>

<p>This chain of intermediaries is not inherently illegitimate — trade in cultural objects has existed for millennia. But the opacity of the process creates opportunities for misrepresentation, forgery, and the laundering of illegally acquired objects.</p>

<h2>The Gallery</h2>

<p>By the time our hypothetical hornbill reaches a New York gallery specializing in African art, it has been cleaned, mounted on a custom stand, and photographed in dramatic lighting. It is accompanied by a provenance that may read something like "ex-collection privée française, acquired before 1970" — a formula that establishes antiquity and European provenance while revealing nothing about how the object was originally acquired.</p>

<p>The gallery\'s presentation emphasizes the object\'s formal qualities — its elegant proportions, the quality of its carving, the warmth of its patina. As explored in our analysis of the <a href="https://artrevisionist.com/senufo-art-museums-fashion/">Yves Saint Laurent collection phenomenon</a>, this aesthetic framing is what converts a sacred object into a luxury commodity.</p>

<h2>The Auction</h2>

<p>Should our hornbill reach auction, it will be described in a catalog that draws on the accumulated (and sometimes inaccurate) literature of African art history. It will be estimated, bid upon, and sold. The hammer price will bear no relationship to the object\'s cultural significance in its community of origin. It will reflect Western taste, market trends, and the prestige of the auction house.</p>

<h2>What Is Lost, What Remains</h2>

<p>Throughout this journey, the physical object remains largely unchanged. The wood is the same wood, the carving the same carving. But everything that made this object meaningful in its original context — its ritual function, its place within the <a href="https://artrevisionist.com/senufo-hornbill/poro-initiation-spiritual-education-through-art/">Poro knowledge system</a>, its relationship to specific people and ceremonies — has been stripped away.</p>

<p>This is not an argument that Senufo objects should never leave their communities of origin. It is an argument for honesty about what happens when they do. Every Senufo hornbill in a Western collection has a story like this one. Telling that story truthfully — including its uncomfortable elements — is the least we owe to the <a href="https://artrevisionist.com/senufo-hornbill/the-senufo-people-guardians-of-ancient-wisdom/">people who created these extraordinary objects</a>.</p>'
]
];

if(!isset($posts_data[$postNum])){echo json_encode(['error'=>"Invalid post number: $postNum"]);exit;}

$p = $posts_data[$postNum];

// Check if already created (by slug)
$existing = get_page_by_path($p['slug'], OBJECT, 'post');
if($existing){
    echo json_encode(['skipped'=>true,'id'=>$existing->ID,'title'=>$existing->post_title,'message'=>'Post already exists']);
    exit;
}

// Create post
$post_id = wp_insert_post([
    'post_type'=>'post',
    'post_title'=>$p['title'],
    'post_name'=>$p['slug'],
    'post_content'=>$p['content'],
    'post_status'=>'future',
    'post_date'=>$p['date'],
    'post_date_gmt'=>get_gmt_from_date($p['date'])
], true);

if(is_wp_error($post_id)){
    echo json_encode(['error'=>$post_id->get_error_message()]);
    exit;
}

// Generate FAQs via OpenAI
$openai_key = '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';

$plain = wp_strip_all_tags($p['content']);
if(strlen($plain)>4000) $plain = substr($plain,0,4000).'...';

$faq_prompt = "Generate 5 FAQ entries for this Art Revisionist blog post:

Title: {$p['title']}
Content: $plain

Requirements:
- 1-2 definition questions (What is.../What does...)
- 1-2 process questions (How does.../How did...)
- 1 context question (Why.../When...)
- 2-4 sentences per answer (50-120 words)
- Academically sound, citation-ready
- ONLY facts from the content above

Return ONLY JSON: {\"faqs\":[{\"question\":\"...\",\"answer\":\"...\"},...]} with EXACTLY 5 entries.";

$ch = curl_init('https://api.openai.com/v1/chat/completions');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER=>true, CURLOPT_POST=>true, CURLOPT_TIMEOUT=>90,
    CURLOPT_HTTPHEADER=>['Content-Type: application/json','Authorization: Bearer '.$openai_key],
    CURLOPT_POSTFIELDS=>json_encode([
        'model'=>'gpt-4o',
        'messages'=>[
            ['role'=>'system','content'=>'You are an SEO and FAQ specialist for Art Revisionist, a scholarly platform on African art provenance and European bronze foundries. Generate citation-ready FAQ entries.'],
            ['role'=>'user','content'=>$faq_prompt]
        ],
        'temperature'=>0.7, 'max_tokens'=>2000
    ])
]);

$resp = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

$faq_status = 'failed';
$faq_count = 0;

if($code === 200){
    $data = json_decode($resp, true);
    $text = $data['choices'][0]['message']['content'] ?? '';
    $text = preg_replace('/^```json\s*/','',$text);
    $text = preg_replace('/\s*```$/','',$text);
    $faqs = json_decode(trim($text), true);

    if($faqs && isset($faqs['faqs']) && is_array($faqs['faqs'])){
        $qa = [];
        foreach($faqs['faqs'] as $f){
            $qa[] = ['question'=>sanitize_text_field($f['question']),'answer'=>wp_kses_post($f['answer'])];
        }
        update_post_meta($post_id, 'b2bk_qa_items', $qa);
        $faq_status = 'success';
        $faq_count = count($qa);
    }
}

echo json_encode([
    'created'=>true,
    'post_number'=>$postNum,
    'post_id'=>$post_id,
    'title'=>$p['title'],
    'slug'=>$p['slug'],
    'date'=>$p['date'],
    'faq_status'=>$faq_status,
    'faq_count'=>$faq_count
], JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE);
