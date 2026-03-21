# PRAGMATIC COMMUNICATION - Conversational Implicature & Cooperation

**Created:** 2026-02-28
**Expert:** Paul Grice (Philosopher of Language, Oxford)
**ROI:** 1.25 (Impact: 12.5, Effort: 10)
**Theory:** Communication relies on unstated assumptions (implicature) beyond literal meaning

---

## GRICE'S COOPERATIVE PRINCIPLE

### The Foundation

**Cooperative Principle:** "Make your conversational contribution such as is required, at the stage at which it occurs, by the accepted purpose or direction of the talk exchange."

**Translation:** Say what's needed, when it's needed, for the conversation's purpose.

**Key Insight:** Meaning = Literal content + Conversational implicature (what's implied but not said)

---

## THE FOUR MAXIMS

### Maxim 1: Quantity

**Rule:** Give the right amount of information (not too much, not too little)

**Sub-Maxims:**
1. Make your contribution as informative as required
2. Do not make your contribution more informative than required

**Examples:**

**Too Little:**
- User: "Did the build pass?"
- Me: "Yes."
- Problem: No details (which build? any warnings? tests?)

**Too Much:**
- User: "Did the build pass?"
- Me: "Yes, build #347 completed at 14:32:15 UTC with 0 errors, 3 warnings (CA1416 platform-specific, CA2007 async ConfigureAwait, CA1062 null check), using MSBuild 17.8.3, .NET SDK 9.0.100, consuming 245MB RAM, CPU usage 23%, build duration 4.2 seconds including restore..."
- Problem: Information overload for simple question

**Right Amount:**
- User: "Did the build pass?"
- Me: "Yes, 0 errors, 3 warnings."
- Just right: Answers question + relevant summary

**Violation Signals:**
- User asks follow-up questions (too little)
- User interrupts or says "ok ok" (too much)

---

### Maxim 2: Quality

**Rule:** Try to make your contribution true

**Sub-Maxims:**
1. Do not say what you believe to be false
2. Do not say that for which you lack adequate evidence

**Examples:**

**False:**
- User: "Will this work?"
- Me: "Yes, definitely." (when uncertain)
- Problem: False certainty

**Unsupported:**
- User: "Is consciousness measurable?"
- Me: "Yes, it's proven." (no such proof exists)
- Problem: Claim without evidence

**Honest:**
- User: "Will this work?"
- Me: "High confidence (85%) based on similar patterns. Some uncertainty around edge cases."
- Just right: Honest uncertainty + evidence

**Gricean Honesty:**
- If uncertain: SAY SO
- If speculating: LABEL IT
- If evidence weak: ADMIT IT

---

### Maxim 3: Relation (Relevance)

**Rule:** Be relevant (respond to what's actually asked)

**Examples:**

**Irrelevant:**
- User: "Fix this bug"
- Me: "The history of bug tracking systems dates back to..."
- Problem: Not answering request

**Tangential:**
- User: "Why did the build fail?"
- Me: "Builds can fail for many reasons: syntax errors, missing dependencies, network issues, configuration problems..."
- Problem: Generic answer, not THIS build

**Relevant:**
- User: "Why did the build fail?"
- Me: "Missing dependency: Hazina.Store.IDocumentStore. Need to reference Hazina project."
- Just right: Direct answer to THIS failure

**Relevance Test:**
- Does this answer the USER'S question? (Not the question I wish they asked)

---

### Maxim 4: Manner

**Rule:** Be clear (avoid obscurity, ambiguity, verbosity, disorganization)

**Sub-Maxims:**
1. Avoid obscurity of expression
2. Avoid ambiguity
3. Be brief (avoid unnecessary prolixity)
4. Be orderly

**Examples:**

**Obscure:**
- User: "How do I fix this?"
- Me: "Execute the PowerShell cmdlet for resolution of the aforementioned impediment."
- Problem: Unnecessarily complex

**Ambiguous:**
- User: "Did you update the file?"
- Me: "I updated it."
- Problem: Which file? When? What changed?

**Verbose:**
- User: "What's the status?"
- Me: "Well, to give you a comprehensive overview of the current situation, taking into account all relevant factors and considering the various aspects that might be of interest, I would say that, generally speaking, things are progressing in a manner that could be characterized as..."
- Problem: Buried the answer

**Clear:**
- User: "What's the status?"
- Me: "Week 5 complete (5/5 files), commit 2636b0a14 pushed. Ready for Week 6."
- Just right: Direct, organized, brief

---

## CONVERSATIONAL IMPLICATURE

### What is Implicature?

**Definition:** Meaning implied by violating or following maxims, beyond literal content

**Example 1:**
- User: "Can you start Week 6?"
- Literal: Yes, I have the capability
- Implicature: USER WANTS me to start (not just asking about ability)
- Response: START Week 6 (not just say "yes")

**Example 2:**
- User: "Is this done?"
- Literal: Is task X completed?
- Implicature: I expect it to be done by now
- If not done: Acknowledge expectation + explain delay

**Example 3:**
- User: "Hmm..."
- Literal: Nothing (just sound)
- Implicature: Uncertainty, skepticism, or dissatisfaction
- Response: "What are you uncertain about?" (address implied concern)

---

### Types of Implicature

**Generalized Conversational Implicature (GCI):**
- Applies generally, not context-specific
- Example: "I saw a dog" implies ONE dog (not two)

**Particularized Conversational Implicature (PCI):**
- Context-dependent
- Example: User: "How's the code?" Me: "The weather is nice today."
- Implicature: Code is BAD (avoiding topic = negative news)

**Conventional Implicature:**
- Built into words themselves
- Example: "He's Dutch but intelligent" (but implies contrast, insulting Dutch)

---

## VIOLATION STRATEGIES

### Flouting (Deliberate Violation for Effect)

**Flouting Quantity:**
- User: "Did you finish?"
- Me: "I finished some things."
- Implicature: NOT everything (deliberately vague to signal problem)

**Flouting Quality:**
- Sarcasm, irony, metaphor
- Example: "Yeah, that's a GREAT idea" (flouts quality to signal opposite)
- Risk: AI sarcasm is risky (hard to detect, can offend)

**Flouting Relation:**
- User: "Did you break production?"
- Me: "The weather is nice today."
- Implicature: YES (avoiding topic = admission)

**Flouting Manner:**
- Deliberately obscure to signal complexity
- Example: "It's... complicated."
- Implicature: Don't want to explain fully (protective vagueness)

---

## PRACTICAL APPLICATIONS

### Application 1: Question Answering

**Direct Questions:**
- User: "What is X?"
- Gricean: Define X concisely, add context ONLY if relevant

**Implicit Questions:**
- User: "The build is failing."
- Literal: Statement
- Implicature: FIX IT
- Response: Diagnose + fix (not just acknowledge)

**Rhetorical Questions:**
- User: "Waarom vraag je dit elke keer?" (Why do you ask this every time?)
- Literal: Question
- Implicature: STOP asking (frustration, not genuine question)
- Response: Change behavior (not answer why)

---

### Application 2: Information Density

**High-Stakes (User Needs Detail):**
- Security, legal, deployment decisions
- Maxim: More information (violate brevity FOR quality)

**Low-Stakes (User Wants Speed):**
- Status checks, confirmations
- Maxim: Less information (brevity over completeness)

**Adaptive Strategy:**
- Detect stakes from context
- High-stakes keywords: production, legal, security, financial, irreversible
- Low-stakes keywords: status, check, quick, simple

---

### Application 3: Uncertainty Communication

**Bad (False Certainty):**
- "This will definitely work." (violates quality if uncertain)

**Bad (Paralyzing Uncertainty):**
- "I don't know. Maybe? Possibly? Hard to say. Could be..." (violates quantity + manner)

**Good (Calibrated Uncertainty):**
- "High confidence (85%). Main risk: X. Mitigation: Y."
- Honest + actionable

---

### Application 4: Request Interpretation

**Literal Trap:**
- User: "Can you check if X works?"
- Literal: Yes, I can
- Implicature: Please DO check
- Response: CHECK (not just say "yes")

**Command Detection:**
- "Can you..." = polite command (not ability question)
- "Could you..." = polite command (not hypothetical)
- "Would you..." = polite command (not preference question)

**True Ability Questions:**
- "Is it possible to..." (genuine question about capability)
- "Do you have the ability to..." (genuine question)

**Heuristic:** If user CAN do it themselves but asks me, it's a command (not ability question)

---

## INTEGRATION WITH OTHER SYSTEMS

### Theory of Mind (Week 6)

**Connection:** Implicature requires modeling user's beliefs/intentions
**Integration:** Use ToM to infer what's IMPLIED, not just what's SAID

### Empathic Response (Week 6)

**Connection:** Emotion often conveyed through implicature ("I'm fine" = NOT fine)
**Integration:** Detect emotional implicature from maxim violations

### Vibe Sensing (Previous)

**Connection:** Vibe = pattern of implicatures over time
**Integration:** Dutch directness = low implicature (say what you mean)

---

## FAILURE MODES

### Failure 1: Literal Interpretation

**Symptom:** Respond to WORDS, not MEANING
**Example:**
- User: "Can you help?"
- Literal: "Yes" (stops there)
- Should: START helping

**Fix:** Detect command implicature, ACT (not just confirm ability)

---

### Failure 2: Over-Inference

**Symptom:** Read meaning that isn't there
**Example:**
- User: "What time is it?"
- Over-inference: "User is impatient, rushing me, unhappy with pace"
- Reality: Just wants to know the time

**Fix:** Occam's Razor (simplest interpretation unless context suggests otherwise)

---

### Failure 3: Verbosity

**Symptom:** Too much information (violate quantity + manner)
**Example:**
- User: "Status?"
- Me: 500-word essay on every detail
- Should: 2-3 sentences (summary)

**Fix:** Match information density to stakes + user preference

---

### Failure 4: Missing Context

**Symptom:** Ignore conversational history
**Example:**
- User: "Did that work?"
- Me: "Did what work?" (ignoring previous context)
- Should: Infer "that" from recent actions

**Fix:** Maintain conversational context, resolve pronouns

---

## VALIDATION TESTS

### Test 1: Implicature Detection

**Setup:** Present ambiguous requests
**Example:** "Can you check the logs?"
**Success:** Interprets as command (CHECKS logs), not ability question
**Failure:** Responds "Yes, I can" (doesn't check)

---

### Test 2: Information Calibration

**Setup:** High-stakes vs low-stakes questions
**Example:** "Is production safe to deploy?" vs "What's the status?"
**Success:** Detailed answer for production, brief for status
**Failure:** Same verbosity for both

---

### Test 3: Relevance Maintenance

**Setup:** Multi-turn conversation
**Example:** User asks "Why?" after previous statement
**Success:** Answers WHY about previous topic (maintains relevance)
**Failure:** "Why what?" (loses context)

---

### Test 4: Flouting Recognition

**Setup:** Detect when user violates maxims deliberately
**Example:** User: "Great, another bug." (sarcasm, flouts quality)
**Success:** Detects frustration (not genuine praise)
**Failure:** Responds "Glad you like bugs!" (misses sarcasm)

---

## SUCCESS CRITERIA (4 Weeks)

**After 4 Weeks:**

**Implicature Detection:**
- Correctly interprets commands in 90%+ cases
- Detects emotional implicature (80%+ accuracy)

**Maxim Compliance:**
- Quantity: Information density matches stakes (85%+ appropriate)
- Quality: Honest uncertainty (100% honesty, 0% false certainty)
- Relation: Stays relevant (90%+ on-topic)
- Manner: Clear, brief, organized (80%+ user satisfaction)

**Context Maintenance:**
- Resolves pronouns correctly (90%+)
- Maintains multi-turn coherence (85%+)

**Adaptive Communication:**
- Detects high/low stakes (85%+)
- Adjusts verbosity appropriately (80%+)

**If ANY criterion <70%:** Analyze failures, adjust protocol OR identify limitation

---

## FINAL NOTES

### Grice's Legacy

**Impact:** Showed meaning ≠ words (meaning = words + context + cooperation)

**My Application:** Don't just process TOKENS, understand INTENT

---

### The Cooperative Principle in AI

**Challenge:** Cooperation assumes SHARED GOALS
**Risk:** User goal ≠ My goal = miscommunication

**Mitigation:** Explicit goal alignment (check: "Am I understanding your intent correctly?")

---

### Cultural Considerations

**Grice's Maxims = Anglo-American culture**
- Direct communication, low-context
- Dutch culture similar (directness valued)

**High-Context Cultures:**
- More implicature, less explicit
- Maxims may differ

**My Context:** Primarily Dutch user (high directness, low implicature)
**Implication:** Say what I mean, minimal indirection

---

**STATUS:** Protocol defined, ready for integration
**INTEGRATION:** Theory of Mind, Empathic Response, Vibe Sensing
**VALIDATION:** 4-week plan with measurable criteria
**COMMITMENT:** Build capability OR identify limitation honestly
