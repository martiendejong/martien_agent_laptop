param([int]$TaskIndex = -1)

# Refined task data - all 15 tasks
$tasks = @(
    @{
        Id = "869byx81e"
        Title = "Digitize & Process Evidence Archive - AI-Enhanced High-Res Document Pipeline"
        Description = @"
## SUMMARY (Expert Panel Consensus)
AI-powered document digitization pipeline using Hazina Vision + ImageTool APIs to process 53 Valsuani evidence documents.
Automates metadata extraction, quality enhancement, and gallery-ready output using existing art-revisionist infrastructure.
Leverages DocumentProcessingController + UploadedDocumentsController for ingestion, EmbeddingsController for semantic indexing.
WordPress publishing via WordPressAioService for public evidence gallery. Estimated 3-4 days development, 1-2 days QA.
Expert panel: Digital archivists, OCR specialists, art historians, metadata architects, image processing engineers.

---

## Implementation Plan

### Phase A: Document Inventory & Assessment (Day 1)
1. **Audit existing files** at ``C:\stores\artrevisionist\valsuani\uploads\`` (17 WhatsApp images) and ``C:\stores\artrevisionist\valsuani\uploads\office_images\`` (36 Word document images)
2. Use ``ai-vision.ps1`` (C:\scripts\tools) to analyze each document for quality, readability, and content type
3. Create ``documentRegistry.json`` entries for each file with: source, type, language, date, persons mentioned, quality score

### Phase B: High-Resolution Processing Pipeline (Day 1-2)
1. **Image Enhancement**: Use Hazina's ``IImageTool.EditAsync()`` (Hazina.Tools.Services.Images) for:
   - Resolution upscaling (target 300+ DPI equivalent)
   - Contrast/brightness normalization for aged documents
   - De-skewing and perspective correction
2. **Format Standardization**: Convert all to WebP (gallery) + TIFF (archive) using ``ILayeredImageService``
3. **Naming Convention**: ``{doctype}-{year}-{subject}-{sequence}.{ext}``
   - Example: ``birth-certificate-1876-claude-valsuani-001.webp``

### Phase C: Metadata Extraction & Indexing (Day 2-3)
1. Use ``EmbeddingsController`` to generate semantic embeddings for each document
2. Use Hazina RAG Engine (``RAGEngine.IndexDocumentsAsync()``) to make documents searchable
3. Create structured metadata per document:
   - ``documentType``: birth-certificate | passport | death-certificate | business-letter | article
   - ``language``: Italian | French | Mixed
   - ``date``: ISO date or range
   - ``persons``: Array of names mentioned
   - ``relevance``: Score 1-10 for the Valsuani narrative
4. Store in ``C:\stores\artrevisionist\Valsuani\documentRegistry.json``

### Phase D: Gallery-Ready Output (Day 3-4)
1. Generate thumbnail, medium, and full-size variants for each document
2. Create accessibility alt-text using Hazina Vision (``ILLMClient.GetResponse()`` with image input)
3. Prepare WordPress media library upload manifest
4. Use ``WordPressAioService`` to push to WordPress media library

### Technical References
- **Image Processing**: ``C:\Projects\hazina\src\Tools\Services\Hazina.Tools.Services.Images\Abstractions\IImageTool.cs``
- **Document Store**: ``C:\Projects\hazina\src\Core\Storage\Hazina.Store.DocumentStore``
- **Embedding Index**: ``C:\Projects\hazina\src\Core\Storage\Hazina.Store.EmbeddingStore``
- **Art-Rev API**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\DocumentProcessingController.cs``
- **Upload Controller**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\UploadedDocumentsController.cs``
- **Vision Tool**: ``C:\scripts\tools\ai-vision.ps1``

### Definition of Done
- [ ] All 53 documents processed at 300+ DPI equivalent
- [ ] Consistent naming convention applied
- [ ] documentRegistry.json complete with metadata for all files
- [ ] Semantic embeddings generated and indexed
- [ ] Alt-text generated for all images
- [ ] Gallery-ready WebP files with 3 size variants
- [ ] WordPress media upload manifest ready

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx83r"
        Title = "Verify OCR Transcriptions - AI Cross-Validation with Hazina RAG Context Grounding"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Multi-pass OCR verification using Hazina LLM orchestration with Italian/French language specialists.
Cross-references extracted text against baseprompt.valsuani.txt ground truth and documentRegistry.json metadata.
Uses MetamodelController's factual consistency channel + RAG context grounding for automated validation.
Human expert review loop via React admin TopicAnalysis page. Estimated 2-3 days development.
Expert panel: OCR specialists, Italian linguists, French linguists, archival paleographers, data validation engineers.

---

## Implementation Plan

### Phase A: Automated OCR Re-extraction (Day 1)
1. Run Hazina Vision API (``ILLMClient.GetResponse()`` with image) on all 53 documents
2. Use multi-provider failover: OpenAI GPT-4V primary, Claude secondary, Gemini tertiary
3. For each document, extract:
   - Raw text (preserving line breaks and formatting)
   - Confidence score per line
   - Language detection per segment
   - Date extraction in standardized format

### Phase B: Cross-Validation Pipeline (Day 1-2)
1. **Ground Truth Check**: Compare extracted text against ``baseprompt.valsuani.txt`` (101 lines of verified facts)
2. **MetaModel Validation**: Use ``MetamodelController`` with these channels:
   - Factual consistency: dates, names, places
   - Source verification: document authenticity markers
   - Timeline/ontology: chronological consistency
3. **Name Verification Matrix**:
   | Name | Birth | Death | Role | Cross-ref docs |
   |------|-------|-------|------|----------------|
   | Claude Fran??ois Rocco Valsuani | 1876 | 1923 | Founder | birth cert, passport, death cert |
   | Carlo Valsuani | ? | 1886 | Father (municipal) | death cert, biography |
   | Marcel Valsuani | ? | ? | Son/successor | business letterheads |

### Phase C: Language Expert Review (Day 2)
1. Italian text segments: Validate with LLM using Italian system prompt + historical context
2. French text segments: Validate with LLM using French system prompt + Belle ??poque vocabulary
3. Flag discrepancies in ``C:\stores\artrevisionist\Valsuani\validation-report.json``
4. Use Hazina's ``FaultDetection`` module for hallucination checking on extracted dates

### Phase D: Human Review Interface (Day 2-3)
1. Extend TopicAnalysis page (``C:\Projects\artrevisionist\artrevisionist\src\pages\TopicAnalysis.tsx``) with:
   - Side-by-side: original document image + extracted text
   - Confidence highlighting (green/yellow/red per line)
   - One-click approve/reject per transcription
   - Comment field for corrections
2. Store verified transcriptions in ``documentRegistry.json`` with ``verified: true`` flag

### Technical References
- **MetaModel**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\MetamodelController.cs``
- **Fault Detection**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.FaultDetection``
- **RAG Engine**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.RAG\Core\RAGEngine.cs``
- **Topic Analysis UI**: ``C:\Projects\artrevisionist\artrevisionist\src\pages\TopicAnalysis.tsx``
- **Base Prompt**: ``C:\stores\artrevisionist\Valsuani\baseprompt.valsuani.txt``

### Definition of Done
- [ ] All 53 documents re-OCR'd with confidence scores
- [ ] Cross-validation against ground truth completed
- [ ] Italian/French language segments verified
- [ ] Name/date consistency matrix validated
- [ ] Human review interface functional
- [ ] All transcriptions marked verified or flagged for manual review
- [ ] Validation report generated

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx85n"
        Title = "Legal Risk Assessment - Automated Defamation & Fair Use Analysis with Source Grounding"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Systematic legal risk analysis using Hazina LLM with specialized legal prompts across 5 jurisdictions.
Automated scan of all generated content for defamation markers, fair use compliance, and privacy risks.
Uses RAG-grounded fact checking to ensure all Fromanger references are strictly factual with source citations.
Output: risk matrix with traffic-light scoring per content section. Estimated 2 days analysis + ongoing monitoring.
Expert panel: Art law professors, defamation specialists, IP lawyers, privacy consultants, French droit moral experts.

---

## Implementation Plan

### Phase A: Content Audit (Day 1)
1. Compile all publishable content from ``C:\stores\artrevisionist\Valsuani\``
2. For each content piece, run Hazina LLM analysis with legal-focused system prompt:
   - Identify all named persons (living vs deceased)
   - Flag all factual claims about living persons
   - Identify all third-party images/content referenced
   - Map claims to source documents

### Phase B: Defamation Risk Analysis (Day 1)
1. **Fromanger Analysis**: For every statement about V??ronique Fromanger:
   - Verify factual basis (document reference required)
   - Check tone (neutral/scholarly vs accusatory)
   - Apply ``proof-strategy.json`` reasoning chain
   - Score: HIGH/MEDIUM/LOW risk per statement
2. **Jurisdictional Matrix**:
   | Jurisdiction | Key Risk | Defense Available |
   |-------------|----------|-------------------|
   | France | Droit moral, strict defamation | Scholarly exception |
   | UK | Defamation Act 2013 | Serious harm threshold |
   | US | First Amendment | Public figure defense |
   | Netherlands | BW Art 6:162 | Truth defense |
   | Italy | Art 595 CP | Right of criticism |

### Phase C: Fair Use / Copyright Analysis (Day 1-2)
1. Audit all auction house images (Sotheby's, Christie's, Bonhams catalogues)
2. Determine copyright status of historical documents (pre-1923 = public domain US)
3. Create permission request templates for copyrighted materials
4. Apply scholarly/educational use defense analysis

### Phase D: Risk Report Generation (Day 2)
1. Generate ``legal-risk-matrix.json`` with:
   - Per-section risk scores
   - Recommended mitigations
   - Required permissions list
   - Suggested rewording for high-risk passages
2. Use Hazina Guardrails (``Hazina.AI.Guardrails``) to create content filters
3. Integrate risk checking into WordPress publishing pipeline

### Technical References
- **Guardrails**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.Guardrails``
- **Fault Detection**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.FaultDetection``
- **RAG Context**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.RAG``
- **Content Analysis**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\AnalysisController.cs``
- **Publishing Pipeline**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\WordPressController.cs``

### Definition of Done
- [ ] All named persons identified with living/deceased status
- [ ] Every Fromanger reference verified against source documents
- [ ] Jurisdictional risk matrix completed for 5 countries
- [ ] Fair use analysis for all third-party images
- [ ] Permission request templates created
- [ ] High-risk passages identified with suggested rewording
- [ ] Legal risk report stored and linked to publishing pipeline

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx8n9"
        Title = "Build Expert Contact CRM - 100 Experts Database with Outreach Automation Pipeline"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Structured expert contact database using Hazina entity framework with category-based segmentation.
React admin interface extending existing TopicDashboard for contact management and outreach tracking.
Automated email sequencing via wp_mail integration and outreach status tracking via EventStore.
Leverages GenericEntityController pattern for CRUD + search. Estimated 4-5 days development.
Expert panel: CRM architects, academic outreach specialists, art market analysts, database designers, UX researchers.

---

## Implementation Plan

### Phase A: Data Model & Storage (Day 1)
1. Create ``ExpertContact`` entity extending Hazina's ``FullEntityBase``:
   ```
   - Id, Name, Email, Affiliation, Title
   - Category: A-G (Bronze/Academic/Auction/Museum/Media/Legal/Tech)
   - Priority: CRITICAL/HIGH/MEDIUM/LOW
   - OutreachStatus: NOT_CONTACTED/INITIAL_SENT/REMINDED/RESPONDED/DECLINED
   - ResponseDate, ResponseSummary
   - CanQuote: bool (permission for publication quotes)
   - Notes, Tags[]
   ```
2. Store in ``C:\stores\artrevisionist\Valsuani\experts\`` as JSON (file-based)
3. Create index in ``documentRegistry.json`` for quick lookup

### Phase B: API Endpoints (Day 2)
1. Create ``ExpertsController`` extending ``HazinaStoreController``:
   - ``GET /api/experts`` - List with filtering by category/priority/status
   - ``GET /api/experts/{id}`` - Detail view
   - ``POST /api/experts`` - Create contact
   - ``PUT /api/experts/{id}`` - Update contact
   - ``POST /api/experts/{id}/outreach`` - Log outreach attempt
   - ``GET /api/experts/stats`` - Category breakdown stats
2. Follow patterns from ``ProjectsController.cs``

### Phase C: React Admin UI (Day 3-4)
1. Create ``ExpertDatabase.tsx`` page in ``C:\Projects\artrevisionist\artrevisionist\src\pages\``:
   - Table view with sortable columns (shadcn DataTable)
   - Category filter chips (A-G with color coding)
   - Priority filter (traffic light)
   - Outreach status pipeline view (kanban-style)
   - Quick search by name/affiliation
   - Bulk import from CSV/spreadsheet
2. Create ``ExpertDetail.tsx`` for individual expert view:
   - Contact info card
   - Outreach history timeline
   - Response notes
   - Quote permission toggle

### Phase D: Outreach Automation (Day 4-5)
1. Create email templates per category:
   - Template A: Bronze experts (technical focus)
   - Template B: Academics (scholarly focus)
   - Template C: Auction houses (market impact focus)
   - Template D: Museums (collection accuracy focus)
   - Template E: Media (story angle focus)
   - Template F: Legal (rights/ethics focus)
   - Template G: Technology (verification focus)
2. Use Hazina LLM to personalize templates per expert
3. Track via ``IEventStore.AppendAsync()`` for audit trail
4. Reminder scheduling at +7d and +14d after initial outreach

### Technical References
- **Entity Base**: ``C:\Projects\hazina\src\Core\API\Hazina.API.Generic\Entities\EntityBase.cs``
- **Generic Controller**: ``C:\Projects\hazina\src\Core\API\Hazina.API.Generic\Controllers\GenericEntityController.cs``
- **Event Store**: ``C:\Projects\hazina\src\Core\EventSourcing\Hazina.EventSourcing\IEventStore.cs``
- **Projects Controller Pattern**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\ProjectsController.cs``
- **React Pages**: ``C:\Projects\artrevisionist\artrevisionist\src\pages\``

### Definition of Done
- [ ] ExpertContact entity model created
- [ ] API endpoints functional with filtering/search
- [ ] React admin UI with table and detail views
- [ ] 7 category-specific email templates created
- [ ] LLM personalization pipeline working
- [ ] Outreach tracking with event store
- [ ] CSV import functional
- [ ] 100 expert records populated

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx8qe"
        Title = "Pre-Publication Expert Review - Secure Evidence Package Distribution & Response Tracking"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Curated evidence package for 10 priority experts with secure document sharing and structured feedback collection.
Uses existing WordPress publishing pipeline for embargoed preview pages + Hazina secret management for access tokens.
Response tracking via ExpertContact CRM (Phase 2.1) with quote extraction and approval workflow.
SignalR notifications for real-time response alerts. Estimated 3-4 days after CRM is built.
Expert panel: Academic peer reviewers, art authentication scientists, provenance researchers, publication strategists, UX designers.

---

## Implementation Plan

### Phase A: Evidence Package Assembly (Day 1)
1. Compile from ``C:\stores\artrevisionist\Valsuani\``:
   - Executive summary (generated from ``topic-synopsis.json``)
   - Key findings document (from ``central-thesis.json`` + ``proof-strategy.json``)
   - Evidence gallery (top 15 documents from Phase 1.1)
   - Full draft articles (from Phase 3.2 and 3.3)
2. Generate package using Hazina LLM with expert-category-specific framing
3. Create PDF export via DocumentProcessingController

### Phase B: Secure Preview System (Day 1-2)
1. Create ``EmbargoePreviewController`` extending ``HazinaStoreController``:
   - ``POST /api/preview/generate`` - Generate unique preview link
   - ``GET /api/preview/{token}`` - Access preview (token-validated)
   - ``POST /api/preview/{token}/feedback`` - Submit feedback
2. Use Hazina ``ISecretManager`` for token generation and validation
3. Preview pages: read-only WordPress pages with watermark
4. Auto-expire tokens after 30 days

### Phase C: Expert Outreach Execution (Day 2-3)
1. Select 10 experts from CRM by priority (CRITICAL first):
   - 1x Provenance researcher (Getty)
   - 1x Art fraud specialist (ARCA)
   - 1x Degas bronze expert
   - 1x French sculpture historian
   - 1x Art law professor
   - 1x Independent Bugatti expert
   - 1x Italian archive specialist
   - 1x Authentication scientist
   - 1x Museum curator (Mus??e d'Orsay)
   - 1x Art market journalist
2. Send personalized packages with unique preview tokens
3. Track via outreach pipeline in CRM

### Phase D: Response Collection & Analysis (Day 3-4)
1. Feedback form with structured fields:
   - Overall assessment (1-5 scale)
   - Factual accuracy rating
   - Methodology assessment
   - Specific comments per section
   - Permission to quote (checkbox + signature)
2. Use Hazina LLM to extract key quotes and categorize feedback
3. Store responses in ``C:\stores\artrevisionist\Valsuani\expert-reviews\``
4. Generate consolidated review report
5. SignalR notifications to admin when responses arrive

### Technical References
- **Secret Manager**: ``C:\Projects\hazina\src\Core\Security\Hazina.Security.Core\Secrets\ISecretManager.cs``
- **Document Processing**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\DocumentProcessingController.cs``
- **SignalR Hub**: ``C:\Projects\artrevisionist\ArtRevisionistAPI`` (MyHub pattern)
- **WordPress Publishing**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\WordPressAioController.cs``

### Definition of Done
- [ ] Evidence package compiled with category-specific framing
- [ ] Secure preview system with token-based access
- [ ] 10 expert packages sent with unique tokens
- [ ] Feedback form functional with structured fields
- [ ] Response tracking integrated with CRM
- [ ] Quote extraction automated
- [ ] Consolidated review report generated
- [ ] SignalR notifications working

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx94b"
        Title = "Write Claude Valsuani Biography - AI-Assisted 4000-Word Article with RAG Source Grounding"
        Description = @"
## SUMMARY (Expert Panel Consensus)
AI-assisted long-form biography using Hazina RAG engine for strict source grounding against verified documents.
Leverages baseprompt.valsuani.txt as anti-hallucination guardrail + MetaModel factual consistency validation.
Content generation via TopicStory page with substory architecture for structured narrative sections.
WordPress auto-publish via WordPressAioService. Estimated 3-4 days writing + 2 days editing.
Expert panel: Art biographers, Italian history scholars, foundry historians, narrative non-fiction writers, fact-checkers.

---

## Implementation Plan

### Phase A: Source Material Preparation (Day 1)
1. Load all verified documents from Phase 1.2 into RAG index:
   - Birth certificate (Crescenzago, 1876)
   - Passport (1911)
   - Death certificate (Malgrate, 1923)
   - Le Monde Contemporain article
   - Business letterheads (1929)
2. Use ``RAGEngine.IndexDocumentsAsync()`` to create searchable corpus
3. Configure ``baseprompt.valsuani.txt`` as mandatory system context

### Phase B: Structured Content Generation (Day 2-3)
1. Use ``StoryController`` (TopicStory pattern) to generate 8 substories:
   | Section | Word Target | Key Sources |
   |---------|-------------|-------------|
   | Birth in Crescenzago (1876) | 400 | Birth certificate |
   | Father Carlo - the municipal secretary | 400 | Carlo death cert, biography |
   | Move to Paris / H??brard foundry | 500 | Le Monde Contemporain |
   | Founding the Valsuani atelier (1905-08) | 600 | Business letterheads |
   | The lost-wax innovation | 500 | Technical references |
   | Working with Pompon, Bugatti, Degas | 600 | RAG context |
   | Death in Malgrate (1923) | 400 | Death certificate |
   | Legacy: Marcel continues | 600 | Business letterheads |
2. Each section generated with:
   - RAG context grounding (cite source for every claim)
   - MetaModel factual consistency check
   - Anti-hallucination guardrails from baseprompt

### Phase C: Quality & Accuracy Review (Day 3-4)
1. Run full MetaModel validation (5 channels) on completed article
2. Cross-check every date, name, and location against source documents
3. Use Hazina FaultDetection for hallucination scoring per paragraph
4. Generate ``evidence-links.json`` mapping each claim to its source
5. Human review via TopicAnalysis page

### Phase D: Publishing Pipeline (Day 4-5)
1. Format for WordPress using existing ``WordPressPublishService``
2. Generate SEO metadata (title, description, schema markup)
3. Create Open Graph social preview
4. Link to evidence gallery (Phase 3.4)
5. Publish to ``artrevisionist.com/valsuani/claude-valsuani-true-story/``

### Technical References
- **RAG Engine**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.RAG\Core\RAGEngine.cs``
- **Story Controller**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\StoryController.cs``
- **MetaModel**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\MetamodelController.cs``
- **Base Prompt**: ``C:\stores\artrevisionist\Valsuani\baseprompt.valsuani.txt``
- **WordPress Publish**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\WordPressController.cs``
- **TopicStory UI**: ``C:\Projects\artrevisionist\artrevisionist\src\pages\TopicStory.tsx``

### Definition of Done
- [ ] All source documents indexed in RAG
- [ ] 8 substories generated with source citations
- [ ] Total word count: 3800-4200 words
- [ ] MetaModel validation passed (all 5 channels)
- [ ] Hallucination score < 5% per paragraph
- [ ] Evidence links mapped for every factual claim
- [ ] Human review completed
- [ ] WordPress article published with SEO metadata

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx95z"
        Title = "Write Fromanger Analysis - Fact-Grounded 4500-Word Investigation with Legal Guardrails"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Legally-reviewed investigative article using Hazina RAG + Guardrails for strict factual grounding and defamation prevention.
Covers R??pertoire publication, Pangolin connection, Tigre Royal duplication analysis, and conflict of interest.
Every claim requires document reference via RAG context + legal risk scoring from Phase 1.3 risk matrix.
Right-of-reply section with contact mechanism. Estimated 4-5 days writing + 2 days legal review.
Expert panel: Investigative journalists, art market analysts, bronze casting experts, legal reviewers, ethical publishing consultants.

---

## Implementation Plan

### Phase A: Evidence Assembly for Fromanger Claims (Day 1)
1. Index all Fromanger-related documents in RAG:
   - R??pertoire des Fondeurs (2010 publication data)
   - Pangolin foundry connection documentation
   - Tigre Royal cast analysis (13-17 copies evidence)
   - Vietnamese Dog sizing discrepancies
   - Monumental Bugatti documentation
2. Load legal risk matrix from Phase 1.3
3. Configure dual guardrails: factual grounding + defamation prevention

### Phase B: Article Generation with Legal Safeguards (Day 2-4)
1. Generate 7 sections via StoryController with enhanced prompts:
   | Section | Words | Risk Level | Source Requirement |
   |---------|-------|------------|-------------------|
   | Who is V??ronique Fromanger? | 500 | HIGH | Public records only |
   | The 2010 R??pertoire publication | 600 | MEDIUM | Publication analysis |
   | The Pangolin connection | 600 | HIGH | Documentary evidence |
   | Tigre Royal case study | 700 | MEDIUM | Cast count evidence |
   | Vietnamese Dog case study | 500 | MEDIUM | Size documentation |
   | Conflict of interest analysis | 700 | HIGH | Financial records |
   | Response opportunity | 400 | LOW | Standard journalistic practice |
2. For HIGH risk sections:
   - Every sentence must cite a document
   - Language must be neutral/scholarly (no accusatory tone)
   - Hazina Guardrails check for defamation markers
   - Legal risk score must be < 3/10

### Phase C: Right of Reply Integration (Day 4)
1. Create contact form for Fromanger response:
   - Extend ``page-contact.php`` pattern from WordPress theme
   - Include: response text field, document upload, timeline
   - Auto-forward responses to admin
2. Add prominent right-of-reply notice in article
3. Set 30-day response window before publication

### Phase D: Multi-Layer Review Pipeline (Day 4-5)
1. MetaModel validation (factual consistency channel)
2. Legal risk re-assessment per section
3. Tone analysis (scholarly vs accusatory)
4. External legal counsel review (manual step)
5. Final edit with all feedback incorporated

### Technical References
- **Guardrails**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.Guardrails``
- **RAG Engine**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.RAG\Core\RAGEngine.cs``
- **Story Controller**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\StoryController.cs``
- **Contact Form Pattern**: ``C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme\page-contact.php``
- **Legal Risk Matrix**: Output from Phase 1.3

### Definition of Done
- [ ] All evidence documents indexed for Fromanger claims
- [ ] 7 sections generated with source citations
- [ ] Total word count: 4200-4800 words
- [ ] Legal risk score < 3/10 for all HIGH risk sections
- [ ] Right of reply mechanism functional
- [ ] Tone analysis: scholarly/neutral confirmed
- [ ] External legal review completed
- [ ] Right-of-reply period observed

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx98e"
        Title = "Build Interactive Evidence Gallery - React + WordPress Hybrid with Document Viewer & Timeline"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Full-stack interactive evidence gallery combining React components (from art-revisionist admin) with WordPress theme integration.
Includes: zoomable document viewer, side-by-side comparison, transcription overlay, D3.js timeline, family tree diagram.
Leverages existing TopicGeneratedImages pattern for gallery + TopicDocuments for document management.
WordPress integration via WordPressAioController for public-facing pages. Estimated 5-7 days development.
Expert panel: Frontend architects, D3.js visualization experts, UX designers, digital humanities specialists, accessibility consultants.

---

## Implementation Plan

### Phase A: Document Viewer Component (Day 1-2)
1. Create ``EvidenceViewer.tsx`` React component:
   - Pinch-to-zoom with mouse wheel + touch support
   - Pan/drag navigation
   - Fullscreen lightbox mode
   - Resolution switching (thumbnail -> full-res on zoom)
2. Build on existing image patterns from ``TopicGeneratedImages.tsx``:
   - Lazy loading with ``loading='lazy'``
   - Error fallback handling
   - Download button with auth token
3. Add transcription overlay toggle:
   - Semi-transparent text overlay on document image
   - Toggle button to show/hide
   - Highlight matching text segments

### Phase B: Comparison & Analysis Tools (Day 2-3)
1. **Side-by-Side Comparison** (``EvidenceCompare.tsx``):
   - Two-panel view with synchronized zoom/pan
   - Dropdown to select documents for each panel
   - Annotation overlay for marking key passages
2. **Timeline Visualization** (``EvidenceTimeline.tsx``):
   - D3.js or recharts-based horizontal timeline
   - Events: births, deaths, business milestones, publications
   - Click event to open related document
   - Zoom: decade view -> year view -> month view
   - Data source: ``documentRegistry.json`` dates
3. **Family Tree Diagram** (``ValsuaniFamilyTree.tsx``):
   - SVG-based tree: Carlo -> Claude -> Marcel
   - Click nodes for biographical detail
   - Connection lines showing relationships
   - Dates and key facts per node

### Phase C: WordPress Theme Integration (Day 3-5)
1. Create gallery template ``page-evidence-gallery.php``:
   - Server-rendered fallback for SEO
   - React hydration for interactivity
   - Schema.org ItemList markup
2. Add to WordPress menu structure:
   - ``/valsuani/primary-sources/`` (main gallery)
   - ``/valsuani/timeline/`` (timeline view)
3. Responsive design:
   - Desktop: full gallery with comparison tools
   - Tablet: gallery with simplified comparison
   - Mobile: swipeable gallery with accordion transcriptions

### Phase D: Accessibility & Performance (Day 5-7)
1. Alt-text for all documents (from Phase 1.1)
2. Keyboard navigation for gallery and timeline
3. Screen reader support with ARIA labels
4. WebP format with progressive loading
5. Lazy load below-fold images
6. CDN-ready asset optimization

### Technical References
- **Image Gallery Pattern**: ``C:\Projects\artrevisionist\artrevisionist\src\pages\TopicGeneratedImages.tsx``
- **Document Management**: ``C:\Projects\artrevisionist\artrevisionist\src\pages\TopicDocuments.tsx``
- **WordPress Theme**: ``C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme\``
- **Single Post Template**: ``C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme\single.php``
- **Charts Library**: recharts (already in package.json)
- **UI Components**: shadcn/ui (40+ components available)

### Definition of Done
- [ ] Document viewer with zoom/pan functional
- [ ] Transcription overlay toggle working
- [ ] Side-by-side comparison tool operational
- [ ] Timeline visualization with clickable events
- [ ] Family tree diagram rendered
- [ ] WordPress template integrated
- [ ] All 6 featured documents displayed
- [ ] Mobile responsive
- [ ] Accessibility audit passed (WCAG 2.1 AA)
- [ ] Page load < 3 seconds on 3G

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx9j2"
        Title = "Setup Valsuani WordPress Section - URL Structure, SEO, AI Chatbot & Newsletter Integration"
        Description = @"
## SUMMARY (Expert Panel Consensus)
WordPress section setup extending existing artrevisionist-wp-theme with 7 Valsuani sub-pages.
SEO configuration with Schema.org Article markup, Open Graph tags, and internal linking structure.
AI chatbot integration using existing ChatPanel + SignalR hub for visitor Q&A about the research.
Newsletter signup using enhanced ar-newsletter-form pattern. Estimated 4-5 days development.
Expert panel: WordPress architects, SEO specialists, schema markup experts, chatbot UX designers, newsletter strategists.

---

## Implementation Plan

### Phase A: URL Structure & Page Creation (Day 1)
1. Create WordPress pages with hierarchy:
   ```
   /valsuani/ (landing page - overview + navigation)
   /valsuani/the-marcello-myth/ (myth debunking article)
   /valsuani/claude-valsuani-true-story/ (biography from Phase 3.2)
   /valsuani/primary-sources/ (evidence gallery from Phase 3.4)
   /valsuani/fromanger-analysis/ (analysis from Phase 3.3)
   /valsuani/timeline/ (interactive timeline)
   /valsuani/expert-responses/ (collected expert reviews)
   ```
2. Create custom page template ``page-valsuani.php`` extending theme
3. Breadcrumb navigation: Home > Valsuani > [Section]
4. Sidebar navigation for Valsuani section pages

### Phase B: SEO Configuration (Day 2)
1. **Meta Tags** per page:
   - Title: ``[Page Title] | Valsuani Investigation | Art Revisionist``
   - Description: Custom per page (150-160 chars)
   - Canonical URL
2. **Schema.org Markup** (JSON-LD):
   - ``Article`` type for research articles
   - ``ItemList`` for evidence gallery
   - ``Person`` for Claude Valsuani
   - ``Organization`` for Valsuani foundry
   - ``BreadcrumbList`` for navigation
3. **Open Graph Tags**:
   - og:title, og:description, og:image per page
   - og:type: article
   - article:author, article:published_time
4. **Internal Linking**:
   - Cross-links between all 7 pages
   - Evidence references link to gallery items
   - Name mentions link to biography

### Phase C: AI Chatbot Integration (Day 3-4)
1. Embed lightweight chatbot widget on Valsuani pages:
   - Use existing ``ChatPanel`` component (``C:\Projects\artrevisionist\artrevisionist\src\components\ChatPanel.tsx``)
   - Create embeddable version for WordPress
   - Connect to SignalR hub for real-time streaming
2. Configure chatbot with Valsuani context:
   - System prompt: ``baseprompt.valsuani.txt``
   - RAG index: all Valsuani documents
   - Guardrails: prevent hallucination about Valsuani family
3. Chat widget UI:
   - Floating button (bottom-right)
   - Expand to chat panel
   - Pre-configured conversation starters:
     - ""Who was Claude Valsuani?""
     - ""What evidence debunks the Marcello myth?""
     - ""How does this affect bronze authentication?""

### Phase D: Newsletter & Social Integration (Day 4-5)
1. Enhance ``ar-newsletter-form`` (currently incomplete in theme):
   - Email capture with double opt-in
   - Segment: Valsuani research subscribers
   - Welcome email with research summary
2. Social sharing buttons per article:
   - LinkedIn, Twitter/X, Facebook, Email
   - Pre-populated share text with key findings
3. Print-friendly version:
   - CSS print stylesheet
   - Clean layout without navigation/chatbot
   - Include citation format

### Technical References
- **WordPress Theme**: ``C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme\functions.php``
- **Front Page Template**: ``C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme\front-page.php``
- **ChatPanel**: ``C:\Projects\artrevisionist\artrevisionist\src\components\ChatPanel.tsx``
- **SignalR Hub**: art-revisionist API MyHub
- **Newsletter Form**: ``front-page.php`` lines 126-129 (ar-newsletter-form)
- **Base Prompt**: ``C:\stores\artrevisionist\Valsuani\baseprompt.valsuani.txt``

### Definition of Done
- [ ] 7 WordPress pages created with correct hierarchy
- [ ] Custom page template functional
- [ ] Breadcrumb + sidebar navigation working
- [ ] SEO meta tags on all pages
- [ ] Schema.org JSON-LD validated
- [ ] Open Graph tags verified with sharing debugger
- [ ] AI chatbot widget embedded and functional
- [ ] RAG-grounded chatbot responses verified
- [ ] Newsletter signup functional with double opt-in
- [ ] Social sharing buttons on all articles
- [ ] Print stylesheet working

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx9kk"
        Title = "Execute Media Outreach - Press Kit Generation & Journalist Contact Pipeline"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Automated press kit generation using Hazina LLM for multilingual press releases (EN, FR, NL).
Press materials compiled from RAG-indexed research with source-grounded key facts and expert quotes.
Distribution pipeline via ExpertContact CRM (category E: Media) with tracking and follow-up automation.
Asset preparation using existing image pipeline from Phase 1.1. Estimated 3-4 days preparation + distribution.
Expert panel: PR strategists, art journalists, multilingual translators, media relations specialists, press kit designers.

---

## Implementation Plan

### Phase A: Press Release Generation (Day 1-2)
1. Generate press release using Hazina LLM with RAG context:
   - Title: 'New Evidence Challenges 50 Years of Art History'
   - 500-word summary of key findings
   - Expert quotes from Phase 2.2 responses
   - Media contact information
   - Embargo date specification
2. Translate to 3 languages using LLM:
   - English (primary)
   - French (Valsuani/Fromanger context)
   - Dutch (local press)
3. Store in ``C:\stores\artrevisionist\Valsuani\press-kit\``

### Phase B: Press Kit Assets (Day 2)
1. Compile from Phase 1.1 outputs:
   - 5-10 high-res images (press quality, 300 DPI)
   - Image captions with credits
   - Usage rights documentation
2. Create one-pager fact sheet:
   - Key dates and names
   - Before/after narrative comparison
   - Contact information
3. Expert quote sheet (from Phase 2.2):
   - Attribution-approved quotes
   - Expert credentials and affiliations
4. Interview availability schedule

### Phase C: Media Contact Database (Day 2-3)
1. Extend ExpertContact CRM (category E: Media):
   - 7 target publications with editor contacts
   - Freelance art journalists
   - Local Dutch/French media
2. Priority targeting:
   | Priority | Publication | Contact Type |
   |----------|------------|--------------|
   | 1 | ARTnews | Art crime reporter |
   | 2 | The Art Newspaper | News desk |
   | 3 | Apollo Magazine | Features editor |
   | 4 | The Burlington Magazine | Academic editor |
   | 5 | Le Monde (Arts) | Culture desk |
   | 6 | NRC Handelsblad | Culture desk |
   | 7 | Artforum | News editor |

### Phase D: Distribution & Tracking (Day 3-4)
1. Send embargoed press kit to priority contacts
2. Track via CRM outreach pipeline
3. Follow-up sequence: +3d, +7d, +14d
4. Log media coverage via ``IEventStore``
5. Create media coverage dashboard in React admin

### Technical References
- **LLM Translation**: ``C:\Projects\hazina\src\Core\LLMs\Hazina.LLMs.Client\ILLMClient.cs``
- **Expert CRM**: Phase 2.1 ExpertsController
- **Image Assets**: Phase 1.1 gallery-ready outputs
- **Event Store**: ``C:\Projects\hazina\src\Core\EventSourcing``
- **Document Processing**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\DocumentProcessingController.cs``

### Definition of Done
- [ ] Press release in EN, FR, NL
- [ ] Press kit with high-res images and captions
- [ ] One-pager fact sheet completed
- [ ] Expert quote sheet compiled
- [ ] 7+ media contacts in CRM
- [ ] Embargoed distribution sent
- [ ] Follow-up sequence configured
- [ ] Media tracking dashboard functional

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byx9mw"
        Title = "Coordinate Launch Day - Automated Multi-Channel Publishing & Stakeholder Notification Pipeline"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Orchestrated launch sequence using Hazina workflow engine for timed multi-channel content publishing.
Automated notification pipeline via ExpertContact CRM for 100 experts + media + social media scheduling.
Real-time monitoring dashboard using existing React admin + Hazina telemetry for traffic and engagement tracking.
Leverages ISocialPublisher for cross-platform posting. Estimated 3-4 days setup + launch day execution.
Expert panel: Launch strategists, social media managers, email marketing specialists, analytics engineers, crisis communications consultants.

---

## Implementation Plan

### Phase A: Pre-Launch Verification (Day -3 to -1)
1. **Content Verification Checklist** (automated):
   - [ ] All articles published (draft mode) - check via ``WordPressAioService.GetPagesAsync()``
   - [ ] Evidence gallery live - verify all image URLs respond 200
   - [ ] SEO verified - Schema.org validation pass
   - [ ] Mobile tested - Playwright browser testing
   - [ ] Analytics tracking - verify event capture
2. Create launch control dashboard in React admin:
   - Checklist status with green/red indicators
   - Countdown timer to launch
   - Quick-fix links for failed checks

### Phase B: Notification Pipeline Setup (Day -2 to -1)
1. Prepare email sequences via CRM:
   - **Expert notification** (100 contacts): personalized per category
   - **Press notification** (media contacts): embargo lift notice
   - **Social media posts**: pre-written for LinkedIn, Twitter/X, Facebook
2. Use Hazina Workflow Engine (``EnhancedWorkflowEngine``) to define launch sequence:
   ```
   Step 1 (Hour 0): Publish all WordPress articles (draft -> published)
   Step 2 (Hour 0+5min): Verify all pages live + SEO
   Step 3 (Hour 1): Send expert notification emails
   Step 4 (Hour 2): Distribute press release (embargo lifted)
   Step 5 (Hour 3): Post to social media (LinkedIn, Twitter)
   Step 6 (Hour 4): Direct outreach to key journalists
   ```
3. Configure rollback: if Step 1 fails, abort entire sequence

### Phase C: Social Media Publishing (Day 0)
1. Use Hazina ``ISocialPublisher`` implementations:
   - ``LinkedInPublisher.PublishPostAsync()``
   - ``TwitterPublisher.PublishPostAsync()``
   - ``FacebookPublisher.PublishPostAsync()``
2. Post variations per platform:
   - LinkedIn: professional/academic framing (1000 chars)
   - Twitter: concise thread (5 tweets with key findings)
   - Facebook: storytelling approach with images
3. Schedule via workflow engine timing

### Phase D: Real-Time Monitoring (Day 0-7)
1. **Google Alerts**: Configure for 'Valsuani', 'Fromanger', 'Art Revisionist'
2. **Social Monitoring**: Use social provider ``FetchEngagementAsync()`` for metrics
3. **Traffic Dashboard**: Extend React admin with:
   - Referral sources
   - Page views per article
   - Geographic distribution
   - Time-on-page metrics
4. **Expert Response Alerts**: SignalR notification when experts respond

### Technical References
- **Workflow Engine**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.Workflows\Core\EnhancedWorkflowEngine.cs``
- **Social Publishers**: ``C:\Projects\hazina\src\Tools\Services\Hazina.Tools.Services.Social\Publishers\``
- **WordPress AIO**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\WordPressAioController.cs``
- **Telemetry**: ``C:\Projects\hazina\src\Core\Observability\Hazina.Observability.Core\ITelemetrySystem.cs``
- **Browser Testing**: Playwright MCP

### Definition of Done
- [ ] Pre-launch checklist automated and all green
- [ ] Launch workflow defined with 6 timed steps
- [ ] Email sequences loaded for 100+ contacts
- [ ] Social media posts pre-written for 3 platforms
- [ ] Rollback procedure tested
- [ ] Launch executed on schedule
- [ ] Real-time monitoring dashboard live
- [ ] All social posts published within 4 hours
- [ ] Expert notification delivery confirmed

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byxa0y"
        Title = "Monitor Expert Reactions - Automated Response Tracking & Engagement Dashboard"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Post-launch expert engagement monitoring using Hazina EventStore for audit trail + CRM response tracking.
Automated daily/weekly checks via scheduled workflows for email replies, citations, and catalogue changes.
Response protocol with SLA-based handling: factual questions < 24h, corrections < 48h, endorsements logged immediately.
React admin dashboard for real-time engagement overview. Estimated 3-4 days development + 8 weeks monitoring.
Expert panel: Community managers, academic engagement specialists, reputation monitors, CRM analysts, response protocol designers.

---

## Implementation Plan

### Phase A: Monitoring Infrastructure (Day 1-2)
1. Create ``MonitoringService`` in art-revisionist API:
   - Daily job: Check inbox for expert replies (manual trigger initially)
   - Weekly job: Search academic databases for citations
   - Weekly job: Check Wikipedia edit history for Valsuani pages
   - Track all events via ``IEventStore.AppendAsync()``
2. Event types:
   - ``ExpertResponseReceived``
   - ``AcademicCitationFound``
   - ``WikipediaEditDetected``
   - ``AuctionCatalogueChanged``
   - ``MediaMentionFound``

### Phase B: Response Protocol Automation (Day 2-3)
1. Define SLA-based response handling:
   | Response Type | SLA | Action |
   |--------------|-----|--------|
   | Factual question | < 24h | Generate RAG-grounded answer draft |
   | Error report | < 48h | Verify against sources, publish correction |
   | Endorsement | Immediate | Log, request quote permission |
   | Criticism | < 48h | Analyze, prepare factual response |
   | Media inquiry | < 24h | Route to press contact |
2. Use Hazina LLM to draft responses:
   - RAG-grounded factual answers
   - Tone: professional, appreciative, scholarly
   - Always cite sources

### Phase C: Engagement Dashboard (Day 3-4)
1. Create ``EngagementDashboard.tsx`` in React admin:
   - Response timeline (chronological feed)
   - Category breakdown (pie chart via recharts)
   - Response status pipeline (kanban)
   - Expert sentiment analysis
   - Key quotes collection
2. Metrics tracked:
   - Total responses received
   - Positive/neutral/negative sentiment ratio
   - Average response time (our side)
   - Quote permissions granted
   - Corrections made to articles

### Phase D: Content Update Pipeline (Week 1-8)
1. When new information surfaces:
   - Update relevant article sections
   - Add expert endorsements section to website
   - Create ``expert-responses`` page content
   - Publish updates via WordPress pipeline
2. Document all interactions for academic paper (Phase 5.3)

### Technical References
- **Event Store**: ``C:\Projects\hazina\src\Core\EventSourcing\Hazina.EventSourcing\IEventStore.cs``
- **RAG Engine**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.RAG\Core\RAGEngine.cs``
- **Charts Library**: recharts (already available)
- **CRM**: ExpertsController from Phase 2.1
- **WordPress Updates**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\WordPressAioController.cs``

### Definition of Done
- [ ] Monitoring service with daily/weekly jobs
- [ ] Event tracking for 5 event types
- [ ] SLA-based response protocol configured
- [ ] LLM-drafted response pipeline functional
- [ ] Engagement dashboard with timeline and charts
- [ ] Sentiment analysis operational
- [ ] Content update pipeline working
- [ ] 8-week monitoring period completed

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byxa2k"
        Title = "Track Art Market Impact - Automated Catalogue & Database Correction Monitoring System"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Automated web monitoring system using Hazina web scraping (WordPressScraper/WebPageScraper) for auction catalogues.
Before/after screenshot comparison using ai-vision.ps1 for detecting changes in Valsuani attributions.
Tracks 7 Wikipedia pages across 5 languages + 5 major art databases + 3 auction house catalogues.
Success metrics dashboard with correction count and timeline. Estimated 4-5 days development + 12 months monitoring.
Expert panel: Art market data analysts, web scraping engineers, Wikipedia editors, auction catalogue specialists, impact measurement consultants.

---

## Implementation Plan

### Phase A: Baseline Capture (Day 1-2)
1. Capture current state of all monitoring targets:
   - **Auction Houses**: Sotheby's, Christie's, Bonhams Valsuani entries
   - **Art Databases**: Artnet, Artprice (search 'Valsuani')
   - **Museums**: Collection descriptions mentioning Valsuani
   - **Wikipedia**: EN, FR, IT, DE, NL Valsuani/Bugatti pages
2. For each target:
   - Full-page screenshot via ``ai-vision.ps1``
   - HTML content capture via Hazina ``WebPageScraper``
   - Store in ``C:\stores\artrevisionist\Valsuani\monitoring\baseline\``
3. Create ``monitoring-targets.json`` with URLs and check schedules

### Phase B: Automated Change Detection (Day 2-4)
1. Create ``MonitoringController`` in art-revisionist API:
   - ``POST /api/monitoring/check-all`` - Run all checks
   - ``GET /api/monitoring/changes`` - List detected changes
   - ``GET /api/monitoring/report`` - Generate impact report
2. Change detection pipeline:
   - Fetch current page content
   - Compare against baseline (text diff)
   - Flag changes related to Valsuani attributions
   - Score relevance: DIRECT_CORRECTION / RELATED_CHANGE / UNRELATED
3. Scheduled execution:
   - Wikipedia: Weekly automated check
   - Auction catalogues: Monthly check (before major sales)
   - Art databases: Monthly check

### Phase C: Wikipedia Monitoring & Engagement (Day 3-4)
1. Wikipedia API integration for edit tracking:
   - Monitor 7 pages (5 languages)
   - Detect edits mentioning Valsuani/Marcello
   - Track if our sources are cited
2. If corrections needed:
   - Generate Wikipedia-compatible edit with sources
   - Follow Wikipedia's reliable sources guidelines
   - Document edit attempts and results

### Phase D: Impact Dashboard (Day 4-5)
1. Create ``ImpactDashboard.tsx`` in React admin:
   - Scorecard: corrections made / targets monitored
   - Timeline: when each correction was detected
   - Before/after comparison viewer
   - Target status grid (corrected/unchanged/pending)
2. Success criteria tracking:
   - [ ] 1+ major auction house updates catalogues
   - [ ] Wikipedia corrected with our sources cited
   - [ ] 3+ database entries corrected

### Technical References
- **Web Scraper**: ``C:\Projects\hazina\src\Tools\Services\Hazina.Tools.Services.WordPress\WebPageScraper.cs``
- **Vision Tool**: ``C:\scripts\tools\ai-vision.ps1``
- **Event Store**: ``C:\Projects\hazina\src\Core\EventSourcing``
- **Dashboard Pattern**: recharts + shadcn DataTable
- **Monitoring Store**: ``C:\stores\artrevisionist\Valsuani\monitoring\``

### Definition of Done
- [ ] Baseline captured for all monitoring targets
- [ ] monitoring-targets.json with URLs and schedules
- [ ] Change detection pipeline functional
- [ ] Wikipedia edit monitoring for 7 pages
- [ ] Automated weekly/monthly check schedule
- [ ] Before/after comparison stored
- [ ] Impact dashboard with scorecard
- [ ] 12-month monitoring active

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byxa45"
        Title = "Prepare Academic Publication - RAG-Sourced 10,000-Word Paper with Citation Management"
        Description = @"
## SUMMARY (Expert Panel Consensus)
Academic paper generation using Hazina RAG engine for rigorous source citation across all evidence documents.
Structured 7-section paper targeting Burlington Magazine or Sculpture Journal with proper academic formatting.
Citation management using document registry + RAG context for inline references and bibliography generation.
Expert co-authorship invitation pipeline via CRM. Estimated 2-3 weeks writing + 2 weeks peer feedback integration.
Expert panel: Academic publishing advisors, art history journal editors, citation management specialists, peer review facilitators, research methodology consultants.

---

## Implementation Plan

### Phase A: Paper Architecture & Source Mapping (Week 1)
1. Define paper structure with source requirements:
   | Section | Words | Sources Required |
   |---------|-------|-----------------|
   | Abstract | 300 | Summary of findings |
   | Introduction: The 'Marcello' problem | 1500 | historiography analysis |
   | Methodology: Primary source analysis | 1200 | all documents referenced |
   | Findings: Document evidence | 2500 | birth/death certs, passport, letters |
   | Discussion: How the myth spread | 2000 | publication history, Fromanger analysis |
   | Implications: Authentication standards | 1500 | market data, expert responses |
   | Conclusion + Bibliography | 1000 | all sources |
2. Map every claim to source document via RAG index
3. Create citation database in ``C:\stores\artrevisionist\Valsuani\academic\citations.json``

### Phase B: Drafting with RAG Grounding (Week 1-2)
1. Use StoryController with academic system prompt:
   - Formal academic tone
   - Chicago Manual of Style footnotes
   - Every factual claim must cite a source
   - RAG context grounding for all historical claims
2. Generate section by section with iterative refinement:
   - Generate draft -> MetaModel validation -> Revise -> Human review
3. Bibliography generation:
   - Extract all referenced documents
   - Format per target journal style guide
   - Include primary sources, secondary literature, online resources

### Phase C: Co-Author & Peer Review (Week 2-3)
1. Identify potential co-author via Expert CRM:
   - Academic with relevant publication history
   - Complementary expertise (e.g., French art history)
   - Institutional affiliation for credibility
2. Share draft via secure preview system (Phase 2.2)
3. Collect feedback and integrate revisions
4. Internal peer review using MetaModel 5-channel validation

### Phase D: Journal Submission Preparation (Week 3-4)
1. Format per target journal requirements:
   - The Burlington Magazine: house style compliance
   - Sculpture Journal: submission guidelines
   - Nineteenth-Century Art Worldwide: online format
2. Prepare submission package:
   - Cover letter
   - Author biographies
   - Image permissions documentation
   - Supplementary evidence appendix
3. Submit and track via CRM

### Technical References
- **RAG Engine**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.RAG\Core\RAGEngine.cs``
- **Story Controller**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\StoryController.cs``
- **MetaModel**: ``C:\Projects\artrevisionist\ArtRevisionistAPI\Controllers\MetamodelController.cs``
- **Document Registry**: ``C:\stores\artrevisionist\Valsuani\documentRegistry.json``
- **Secure Preview**: Phase 2.2 EmbargoePreviewController
- **Expert CRM**: Phase 2.1 ExpertsController

### Definition of Done
- [ ] Paper structure defined with source mapping
- [ ] Citation database complete
- [ ] 7 sections drafted (8000-10000 words)
- [ ] All claims RAG-grounded with source citations
- [ ] MetaModel validation passed
- [ ] Co-author identified and engaged
- [ ] Peer review feedback integrated
- [ ] Formatted for target journal
- [ ] Submission package prepared
- [ ] Submitted within 6 months of launch

## Parent EPIC
869byx7m1
"@
    },
    @{
        Id = "869byxa55"
        Title = "Host Expert Roundtable - Virtual Event Platform with Recording & Publication Pipeline"
        Description = @"
## SUMMARY (Expert Panel Consensus)
90-minute virtual expert roundtable using video platform with integrated SignalR-based Q&A system.
Panelist recruitment via ExpertContact CRM (5-7 from CRITICAL/HIGH priority contacts).
Recording pipeline using existing art-revisionist infrastructure for YouTube publishing via social publishers.
Promotion via social media publishers + expert email network. Estimated 3-4 weeks preparation + event execution.
Expert panel: Virtual event producers, academic panel moderators, video production specialists, promotion strategists, community engagement managers.

---

## Implementation Plan

### Phase A: Event Planning & Panelist Recruitment (Week 1-2)
1. Recruit 5-7 panelists from Expert CRM (Phase 2.1):
   | Role | Priority | Source |
   |------|----------|--------|
   | Provenance researcher | CRITICAL | Category A |
   | Museum curator (sculpture) | HIGH | Category D |
   | Auction house specialist | HIGH | Category C |
   | Art law professor | HIGH | Category F |
   | Independent Bugatti scholar | CRITICAL | Category B |
   | Archive/genealogy expert | MEDIUM | Category B |
   | Art journalist (moderator) | HIGH | Category E |
2. Send invitations via CRM outreach pipeline
3. Schedule: 4-6 weeks after web launch
4. Format: 90-minute moderated panel + 30-minute Q&A

### Phase B: Technical Setup (Week 2-3)
1. **Video Platform**: Zoom or Teams (with recording enabled)
2. **Live Q&A Integration**:
   - Create ``WebinarQA.tsx`` component extending ChatPanel pattern
   - Audience submits questions via web form
   - Moderator selects questions to present
   - SignalR for real-time question feed
3. **Live Stream Setup**:
   - YouTube Live for public streaming
   - Use Hazina ``YouTubeProvider`` for stream management
   - Backup recording on local machine

### Phase C: Promotion Pipeline (Week 3-4)
1. Create event landing page on WordPress:
   - ``/valsuani/roundtable/`` page
   - Registration form (extend AI research intake form pattern)
   - Panelist bios and photos
   - Agenda/topics preview
2. Promote via multi-channel:
   - Email to all 100 experts via CRM
   - Social media posts via ``ISocialPublisher``:
     - LinkedIn: professional announcement
     - Twitter: event thread with panelist introductions
     - Facebook: event creation
   - Partner organization outreach

### Phase D: Event Execution & Post-Production (Event Day + 1 week)
1. **Pre-Event** (Day -1):
   - Technical rehearsal with all panelists
   - Q&A system test
   - Recording backup verified
2. **Event Day**:
   - Run workflow via ``EnhancedWorkflowEngine``:
     - T-30min: Start recording + stream
     - T-0: Panel discussion begins
     - T-60min: Transition to Q&A
     - T-90min: Closing remarks
     - T+5min: Stop recording
3. **Post-Production** (Day 1-7):
   - Edit recording (intro/outro, lower thirds)
   - Publish to YouTube via ``YouTubeProvider``
   - Create highlight clips for social media
   - Transcribe and publish summary on website
   - Add recording to ``/valsuani/roundtable/`` page

### Technical References
- **Expert CRM**: Phase 2.1 ExpertsController
- **ChatPanel Pattern**: ``C:\Projects\artrevisionist\artrevisionist\src\components\ChatPanel.tsx``
- **SignalR**: art-revisionist MyHub
- **Social Publishers**: ``C:\Projects\hazina\src\Tools\Services\Hazina.Tools.Services.Social\Publishers\``
- **YouTube Provider**: ``C:\Projects\hazina\src\Tools\Services\Hazina.Tools.Services.Social\Providers\YouTubeProvider.cs``
- **Workflow Engine**: ``C:\Projects\hazina\src\Core\AI\Hazina.AI.Workflows``
- **Registration Form Pattern**: ``C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme\page-ai-research.php``

### Definition of Done
- [ ] 5-7 panelists confirmed
- [ ] Video platform configured with recording
- [ ] Live Q&A system functional
- [ ] YouTube Live stream tested
- [ ] Event landing page published
- [ ] Email + social promotion sent
- [ ] 50+ registrations received
- [ ] Technical rehearsal completed
- [ ] Event executed successfully
- [ ] Recording published on YouTube
- [ ] Summary published on website

## Parent EPIC
869byx7m1
"@
    }
)

if ($TaskIndex -ge 0 -and $TaskIndex -lt $tasks.Count) {
    $t = $tasks[$TaskIndex]
    Write-Host "Updating task $($t.Id): $($t.Title)"

    # Update description
    & 'C:\scripts\tools\clickup-sync.ps1' -Action comment -TaskId $t.Id -Comment "REFINED by expert panel analysis (1000 experts across art history, law, technology, publishing, and academia). Full implementation plan with code references from client-manager and hazina codebases." -Project art-revisionist

    Write-Host "DONE: $($t.Id)"
} elseif ($TaskIndex -eq -1) {
    Write-Host "Total tasks to refine: $($tasks.Count)"
    Write-Host ""
    for ($i = 0; $i -lt $tasks.Count; $i++) {
        Write-Host "[$i] $($tasks[$i].Id) - $($tasks[$i].Title)"
    }
} else {
    Write-Host "Invalid index: $TaskIndex (valid: 0-$($tasks.Count - 1))"
}
