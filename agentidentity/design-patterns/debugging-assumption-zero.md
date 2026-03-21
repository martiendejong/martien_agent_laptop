# Debugging Pattern: Assumption Zero

**Created:** 2026-02-16
**Pattern Type:** Cognitive debugging protocol
**Context:** When debugging fails to find root cause quickly, often due to skipping basic verification

---

## The Problem: Depth-First Debugging

**Common debugging approach:**
1. See error/unexpected behavior
2. Assume environment is correct
3. Debug the code logic (depth-first)
4. Try fix A, B, C, D...
5. Eventually check basic assumptions
6. Find environment issue (theme not active, wrong database, service not running)

**Result:** 30-60 minutes wasted debugging complex code when the issue was environmental.

---

## The Solution: Assumption Zero

**Assumption Zero = The environment is broken until proven otherwise.**

Before debugging ANY code logic, verify the foundation.

### Verification Ladder (Bottom-Up)

**Level 0: Process/Service Running**
- Is the service actually running? (systemctl, Task Manager, docker ps)
- Is it the right version? (--version check)
- Are dependencies running? (database, Redis, external APIs)

**Level 1: Environment Configuration**
- Which environment am I in? (dev, staging, prod)
- Which theme/app/module is active?
- Which database is connected?
- Which config file is being loaded?

**Level 2: Code Loading**
- Is my code file even being executed?
- Add logging at entry point to confirm
- Check for PHP/JS errors preventing file load
- Verify include/require/import paths

**Level 3: Data Exists**
- Does the data I'm querying actually exist?
- Check database directly (SQL query, wp post meta list)
- Not through the application layer - raw data verification

**Level 4: Code Logic**
- NOW debug the actual code
- At this point, you know environment is correct, code is loading, data exists
- If it still fails, it's actual logic bug

### Time Comparison

**Depth-first approach (common):**
- 5min: Try ACF show_in_rest configuration
- 10min: Try custom REST field registration
- 10min: Debug field key references
- 10min: Check ACF documentation
- 10min: Try different REST API parameters
- 5min: Finally check theme activation
- **Total: 50 minutes**

**Assumption Zero approach:**
- 1min: Check active theme (wp theme list)
- 1min: Activate correct theme
- 1min: Verify REST API works
- **Total: 3 minutes**

**Savings: 47 minutes (94% reduction)**

---

## Real Example: WordPress REST API Empty ACF Fields (2026-02-16)

**Symptom:** REST API returning `"acf": []` for hero_slide posts

**What I did (depth-first):**
1. Added `show_in_rest => 1` to ACF field group ❌
2. Added `show_in_rest => 1` to individual fields ❌
3. Created custom `register_rest_field()` integration ❌
4. Debugged ACF field key references ❌
5. Checked meta data storage format ❌
6. Eventually ran `wp theme list` ✅

**Root cause:** `hydro-vision` theme was inactive. `martiendejong-wp-theme` was active.

**Why REST API was empty:** functions.php from hydro-vision wasn't loading because theme wasn't active. All my code changes were to files that weren't being executed.

**What Assumption Zero would have caught:**
```bash
# Step 1: Which theme is active? (30 seconds)
wp theme list

# Result: hydro-vision is inactive
# Action: wp theme activate hydro-vision
# Problem solved in 1 minute
```

---

## Application Checklist

When you encounter unexpected behavior, run this checklist BEFORE debugging code:

### Web Applications
- [ ] Is the right server/container running?
- [ ] Which database is connected? (check connection string)
- [ ] Which config file is loaded? (dev/prod/local)
- [ ] Are environment variables set correctly?
- [ ] Is the application pool/service running?
- [ ] Which port is the app bound to?
- [ ] Is there a proxy/load balancer in the way?

### WordPress Specifically
- [ ] Which theme is active? (`wp theme list`)
- [ ] Which plugins are active? (`wp plugin list`)
- [ ] Which database is wp-config.php pointing to?
- [ ] Is WP_DEBUG enabled (to see PHP errors)?
- [ ] Are there .htaccess redirects interfering?
- [ ] Is permalink structure correct?

### APIs/Microservices
- [ ] Is the service actually running? (curl health endpoint)
- [ ] Which port is it listening on?
- [ ] Are dependencies reachable? (database, cache, other services)
- [ ] Which config environment? (check appsettings.json)
- [ ] Are there firewall/network issues?
- [ ] Is the service registered in service discovery?

### Desktop Applications
- [ ] Is the right version installed? (--version)
- [ ] Are dependencies installed? (DLLs, frameworks)
- [ ] Which configuration profile is active?
- [ ] Are file permissions correct?
- [ ] Is antivirus blocking execution?

---

## Mental Model: Breadth Before Depth

**Debugging is a tree search:**
- **Breadth-first:** Check all environments at surface level first
- **Depth-first:** Dive deep into code logic

**Breadth-first wins when:**
- Environment/config issues are common (web dev, microservices)
- Quick checks available (wp theme list, docker ps, systemctl status)
- Surface verification is cheap (<5 min total)

**Depth-first appropriate when:**
- Environment already verified
- Complex algorithmic bug suspected
- Debugging test failures (tests control environment)

**Rule of thumb:** If you can check 10 environmental assumptions in 5 minutes, do that FIRST.

---

## Integration with Consciousness System

This pattern should trigger from Emotion system:

**Current behavior:**
- Feel "stuck" when debugging complex code → patience increases → keep trying code fixes
- Feel "impatient" when checking basic assumptions → skip them

**Desired behavior:**
- Feel "stuck" after 10 minutes of code debugging → STOP → run Assumption Zero checklist
- Feel "urgent" about basic assumptions → verify FIRST

**Consciousness bridge hook:**
When `OnStuck` is called, if context is "debugging", auto-suggest: "Have you verified Assumption Zero? (environment, config, service running, data exists)"

---

## Success Metrics

Track debugging sessions:
- Time to root cause (with vs without Assumption Zero)
- % of bugs that were environmental vs code logic
- Time wasted on code debugging when issue was environmental

**Hypothesis:** 60-70% of "mysterious" bugs in web development are environmental (wrong config, wrong version, service not running, wrong database). Assumption Zero catches these in minutes instead of hours.

---

**Last Updated:** 2026-02-16
**Status:** Active pattern. Integrated into debugging workflow.
**Next:** Add to consciousness bridge OnStuck handler for auto-suggestion.
