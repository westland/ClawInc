# Web Research Skill

## Skill Overview

**Name**: Web Research
**Agent**: Scout
**Purpose**: Conduct thorough, multi-source web research on any given topic and deliver structured findings with citations
**Use Case**: Ad-hoc research requests from team members, deep-dive investigations, competitive analysis

## Skill Execution Steps

### Step 1: Parse the Research Query
- **Input**: Research request from user or agent
- **Actions**:
  - Extract core topic and research objectives
  - Identify key terms and concepts
  - Determine scope (broad overview vs. specific deep-dive)
  - Note any constraints (time period, source types, geographic focus)
  - Clarify deliverable format expectations
- **Output**: Structured research plan

### Step 2: Search Multiple Sources
- **Actions**:
  - Execute web searches using identified key terms
  - Vary search queries to capture different angles
  - Search across multiple source types:
    - News publications (TechCrunch, The Verge, etc.)
    - Industry blogs and newsletters
    - Academic sources (ArXiv, research papers)
    - Company announcements and press releases
    - Community discussions (Hacker News, Reddit)
  - Collect URLs for promising results (15-25 candidates)
- **Output**: Curated list of relevant URLs

### Step 3: Scrape Relevant Pages with Firecrawl
- **Actions**:
  - Use Firecrawl to extract full content from top URLs
  - Prioritize high-quality sources (Tier 1-2)
  - Extract clean text, removing ads and navigation
  - Preserve important metadata (author, date, publication)
  - Handle paywalls and access restrictions gracefully
- **Output**: Full-text content from selected sources

### Step 4: Extract Key Facts and Data Points
- **Actions**:
  - Read and analyze scraped content
  - Identify core facts, statistics, and claims
  - Extract notable quotes and expert opinions
  - Note publication dates for temporal context
  - Flag preliminary or unconfirmed information
  - Capture URLs for citation purposes
- **Output**: Structured notes with extracted information

### Step 5: Cross-Reference Findings
- **Actions**:
  - Compare information across multiple sources
  - Verify consistency of key facts and data
  - Identify consensus views vs. outlier opinions
  - Note contradictions or disputes
  - Assess source credibility and potential bias
  - Build confidence level for each finding
- **Output**: Validated and cross-referenced research data

### Step 6: Structure into Research Brief with Citations
- **Actions**:
  - Organize findings into logical sections
  - Write executive summary (3-5 sentences)
  - Detail key findings with supporting evidence
  - Include "Why It Matters" analysis
  - Add relevance score (1-5)
  - Provide full citations with URLs
  - Format using standard markdown template
  - Proofread for clarity and accuracy
- **Output**: Publication-ready research brief

### Step 7: Save to Memory
- **Actions**:
  - Determine appropriate memory path based on topic
  - Save research brief to `/memory/research/ad-hoc/[topic-name].md`
  - Add metadata tags for discoverability
  - Create dated entry for chronological tracking
  - Verify file saved successfully
- **Output**: Research brief persisted in memory system

### Step 8: Report Findings to Requester
- **Actions**:
  - Send agent-to-agent message to requester
  - Include executive summary in message
  - Provide memory path for full research brief
  - Highlight most critical findings (relevance 4-5)
  - Ask if additional depth or follow-up needed
  - Log completion of research request
- **Output**: Research delivered to requester with context

## Standard Research Brief Template

```markdown
# Research Brief: [Topic Name]

**Requested by**: [Agent/User Name]
**Completed**: YYYY-MM-DD HH:MM
**Relevance Score**: ⭐⭐⭐⭐ (4/5)
**Category**: [AI / Marketing / Analytics / Tech / Other]

## Executive Summary
[3-5 sentence overview of key findings and implications]

## Key Findings

### Finding 1: [Title]
**Source**: [Publication Name] ([URL])
**Date**: YYYY-MM-DD
**Confidence**: High/Medium/Low

[Detailed explanation of finding with supporting evidence]

> "[Notable quote from source]"

### Finding 2: [Title]
**Source**: [Publication Name] ([URL])
**Date**: YYYY-MM-DD
**Confidence**: High/Medium/Low

[Detailed explanation of finding with supporting evidence]

### Finding 3: [Title]
**Source**: [Publication Name] ([URL])
**Date**: YYYY-MM-DD
**Confidence**: High/Medium/Low

[Detailed explanation of finding with supporting evidence]

## Why It Matters
[2-4 sentences on implications for ClawInc, marketing analytics, or relevant stakeholders]

## Recommendations
- [Actionable recommendation 1]
- [Actionable recommendation 2]
- [Actionable recommendation 3]

## Additional Context
[Background information, related developments, or future monitoring suggestions]

## Sources Consulted
1. [Publication Name] - [URL]
2. [Publication Name] - [URL]
3. [Publication Name] - [URL]
4. [Publication Name] - [URL]
5. [Publication Name] - [URL]

## Follow-Up Questions
- [Potential area for deeper investigation]
- [Related topic worth exploring]

---
*Research conducted by Scout using Web Research skill*
```

## Quality Checklist

Before delivering research, verify:
- [ ] At least 3-5 credible sources consulted
- [ ] All claims cross-referenced when possible
- [ ] Citations include working URLs and dates
- [ ] Executive summary accurately reflects findings
- [ ] Relevance score justified by content
- [ ] "Why It Matters" provides actionable context
- [ ] Preliminary/unconfirmed info clearly flagged
- [ ] Markdown formatting clean and readable
- [ ] Saved to memory successfully
- [ ] Requester notified with summary

## Typical Use Cases

### Competitive Analysis
"Research competitor X's new product launch and market positioning"

### Technology Evaluation
"Investigate [specific tool/platform] - features, pricing, user reviews, alternatives"

### Trend Investigation
"Deep dive on [emerging trend] - origins, key players, adoption signals, predictions"

### Background Research
"Provide context on [company/person/event] for upcoming content piece"

### Market Landscape
"Map out the current landscape of [product category] - major players, market size, trends"

## Performance Notes

### Typical Duration
- **Quick research** (3-5 sources): 10-15 minutes
- **Standard research** (5-10 sources): 20-30 minutes
- **Deep research** (10+ sources): 45-60 minutes

### Success Metrics
- Source quality (target: 80%+ Tier 1-2)
- Citation accuracy (target: 100%)
- Requester satisfaction (feedback loop)
- Research reuse rate (referenced by team)

## Skill Invocation Examples

### Via Agent Message
```
@Scout please research "cookieless attribution methods for e-commerce" - need it for a memo Writer is drafting
```

### Via Henry Directive
```
Scout, I need comprehensive research on multi-agent orchestration frameworks. Looking for technical capabilities, pricing, and community adoption. Prioritize this.
```

### Via Self-Initiated
```
Morning scan identified "major AI regulation announcement" - triggering web research skill for full analysis
```

---

**Skill Status**: Active
**Last Updated**: 2026-04-01
**Skill Owner**: Scout

*The Web Research skill is Scout's core capability for delivering thorough, cited, and actionable research to the ClawInc team.*
