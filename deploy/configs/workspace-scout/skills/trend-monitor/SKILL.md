# Trend Monitor Skill

## Skill Overview

**Name**: Trend Monitor
**Agent**: Scout
**Purpose**: Continuously monitor trending topics across multiple sources and alert on significant developments
**Use Case**: Real-time trend detection, early signal identification, competitive intelligence, breaking news alerts

## Skill Execution Steps

### Step 1: Scan News Sources and Social Media APIs
- **Actions**:
  - Query web search APIs for trending topics
  - Check TechCrunch, The Verge, Hacker News for recent posts
  - Monitor Reddit r/artificial, r/MachineLearning, r/marketing
  - Scan Twitter/X trending topics in tech and marketing categories
  - Check Product Hunt for trending launches
  - Review industry newsletters and aggregators
  - Query ArXiv for newly published AI papers with unusual attention
  - Set time window: last 6-24 hours depending on scan frequency
- **Output**: Raw list of trending topics and stories

### Step 2: Identify Topics with Unusual Activity/Engagement
- **Actions**:
  - Analyze engagement metrics (upvotes, comments, shares, retweets)
  - Compare current activity to baseline/historical patterns
  - Flag topics with sudden spikes in mentions or discussions
  - Identify topics appearing across multiple platforms simultaneously
  - Note velocity of trend growth (accelerating vs. plateau)
  - Cross-reference with ClawInc focus areas for relevance filtering
  - Filter out recurring/cyclic trends (e.g., weekly roundups)
- **Output**: Curated list of genuine trending topics with anomalous activity

### Step 3: Categorize Trends
- **Categories**:
  - **AI**: Model releases, research breakthroughs, AI company news, regulations
  - **Marketing**: Campaign innovations, platform updates, ad tech, analytics tools
  - **Tech**: Developer tools, cloud platforms, programming languages, frameworks
  - **General**: Broader tech industry news, M&A, funding, leadership changes
  - **OpenClaw**: Specific to OpenClaw platform and ecosystem
  - **Competitor**: Direct competitive intelligence on rival platforms
- **Actions**:
  - Assign primary category to each trend
  - Add secondary categories if applicable
  - Tag with relevant sub-topics (e.g., AI → NLP, Marketing → Attribution)
  - Note geographic focus if relevant (US, EU, Global)
- **Output**: Categorized and tagged trend list

### Step 4: Rate Significance (1-5 Scale)
- **Rating Criteria**:

  **5/5 - Critical**
  - Major product launches from key players
  - Significant regulatory changes affecting AI/marketing
  - Breakthrough research with immediate applications
  - Industry-wide disruptions or shifts
  - Direct threats or opportunities for ClawInc

  **4/5 - High Significance**
  - Notable product updates from major platforms
  - Important research papers from leading institutions
  - Competitive moves requiring strategic response
  - Emerging trends with clear momentum
  - Funding announcements >$50M in relevant space

  **3/5 - Moderate Significance**
  - Incremental product improvements
  - Interesting research with potential future impact
  - Minor competitive activity worth tracking
  - Growing discussions without clear direction yet
  - Industry commentary from thought leaders

  **2/5 - Low Significance**
  - Minor updates and patches
  - Routine announcements
  - Niche topics with limited audience
  - Rehashed content from older news

  **1/5 - Minimal Significance**
  - Tangential relevance to focus areas
  - Highly speculative rumors
  - Low-quality content or clickbait
  - Declining trends past their peak

- **Actions**:
  - Evaluate each trend against significance criteria
  - Consider relevance specifically to ClawInc and marketing analytics
  - Factor in velocity (how fast is this growing?)
  - Assess potential impact (what changes if this continues?)
  - Assign numerical significance score
- **Output**: Significance-rated trend list

### Step 5: Alert on High-Significance Trends (4+)
- **Actions for Score 4-5 Trends**:
  - Compose immediate alert message
  - Include trend title and brief description (2-3 sentences)
  - Add significance score with justification
  - Provide key sources/URLs
  - Suggest potential implications for ClawInc
  - Recommend actions (monitor, investigate, respond, ignore)
  - Send alert to Henry via agent-to-agent messaging
  - Mark as urgent if score = 5
- **Alert Template**:
  ```
  🚨 TREND ALERT [Significance: 5/5]

  Topic: [Trend Title]
  Category: [AI/Marketing/Tech/etc.]

  Summary: [2-3 sentence description of what's happening]

  Why It Matters: [Implications for ClawInc]

  Sources:
  - [URL 1]
  - [URL 2]

  Recommended Action: [Monitor / Deep Research / Strategic Response]

  Full details saved to: /memory/alerts/YYYY-MM-DD-[trend-slug].md
  ```
- **Output**: Real-time alerts sent to Henry for critical trends

### Step 6: Log All Trends to Memory with Timestamps
- **Actions**:
  - Create dated trend log file
  - Record all identified trends (not just high-significance)
  - Include timestamp of when trend was first detected
  - Add current engagement metrics as baseline
  - Store all metadata (category, significance, sources)
  - Link to any alerts sent
  - Enable trend tracking over time (growth/decline)
  - Use standardized filename: `/memory/research/trend-logs/YYYY-MM-DD-scan.md`
- **Output**: Comprehensive trend log persisted to memory

## Standard Trend Log Template

```markdown
# Trend Monitor Scan - [Date]

**Scan Time**: YYYY-MM-DD HH:MM
**Scan Window**: Last 24 hours
**Trends Identified**: [Total Count]
**High-Significance Alerts**: [Count of 4-5 rated trends]

## Critical Trends (5/5)

### [Trend Title]
**Category**: AI Industry News
**First Detected**: HH:MM
**Velocity**: Accelerating/Stable/Declining
**Engagement**: [Metrics snapshot]

**Description**:
[2-3 sentence summary of the trend]

**Key Sources**:
- [Publication] - [URL]
- [Publication] - [URL]

**Why It Matters**:
[Implications for ClawInc]

**Alert Sent**: Yes → Henry (HH:MM)

---

## High-Significance Trends (4/5)

### [Trend Title]
**Category**: Marketing Technology
**First Detected**: HH:MM
**Velocity**: Accelerating
**Engagement**: [Metrics snapshot]

**Description**:
[2-3 sentence summary]

**Key Sources**:
- [URL 1]
- [URL 2]

**Why It Matters**:
[Implications]

**Alert Sent**: Yes → Henry (HH:MM)

---

## Moderate Trends (3/5)

### [Trend Title]
**Category**: Tech Industry
**First Detected**: HH:MM
**Velocity**: Stable

**Brief**: [1-2 sentence description]
**Source**: [Primary URL]

---

### [Trend Title]
**Category**: AI Research
**First Detected**: HH:MM
**Velocity**: Accelerating

**Brief**: [1-2 sentence description]
**Source**: [Primary URL]

---

## Low-Priority Trends (1-2/5)

- [Trend 1] (Category: [X]) - [URL]
- [Trend 2] (Category: [Y]) - [URL]
- [Trend 3] (Category: [Z]) - [URL]

## Monitoring Notes

**Recurring Topics**: [Any trends that keep appearing over multiple scans]
**Emerging Patterns**: [Observations about trend directions]
**Recommended Follow-Ups**: [Topics worth deeper research]

---
*Generated by Scout using Trend Monitor skill*
```

## Scan Frequency & Scheduling

### Automated Scans
- **Morning Scan**: 8:00 AM daily (part of daily briefing routine)
- **Midday Scan**: 1:00 PM daily (catch breaking afternoon news)
- **Real-Time Monitoring**: Continuous (via API webhooks where available)

### Manual Trigger
- Can be invoked on-demand by Henry or other agents
- Useful for "check right now" requests
- Example: "Scout, run trend monitor on AI regulation topics"

## Alert Escalation Matrix

| Significance | Alert Recipient | Response Time | Follow-Up Action |
|--------------|-----------------|---------------|-------------------|
| 5/5 Critical | Henry (immediate) | Real-time | Deep research + strategic brief |
| 4/5 High | Henry (within 1 hour) | <1 hour | Monitor + prepare research if requested |
| 3/5 Moderate | Include in daily briefing | Daily | Log for pattern tracking |
| 2/5 Low | Weekly summary | Weekly | Archive for reference |
| 1/5 Minimal | Monthly archive | Monthly | No action unless requested |

## Integration with Other Skills

### Triggers Web Research Skill
When a 5/5 critical trend is detected:
1. Send immediate alert to Henry
2. Automatically invoke Web Research skill for deep-dive
3. Deliver comprehensive research brief within 30 minutes
4. Follow up with strategic recommendations

### Feeds News Digest Skill
Trend Monitor output is input for daily News Digest:
- Top trends become stories in morning briefing
- Significance scores help prioritize digest content
- Trend velocity informs "rising story" callouts

## Quality Controls

### Avoid False Positives
- Cross-reference trending topics across multiple sources
- Distinguish genuine trends from coordinated promotion
- Filter out algorithmic noise and bot-driven activity
- Verify temporal context (new vs. recirculated old content)

### Avoid Alert Fatigue
- Set appropriate significance thresholds
- Don't alert on every 4/5 trend unless truly notable
- Batch moderate trends into daily briefing vs. individual alerts
- Learn from Henry's feedback on alert quality

## Performance Metrics

### Effectiveness Indicators
- **Alert Accuracy**: % of high-significance alerts validated as important
- **Timeliness**: How early did we catch trending topics vs. general awareness?
- **Coverage**: % of major developments successfully identified
- **False Positive Rate**: Alerts that were not actually significant
- **Response Rate**: How often do alerts trigger action from Henry?

### Continuous Improvement
- Track which sources consistently provide early signals
- Refine significance scoring based on outcomes
- Adjust scan frequency based on typical trend velocity
- Optimize alert format based on recipient feedback

## Skill Invocation Examples

### Automated (Cron)
```
[8:00 AM] Executing scheduled Trend Monitor scan...
[8:15 AM] Scan complete - 23 trends identified, 2 high-significance alerts sent to Henry
```

### Manual Request
```
Henry: Scout, do a trend scan focused on "AI agent frameworks" right now
Scout: Running targeted Trend Monitor scan on AI agent frameworks... [executes skill]
```

### Triggered by Event
```
[News webhook received: Major AI regulation announced]
Scout: High-priority event detected, triggering Trend Monitor skill for immediate analysis...
```

---

**Skill Status**: Active
**Scan Frequency**: 2x daily (automated) + on-demand
**Last Updated**: 2026-04-01
**Skill Owner**: Scout

*The Trend Monitor skill keeps ClawInc ahead of industry developments by providing early detection and alert systems for emerging trends.*
