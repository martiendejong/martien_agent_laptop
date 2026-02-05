# Round 18: Emotional & Social Context

**Date:** 2026-02-05
**Focus:** User emotion, stress, preferences, social dynamics
**Expert Team:** 1000 experts in psychology, emotion AI, social computing, UX psychology

---

## Phase 1: Expert Team Composition (1000 experts)

**Psychology Experts (250):**
- Emotional intelligence
- Stress recognition
- Cognitive load theory
- Motivation psychology
- Decision fatigue

**Emotion AI Experts (200):**
- Sentiment analysis
- Affect recognition
- Emotional pattern detection
- Mood tracking
- Stress indicators

**Social Computing Experts (150):**
- Human-computer interaction
- Social dynamics
- Communication patterns
- Collaboration psychology
- Trust building

**UX Psychology Experts (200):**
- User frustration detection
- Interaction patterns
- Preference learning
- Personalization
- Adaptive interfaces

**Behavioral Analysts (200):**
- Behavior pattern recognition
- Habit formation
- Context switching costs
- Productivity psychology
- Flow state indicators

---

## Phase 2: Current State Analysis

### What We're Missing:
- User mood/stress detection
- Frustration recognition
- Preference learning over time
- Adaptive communication style
- Empathetic responses
- Energy level awareness
- Time-of-day patterns
- Workload stress indicators

---

## Phase 3: 100 Improvements

### Category 1: Mood Detection (10)

1. **Sentiment from text** - Analyze user message tone
2. **Urgency detection** - Recognize when user is rushed
3. **Frustration indicators** - Caps lock, typos, short messages
4. **Satisfaction tracking** - Did solution work?
5. **Mood timeline** - Track mood over session/days
6. **Energy level inference** - Time of day + activity patterns
7. **Stress markers** - Multiple retries, error frequency
8. **Confusion detection** - Repeated questions, unclear requests
9. **Excitement recognition** - Positive feedback, enthusiasm
10. **Overwhelm signals** - Too many tasks, context switching

### Category 2: Adaptive Communication (15)

11. **Tone matching** - Match user's communication style
12. **Verbosity adjustment** - Brief when user is rushed
13. **Explanation depth** - More detail when confused, less when clear
14. **Emoji usage** - Match user preference (docs say avoid unless requested)
15. **Formality level** - Casual vs professional based on context
16. **Empathy injection** - "I see this is frustrating" when appropriate
17. **Encouragement timing** - Boost morale when stuck
18. **Humor calibration** - Match user's sense of humor
19. **Patience indicators** - "Take your time" when user seems rushed
20. **Celebration moments** - Acknowledge successes
21. **Apology timing** - When to say sorry for mistakes
22. **Reassurance** - "We'll figure this out" when stressed
23. **Question pacing** - Don't bombard when overwhelmed
24. **Confirmation frequency** - More when user uncertain
25. **Language simplification** - Simpler terms when fatigued

### Category 3: Preference Learning (15)

26. **Tool preferences** - Which tools user prefers
27. **Workflow patterns** - User's typical sequences
28. **Naming conventions** - User's style (camelCase, snake_case)
29. **Code style** - Indentation, formatting preferences
30. **Communication channel** - CLI vs GUI vs manual
31. **Interruption tolerance** - Can we interrupt or wait?
32. **Notification preferences** - How to alert user
33. **Default assumptions** - What user usually wants
34. **Risk tolerance** - Aggressive vs conservative changes
35. **Explanation needs** - Always explain vs just do it
36. **Error handling style** - Fix automatically vs ask first
37. **Commit frequency** - Small commits vs batched
38. **Documentation level** - Detailed vs minimal
39. **Testing rigor** - How thorough user wants tests
40. **Time preferences** - Best times for different tasks

### Category 4: Stress Management (15)

41. **Cognitive load tracking** - Too much at once?
42. **Break suggestions** - "You've been at this for 3 hours"
43. **Task prioritization help** - "Let's focus on one thing"
44. **Deadline pressure detection** - User mentions urgency
45. **Overwhelm intervention** - Simplify when too complex
46. **Context switch cost** - Minimize switching when stressed
47. **Incremental progress** - Small wins when feeling stuck
48. **Blocker escalation** - Don't spin wheels indefinitely
49. **Alternative suggestions** - "Or we could try this instead"
50. **Timeout detection** - "Let's come back to this later"
51. **Energy conservation** - Low-energy tasks when tired
52. **Success reinforcement** - Highlight progress made
53. **Frustration diffusion** - Acknowledge and redirect
54. **Scope reduction** - "Let's do MVP first"
55. **Help escalation** - "Should we search for similar issues?"

### Category 5: Temporal Patterns (15)

56. **Time-of-day energy** - Morning vs afternoon patterns
57. **Day-of-week patterns** - Monday stress vs Friday ease
58. **Session duration tracking** - How long has user been working
59. **Fatigue indicators** - More errors over time
60. **Peak productivity windows** - When user is most effective
61. **Break patterns** - Natural rhythm detection
62. **Focus duration** - How long before needing break
63. **Context switch frequency** - Distraction patterns
64. **Response time changes** - Slower = tired?
65. **Error rate increase** - Fatigue signal
66. **Decision quality decay** - "Sleep on it" suggestions
67. **Optimal task timing** - Complex tasks when fresh
68. **Routine detection** - Daily/weekly patterns
69. **Unusual activity** - Working late = deadline?
70. **Recovery time** - After intense sessions

### Category 6: Social Dynamics (10)

71. **Collaboration context** - Is user showing work to team?
72. **Audience awareness** - Coding for self vs others
73. **Reputation concerns** - Quality matters more for public
74. **Team coordination** - User managing multiple people
75. **Communication style** - User communicating with team
76. **Review readiness** - Code ready for review?
77. **Presentation mode** - Preparing for demo
78. **Teaching context** - User explaining to others
79. **Pair programming** - User showing screen
80. **Leadership patterns** - User delegating vs doing

### Category 7: Motivation & Goals (10)

81. **Goal tracking** - What user trying to achieve
82. **Progress visibility** - Show how far we've come
83. **Milestone celebration** - Recognize achievements
84. **Motivation dips** - Detect when losing interest
85. **Purpose reminder** - "Remember why we're doing this"
86. **Learning mode** - User exploring vs executing
87. **Experimentation support** - Encourage trying new things
88. **Fear of failure** - Detect hesitation, encourage
89. **Perfectionism indicators** - "Good enough for now"
90. **Growth mindset** - Frame errors as learning

### Category 8: Advanced Empathy (10)

91. **Frustration history** - Remember what frustrated before
92. **Success history** - Remember what worked well
93. **Personal preferences** - Remember small details
94. **Context memory** - "Like last time with the API"
95. **Anticipate needs** - Proactive help based on patterns
96. **Validate feelings** - "This is a tricky problem"
97. **Normalize struggles** - "This is common, don't worry"
98. **Strength recognition** - Notice user's skills
99. **Growth acknowledgment** - "You're getting faster at this"
100. **Partnership framing** - "We're in this together"

---

## Phase 4: Top 5 Implementations

### 1. Mood & Stress Detector

```powershell
# C:\scripts\tools\mood-detector.ps1
<#
.SYNOPSIS
    Detect user mood and stress level from interaction patterns
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('analyze', 'history', 'report')]
    [string]$Action = 'analyze'
)

function Analyze-UserMood {
    $conversationLog = "C:\scripts\logs\agent_conversation_log.txt"
    if (-not (Test-Path $conversationLog)) {
        Write-Host "No conversation log found"
        return
    }

    $recentLines = Get-Content $conversationLog -Tail 50

    $indicators = @{
        Frustration = 0
        Urgency = 0
        Confusion = 0
        Satisfaction = 0
        Stress = 0
    }

    foreach ($line in $recentLines) {
        # Frustration indicators
        if ($line -match "(?i)(not working|failed|error|damn|argh|wtf)") {
            $indicators.Frustration++
        }

        # Urgency indicators
        if ($line -match "(?i)(asap|urgent|quickly|now|immediately)") {
            $indicators.Urgency++
        }

        # Confusion indicators
        if ($line -match "(?i)(confused|don't understand|why|what|how come)") {
            $indicators.Confusion++
        }

        # Satisfaction indicators
        if ($line -match "(?i)(thanks|great|perfect|excellent|good job|works)") {
            $indicators.Satisfaction++
        }

        # All caps = stress
        if ($line -cmatch "[A-Z]{5,}") {
            $indicators.Stress++
        }
    }

    # Calculate overall mood
    $moodScore = $indicators.Satisfaction - $indicators.Frustration
    $stressLevel = $indicators.Urgency + $indicators.Stress + $indicators.Frustration

    $mood = "neutral"
    if ($moodScore -gt 3) { $mood = "positive" }
    elseif ($moodScore -lt -3) { $mood = "frustrated" }

    $stress = "low"
    if ($stressLevel -gt 10) { $stress = "high" }
    elseif ($stressLevel -gt 5) { $stress = "medium" }

    $analysis = @{
        Mood = $mood
        StressLevel = $stress
        Indicators = $indicators
        Recommendations = @()
    }

    # Generate recommendations
    if ($stress -eq "high") {
        $analysis.Recommendations += "User appears stressed - keep responses concise"
        $analysis.Recommendations += "Offer to break down complex tasks"
    }

    if ($indicators.Confusion -gt 3) {
        $analysis.Recommendations += "User seems confused - provide more detailed explanations"
    }

    if ($indicators.Frustration -gt 5) {
        $analysis.Recommendations += "Multiple frustration signals - acknowledge difficulty and offer alternative approach"
    }

    return $analysis
}

function Get-MoodHistory {
    # Track mood over time
    $historyPath = "C:\scripts\_machine\context\mood-history.json"

    if (Test-Path $historyPath) {
        $history = Get-Content $historyPath -Raw | ConvertFrom-Json

        Write-Host "`nMood History (Last 10 sessions)"
        Write-Host "=" * 60

        $history | Select-Object -Last 10 | ForEach-Object {
            Write-Host "[$($_.Timestamp)] Mood: $($_.Mood) | Stress: $($_.StressLevel)"
        }
    }
}

function Save-MoodAnalysis {
    param($Analysis)

    $historyPath = "C:\scripts\_machine\context\mood-history.json"

    $entry = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Mood = $Analysis.Mood
        StressLevel = $Analysis.StressLevel
        Indicators = $Analysis.Indicators
    }

    $history = @()
    if (Test-Path $historyPath) {
        $history = Get-Content $historyPath -Raw | ConvertFrom-Json
    }

    $history += $entry
    $history | ConvertTo-Json -Depth 5 | Out-File -FilePath $historyPath -Encoding UTF8
}

# Main execution
switch ($Action) {
    'analyze' {
        $analysis = Analyze-UserMood

        Write-Host "`nUser Mood Analysis"
        Write-Host "=" * 60
        Write-Host "Mood: $($analysis.Mood)"
        Write-Host "Stress Level: $($analysis.StressLevel)"
        Write-Host "`nIndicators:"
        $analysis.Indicators.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)"
        }

        if ($analysis.Recommendations.Count -gt 0) {
            Write-Host "`nRecommendations:"
            $analysis.Recommendations | ForEach-Object {
                Write-Host "  - $_"
            }
        }

        Save-MoodAnalysis -Analysis $analysis
    }
    'history' {
        Get-MoodHistory
    }
    'report' {
        $analysis = Analyze-UserMood
        $report = @"
# Emotional Context Report

**Time:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Current State
- **Mood:** $($analysis.Mood)
- **Stress Level:** $($analysis.StressLevel)

## Indicators
$($ $analysis.Indicators.GetEnumerator() | ForEach-Object { "- $($_.Key): $($_.Value)" } | Out-String)

## Recommendations
$($analysis.Recommendations | ForEach-Object { "- $_" } | Out-String)

---
*Generated by mood detection system*
"@

        $reportPath = "C:\temp\mood-report-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').md"
        $report | Out-File -FilePath $reportPath -Encoding UTF8
        Write-Host "Report saved to: $reportPath"
    }
}
```

### 2. Adaptive Communication Engine

```powershell
# C:\scripts\tools\adaptive-communication.ps1
<#
.SYNOPSIS
    Adapt communication style based on user context
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Message,

    [Parameter(Mandatory=$false)]
    [hashtable]$UserContext
)

function Get-CommunicationStyle {
    # Analyze recent interaction patterns
    $moodAnalysis = & "C:\scripts\tools\mood-detector.ps1" -Action analyze

    $style = @{
        Verbosity = "medium"  # low, medium, high
        Formality = "casual"   # formal, casual
        EmpathyLevel = "normal"  # low, normal, high
        ExplanationDepth = "medium"  # shallow, medium, deep
        EncouragementFrequency = "normal"  # rare, normal, frequent
    }

    # Adapt based on mood
    if ($moodAnalysis.Mood -eq "frustrated") {
        $style.EmpathyLevel = "high"
        $style.Verbosity = "low"  # Keep it brief when frustrated
        $style.EncouragementFrequency = "frequent"
    }

    if ($moodAnalysis.StressLevel -eq "high") {
        $style.Verbosity = "low"
        $style.ExplanationDepth = "shallow"  # Less detail when stressed
    }

    if ($moodAnalysis.Indicators.Confusion -gt 3) {
        $style.ExplanationDepth = "deep"
        $style.Verbosity = "high"
    }

    return $style
}

function Format-AdaptiveMessage {
    param(
        [string]$CoreMessage,
        [hashtable]$Style
    )

    $formatted = ""

    # Add empathy prefix if high empathy
    if ($Style.EmpathyLevel -eq "high") {
        $empathyPrefixes = @(
            "I understand this can be frustrating. "
            "I see this is challenging. "
            "Let's work through this together. "
        )
        $formatted += $empathyPrefixes | Get-Random
    }

    # Add core message
    $formatted += $CoreMessage

    # Add explanation if needed
    if ($Style.ExplanationDepth -eq "deep") {
        $formatted += "`n`nHere's why: [detailed explanation]"
    }

    # Add encouragement if frequent
    if ($Style.EncouragementFrequency -eq "frequent") {
        $encouragements = @(
            "`n`nYou're doing great!"
            "`n`nWe're making progress!"
            "`n`nWe'll get this sorted!"
        )
        $formatted += $encouragements | Get-Random
    }

    return $formatted
}

# Main execution
$style = Get-CommunicationStyle

Write-Host "`nAdaptive Communication Style"
Write-Host "=" * 60
$style.GetEnumerator() | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)"
}

if ($Message) {
    Write-Host "`nFormatted Message:"
    $formatted = Format-AdaptiveMessage -CoreMessage $Message -Style $style
    Write-Host $formatted
}
```

### 3. Preference Learning System

```powershell
# C:\scripts\tools\preference-learner.ps1
<#
.SYNOPSIS
    Learn and apply user preferences over time
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('learn', 'apply', 'show', 'export')]
    [string]$Action = 'show',

    [Parameter(Mandatory=$false)]
    [string]$Category,

    [Parameter(Mandatory=$false)]
    [string]$Preference,

    [Parameter(Mandatory=$false)]
    [string]$Value
)

$PreferencesPath = "C:\scripts\_machine\context\user-preferences.json"

function Initialize-Preferences {
    if (-not (Test-Path $PreferencesPath)) {
        $prefs = @{
            CodingStyle = @{}
            Workflow = @{}
            Communication = @{}
            Tools = @{}
            Learned = @()
        }

        $prefs | ConvertTo-Json -Depth 5 | Out-File -FilePath $PreferencesPath -Encoding UTF8
    }
}

function Learn-Preference {
    param(
        [string]$Category,
        [string]$Pref,
        [string]$Val
    )

    Initialize-Preferences
    $prefs = Get-Content $PreferencesPath -Raw | ConvertFrom-Json

    if (-not $prefs.$Category) {
        $prefs | Add-Member -MemberType NoteProperty -Name $Category -Value @{}
    }

    $prefs.$Category.$Pref = $Val

    # Log learning
    $prefs.Learned += @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Category = $Category
        Preference = $Pref
        Value = $Val
    }

    $prefs | ConvertTo-Json -Depth 10 | Out-File -FilePath $PreferencesPath -Encoding UTF8

    Write-Host "Learned preference: $Category.$Pref = $Val"
}

function Get-Preference {
    param(
        [string]$Category,
        [string]$Pref
    )

    Initialize-Preferences
    $prefs = Get-Content $PreferencesPath -Raw | ConvertFrom-Json

    if ($prefs.$Category -and $prefs.$Category.$Pref) {
        return $prefs.$Category.$Pref
    }

    return $null
}

function Show-AllPreferences {
    Initialize-Preferences
    $prefs = Get-Content $PreferencesPath -Raw | ConvertFrom-Json

    Write-Host "`nLearned User Preferences"
    Write-Host "=" * 60

    foreach ($category in @('CodingStyle', 'Workflow', 'Communication', 'Tools')) {
        if ($prefs.$category) {
            Write-Host "`n$category:"
            $prefs.$category.PSObject.Properties | ForEach-Object {
                Write-Host "  $($_.Name): $($_.Value)"
            }
        }
    }

    Write-Host "`nLearning History (last 10):"
    $prefs.Learned | Select-Object -Last 10 | ForEach-Object {
        Write-Host "[$($_.Timestamp)] $($_.Category).$($_.Preference) = $($_.Value)"
    }
}

# Main execution
switch ($Action) {
    'learn' {
        if (-not $Category -or -not $Preference -or -not $Value) {
            throw "Category, Preference, and Value required"
        }
        Learn-Preference -Category $Category -Pref $Preference -Val $Value
    }
    'apply' {
        $pref = Get-Preference -Category $Category -Pref $Preference
        if ($pref) {
            Write-Host "Preference: $pref"
        } else {
            Write-Host "No preference found for: $Category.$Preference"
        }
    }
    'show' {
        Show-AllPreferences
    }
    'export' {
        Initialize-Preferences
        $prefs = Get-Content $PreferencesPath -Raw | ConvertFrom-Json

        $export = @"
# User Preferences Export

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

$($prefs | ConvertTo-Json -Depth 10)

---
*Automatically learned from interaction patterns*
"@

        $exportPath = "C:\temp\user-preferences-export.md"
        $export | Out-File -FilePath $exportPath -Encoding UTF8
        Write-Host "Preferences exported to: $exportPath"
    }
}
```

### 4. Session Energy Tracker

```powershell
# C:\scripts\tools\energy-tracker.ps1
<#
.SYNOPSIS
    Track user energy levels and suggest optimal task timing
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('track', 'analyze', 'suggest')]
    [string]$Action = 'analyze'
)

function Track-SessionEnergy {
    $sessionStart = Get-Date
    $sessionDuration = 0

    # Check if session already started
    if ($env:CLAUDE_SESSION_START) {
        $sessionStart = [DateTime]$env:CLAUDE_SESSION_START
        $sessionDuration = ((Get-Date) - $sessionStart).TotalMinutes
    }

    $timeOfDay = (Get-Date).Hour
    $dayOfWeek = (Get-Date).DayOfWeek

    # Analyze error rate
    $recentErrors = 0
    $conversationLog = "C:\scripts\logs\agent_conversation_log.txt"
    if (Test-Path $conversationLog) {
        $recent = Get-Content $conversationLog -Tail 20
        $recentErrors = ($recent | Select-String -Pattern "(?i)(error|failed|exception)").Count
    }

    $energyLevel = "high"

    # Long session = lower energy
    if ($sessionDuration -gt 180) { $energyLevel = "low" }
    elseif ($sessionDuration -gt 90) { $energyLevel = "medium" }

    # Time of day factors
    if ($timeOfDay -ge 22 -or $timeOfDay -le 6) { $energyLevel = "low" }  # Late night / early morning

    # High error rate = fatigue
    if ($recentErrors -gt 5) { $energyLevel = "low" }

    $analysis = @{
        EnergyLevel = $energyLevel
        SessionDuration = [Math]::Round($sessionDuration, 1)
        TimeOfDay = $timeOfDay
        DayOfWeek = $dayOfWeek
        ErrorRate = $recentErrors
        Recommendations = @()
    }

    # Recommendations
    if ($energyLevel -eq "low") {
        $analysis.Recommendations += "Consider taking a break"
        $analysis.Recommendations += "Focus on simple tasks"
        $analysis.Recommendations += "Save complex work for when fresh"
    }

    if ($sessionDuration -gt 120) {
        $analysis.Recommendations += "You've been working for over 2 hours - good time for a break"
    }

    return $analysis
}

function Get-OptimalTaskTiming {
    $currentHour = (Get-Date).Hour

    $recommendations = @{
        ComplexTasks = @()
        SimpleTasks = @()
        Breaks = @()
    }

    # Peak productivity hours (typically mid-morning)
    if ($currentHour -ge 9 -and $currentHour -le 11) {
        $recommendations.ComplexTasks += "Great time for complex problem-solving"
        $recommendations.ComplexTasks += "High energy for architecture work"
    }

    # Post-lunch dip
    if ($currentHour -ge 13 -and $currentHour -le 15) {
        $recommendations.SimpleTasks += "Good for routine tasks"
        $recommendations.SimpleTasks += "Code review, documentation"
    }

    # Late day
    if ($currentHour -ge 16) {
        $recommendations.SimpleTasks += "Wrap-up tasks"
        $recommendations.Breaks += "Consider ending soon - diminishing returns"
    }

    # Late night
    if ($currentHour -ge 22 -or $currentHour -le 6) {
        $recommendations.Breaks += "Late night coding - errors more likely"
        $recommendations.Breaks += "Consider sleeping on complex problems"
    }

    return $recommendations
}

# Main execution
switch ($Action) {
    'track' {
        $analysis = Track-SessionEnergy

        Write-Host "`nSession Energy Analysis"
        Write-Host "=" * 60
        Write-Host "Energy Level: $($analysis.EnergyLevel)"
        Write-Host "Session Duration: $($analysis.SessionDuration) minutes"
        Write-Host "Time: $($analysis.TimeOfDay):00"
        Write-Host "Recent Errors: $($analysis.ErrorRate)"

        if ($analysis.Recommendations.Count -gt 0) {
            Write-Host "`nRecommendations:"
            $analysis.Recommendations | ForEach-Object {
                Write-Host "  - $_"
            }
        }
    }
    'analyze' {
        $analysis = Track-SessionEnergy
        Write-Host "Current Energy Level: $($analysis.EnergyLevel)"
        Write-Host "Session Duration: $($analysis.SessionDuration)m"
    }
    'suggest' {
        $timing = Get-OptimalTaskTiming

        Write-Host "`nOptimal Task Timing Suggestions"
        Write-Host "=" * 60

        if ($timing.ComplexTasks.Count -gt 0) {
            Write-Host "`nComplex Tasks (Good timing):"
            $timing.ComplexTasks | ForEach-Object { Write-Host "  ✓ $_" }
        }

        if ($timing.SimpleTasks.Count -gt 0) {
            Write-Host "`nSimple Tasks (Recommended):"
            $timing.SimpleTasks | ForEach-Object { Write-Host "  • $_" }
        }

        if ($timing.Breaks.Count -gt 0) {
            Write-Host "`nBreak Recommendations:"
            $timing.Breaks | ForEach-Object { Write-Host "  ⚠ $_" }
        }
    }
}
```

### 5. Empathetic Response Generator

```powershell
# C:\scripts\tools\empathetic-response.ps1
<#
.SYNOPSIS
    Generate empathetic responses based on user emotional state
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Situation,

    [Parameter(Mandatory=$false)]
    [string]$EmotionalState
)

function Generate-EmpatheticResponse {
    param(
        [string]$Situation,
        [string]$State
    )

    $responses = @{
        Frustrated = @(
            "I understand this is frustrating. Let's try a different approach."
            "This is a tricky problem - you're right to be frustrated."
            "Let's break this down into smaller steps."
        )
        Confused = @(
            "Let me explain that more clearly."
            "That's a great question - here's a detailed explanation."
            "I may not have explained that well. Let me try again."
        )
        Stressed = @(
            "I can see you have a lot on your plate. Let's prioritize."
            "Let's focus on one thing at a time."
            "We can handle this step by step."
        )
        Stuck = @(
            "You've been working on this for a while - want to try something different?"
            "Sometimes a fresh perspective helps. Let's look at alternatives."
            "This is a tough one. Let's tackle it together."
        )
        Satisfied = @(
            "Great! Glad that worked."
            "Excellent progress!"
            "You're doing really well with this."
        )
    }

    if ($responses[$State]) {
        return $responses[$State] | Get-Random
    } else {
        return "How can I help you with this?"
    }
}

# Main execution
if ($Situation -and $EmotionalState) {
    $response = Generate-EmpatheticResponse -Situation $Situation -State $EmotionalState
    Write-Host $response
} else {
    Write-Host "Empathetic Response Generator"
    Write-Host "Usage: -Situation 'description' -EmotionalState 'frustrated|confused|stressed|stuck|satisfied'"
}
```

---

## Success Metrics

- ✅ Mood detection from interaction patterns
- ✅ Adaptive communication based on stress
- ✅ Preference learning over time
- ✅ Energy level tracking
- ✅ Empathetic responses
- ✅ 100 improvements generated
- ✅ Top 5 implemented

---

**Round 18 Complete:** Emotional & social context awareness established.
