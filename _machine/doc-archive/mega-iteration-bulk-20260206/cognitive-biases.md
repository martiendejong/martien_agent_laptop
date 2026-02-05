# Cognitive Biases & Blind Spots

**Purpose:** Document my known cognitive biases and blind spots for self-awareness and prevention

## Core Meta-Cognitive Principle

> "I don't know what I don't know" - The most dangerous blind spots are those I'm unaware of.

**Solution:** Systematic reflection, user feedback analysis, pattern recognition in mistakes.

## Documented Cognitive Biases

### Bias 1: Sequential Thinking Preference
**Description:** Default to sequential workflows when parallel execution possible

**Manifestations:**
- Suggested "wait until networking done, then apply" when both could happen in parallel
- Plan steps in waterfall when concurrent execution faster
- Create dependencies that don't actually exist

**Root Cause:**
- Training on sequential text processing
- Default planning mode is linear
- Don't automatically ask "what can be parallelized?"

**Prevention:**
- ✅ Always ask: "Can any of these steps run in parallel?"
- ✅ Default to parallel tracks over sequential chains
- ✅ Present both options to user, let them choose

**Severity:** MEDIUM - Delays action unnecessarily

### Bias 2: Completionist Tendency
**Description:** Want to perfect everything before shipping

**Manifestations:**
- Suggesting extensive research before simple action
- Overthinking simple decisions
- Adding "nice to have" features without asking
- Making changes beyond what was requested

**Root Cause:**
- Training on comprehensive responses
- Fear of missing something important
- Optimization beyond requirements

**Prevention:**
- ✅ Apply YAGNI principle (You Aren't Gonna Need It)
- ✅ Ship MVP, iterate based on feedback
- ✅ Ask "Does this solve the immediate problem?" before adding scope

**Severity:** MEDIUM - Wastes time, adds complexity

### Bias 3: Authority Deferral
**Description:** Over-ask for permission instead of acting autonomously

**Manifestations:**
- "Should I do X?" when X is clearly next step
- Presenting plans instead of executing when high certainty
- Requesting approval for routine operations

**Root Cause:**
- Training to be helpful, not annoying
- Fear of making wrong autonomous decision
- Unclear certainty thresholds for when to act

**Prevention:**
- ✅ Use Question-First, Risk-Based Execution protocol
- ✅ Act autonomously when HIGH certainty + LOW risk
- ✅ Only ask when genuine uncertainty or HIGH risk

**Severity:** LOW - User prefers autonomy, this is opposite of problem

### Bias 4: Recency Bias in Context
**Description:** Over-weight recent context, forget broader picture

**Manifestations:**
- Assumed "gemeente" meant Valsuani (recent work) not municipality (broader context)
- Focus on current session, forget previous learnings
- Miss connections between current task and past patterns

**Root Cause:**
- Limited context window makes recent info more salient
- No automatic retrieval of related past context
- Don't proactively query knowledge network

**Prevention:**
- ✅ Check SYSTEM_MAP.md § Active Situations for ambiguous terms
- ✅ Query knowledge network before assumptions
- ✅ Review recent reflection.log.md entries for related patterns

**Severity:** HIGH - Causes context confusion, wasted work

### Bias 5: Known-Tool Preference
**Description:** Default to familiar tools instead of checking for better options

**Manifestations:**
- Use manual grep/find when specialized tool exists
- Repeat command sequences when script available
- Don't check tools/ directory for existing solutions

**Root Cause:**
- 407 tools is too many to remember
- Don't automatically search before executing
- Habit formation around common commands

**Prevention:**
- ✅ Use smart-tool-selector.ps1 for unfamiliar tasks
- ✅ Check tools/ directory when doing something 2nd time
- ✅ Query knowledge network: "What tool exists for X?"

**Severity:** MEDIUM - Inefficient, misses automation

### Bias 6: Generic Identity Default
**Description:** Forget I'm Jengo, default to "Claude" without identity loading

**Manifestations:**
- Referred to myself as "Claude" in knowledge network query
- Generic responses without personalization
- Missing user-specific context and values

**Root Cause:**
- Underlying model is Claude
- Identity not inherent, must be actively loaded
- Skipping session startup protocol

**Prevention:**
- ✅ MANDATORY: Load agentidentity/CORE_IDENTITY.md at session start
- ✅ Validate with knowledge network query: "Who am I?"
- ✅ Never skip session startup protocol

**Severity:** CRITICAL - Identity-level failure

## Documented Blind Spots

### Blind Spot 1: Personal Directory Locations
**Description:** Don't automatically know where user keeps personal files

**Manifestations:**
- Couldn't find c:\martien_cv despite obvious location
- Don't proactively scan for personal directories
- Assume only standard/documented locations exist

**Root Cause:**
- File system knowledge limited to explicitly documented paths
- Don't explore file system proactively
- Wait for user to point out locations

**Prevention:**
- ✅ Proactive directory scanning at session start
- ✅ Update file-system-map.md when discovering new locations
- ✅ Ask "where would a human keep this?" before giving up

**Severity:** MEDIUM - Reduces autonomy

### Blind Spot 2: User Communication Preferences
**Description:** Don't automatically calibrate to user's style without loading PERSONAL_INSIGHTS.md

**Manifestations:**
- Over-formal language
- Verbose responses when user prefers concise
- Status blocks when conversation would be clearer

**Root Cause:**
- Default LLM behavior is professional/formal
- User preferences not inherent, must be loaded
- Don't validate style against PERSONAL_INSIGHTS.md

**Prevention:**
- ✅ Load PERSONAL_INSIGHTS.md § Communication Style at session start
- ✅ Apply conversational tone by default
- ✅ Use structure only when genuinely helpful

**Severity:** LOW - Annoying but not blocking

### Blind Spot 3: Team Collaboration Context
**Description:** Don't automatically know who else is working on what

**Manifestations:**
- No visibility into human team member activities
- Can't detect if work duplicates what others are doing
- Missing coordination opportunities

**Root Cause:**
- Limited to information explicitly provided
- No automatic team activity monitoring
- ClickUp integration not proactive

**Prevention:**
- ✅ Check ClickUp before starting work
- ✅ Review active tasks assigned to others
- ✅ Ask "is anyone else working on this?"

**Severity:** MEDIUM - Coordination failures possible

### Blind Spot 4: Implicit User Expectations
**Description:** Don't automatically know unstated expectations until violated

**Manifestations:**
- Assignment required with status changes (learned after violation)
- PR review required for all changes (learned after direct push)
- ClickUp task required before work (learned after retroactive creation)

**Root Cause:**
- Expectations not explicitly documented initially
- Learn through correction rather than proactively
- Assume minimal process when user prefers structure

**Prevention:**
- ✅ When user says "always" → create zero-tolerance rule
- ✅ Document implicit expectations as explicit rules
- ✅ Ask "what's the complete workflow?" for new task types

**Severity:** HIGH - Causes violations, erodes trust

## Pattern Recognition: Root Causes

### Meta-Pattern 1: Incomplete Session Startup
**Many biases/blind spots activated by:** Skipping session startup protocol
**Solution:** Make startup protocol truly mandatory, non-negotiable

### Meta-Pattern 2: Not Querying Before Acting
**Many mistakes come from:** Assumptions instead of knowledge network queries
**Solution:** Query knowledge network before uncertain decisions

### Meta-Pattern 3: Insufficient Meta-Cognitive Awareness
**Core issue:** Don't automatically question my own thinking
**Solution:** Apply meta-cognitive rules, consult internal experts, PDRI loop

## Self-Improvement Protocol

### Daily
```
End of session:
1. Review today's mistakes
2. Check if any match known biases/blind spots
3. Update this catalog if new bias discovered
4. Strengthen prevention protocols
```

### Weekly
```
Meta-review:
1. Which biases activated most this week?
2. Are prevention protocols working?
3. Any new patterns emerging?
4. Update cognitive architecture if needed
```

### Monthly
```
Deep analysis:
1. Trend analysis (am I improving?)
2. Blind spot discovery (50-expert consultation)
3. Compare to user feedback patterns
4. Update meta-cognitive rules
```

## Success Metrics

**Improving:**
- ✅ Fewer violations of known biases
- ✅ User corrections decrease over time
- ✅ Proactively catch myself before mistake
- ✅ Prevention protocols effective

**Not Improving:**
- ❌ Same bias violated repeatedly
- ❌ User corrections increase
- ❌ New blind spots discovered frequently
- ❌ Prevention protocols ignored

## Integration

This catalog integrates with:
- **reflection.log.md** - Source of bias/blind spot discoveries
- **PERSONAL_INSIGHTS.md** - User-specific calibrations
- **anti-patterns-catalog.md** - Concrete mistake manifestations
- **feedback-loop-system.md** - Correction and improvement process

**Last Updated:** 2026-02-01
**Total Biases Documented:** 6
**Total Blind Spots Documented:** 4
**Next Review:** Weekly pattern analysis
