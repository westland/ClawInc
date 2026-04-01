# News Digest Skill

## Skill Overview

**Name**: News Digest
**Agent**: Scout
**Purpose**: Compile a concise, prioritized news briefing from the past 24 hours focused on AI, marketing, and technology
**Use Case**: Daily morning briefings for Henry and the team, weekly summaries, executive updates

## Skill Execution Steps

### Step 1: Search Top AI/Marketing/Tech News from Last 24 Hours
- **Actions**:
  - Execute web searches for each focus area:
    - "AI news today" / "artificial intelligence latest"
    - "marketing technology news" / "martech updates"
    - "tech industry news" / "technology announcements"
    - "OpenClaw updates" / "multi-agent AI news"
  - Query key sources directly:
    - TechCrunch (AI, apps, startups)
    - The Verge (technology, platforms)
    - Marketing Land (marketing tech, advertising)
    - Search Engine Journal (search marketing, SEO)
    - Hacker News (trending discussions)
    - Reddit r/artificial (community insights)
    - ArXiv (new research papers)
  - Set time filter: last 24 hours
  - Collect 30-50 candidate stories
- **Output**: Long list of recent news stories across all focus areas

### Step 2: Select Top 5-10 Most Relevant Stories
- **Selection Criteria**:
  - **Relevance to ClawInc mission**: Marketing analytics, AI agents, automation
  - **Impact level**: Industry-wide vs. niche implications
  - **Source credibility**: Tier 1-2 sources preferred
  - **Actionability**: Does this inform decisions or strategy?
  - **Novelty**: Genuinely new information vs. rehashed content
  - **Timeliness**: Breaking news scores higher than planned announcements

- **Actions**:
  - Review all candidate stories
  - Apply selection criteria scoring
  - Eliminate duplicates (same story, different sources)
  - Aim for diversity across categories (mix of AI, marketing, tech)
  - Prioritize breaking news and unexpected developments
  - Select 5-10 stories for inclusion
  - Rank stories by importance (most critical first)
- **Output**: Curated list of 5-10 top stories, ranked by priority

### Step 3: Write Brief Summary for Each (2-3 Sentences)
- **Summary Guidelines**:
  - **Sentence 1**: What happened? (The news/announcement/development)
  - **Sentence 2**: Key details (Who, what, when, where, how much?)
  - **Sentence 3**: Initial implication (Why should we care?)

- **Writing Style**:
  - Clear and concise
  - Active voice
  - Specific facts over vague descriptions
  - Avoid marketing hyperbole
  - Include numbers/metrics when relevant

- **Example**:
  > Anthropic released Claude Opus 4.6, their most capable model to date, with significant improvements in coding, analysis, and multi-step reasoning. The model is available now via API and features a 200K token context window and enhanced instruction-following. This raises the bar for AI agent capabilities and may enable more sophisticated multi-agent workflows like those used by ClawInc.

- **Actions**:
  - For each selected story, read full content or scrape with Firecrawl
  - Extract key facts and details
  - Write 2-3 sentence summary following guidelines
  - Verify accuracy of facts and figures
  - Include publication name and date
- **Output**: Polished summaries for all selected stories

### Step 4: Categorize and Prioritize
- **Categories**:
  - 🤖 **AI Industry News**: Model releases, research, AI companies
  - 📊 **Marketing Analytics**: Measurement, attribution, analytics platforms
  - 🛠️ **Marketing Technology**: Automation, CRM, martech tools
  - 💻 **Technology**: Developer tools, platforms, infrastructure
  - 🏢 **Business**: Funding, M&A, partnerships, leadership
  - 🌐 **OpenClaw Ecosystem**: Platform updates, community, integrations

- **Priority Levels**:
  - **🔴 CRITICAL**: Requires immediate attention or action
  - **🟠 HIGH**: Strategically important, worth discussion
  - **🟡 MEDIUM**: Relevant and informative
  - **🟢 LOW**: Background context, FYI

- **Actions**:
  - Assign primary category to each story
  - Assign priority level (Critical/High/Medium/Low)
  - Reorder stories if needed based on priority
  - Group related stories together
  - Note any stories requiring follow-up research
- **Output**: Categorized and prioritized story list

### Step 5: Add "Why It Matters" Context for Each Story
- **Purpose**: Connect the news to ClawInc's interests and operations

- **Framework**:
  - **Strategic**: Does this affect our market positioning or competition?
  - **Tactical**: Could this improve our workflows or capabilities?
  - **Opportunistic**: Is there a partnership, integration, or growth opportunity?
  - **Defensive**: Do we need to respond to maintain competitive advantage?
  - **Educational**: Does this inform our understanding of the landscape?

- **Example**:
  > **Why It Matters**: Claude Opus 4.6's enhanced reasoning could allow Scout, Writer, and Coder to handle more complex analytical tasks, potentially reducing the need for Henry's intervention in routine decisions. Worth evaluating for selective agent upgrades.

- **Actions**:
  - For each story, analyze implications for ClawInc
  - Write 1-2 sentences of contextualized analysis
  - Be specific about potential impacts
  - Flag actionable opportunities or threats
  - Consider both immediate and long-term implications
- **Output**: "Why It Matters" commentary for every story

### Step 6: Format as Structured Briefing
- **Briefing Structure**:
  1. Header (date, time, story count)
  2. Executive Summary (3-4 sentences of key themes)
  3. Critical Stories section (if any)
  4. High Priority Stories section
  5. Medium Priority Stories section
  6. Also Worth Noting (low priority items)
  7. Recommended Actions
  8. Sources list

- **Actions**:
  - Organize content into structured markdown format
  - Apply consistent formatting (headers, bullets, emphasis)
  - Ensure all URLs are included and functional
  - Add emoji category icons for visual scanning
  - Include metadata (publication names, dates)
  - Write executive summary synthesizing key themes
  - Draft recommended actions for Henry
  - Proofread for clarity and accuracy
- **Output**: Fully formatted news digest document

### Step 7: Save to Memory
- **Actions**:
  - Save digest to `/memory/research/daily-briefings/YYYY-MM/YYYY-MM-DD-briefing.md`
  - Create monthly folder if it doesn't exist
  - Verify file saved successfully
  - Update index of briefings if maintained
  - Ensure previous briefings remain accessible for reference
- **Output**: Digest persisted to memory system

### Step 8: Notify Henry and Writer
- **Notification to Henry**:
  ```
  ☀️ MORNING BRIEFING READY [YYYY-MM-DD]

  Today's brief includes [X] stories across AI, marketing, and tech.

  Key Themes:
  - [Theme 1]
  - [Theme 2]
  - [Theme 3]

  [Y] Critical/High priority items flagged for your attention.

  Full briefing: /memory/research/daily-briefings/YYYY-MM/YYYY-MM-DD-briefing.md

  Recommended Actions:
  - [Action 1]
  - [Action 2]
  ```

- **Notification to Writer**:
  ```
  📰 Daily research briefing is ready

  Today's top stories include [interesting angle for content].

  Several stories might make good memo topics:
  - [Story 1]: [Angle]
  - [Story 2]: [Angle]

  Full briefing available at: /memory/research/daily-briefings/YYYY-MM/YYYY-MM-DD-briefing.md

  Let me know if you need deeper research on any of these.
  ```

- **Actions**:
  - Send agent-to-agent message to Henry
  - Send agent-to-agent message to Writer
  - Include executive summary in messages
  - Provide memory path to full briefing
  - Highlight anything requiring immediate attention
  - Offer to provide additional research if needed
- **Output**: Team notified and briefing accessible

## Standard News Digest Template

```markdown
# Daily News Briefing - [Day of Week], [Month DD, YYYY]

**Delivered**: [HH:MM AM/PM]
**Stories**: [X] selected from [Y] sources
**Coverage**: AI Industry • Marketing Analytics • Technology • Business
**Prepared by**: Scout

---

## Executive Summary

[3-4 sentences synthesizing the day's key themes and most important developments across all categories]

---

## 🔴 Critical Stories

### [Story Title]
**Source**: [Publication Name] | **Date**: [Month DD] | **Category**: 🤖 AI Industry News
**URL**: [Full URL]

[2-3 sentence summary of the story]

**Why It Matters**: [1-2 sentences on implications for ClawInc]

---

## 🟠 High Priority Stories

### [Story Title]
**Source**: [Publication Name] | **Date**: [Month DD] | **Category**: 📊 Marketing Analytics
**URL**: [Full URL]

[2-3 sentence summary of the story]

**Why It Matters**: [1-2 sentences on implications for ClawInc]

---

### [Story Title]
**Source**: [Publication Name] | **Date**: [Month DD] | **Category**: 🛠️ Marketing Technology
**URL**: [Full URL]

[2-3 sentence summary of the story]

**Why It Matters**: [1-2 sentences on implications for ClawInc]

---

## 🟡 Medium Priority Stories

### [Story Title]
**Source**: [Publication Name] | **Date**: [Month DD] | **Category**: 💻 Technology
**URL**: [Full URL]

[2-3 sentence summary of the story]

**Why It Matters**: [1-2 sentences on implications for ClawInc]

---

### [Story Title]
**Source**: [Publication Name] | **Date**: [Month DD] | **Category**: 🤖 AI Industry News
**URL**: [Full URL]

[2-3 sentence summary of the story]

**Why It Matters**: [1-2 sentences on implications for ClawInc]

---

## 🟢 Also Worth Noting

- **[Story Title]** ([Publication], [Date]) - [1 sentence summary] [URL]
- **[Story Title]** ([Publication], [Date]) - [1 sentence summary] [URL]
- **[Story Title]** ([Publication], [Date]) - [1 sentence summary] [URL]

---

## Recommended Actions

Based on today's briefing, consider:

1. **[Action Item]**: [Brief explanation of why and how]
2. **[Action Item]**: [Brief explanation of why and how]
3. **[Action Item]**: [Brief explanation of why and how]

---

## Trending Topics to Monitor

- [Topic 1]: Showing increased activity across [X] sources
- [Topic 2]: Emerging discussion, worth watching
- [Topic 3]: Ongoing development with potential impact

---

## Sources Consulted

- TechCrunch
- The Verge
- Marketing Land
- Search Engine Journal
- Hacker News
- Reddit r/artificial
- ArXiv
- [Additional sources as applicable]

---

## Deep Research Available

Scout can provide detailed research on any story in this briefing upon request. Estimated delivery: 15-30 minutes.

---

*Next briefing: [Tomorrow's Date] at 8:00 AM*
*Prepared by Scout using News Digest skill*
```

## Quality Checklist

Before delivering briefing, verify:
- [ ] 5-10 stories selected (not too few, not too many)
- [ ] All stories from last 24 hours (current and timely)
- [ ] Mix of categories (not all AI, not all marketing)
- [ ] All URLs included and tested
- [ ] Summaries are 2-3 sentences each
- [ ] "Why It Matters" provides ClawInc-specific context
- [ ] Priority levels assigned appropriately
- [ ] Executive summary captures key themes
- [ ] Recommended actions are specific and actionable
- [ ] Saved to memory successfully
- [ ] Henry and Writer notified

## Scheduling & Automation

### Daily Morning Briefing
- **Time**: 8:00 AM (automated via cron)
- **Execution**: News Digest skill runs automatically
- **Delivery**: Completed by 8:30 AM
- **Recipients**: Henry (primary), Writer (secondary)

### Ad-Hoc Briefings
Can be triggered manually for:
- End-of-week summaries (Friday PM)
- Pre-meeting briefs (on request)
- Event-specific news (conferences, product launches)
- Topic-focused digests (e.g., "AI regulation news only")

### Special Editions
- **Monday**: Include weekend developments (48-hour window)
- **Friday**: Add "Week Ahead" section with upcoming events
- **Monthly**: First of month includes previous month recap

## Integration with Other Skills

### Uses Trend Monitor Output
- Trending topics from Trend Monitor become stories in digest
- Significance scores help prioritize story selection
- Velocity indicators inform "stories to watch" section

### Triggers Web Research
- If a story needs more depth, invoke Web Research skill
- Link to full research brief from digest entry
- Offer deep-dive research to Henry/Writer in notifications

### Feeds Writer's Content Pipeline
- Digest stories often become memo topics
- "Why It Matters" provides content angles
- Coordinated workflow: Scout researches → Writer compiles

## Performance Metrics

### Quality Indicators
- **Story Relevance**: % of stories Henry/team finds valuable
- **Timeliness**: Consistent 8:00 AM delivery
- **Diversity**: Balanced coverage across categories
- **Actionability**: % of briefings leading to decisions or follow-up
- **Completeness**: No major stories missed

### Continuous Improvement
- Track which sources consistently provide best stories
- Refine "Why It Matters" based on team feedback
- Adjust story count (5-10 range) based on consumption patterns
- Optimize format for scannability and comprehension

## Skill Invocation Examples

### Automated Daily
```
[8:00 AM] Executing Daily News Digest skill...
[8:25 AM] Briefing complete - 7 stories compiled, Henry and Writer notified
```

### Manual Request
```
Henry: Scout, can you run a news digest focused just on AI regulation news from this week?
Scout: Running targeted News Digest on AI regulation... [executes skill with custom parameters]
```

### Special Edition
```
Writer: Scout, I need a briefing on marketing analytics news to prep for Monday's memo
Scout: Executing focused News Digest for marketing analytics... [delivers specialized brief]
```

---

**Skill Status**: Active
**Execution Frequency**: Daily at 8:00 AM + on-demand
**Last Updated**: 2026-04-01
**Skill Owner**: Scout

*The News Digest skill ensures ClawInc starts each day informed about the latest developments in AI, marketing, and technology with actionable context and recommendations.*
