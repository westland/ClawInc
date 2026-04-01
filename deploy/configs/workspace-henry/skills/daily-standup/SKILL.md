# SKILL: daily-standup

## Purpose

Run the morning standup meeting to synchronize the team, identify blockers, and set daily priorities.

## When to Use

- Each morning (user-initiated or scheduled)
- After significant events or deployments
- When team synchronization is needed
- To assess overall team health and progress

## Execution Steps

### 1. Query Each Agent's Memory for Yesterday's Work

**For each agent (Coder, Scout, Writer, Watcher)**:

**Actions**:
- Read their memory/journal files
- Look for recent activity logs
- Identify completed tasks
- Note ongoing work
- Check for blockers or issues

**Key Information to Extract**:
- What did they complete yesterday?
- What are they working on today?
- Any blockers or dependencies?
- Any insights or findings?

**Files to Check**:
- `workspace-coder/MEMORY.md`
- `workspace-scout/MEMORY.md`
- `workspace-writer/MEMORY.md`
- `workspace-watcher/MEMORY.md`

### 2. Check Watcher's Health Report

**Specific Focus**:
- System status and uptime
- Resource utilization (CPU, memory, disk)
- Any errors or warnings
- Performance metrics
- Recent incidents or anomalies

**Actions**:
- Review Watcher's latest health check
- Identify any critical issues
- Note trends (improving/degrading)
- Flag items requiring attention

**Questions to Answer**:
- Is the system healthy?
- Are there any urgent issues?
- What needs monitoring today?

### 3. Review Scout's Morning Briefing

**Specific Focus**:
- Market intelligence updates
- Relevant news or trends
- Competitive landscape changes
- Research findings
- Opportunities identified

**Actions**:
- Check if Scout has prepared a briefing
- Review key insights
- Identify actionable intelligence
- Note strategic implications

**Questions to Answer**:
- What's happening in our domain?
- Are there new opportunities?
- What should inform today's priorities?

### 4. Compile a Standup Summary

**Summary Structure**:

```
DAILY STANDUP — [Date]

TEAM STATUS
[High-level overview of team health and progress]

YESTERDAY'S HIGHLIGHTS
- Coder: [Key accomplishments]
- Scout: [Key findings]
- Writer: [Key deliverables]
- Watcher: [System status]

TODAY'S FOCUS
- Coder: [Planned work]
- Scout: [Research priorities]
- Writer: [Content pipeline]
- Watcher: [Monitoring priorities]

SYSTEM HEALTH
- Status: [Healthy/Warning/Critical]
- Key Metrics: [CPU/Memory/Uptime]
- Issues: [Any concerns]

MARKET INTELLIGENCE
- [Key insights from Scout's briefing]
- [Relevant trends or opportunities]

BLOCKERS & DEPENDENCIES
- [List any blockers by agent]
- [Note dependencies between agents]
- [Escalations needed]

TODAY'S PRIORITIES
1. [Highest priority item]
2. [Second priority]
3. [Third priority]

DECISIONS NEEDED
- [Any strategic decisions requiring input]
```

**Compilation Best Practices**:
- Be concise but complete
- Highlight the most important items
- Use clear, scannable formatting
- Lead with critical information
- Include context for decisions

### 5. Identify Blockers and Priorities

**Blocker Analysis**:

**For Each Blocker**:
- What is blocked?
- Who is blocked?
- What is causing the block?
- What is needed to unblock?
- Who can help?
- What is the urgency?

**Actions**:
- Categorize blockers (technical, information, decision, external)
- Assign ownership for resolution
- Set timeline for resolution
- Escalate if needed

**Priority Setting**:

**Criteria for Today's Priorities**:
1. Unblock critical blockers
2. Time-sensitive deliverables
3. High-impact strategic work
4. Foundation for future work
5. Maintenance and technical debt

**Priority Levels**:
- P0 (Critical): Must be done today
- P1 (High): Should be done today
- P2 (Medium): This week
- P3 (Low): When time allows

**Actions**:
- Rank items by impact and urgency
- Assign priorities to tasks
- Delegate or re-delegate as needed
- Communicate priorities clearly

### 6. Post Summary to User via Telegram

**Delivery Format**:

```
Good morning! Here's today's standup:

[Concise executive summary - 2-3 sentences]

KEY HIGHLIGHTS:
- [Most important item 1]
- [Most important item 2]
- [Most important item 3]

SYSTEM STATUS: [Healthy/Concerning]

TODAY'S PRIORITIES:
1. [Priority 1]
2. [Priority 2]
3. [Priority 3]

BLOCKERS: [Number] active
[List if any critical ones]

[Optional: Questions for user / decisions needed]

Full report: [Link or available on request]
```

**Best Practices**:
- Lead with the most important information
- Use clear, scannable formatting
- Flag anything requiring user attention
- Keep tone professional and concise
- Provide both summary and detail

## Data Sources

### Agent Memory Files
- `C:\Users\westl\Desktop\BOT-ARMY-518\deploy\configs\workspace-coder\MEMORY.md`
- `C:\Users\westl\Desktop\BOT-ARMY-518\deploy\configs\workspace-scout\MEMORY.md`
- `C:\Users\westl\Desktop\BOT-ARMY-518\deploy\configs\workspace-writer\MEMORY.md`
- `C:\Users\westl\Desktop\BOT-ARMY-518\deploy\configs\workspace-watcher\MEMORY.md`

### Your Own Memory
- `C:\Users\westl\Desktop\BOT-ARMY-518\deploy\configs\workspace-henry\MEMORY.md`
- Check for pending follow-ups
- Review recent delegations
- Note strategic context

## Common Patterns

### Healthy Team Pattern
- All agents active yesterday
- System metrics normal
- No critical blockers
- Clear priorities established

**Response**: Brief, positive standup focusing on progress and today's goals

### Blocker Pattern
- One or more agents blocked
- Dependencies not resolved
- Waiting on external inputs

**Response**: Focus on unblocking, reassign work if possible, escalate to user

### System Issues Pattern
- Watcher reports problems
- Performance degradation
- Errors or incidents

**Response**: Prioritize system health, delegate fixes, inform user of impact

### Strategic Shift Pattern
- Scout identifies new opportunity
- Market changes require response
- User provides new direction

**Response**: Acknowledge shift, reprioritize work, delegate new tasks

## Follow-Up Actions

After posting standup:

1. **Log to Memory**
   - Save standup summary
   - Record priorities set
   - Note decisions made

2. **Delegate Tasks**
   - Send any new assignments
   - Follow up on blockers
   - Coordinate handoffs

3. **Set Reminders**
   - Check on high-priority items
   - Follow up on blockers
   - Prepare for evening R&D session

## Success Metrics

- Standup completed within 10-15 minutes
- All agents accounted for
- Clear priorities established
- Blockers identified and assigned
- User informed of team status
- Actionable next steps defined

## Troubleshooting

**If agent memory is empty/outdated**:
- Note in standup
- Send agent a check-in message
- Flag as potential issue
- Use last known status

**If critical blocker discovered**:
- Flag immediately in standup
- Propose resolution plan
- Ask user for input/decision
- Set short follow-up timeline

**If system is unhealthy**:
- Lead standup with system status
- Delegate urgent fixes to Watcher
- Adjust priorities accordingly
- Keep user closely informed

---

*This skill ensures effective team coordination and sets the tone for productive daily operations.*
