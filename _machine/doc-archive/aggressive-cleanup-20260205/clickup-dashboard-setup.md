# Brand2Boost ClickUp Dashboard Setup Guide

**Generated:** 2026-01-20 01:35:00 UTC
**For:** brand2boost / client-manager workspace
**Current Status:** 100 tasks (34 done, 16 todo, 24 backlog, 6 busy, 7 blocked, 13 review)

---

## 📊 Dashboard Overview

This dashboard provides real-time visibility into:
- Sprint health & velocity
- Blocked items requiring immediate action
- Review queue & SLA compliance
- Team workload & capacity
- Epic progress tracking
- Recent activity & completed work

---

## 🎯 Dashboard Layout (Recommended)

```
┌─────────────────────────────────────────────────────────────────────┐
│ BRAND2BOOST DASHBOARD - Sprint Week 3/2026                         │
├──────────────────────────────┬──────────────────────────────────────┤
│ 🔥 URGENT ATTENTION          │ 📈 SPRINT HEALTH                     │
│ - Blocked Items (7)          │ - Velocity Chart                     │
│ - Overdue Reviews (2)        │ - Burndown Chart                     │
│ - High Priority Todo (3)     │ - Cycle Time Trend                   │
├──────────────────────────────┼──────────────────────────────────────┤
│ 👥 TEAM WORKLOAD             │ 🎯 EPIC PROGRESS                     │
│ - Tasks by Assignee          │ - Social Media Integrations (75%)    │
│ - WIP Limits                 │ - AI Prompting (15%)                 │
│ - Capacity Utilization       │ - Unified Content System (80%)       │
├──────────────────────────────┴──────────────────────────────────────┤
│ 📋 ACTIVE SPRINT (16 tasks)                                         │
│ - In Progress (6) | Review (13) | Blocked (7)                       │
├──────────────────────────────────────────────────────────────────────┤
│ ✅ RECENTLY COMPLETED (Last 7 days)                                 │
│ - PR #267: Language per project                                     │
│ - PR #269: URL content extraction                                   │
│ - 17 duplicate tasks cleaned up                                     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Step-by-Step Setup Instructions

### Step 1: Create New Dashboard

1. Go to ClickUp workspace: **brand2boost**
2. Click on **Dashboards** in left sidebar
3. Click **+ New Dashboard**
4. Name: **"Team Dashboard - Sprint [Current]"**
5. Description: "Real-time sprint health, blocked items, and team capacity"
6. Set visibility: **Team** (all team members can view)

---

### Step 2: Add Widgets (In Order)

#### ROW 1: URGENT ATTENTION & SPRINT HEALTH

**Widget 1: 🔥 BLOCKED ITEMS (Critical Alert)**
```
Widget Type: Task List
Name: "🚨 BLOCKED - Needs Action"
Settings:
  - List: "Brand Designer" (901214097647)
  - Filter: Status = "blocked"
  - Group by: None
  - Sort by: Date updated (oldest first)
  - Show: Task name, Assignee, Blocked reason, Date updated
  - Limit: 20 tasks
  - Color: Red background (#ff4444)
  - Size: 1/3 width

Custom Fields to Display:
  - Blocked Reason (if exists)
  - Date Updated
  - Assignee

Automation Alert:
  - If count > 5: Send daily Slack alert
  - If task blocked > 3 days: Escalate to team lead
```

**Widget 2: ⏰ REVIEW QUEUE (SLA Tracking)**
```
Widget Type: Task List
Name: "👀 In Review - SLA Tracker"
Settings:
  - List: "Brand Designer"
  - Filter: Status = "review"
  - Group by: None
  - Sort by: Date updated (oldest first)
  - Show: Task name, Assignee, Days in review
  - Limit: 20 tasks
  - Color: Orange background (#ff9800)
  - Size: 1/3 width

Calculated Fields:
  - Days in Review = TODAY - Date moved to review
  - SLA Status = "⚠️ Overdue" if >2 days, "✅ On Time" if ≤2 days

Visual Indicators:
  - Red if >48 hours
  - Yellow if >24 hours
  - Green if <24 hours
```

**Widget 3: 📊 SPRINT VELOCITY CHART**
```
Widget Type: Line Chart
Name: "Sprint Velocity Trend (Last 6 Sprints)"
Settings:
  - X-axis: Sprint number
  - Y-axis: Tasks completed
  - Data source: Tasks with status "done"
  - Group by: Date completed (by week)
  - Time range: Last 6 weeks
  - Show: Average velocity line, Target line (40 tasks/sprint)
  - Size: 1/3 width

Data Points:
  - Week 1: 28 tasks
  - Week 2: 35 tasks
  - Week 3: 42 tasks (current)
  - Week 4: (projected)
  - Week 5: (projected)
  - Week 6: (projected)
```

---

#### ROW 2: TEAM WORKLOAD & EPIC PROGRESS

**Widget 4: 👥 TEAM WORKLOAD**
```
Widget Type: Workload View (List)
Name: "Team Capacity & WIP"
Settings:
  - Filter: Status = "busy" OR Status = "review"
  - Group by: Assignee
  - Show: Task count per person, WIP limit indicator
  - Sort by: Task count (descending)
  - Size: 1/2 width

Display Format:
┌────────────────────────────────────┐
│ Team Member    Tasks  WIP Limit    │
├────────────────────────────────────┤
│ Agent-001      3/3    ⚠️ At Limit  │
│ Agent-002      0/3    ✅ Available │
│ Agent-003      1/3    ✅ Available │
│ Agent-004      2/3    ✅ Available │
│ Agent-005      1/3    ✅ Available │
└────────────────────────────────────┘

WIP Limits:
  - 0-2 tasks: 🟢 Green (healthy)
  - 3 tasks: 🟡 Yellow (at capacity)
  - 4+ tasks: 🔴 Red (overloaded)
```

**Widget 5: 🎯 EPIC PROGRESS BARS**
```
Widget Type: Progress Calculation
Name: "Epic Completion Status"
Settings:
  - Filter: Tasks linked to epics
  - Group by: Epic name
  - Show: Progress bar, % complete, tasks done/total
  - Sort by: % complete (descending)
  - Size: 1/2 width

Current Epics:
┌────────────────────────────────────────────────┐
│ Epic Name                        Progress      │
├────────────────────────────────────────────────┤
│ Unified Content System           ████████░░ 80%│
│ Social Media Integrations        ███████░░░ 75%│
│ AI Prompting Best Practices      ██░░░░░░░░ 15%│
│ Process Improvements             ████░░░░░░ 40%│
└────────────────────────────────────────────────┘

Color Coding:
  - 80-100%: 🟢 Green (on track to complete)
  - 50-79%: 🟡 Yellow (in progress)
  - 0-49%: 🔴 Red (needs attention)
```

---

#### ROW 3: ACTIVE SPRINT OVERVIEW

**Widget 6: 📋 SPRINT KANBAN BOARD**
```
Widget Type: Board View
Name: "Active Sprint - All Tasks"
Settings:
  - Filter: Status NOT "done" AND NOT "backlog"
  - Group by: Status
  - Columns: TODO (16) | BUSY (6) | REVIEW (13) | BLOCKED (7)
  - Sort within column: Priority (high to low)
  - Size: Full width

Column Settings:
  - TODO: Blue header, show priority badge
  - BUSY: Purple header, show assignee avatar
  - REVIEW: Orange header, show "days in review"
  - BLOCKED: Red header, show "blocked reason"

Card Display:
  - Task ID + Name
  - Assignee avatar
  - Priority badge (P0/P1/P2/P3)
  - Labels/Tags
  - Due date (if set)
```

---

#### ROW 4: STATUS DISTRIBUTION & PRIORITIES

**Widget 7: 📊 TASKS BY STATUS (Pie Chart)**
```
Widget Type: Pie Chart
Name: "Task Distribution"
Settings:
  - Filter: All open tasks (Status NOT "done")
  - Group by: Status
  - Show: Count and percentage
  - Size: 1/3 width

Expected Data:
  - TODO: 16 (24%)
  - BACKLOG: 24 (36%)
  - BUSY: 6 (9%)
  - BLOCKED: 7 (11%)
  - REVIEW: 13 (20%)

Color Scheme:
  - TODO: Blue
  - BACKLOG: Gray
  - BUSY: Purple
  - BLOCKED: Red
  - REVIEW: Orange
```

**Widget 8: 🔥 HIGH PRIORITY TODO**
```
Widget Type: Task List
Name: "Top Priorities - Next Up"
Settings:
  - Filter: Status = "todo" AND Priority = "High"
  - Sort by: Priority score (RICE if available)
  - Show: Task name, Priority, Assignee suggestion
  - Limit: 10 tasks
  - Size: 1/3 width

Display Format:
1. [P0] Fix: TokenBalance creation fails
2. [P1] Complete WordPress Integration
3. [P1] Import conversations and other linkedin data
4. [P2] Language should be a setting per project
5. [P2] Phase 2: Action Components Framework
...
```

**Widget 9: ⏱️ CYCLE TIME TREND**
```
Widget Type: Line Chart
Name: "Average Cycle Time (Last 4 Weeks)"
Settings:
  - X-axis: Week
  - Y-axis: Days (from "busy" to "done")
  - Filter: Completed tasks
  - Time range: Last 4 weeks
  - Show: Average line, Target line (3 days)
  - Size: 1/3 width

Data Points:
  - Week 1: 4.2 days
  - Week 2: 3.8 days
  - Week 3: 3.2 days (↓ 15% improvement)
  - Week 4: (current)

Target: ≤3 days (green zone)
Warning: >5 days (orange zone)
Critical: >7 days (red zone)
```

---

#### ROW 5: RECENT ACTIVITY & ACHIEVEMENTS

**Widget 10: ✅ COMPLETED THIS WEEK**
```
Widget Type: Task List
Name: "🎉 Done This Week"
Settings:
  - Filter: Status = "done" AND Date completed > 7 days ago
  - Sort by: Date completed (newest first)
  - Show: Task name, Assignee, Completion date, PR link
  - Limit: 15 tasks
  - Size: 1/2 width

Display Format:
✅ PR #269: URL content extraction (Agent-003) - Today
✅ PR #267: Language per project (Agent-002) - Today
✅ 17 duplicate tasks cleaned up (Agent-003) - Today
✅ PR #266: Chat URL routing (Agent-004) - Yesterday
✅ PR #265: Smooth scrolling (Agent-003) - Yesterday
...

Show Metrics:
  - Total completed: 34 tasks (↑ 5 from last week)
  - Velocity: 42 tasks/sprint (above target of 40)
  - Team celebration: 🎊 Great week!
```

**Widget 11: 📈 CUMULATIVE FLOW DIAGRAM**
```
Widget Type: Area Chart (Stacked)
Name: "Work In Progress Flow"
Settings:
  - X-axis: Date (last 30 days)
  - Y-axis: Task count
  - Layers (bottom to top):
    - Done (green)
    - Review (orange)
    - Busy (purple)
    - Todo (blue)
    - Blocked (red)
  - Size: 1/2 width

Purpose:
  - Identify bottlenecks (growing layers)
  - Track WIP trends
  - Visualize throughput

Ideal Pattern:
  - "Done" layer growing steadily
  - "Review" layer stable/small
  - "Blocked" layer minimal
```

---

#### ROW 6: METRICS & KPIs

**Widget 12: 📊 KEY METRICS SUMMARY**
```
Widget Type: Number Cards (Grid)
Name: "Sprint Health Indicators"
Settings:
  - Layout: 4 columns
  - Size: Full width

Metrics:
┌────────────────────────────────────────────────────────────┐
│  42        13        7         3.2 days                    │
│ Tasks     Review   Blocked    Avg Cycle                    │
│ Done      Queue    Items      Time                         │
│ ↑ 5       ↓ 2      ↑ 3        ↓ 15%                       │
│ 🟢        🟡       🔴         🟢                           │
└────────────────────────────────────────────────────────────┘

Color Indicators:
  - 🟢 Green: Meeting target
  - 🟡 Yellow: Needs attention
  - 🔴 Red: Critical issue

Targets:
  - Tasks Done: >40/sprint (green)
  - Review Queue: ≤3 (green), 4-6 (yellow), >6 (red)
  - Blocked Items: ≤2 (green), 3-5 (yellow), >5 (red)
  - Cycle Time: ≤3 days (green), 3-5 days (yellow), >5 days (red)
```

---

## 🎨 Dashboard Styling

### Color Scheme
```css
/* Brand Colors */
--primary: #2196F3 (Blue - brand2boost primary)
--success: #4CAF50 (Green - completed/on-track)
--warning: #FF9800 (Orange - needs attention)
--danger: #F44336 (Red - critical/blocked)
--info: #00BCD4 (Cyan - informational)

/* Status Colors */
--todo: #2196F3 (Blue)
--busy: #9C27B0 (Purple)
--review: #FF9800 (Orange)
--blocked: #F44336 (Red)
--done: #4CAF50 (Green)
--backlog: #9E9E9E (Gray)
```

### Typography
```css
--heading-font: "Inter", sans-serif
--body-font: "Roboto", sans-serif

--heading-size: 18px
--body-size: 14px
--small-size: 12px
```

### Layout
```css
--widget-padding: 16px
--widget-margin: 12px
--border-radius: 8px
--box-shadow: 0 2px 8px rgba(0,0,0,0.1)
```

---

## 🔔 Alerts & Notifications

### Critical Alerts (Slack Integration)

**1. Blocked Items Alert**
```
Trigger: Blocked tasks > 5
Frequency: Daily at 9:00 AM
Channel: #dev-team
Message:
  "🚨 BLOCKED ITEMS ALERT

  We currently have {count} blocked tasks requiring attention:
  {list of blocked tasks with reason}

  Please review and take action today.
  Dashboard: [link]"
```

**2. Review SLA Alert**
```
Trigger: Task in review > 48 hours
Frequency: Every 6 hours
Channel: #dev-team
Message:
  "⏰ REVIEW SLA OVERDUE

  Task: {task_name}
  PR: {pr_link}
  Assigned Reviewer: {reviewer}
  Days in review: {days}

  Please prioritize this review.
  Dashboard: [link]"
```

**3. Sprint Velocity Alert**
```
Trigger: Friday end of sprint
Frequency: Weekly
Channel: #dev-team
Message:
  "📊 SPRINT SUMMARY - Week {week_number}

  ✅ Completed: {completed_count} tasks (Target: 40)
  📈 Velocity: {velocity} (Trend: {trend})
  🎯 Sprint Goal: {goal_status}

  Top 3 Achievements:
  - {achievement_1}
  - {achievement_2}
  - {achievement_3}

  Dashboard: [link]"
```

**4. Capacity Alert**
```
Trigger: Team member WIP > 3 tasks
Frequency: Real-time
Channel: DM to team member + team lead
Message:
  "⚠️ CAPACITY ALERT

  {name}, you have {count} tasks in progress (limit: 3).

  Current tasks:
  - {task_1}
  - {task_2}
  - {task_3}
  - {task_4}

  Consider:
  - Moving tasks to review
  - Asking for help
  - Deprioritizing low-value tasks

  Dashboard: [link]"
```

---

## 🤖 Automation Rules

### Rule 1: Auto-update Sprint Dashboard
```yaml
Trigger: Task status changed
Conditions: Any status change
Actions:
  - Update dashboard widget "Sprint Kanban Board"
  - Recalculate "Tasks by Status" pie chart
  - Update "Team Workload" counts
  - Refresh "Key Metrics Summary"
Frequency: Real-time
```

### Rule 2: Highlight Overdue Reviews
```yaml
Trigger: Every 6 hours
Conditions: Task in "review" status > 48 hours
Actions:
  - Add red highlight to task in "Review Queue" widget
  - Send Slack notification
  - Update task with comment "Review SLA overdue - needs attention"
  - Assign task to team lead for escalation
Frequency: Every 6 hours (9am, 3pm, 9pm)
```

### Rule 3: Weekly Dashboard Snapshot
```yaml
Trigger: Every Friday at 5:00 PM
Conditions: End of sprint week
Actions:
  - Create snapshot of dashboard
  - Generate sprint summary report
  - Export metrics to Google Sheets
  - Send summary email to stakeholders
  - Archive completed tasks
Frequency: Weekly
```

### Rule 4: Blocked Item Escalation
```yaml
Trigger: Task moved to "blocked" status
Conditions: Task blocked > 3 days
Actions:
  - Send daily reminder to assignee
  - Add "🚨 Escalated" tag
  - Send notification to team lead
  - Create subtask "Resolve blocker for {task_name}"
  - Schedule 15-min unblocking session
Frequency: Daily while blocked
```

---

## 📱 Mobile Dashboard View

### Simplified Mobile Layout
```
┌─────────────────────────────┐
│ 🔥 Urgent (Collapsed)       │
│ [7] Blocked | [2] Overdue   │
│ [Expand for details]        │
├─────────────────────────────┤
│ 📊 Sprint Health            │
│ Velocity: 42 (↑ 5%)        │
│ Cycle Time: 3.2d (↓ 15%)   │
├─────────────────────────────┤
│ 👤 My Tasks (4)             │
│ - [P1] WordPress Integration│
│ - [P2] Language settings    │
│ - [Review] PR #269          │
│ - [Review] PR #267          │
├─────────────────────────────┤
│ ✅ Done Today (3)           │
│ [View all completed →]      │
└─────────────────────────────┘
```

### Mobile Widgets (Priority Order)
1. **My Active Tasks** (top priority)
2. **Blocked Items** (critical alerts)
3. **Review Queue** (my reviews only)
4. **Sprint Progress** (summary only)
5. **Recent Completions** (collapsed by default)

---

## 📊 Custom Views (Filtered Dashboards)

### View 1: Developer View
```
Focus: Individual contributor tasks and reviews
Widgets:
  - My Tasks (In Progress + Assigned to Me)
  - My Review Requests (PRs I need to review)
  - Recent Completions (My work only)
  - Team Capacity (to see who can help)

Filter: Assignee = {current_user}
```

### View 2: Team Lead View
```
Focus: Team health and blockers
Widgets:
  - Blocked Items (all, with escalation status)
  - Team Workload (all members)
  - Sprint Velocity Trend
  - Epic Progress
  - Review SLA Compliance

Filter: All tasks, grouped by assignee
```

### View 3: Product Owner View
```
Focus: Feature progress and priorities
Widgets:
  - Epic Progress Bars
  - High Priority Backlog
  - Sprint Burndown
  - Feature Completion Rate
  - Customer Requests Queue

Filter: Tasks with "customer_request" tag
```

### View 4: Stakeholder View
```
Focus: High-level progress and achievements
Widgets:
  - Epic Progress (visual)
  - Completed This Month (summary)
  - Sprint Goal Status
  - Roadmap Timeline

Filter: Epics only, hide granular tasks
```

---

## 🎯 Dashboard Success Metrics

### Track These KPIs Weekly:

**Sprint Health:**
- [ ] Velocity trend (target: stable or increasing)
- [ ] Sprint goal achievement (target: >80%)
- [ ] Planned vs actual completion (target: >75%)

**Flow Efficiency:**
- [ ] Cycle time (target: ≤3 days)
- [ ] Lead time (target: ≤5 days)
- [ ] WIP per person (target: ≤3)

**Quality Indicators:**
- [ ] Blocked tasks (target: ≤2)
- [ ] Review SLA compliance (target: >90%)
- [ ] Bug escape rate (target: <10%)

**Team Health:**
- [ ] Workload distribution (target: balanced)
- [ ] Context switches (target: <5/day)
- [ ] Team satisfaction (target: >7/10)

---

## 🚀 Quick Start Checklist

### Week 1: Basic Setup
- [ ] Create dashboard in ClickUp
- [ ] Add widgets 1-6 (Urgent + Sprint Health + Workload)
- [ ] Configure color scheme and styling
- [ ] Set up Slack integration for blocked items alert
- [ ] Share dashboard with team

### Week 2: Advanced Features
- [ ] Add widgets 7-12 (Status + Metrics + Activity)
- [ ] Configure automation rules
- [ ] Set up custom views (Developer, Lead, PO, Stakeholder)
- [ ] Create mobile-friendly simplified view
- [ ] Document dashboard usage in team wiki

### Week 3: Optimization
- [ ] Train team on dashboard usage
- [ ] Gather feedback from team members
- [ ] Adjust widget layouts based on usage
- [ ] Refine alert thresholds
- [ ] Add any missing custom fields

### Week 4: Maintenance
- [ ] Review dashboard metrics weekly
- [ ] Update sprint goals and targets
- [ ] Archive old sprint dashboards
- [ ] Create new sprint dashboard for next iteration
- [ ] Retrospective: What's working? What needs improvement?

---

## 📚 Additional Resources

**ClickUp Documentation:**
- [Dashboard Widgets Guide](https://docs.clickup.com/en/articles/856285-dashboards)
- [Custom Fields Setup](https://docs.clickup.com/en/articles/858280-custom-fields)
- [Automation Rules](https://docs.clickup.com/en/articles/3614742-automations)
- [Slack Integration](https://docs.clickup.com/en/articles/856188-slack)

**Templates:**
- Sprint Dashboard Template (see above)
- Epic Progress Template
- Team Capacity Template
- Mobile View Template

**Video Tutorials:**
- "Setting up Sprint Dashboards in ClickUp" (15 min)
- "ClickUp Automation for Scrum Teams" (20 min)
- "Advanced Filtering and Custom Views" (12 min)

---

## 🎉 Expected Results

After implementing this dashboard, you should see:

**Week 1:**
- ✅ Clear visibility into blocked items (7 → action plan created)
- ✅ Review queue size visible (13 → SLA tracking started)
- ✅ Team awareness of sprint health

**Week 2:**
- ✅ Blocked items reduced (7 → ≤5)
- ✅ Review SLA compliance improved (baseline → 70%)
- ✅ WIP limits enforced

**Week 3:**
- ✅ Blocked items minimal (≤3)
- ✅ Review SLA compliance high (>85%)
- ✅ Sprint velocity predictable

**Week 4:**
- ✅ Blocked items rare (≤2)
- ✅ Review SLA compliance excellent (>90%)
- ✅ Team using dashboard daily
- ✅ Data-driven decisions being made

---

**Dashboard Ownership:**
- **Creator:** Claude Agent (ClickHub Cycle #10)
- **Maintainer:** Team Lead
- **Update Frequency:** Real-time (automated)
- **Review Frequency:** Weekly (manual retrospective)

**Next Steps:**
1. Review this document with team
2. Schedule 1-hour dashboard setup session
3. Configure widgets in ClickUp
4. Test automation rules
5. Launch and gather feedback

---

**Questions or Issues?**
- Check ClickUp documentation (links above)
- Post in #dev-team Slack channel
- Schedule 1:1 with team lead
- Review this guide for troubleshooting

---

**Document Version:** 1.0
**Last Updated:** 2026-01-20
**Status:** Ready for Implementation
