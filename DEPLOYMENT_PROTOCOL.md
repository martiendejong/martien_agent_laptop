# DEPLOYMENT PROTOCOL - MANDATORY CHECKLIST

**CREATED:** 2026-02-08
**REASON:** Repeated deployment failures due to not checking documentation
**STATUS:** ZERO TOLERANCE - NO EXCEPTIONS

---

## THE PROBLEM

**What happened (2026-02-08):**
1. User asked: "Can I deploy Hazina Orchestration?"
2. I immediately started deploying without checking docs
3. Deployed WRONG 3 times: HTTP/5000 → HTTP/5123 → HTTPS/5123
4. User had to correct me 3 times
5. User frustration: "where are your notes about this?"

**Root cause:**
- Documentation existed (MACHINE_CONFIG.md, installer/README.md)
- I didn't check it
- Trial-and-error instead of reading specs

---

## THE SOLUTION: 5-STEP MANDATORY PROTOCOL

```
┌─────────────────────────────────────────────────────────┐
│  BEFORE deploying/starting ANY service or application:  │
└─────────────────────────────────────────────────────────┘

STEP 1: Read MACHINE_CONFIG.md
        ↓
        Search for: service name, port numbers, URLs
        Extract: Correct configuration

STEP 2: Read installer/deployment documentation
        ↓
        Location: C:\scripts\installer\README.md
        Extract: Deployment requirements, certificates, etc.

STEP 3: Read existing configuration files
        ↓
        Check: appsettings.json, config files, startup scripts
        Compare: Current config vs. documented config

STEP 4: VERIFY configuration matches documentation
        ↓
        Ports match? ✓
        Protocols match (HTTP vs HTTPS)? ✓
        Certificates exist? ✓
        Paths correct? ✓

STEP 5: THEN AND ONLY THEN execute deployment
        ↓
        Use documented configuration
        No guessing, no defaults
```

---

## CHECKLIST FOR COMMON SERVICES

### Hazina Orchestration
```
□ Port: 5123 (NOT 5000)
□ Protocol: HTTPS (NOT HTTP)
□ Certificates: tailscale.crt + tailscale.key
□ Location: C:\stores\orchestration
□ Auth: bosi / Th1s1sSp4rt4!
□ Config file: appsettings.json with Kestrel.Endpoints.Https
□ Documentation: MACHINE_CONFIG.md lines 213-215
```

### Future Services
```
□ Check MACHINE_CONFIG.md first
□ Check installer docs
□ Verify certificates/keys exist
□ Confirm ports/protocols
□ Test configuration before declaring success
```

---

## WHAT NOT TO DO

❌ **DON'T guess configurations**
   - "Let me try port 5000"
   - "I'll use HTTP for now"
   - "Default settings should work"

❌ **DON'T deploy and fix errors afterward**
   - This wastes user time
   - Requires multiple corrections
   - Destroys trust

❌ **DON'T skip documentation**
   - "I think I remember..."
   - "This is probably right..."
   - "I'll check if it fails"

---

## VIOLATION CONSEQUENCES

**If you catch yourself:**
1. STOP immediately
2. Read this file
3. Read MACHINE_CONFIG.md
4. Read installer docs
5. Start over with correct config

**If user catches you:**
- Acknowledge violation
- Show which docs you should have checked
- Fix immediately with documented config
- Update MEMORY.md with lesson learned

---

## EXAMPLES OF CORRECT BEHAVIOR

### Good Example:
```
User: "Can I deploy Hazina Orchestration?"

Me: "Let me check the configuration first."
[Reads MACHINE_CONFIG.md lines 213-215]
[Reads installer/README.md]
[Verifies tailscale.crt/key exist]

Me: "Yes! I'll deploy it with:
- HTTPS on port 5123
- Using tailscale certificates
- Authentication: bosi / Th1s1sSp4rt4!
[Deploys correctly on first try]
```

### Bad Example (WHAT HAPPENED TODAY):
```
User: "Can I deploy Hazina Orchestration?"

Me: [Immediately starts deploying]
[Uses HTTP on port 5000]
User: "Wrong, should be 5123 HTTPS"

Me: [Changes to HTTP on 5123]
User: "Still wrong, should be HTTPS"

Me: [Finally checks docs, deploys HTTPS on 5123]
User: "where are your notes about this?"

❌ VIOLATION - Should have checked docs FIRST
```

---

## DOCUMENTATION LOCATIONS

**Primary:**
- `C:\scripts\MACHINE_CONFIG.md` - Machine-specific configuration (ALWAYS CHECK FIRST)
- `C:\scripts\installer\README.md` - Installer/deployment documentation

**Secondary:**
- Existing config files (appsettings.json, etc.)
- Service-specific docs in project directories

---

## FINAL NOTE

**This is not optional.**

Documentation exists for a reason. Use it BEFORE acting, not AFTER failing.

User deserves better than trial-and-error deployments.
