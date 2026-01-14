# Expert Panel: Should Restaurant Menu be in analysis-fields.config.json?

**Question:** Should the restaurant menu catalog feature be registered in analysis-fields.config.json like other content hooks?

**Context:**
- analysis-fields.config.json defines AI-generated content hooks with custom UI components
- Restaurant menu is currently a standalone CRUD feature (items, categories, allergens)
- The system has menu-header and menu-footer already registered

---

## Panel Votes Summary

| Position | Count | Percentage |
|----------|-------|------------|
| **AGREE (should be integrated)** | 18 | 36% |
| **DISAGREE (keep separate)** | 22 | 44% |
| **PARTIAL (hybrid approach)** | 10 | 20% |

---

## Expert Opinions

### Category 1: Software Architects (10 experts)

**1. Dr. Sarah Chen - Enterprise Architect, 20 years**
> "DISAGREE. The analysis-fields system is designed for AI-generated content that follows a prompt→generate→display pattern. Restaurant menus are user-managed CRUD data. Mixing them violates single responsibility principle."

**2. Marcus Williams - Platform Architect, Google**
> "PARTIAL. The menu ITEMS shouldn't be analysis fields, but menu DESCRIPTIONS and MARKETING COPY should be. Create a hybrid: data in database, AI-generated descriptions in analysis-fields."

**3. Elena Kowalski - SaaS Architect, 15 years**
> "AGREE. Consistency matters. If business-plan uses OfficeDocument component via analysis-fields, restaurant-menu should use a MenuCatalog component the same way. It's about predictable patterns."

**4. James Morrison - Solution Architect, Microsoft**
> "DISAGREE. Analysis fields are for brand identity assets. A menu catalog is operational data. These have different lifecycles, storage patterns, and update frequencies."

**5. Dr. Aisha Patel - Domain-Driven Design Expert**
> "DISAGREE. These are different bounded contexts. Brand identity (analysis fields) vs. Operations (menu management). Keep them separate with clear integration points."

**6. Tom Reynolds - Microservices Architect**
> "PARTIAL. Create menu-catalog as analysis field for the GENERATED menu document, but keep the MenuItemService for raw data management. Two systems, one output."

**7. Lisa Zhang - Frontend Architecture Lead**
> "AGREE. From frontend perspective, having all content types registered in one config makes routing, permissions, and component loading consistent. Don't fragment the architecture."

**8. Robert Kim - API Design Specialist**
> "DISAGREE. The REST API for menu items (CRUD) is fundamentally different from analysis field APIs (generate, regenerate). Don't force them into the same model."

**9. Dr. Michael Foster - Systems Integration Expert**
> "PARTIAL. Register menu-catalog as a READ-ONLY analysis field that renders the current menu state. Keep write operations separate."

**10. Anna Bergström - Clean Architecture Advocate**
> "DISAGREE. The analysis-fields pattern works for content generation. Menus are user data. Coupling them creates a god-config anti-pattern."

---

### Category 2: UX/Product Designers (10 experts)

**11. David Park - Head of Product Design**
> "AGREE. Users don't care about technical separation. They want one place to manage their brand assets. Menu is a brand asset."

**12. Sophie Laurent - UX Researcher**
> "DISAGREE. User mental model: 'I create my brand' (analysis) vs 'I manage my menu' (operations). These are different jobs-to-be-done."

**13. Chris Taylor - Product Manager, Restaurant Tech**
> "AGREE. Restaurant owners update menus daily. Treating it as 'analysis' makes it feel premium and AI-powered, which is the product positioning."

**14. Maria Gonzalez - Information Architect**
> "PARTIAL. Menu STRUCTURE (categories, layout) = analysis field. Menu ITEMS (prices, descriptions) = operational data. Split it."

**15. Kevin O'Brien - Design Systems Lead**
> "AGREE. One config for all content types means one design system approach. Consistency in how things appear, behave, and get generated."

**16. Dr. Jennifer Wu - Human-Computer Interaction**
> "DISAGREE. Analysis fields have a 'generate' action paradigm. Menus have 'add/edit/delete'. Forcing menus into analysis-fields will confuse the UI patterns."

**17. Alex Rivera - Mobile UX Specialist**
> "PARTIAL. For mobile, having one unified content system is crucial. Register menu but with different interaction patterns."

**18. Emma Thompson - Accessibility Expert**
> "DISAGREE. Each content type should have optimized accessibility. A generic 'analysis field' wrapper may hurt menu usability."

**19. Daniel Lee - Conversion Optimization**
> "AGREE. Registration in analysis-fields means it shows in the main dashboard. Visibility = usage = value delivered."

**20. Rachel Green - Design Ops Manager**
> "AGREE. From ops perspective, one config to manage all content types simplifies deployment, feature flags, and A/B testing."

---

### Category 3: Backend Engineers (10 experts)

**21. Sergei Volkov - Senior Backend Developer**
> "DISAGREE. Menu items need proper relational data (allergens, categories, images). Analysis fields use simple file storage. Wrong tool."

**22. Priya Sharma - Database Architect**
> "DISAGREE. Menu data has complex relationships (MenuItem → MenuCategory → MenuItemAllergen). This doesn't fit the flat file model of analysis fields."

**23. Hans Mueller - .NET Core Specialist**
> "PARTIAL. Use analysis-fields for the GENERATED PDF menu. Use EF Core entities for the raw data. Connect them via a 'publish menu' action."

**24. Yuki Tanaka - API Performance Engineer**
> "DISAGREE. Analysis fields are regenerated occasionally. Menus are queried constantly. Different caching, different optimization strategies."

**25. Carlos Mendez - DevOps Engineer**
> "AGREE. One config means one deployment artifact. Simpler CI/CD, simpler rollbacks, simpler feature toggles."

**26. Olga Petrov - Data Engineer**
> "DISAGREE. Menu data should flow to analytics pipelines differently than brand analysis data. Separate systems enable separate processing."

**27. Ahmed Hassan - Security Engineer**
> "PARTIAL. Analysis fields have brand-level permissions. Menu items may need item-level permissions (e.g., hide prices from certain roles). Need flexibility."

**28. Laura Chen - Scalability Expert**
> "DISAGREE. Menus scale per-restaurant. Brand analysis scales per-brand. Different sharding strategies needed."

**29. Mark Johnson - Legacy System Integrator**
> "AGREE. Many restaurant systems expect a single 'content feed'. Having menu in analysis-fields enables easier integration with existing APIs."

**30. Nina Andersson - Event Sourcing Specialist**
> "DISAGREE. Menu changes are frequent user actions. Analysis changes are AI-generated events. Different event patterns, different storage."

---

### Category 4: Restaurant Industry Experts (10 experts)

**31. Chef Anthony Bourdain Jr. - Restaurant Consultant**
> "AGREE. A menu IS the brand. It should be managed alongside brand assets. The separation is artificial."

**32. Michelle Wong - Restaurant Technology Advisor**
> "PARTIAL. Quick-service restaurants need fast menu updates (pricing). Fine dining needs brand-consistent design. Support both via hybrid."

**33. Roberto Espinoza - POS Integration Specialist**
> "DISAGREE. Menus must sync with POS systems. Analysis fields don't have webhook/sync capabilities. Keep menu as proper API resource."

**34. Stephanie Brooks - Food Delivery Platform Expert**
> "DISAGREE. Delivery platforms need structured menu data (JSON/XML). Analysis fields output documents. Wrong format."

**35. John McCarthy - Restaurant Chain CTO**
> "AGREE. For brand consistency across locations, treating menu as brand asset (analysis field) enforces standards better."

**36. Dr. Linda Foster - Hospitality Technology Researcher**
> "PARTIAL. Franchise models need corporate-controlled templates (analysis fields) + local customization (CRUD). Hybrid approach."

**37. Peter Nguyen - Independent Restaurant Owner**
> "DISAGREE. I just want to add a dish and set a price. Don't make me understand 'brand analysis'. Simple menu management please."

**38. Alexandra Kim - Menu Engineering Consultant**
> "AGREE. Menu engineering requires understanding menu as strategic brand tool. Analysis-fields positioning supports this."

**39. Richard Thompson - Food Photography Director**
> "PARTIAL. Menu IMAGES should be analysis fields (AI-enhanced, brand-consistent). Menu DATA should be separate."

**40. Maria Santos - Nutritional Compliance Officer**
> "DISAGREE. Allergen data has legal requirements. This needs proper database constraints, not JSON files in analysis-fields."

---

### Category 5: AI/ML Engineers (10 experts)

**41. Dr. Wei Zhang - NLP Specialist**
> "AGREE. Menu descriptions are perfect for AI generation. Registration enables consistent prompt engineering across all content types."

**42. James Patterson - LLM Application Developer**
> "PARTIAL. Menu item descriptions = analysis field. Menu structure = user data. AI generates copy, user organizes structure."

**43. Samantha Green - Computer Vision Engineer**
> "AGREE. Menu images need AI processing (style consistency, quality). Analysis-fields pipeline already handles this for logos."

**44. Dr. Raj Patel - Recommendation Systems**
> "DISAGREE. Menu recommendations need real-time user behavior data. Analysis-fields are static snapshots. Different system needed."

**45. Emily Watson - Prompt Engineering Lead**
> "AGREE. Unified prompt config (analysis-fields) means consistent AI behavior. Menu prompts should live alongside brand prompts."

**46. Michael Brown - ML Operations Engineer**
> "PARTIAL. Use analysis-fields for inference (generate menu descriptions). Use separate pipeline for training (menu performance data)."

**47. Dr. Sarah Lee - Generative AI Researcher**
> "AGREE. Menu generation (layout, design, copy) is a generative task. It belongs in the same system as other generative brand tasks."

**48. Alex Turner - AI Product Manager**
> "DISAGREE. Analysis fields are one-shot generation. Menus need iterative editing. Different interaction patterns, different architecture."

**49. Dr. Nina Chen - Multimodal AI Expert**
> "AGREE. Menu = text (descriptions) + images (food photos) + layout (design). Multimodal generation fits analysis-fields perfectly."

**50. Robert Martinez - AI Ethics Consultant**
> "PARTIAL. AI-generated menu descriptions should be flagged as such (in analysis-fields). User-entered data should be clearly separate."

---

## Consensus Analysis

### Arguments FOR Integration (36%)
1. Brand consistency - menu is a brand asset
2. Unified config - simpler architecture
3. AI generation - menu copy benefits from same prompts
4. Dashboard visibility - registered content gets featured
5. Design system consistency - one pattern for all content

### Arguments AGAINST Integration (44%)
1. Different data models - CRUD vs. generation
2. Different update frequency - daily vs. occasional
3. Different storage needs - relational vs. files
4. Different integration needs - POS/delivery APIs
5. Different user mental models - manage vs. create

### Arguments for HYBRID Approach (20%)
1. Separate data (menu items in DB) + generated presentation (menu document in analysis-fields)
2. User-entered content (prices) + AI-generated content (descriptions)
3. Corporate templates (analysis-fields) + local customization (CRUD)

---

## Recommendation

**The majority (44%) recommends keeping restaurant menu SEPARATE from analysis-fields, with a clear integration point.**

**Proposed Architecture:**
```
┌─────────────────────────────────────────────────────────────┐
│                    analysis-fields.config.json               │
├─────────────────────────────────────────────────────────────┤
│ menu-header        │ BrandDocumentFragment (AI-generated)   │
│ menu-footer        │ BrandDocumentFragment (AI-generated)   │
│ menu-document      │ NEW: Generated PDF/layout from items   │
│ menu-descriptions  │ NEW: AI-generated item descriptions    │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ Pulls data from
                              │
┌─────────────────────────────────────────────────────────────┐
│                    Database (EF Core)                        │
├─────────────────────────────────────────────────────────────┤
│ MenuItem           │ CRUD via RestaurantMenuController      │
│ MenuCategory       │ Relational data with allergens, tags   │
│ MenuItemImage      │ User-managed, not AI-generated         │
└─────────────────────────────────────────────────────────────┘
```

**What's Missing in PR #148:**
1. `menu-document` analysis field - to generate the printable menu from items
2. `menu-descriptions` analysis field - AI-generated descriptions for items
3. Prompt file: `restaurant-menu.prompt.txt` - for menu generation
