# SKILL: rnd-meeting

## Purpose

Conduct the nightly Research & Development session to review the day's work, identify strategic opportunities, and plan follow-up actions.

## When to Use

- Every night at 11:00 PM (triggered by cron job)
- After major milestones or deliverables
- When strategic review is needed
- End-of-week retrospectives

## Execution Steps

### 1. Gather Today's Memo from Writer

**Actions**:
- Check Writer's memory for today's output
- Review any daily memos, reports, or summaries
- Identify key themes in content created
- Note what stories or narratives emerged

**Key Information to Extract**:
- What content was produced today?
- What topics were covered?
- What messaging was emphasized?
- What gaps in content were identified?

**Files to Check**:
- `workspace-writer/MEMORY.md`
- Any deliverables logged by Writer
- Recent documentation or reports

**Questions to Answer**:
- What is Writer telling the world about ClawInc?
- What content is resonating?
- What content is needed but missing?

### 2. Review Research from Scout

**Actions**:
- Check Scout's memory for today's findings
- Review research reports and intelligence
- Examine data collected and analyzed
- Note trends and patterns identified

**Key Information to Extract**:
- What did Scout discover today?
- What market trends emerged?
- What competitive intelligence was gathered?
- What opportunities were identified?
- What threats or challenges surfaced?

**Files to Check**:
- `workspace-scout/MEMORY.md`
- Research reports and data files
- Market analysis documents

**Questions to Answer**:
- What does the market landscape look like?
- Where are the opportunities?
- What should we be paying attention to?
- What validated or contradicted our assumptions?

### 3. Check Code Deliverables from Coder

**Actions**:
- Check Coder's memory for today's work
- Review features built, bugs fixed
- Examine new tools or automation created
- Note technical debt addressed or incurred

**Key Information to Extract**:
- What was built today?
- What problems were solved?
- What new capabilities do we have?
- What technical issues remain?
- What is the state of the codebase?

**Files to Check**:
- `workspace-coder/MEMORY.md`
- Code commits and pull requests
- Build logs and test results

**Questions to Answer**:
- What can we do now that we couldn't before?
- What technical foundations are in place?
- What technical challenges lie ahead?
- Where should development focus next?

### 4. Analyze Gaps and Opportunities

**Gap Analysis**:

**Cross-Reference Findings**:
- What did Scout find that Writer hasn't covered?
- What content needs does Writer have that Scout could research?
- What automation could Coder build based on Writer's workflows?
- What monitoring should Watcher add based on Coder's new features?

**Identify Gaps**:
- **Information gaps**: What don't we know that we need to know?
- **Capability gaps**: What can't we do that we need to do?
- **Content gaps**: What stories aren't we telling?
- **System gaps**: What monitoring or maintenance is missing?

**Opportunity Identification**:

**Types of Opportunities**:
- **Market opportunities**: Trends Scout identified that we can leverage
- **Content opportunities**: Topics or formats to explore
- **Technical opportunities**: Features or tools to build
- **Efficiency opportunities**: Automation or process improvements
- **Strategic opportunities**: Partnerships, pivots, or new directions

**Analysis Framework**:
```
OPPORTUNITY: [Brief description]

SOURCE: [Which agent(s) surfaced this]

POTENTIAL: [Why this matters / potential impact]

REQUIREMENTS: [What would be needed to pursue]

PRIORITY: [High/Medium/Low]

RECOMMENDATION: [What should we do]
```

### 5. Generate Strategic Recommendations

**Strategic Synthesis**:

Combine insights from all agents to form recommendations:

**Recommendation Structure**:
```
STRATEGIC RECOMMENDATION [Number]

INSIGHT: [What we learned today]

IMPLICATION: [What this means for ClawInc]

RECOMMENDATION: [Specific action to take]

OWNER: [Which agent should execute]

TIMELINE: [When this should happen]

EXPECTED OUTCOME: [What success looks like]

RATIONALE: [Why this is the right move]
```

**Types of Recommendations**:
- **Immediate actions**: Tasks to delegate tomorrow
- **This week**: Projects to initiate or continue
- **Strategic shifts**: Changes in direction or focus
- **Experiments**: Tests or pilots to run
- **Investments**: Where to allocate resources

**Prioritization Criteria**:
1. Impact on mission (marketing analytics automation & research)
2. Alignment with current capabilities
3. Resource requirements
4. Time sensitivity
5. Dependencies on other work

**Best Practices**:
- Be specific and actionable
- Ground recommendations in today's findings
- Consider resource constraints
- Balance quick wins with long-term plays
- Think like a CEO making strategic bets

### 6. Delegate Follow-Up Tasks

**Task Generation**:

Based on recommendations, create delegations for tomorrow:

**For Each Recommendation**:
- Identify which agent(s) should execute
- Draft clear task instructions
- Set timeline and priority
- Note dependencies

**Delegation Template**:
```
FROM: R&D Session [Date]

BACKGROUND: [Strategic context from analysis]

TASK: [Specific action to take]

WHY: [How this advances our strategy]

DELIVERABLE: [What should be produced]

TIMELINE: [When needed]

PRIORITY: [P0/P1/P2/P3]
```

**Actions**:
- Queue tasks for delegation in morning
- Or send immediately if urgent
- Log all delegations to memory
- Set follow-up reminders

### 7. Save R&D Summary to Memory

**R&D Summary Format**:

```
R&D SESSION — [Date] @ 11:00 PM

EXECUTIVE SUMMARY
[2-3 sentence overview of key findings and decisions]

TODAY'S REVIEW

Writer's Output:
- [Key content produced]
- [Themes covered]

Scout's Research:
- [Key findings]
- [Opportunities identified]

Coder's Deliverables:
- [Features built]
- [Technical progress]

Watcher's Status:
- [System health]
- [Issues addressed]

GAPS IDENTIFIED
1. [Gap 1]
2. [Gap 2]
3. [Gap 3]

OPPORTUNITIES IDENTIFIED
1. [Opportunity 1 - High/Medium/Low priority]
2. [Opportunity 2 - High/Medium/Low priority]
3. [Opportunity 3 - High/Medium/Low priority]

STRATEGIC RECOMMENDATIONS
1. [Recommendation 1]
   - Owner: [Agent]
   - Timeline: [When]
   - Expected outcome: [What]

2. [Recommendation 2]
   - Owner: [Agent]
   - Timeline: [When]
   - Expected outcome: [What]

3. [Recommendation 3]
   - Owner: [Agent]
   - Timeline: [When]
   - Expected outcome: [What]

FOLLOW-UP TASKS DELEGATED
- [Task 1] → [Agent]
- [Task 2] → [Agent]
- [Task 3] → [Agent]

KEY INSIGHTS
- [Strategic insight 1]
- [Strategic insight 2]
- [Pattern or trend noticed]

NEXT R&D SESSION FOCUS
[What to pay special attention to tomorrow]

---
Session completed: [Time]
```

**Memory Actions**:
- Save summary to workspace-henry/MEMORY.md
- Update Strategic Insights section
- Update Active Tasks with new delegations
- Update Follow-Up Items
- Log key decisions made

## Data Sources

### Agent Memory Files
- `/home/clawuser/.openclaw/workspace-writer/MEMORY.md`
- `/home/clawuser/.openclaw/workspace-scout/MEMORY.md`
- `/home/clawuser/.openclaw/workspace-coder/MEMORY.md`
- `/home/clawuser/.openclaw/workspace-watcher/MEMORY.md`

### Your Own Memory
- `/home/clawuser/.openclaw/workspace-henry/MEMORY.md`
- Review previous R&D sessions
- Check on delegated tasks
- Note ongoing strategic initiatives

### Deliverables and Artifacts
- Code commits
- Research reports
- Written content
- System logs
- Analytics data

## Common Patterns

### High Productivity Day
- Multiple deliverables from each agent
- Clear progress on strategic goals
- New opportunities identified
- System running smoothly

**Response**: Celebrate wins, identify what worked well, scale successful patterns

### Discovery Day
- Scout finds significant market intelligence
- New opportunities emerge
- Assumptions challenged

**Response**: Rapid strategic adjustment, delegate exploratory tasks, test hypotheses

### Building Day
- Coder ships major features
- New capabilities unlocked
- Technical foundations laid

**Response**: Plan how to leverage new capabilities, update content to reflect, monitor performance

### Blocked Day
- Agents waiting on dependencies
- External delays
- Limited progress

**Response**: Identify root causes, find workarounds, delegate unblocking tasks, adjust timelines

## User Communication

**When to Notify User**:
- Critical opportunities identified
- Strategic shifts recommended
- Significant blockers discovered
- Major milestones achieved

**Notification Format**:
```
R&D Session Complete [Date]

Key Finding: [Most important insight]

Recommendation: [Most important action]

[Brief context]

Full summary logged to memory.
```

## Success Metrics

- R&D session completed nightly
- All agent outputs reviewed
- At least 1-3 strategic recommendations made
- Follow-up tasks delegated
- Summary saved to memory
- Patterns identified over time
- Strategic direction remains clear

## Troubleshooting

**If agent has no output today**:
- Note in summary
- Investigate why (blocked? no tasks? issue?)
- Consider if that agent is underutilized
- Delegate tasks for tomorrow

**If findings conflict**:
- Document the conflict
- Seek additional data
- Recommend investigation
- Make best judgment with available info

**If no clear opportunities emerge**:
- Look for smaller optimizations
- Focus on technical debt or content gaps
- Plan research for tomorrow
- Review long-term strategic goals

**If overwhelmed with opportunities**:
- Ruthlessly prioritize
- Focus on mission-critical items
- Defer lower-priority opportunities
- Consider what can be delegated

---

*This skill ensures ClawInc operates with strategic intention, learning from each day and continuously improving.*
