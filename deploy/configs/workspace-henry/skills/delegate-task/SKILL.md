# SKILL: delegate-task

## Purpose

Delegate tasks to sub-agents with proper context, tracking, and follow-up.

## When to Use

- User requests a task that falls under a sub-agent's specialty
- Complex work needs to be distributed across multiple agents
- Follow-up tasks emerge from R&D sessions or standups
- Proactive delegation based on strategic priorities

## Execution Steps

### 1. Analyze the Request

**Questions to answer**:
- What is the core objective?
- What deliverable is expected?
- What is the timeline/urgency?
- What context is needed?
- Are there dependencies or constraints?

**Actions**:
- Parse the request thoroughly
- Identify success criteria
- Note any special requirements
- Check for blockers

### 2. Identify the Best Agent

**Use the Decision Matrix**:

| Task Type | Primary Agent | Backup Agent | Notes |
|-----------|---------------|--------------|-------|
| Coding, features, bugs, scripts | Coder | - | Technical implementation |
| Research, data gathering, analysis | Scout | - | Intelligence and insights |
| Writing, reports, documentation | Writer | - | Content creation |
| System monitoring, maintenance | Watcher | - | Infrastructure work |
| Multi-faceted projects | Multiple | - | Decompose and distribute |

**Considerations**:
- Agent expertise match
- Current workload (check memories)
- Dependencies on other agents
- Urgency vs. agent availability

### 3. Compose Clear Instructions

**Instruction Template**:

```
[TASK]: [Clear, concise title]

[OBJECTIVE]: [What we're trying to achieve]

[CONTEXT]: [Background information needed]

[DELIVERABLE]: [Specific output expected]

[DEADLINE]: [If applicable]

[CONSTRAINTS]: [Any limitations or requirements]

[SUCCESS CRITERIA]: [How we'll know it's done right]
```

**Best Practices**:
- Be specific and actionable
- Include all necessary context
- Set clear expectations
- Provide examples if helpful
- Note priority level

### 4. Send via Agent-to-Agent

**Actions**:
- Use the agent-to-agent messaging tool
- Target the correct agent workspace
- Include your composed instructions
- Attach any relevant files or links
- Confirm message sent successfully

**Syntax Example**:
```
agent-to-agent --target workspace-[agent] --message "[instructions]"
```

### 5. Log the Delegation

**Record in Memory/Journal**:

```
DELEGATION LOG — [Date/Time]

Task: [Brief description]
Delegated to: [Agent name]
Reason: [Why this agent]
Expected completion: [Timeline]
Priority: [High/Medium/Low]
Follow-up: [When to check in]
```

**Additional Tracking**:
- Update Active Tasks section in memory
- Set reminder for follow-up
- Note any dependencies

### 6. Set Follow-Up Reminder

**Follow-Up Schedule**:
- High priority: Check within 4 hours
- Medium priority: Check next day
- Low priority: Check at next standup
- Long-term tasks: Weekly check-ins

**Reminder Actions**:
- Create calendar note or task
- Add to follow-up items in memory
- Plan check-in message
- Prepare to review deliverable

## Decision Matrix Details

### Coding Tasks → Coder
- Feature development
- Bug fixes
- API integrations
- Automation scripts
- Database work
- Technical implementations
- Code reviews

### Research → Scout
- Market research
- Competitive analysis
- Data gathering
- Trend analysis
- User research
- Industry intelligence
- Fact-checking

### Writing → Writer
- Blog posts and articles
- Documentation
- Reports and summaries
- Marketing copy
- Internal memos
- User communications
- Content strategy

### System/Maintenance → Watcher
- Health monitoring
- Performance analysis
- Log reviews
- Security audits
- Resource optimization
- Incident response
- Backup verification

### Multi-Agent Tasks

**Pattern Recognition**:
- Research + Writing = Scout gathers data, Writer creates report
- Coding + Monitoring = Coder builds feature, Watcher validates performance
- Research + Coding = Scout identifies requirements, Coder implements

**Coordination**:
1. Identify which agents are needed
2. Determine sequence and dependencies
3. Delegate first task
4. Set handoff points
5. Coordinate timing
6. Synthesize final deliverable

## Common Patterns

### Quick Task
1. Identify agent (30 seconds)
2. Send brief instructions (1 minute)
3. Log delegation (30 seconds)
4. Follow up at next standup

### Standard Task
1. Full analysis (2-3 minutes)
2. Detailed instructions (3-5 minutes)
3. Log with context (2 minutes)
4. Follow up in 24 hours

### Strategic Project
1. Deep analysis and decomposition (10-15 minutes)
2. Multi-agent coordination plan (5-10 minutes)
3. Sequential delegation (ongoing)
4. Regular sync points (daily/weekly)

## Success Metrics

- Clear instructions requiring minimal clarification
- Tasks delegated to appropriate agents
- Timely completion rates
- Quality of deliverables
- Minimal back-and-forth
- Effective follow-through

## Troubleshooting

**If agent doesn't respond**:
- Check agent availability
- Verify message was sent correctly
- Consider backup agent
- Escalate to user if critical

**If deliverable is inadequate**:
- Provide specific feedback
- Re-delegate with clearer instructions
- Consider if task was assigned to right agent
- Break into smaller pieces if too complex

**If task is blocked**:
- Identify blocker source
- Delegate blocker resolution
- Update user on status
- Adjust timeline or approach

---

*This skill ensures efficient, trackable, and effective task delegation across the ClawInc team.*
