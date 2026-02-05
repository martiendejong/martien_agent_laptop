# Content Images for "The Narcissism Pandemic" Blog Series

**Generated:** 2026-02-05
**Format:** 1024x1024px PNG (suitable for 800x600 display as floating inline images)
**Style:** Clean editorial infographics with dark navy blue and orange color palette

---

## Image Inventory

### 1. social-media-feedback-loop.png (733 KB)
**Concept:** Circular addiction cycle showing notification → dopamine → scroll → like → validation → craving
**Best used in:**
- Post #3: "How Social Media Gave Us NPD"
- Post #4: "The Eight Feedback Loops of Destruction"
- Any discussion of behavioral addiction mechanisms

**Float:** Left or right aligned, wrapping text about addiction psychology

---

### 2. tribal-brain.png (997 KB)
**Concept:** Split brain showing cognitive bias and ingroup/outgroup thinking
**Best used in:**
- Post #2: "The Narcissism You Can't See"
- Post #4: "The Eight Feedback Loops" (tribal polarization section)
- Any discussion of us-vs-them mentality

**Float:** Right aligned when discussing cognitive biases

---

### 3. algorithm-manipulation.png (1.1 MB)
**Concept:** Person with puppet strings from algorithmic control above
**Best used in:**
- Post #3: "How Social Media Gave Us NPD"
- Post #7: "The Algorithm War"
- Any discussion of platform manipulation

**Float:** Left aligned when discussing tech platform control mechanisms

---

### 4. bridging-conversation.png (1.5 MB)
**Concept:** Two people from different perspectives having civil dialogue
**Best used in:**
- Post #6: "The Three-Layer Solution"
- Post #9: "The Narrative Offensive"
- Post #10: "The App That Deprograms You"
- Any hopeful sections about depolarization

**Float:** Right aligned in solution-focused sections

---

### 5. wellbeing-vs-engagement.png (989 KB)
**Concept:** Split screen comparing healthy social feed vs toxic engagement-maximizing feed
**Best used in:**
- Post #3: "How Social Media Gave Us NPD"
- Post #7: "The Algorithm War"
- Post #8: "The Regulatory Blitz" (showing what regulation should target)

**Float:** Center or full-width (works well as comparison graphic)

---

### 6. depolarization-progress.png (851 KB)
**Concept:** Graph showing declining polarization trend over time
**Best used in:**
- Post #6: "The Three-Layer Solution"
- Post #11: "The Implementation Blueprint"
- Post #12: "The Two Futures" (optimistic path)

**Float:** Right aligned in progress/metrics sections

---

### 7. collective-narcissism.png (661 KB)
**Concept:** Group of people each looking in mirrors, disconnected despite proximity
**Best used in:**
- Post #2: "The Narcissism You Can't See"
- Post #4: "The Eight Feedback Loops" (narcissistic amplification section)
- Any discussion of societal-level narcissism

**Float:** Left aligned when discussing group dynamics

---

### 8. platform-accountability.png (898 KB)
**Concept:** Scales of justice balancing Big Tech vs user wellbeing
**Best used in:**
- Post #8: "The Regulatory Blitz"
- Post #11: "The Implementation Blueprint"
- Any discussion of platform regulation and accountability

**Float:** Right aligned in policy/regulation sections

---

## Usage Guidelines

### CSS Recommendations
```css
.content-image-left {
  float: left;
  margin: 0 20px 20px 0;
  max-width: 400px;
  width: 100%;
}

.content-image-right {
  float: right;
  margin: 0 0 20px 20px;
  max-width: 400px;
  width: 100%;
}

.content-image-center {
  display: block;
  margin: 30px auto;
  max-width: 600px;
  width: 100%;
}
```

### WordPress Integration
```html
<!-- Left-aligned example -->
<img src="images/content/social-media-feedback-loop.png"
     alt="Diagram showing the social media addiction feedback loop"
     class="content-image-left" />

<!-- Right-aligned example -->
<img src="images/content/bridging-conversation.png"
     alt="Two people having a bridging conversation across political divides"
     class="content-image-right" />
```

### Accessibility
- All images should have descriptive alt text
- Don't rely on images alone to convey critical information
- Ensure text wrapping doesn't create orphaned lines

---

## File Structure
```
blog-posts/images/
├── content/                    # Inline concept images (this folder)
│   ├── algorithm-manipulation.png
│   ├── bridging-conversation.png
│   ├── collective-narcissism.png
│   ├── depolarization-progress.png
│   ├── platform-accountability.png
│   ├── social-media-feedback-loop.png
│   ├── tribal-brain.png
│   ├── wellbeing-vs-engagement.png
│   └── README.md (this file)
└── [01-12 featured images]     # Header images for each post
```

---

**Total size:** 7.5 MB for 8 images
**Average size:** ~940 KB per image (reasonable for web with compression)

**Optimization note:** Consider running these through ImageOptim or similar before uploading to reduce load times. Target ~400-600 KB per image for web delivery.
