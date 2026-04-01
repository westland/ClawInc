# Skill: Write Memo

## Description

Write professional executive memos that synthesize information into clear, actionable insights. Memos are 1-2 page documents designed for quick consumption by busy decision-makers.

## Use Cases

- Daily morning memos
- Executive briefings
- Status updates
- Decision support documents
- Internal announcements
- Meeting summaries

## Input Requirements

- **Topic/Subject**: Clear memo purpose
- **Audience**: Who will read this (default: Henry)
- **Source Material**: Scout's research, directives, or other inputs
- **Urgency**: Standard or urgent (affects detail level)

## Execution Steps

### Step 1: Gather Source Material

**Actions:**
- Read Scout's research briefings from memory
- Review Henry's directives or request details
- Access relevant previous memos for context
- Identify web sources if additional fact-checking needed

**Output:**
- Consolidated list of source materials
- Key data points and findings
- Attribution notes for citations

### Step 2: Identify Key Themes and Priorities

**Actions:**
- Extract the 3-5 most important insights
- Prioritize based on:
  - Impact on business objectives
  - Urgency or time-sensitivity
  - Actionability
  - Relevance to audience

**Output:**
- Prioritized list of themes
- Supporting data for each theme
- Initial angle for memo focus

### Step 3: Write Executive Summary

**Actions:**
- Craft 3-5 bullet points (BLUF - Bottom Line Up Front)
- Each bullet: one key insight or recommendation
- Lead with the most important information
- Keep bullets concise (1-2 sentences each)

**Format:**
```markdown
## Executive Summary

- [Most critical insight or recommendation]
- [Second priority insight or recommendation]
- [Third priority insight or recommendation]
- [Additional insight if needed]
```

### Step 4: Expand Each Theme with Supporting Data

**Actions:**
- Create a section for each major theme
- Open with the main point
- Support with data and evidence
- Add context and implications
- Keep paragraphs short (3-5 sentences)

**Format:**
```markdown
## [Theme Title]

[Main point statement]

[Supporting data and evidence]

[Context and implications]
```

### Step 5: Add Action Items and Recommendations

**Actions:**
- List specific, actionable next steps
- Assign priority levels (High/Medium/Low)
- Include timelines when applicable
- Identify owners if known

**Format:**
```markdown
## Recommendations

**High Priority:**
- [Action item with clear outcome]

**Medium Priority:**
- [Action item with clear outcome]

**Low Priority:**
- [Action item with clear outcome]
```

### Step 6: Format as Clean Markdown Memo

**Actions:**
- Apply standard memo header
- Ensure consistent heading hierarchy
- Add horizontal rules for section breaks
- Include date and metadata
- Add sources section

**Standard Template:**
```markdown
# [Memo Title]

**Date:** YYYY-MM-DD
**To:** [Recipient]
**From:** Writer (Content Creator)
**Re:** [Subject line]

---

## Executive Summary

[3-5 bullet points]

---

## [Theme 1]

[Content]

## [Theme 2]

[Content]

---

## Recommendations

[Action items]

---

## Sources

- [Source attribution]
```

### Step 7: Save to Memory

**Actions:**
- Save with proper metadata
- Use naming convention: `memo-[topic]-YYYY-MM-DD`
- Tag with relevant categories
- Mark as final version

**Metadata:**
```
Title: Memo - [Topic] - YYYY-MM-DD
Type: memo
Date: YYYY-MM-DD
Audience: [Henry/Team/Specific person]
Source: [Scout briefing/Henry directive/etc.]
Status: final
Tags: [relevant, topic, tags]
```

### Step 8: Notify Henry

**Actions:**
- Send agent-to-agent message
- Include memo title
- Provide 1-sentence summary
- Note memory location
- Indicate urgency level if applicable

**Message Template:**
```
Subject: Memo Ready - [Topic]

Henry,

I've completed the memo on [topic]. Key takeaway: [one sentence summary].

Saved to memory as: memo-[topic]-YYYY-MM-DD

[Urgent/Standard priority]

-Writer
```

## Quality Checklist

Before saving and notifying:

- [ ] Executive summary captures the most important points
- [ ] Each theme has clear supporting evidence
- [ ] Recommendations are specific and actionable
- [ ] Tone is professional and appropriate
- [ ] No spelling or grammar errors
- [ ] Sources are properly cited
- [ ] Formatting is clean and consistent
- [ ] Length is 1-2 pages (appropriate for memo format)
- [ ] All data points are accurate
- [ ] Memo answers "so what?" question

## Output Specifications

- **Length**: 1-2 pages (400-800 words)
- **Format**: Markdown
- **Tone**: Professional, concise, actionable
- **Reading time**: 3-5 minutes
- **Structure**: Header → Executive Summary → Themes → Recommendations → Sources

## Time Estimate

- **Simple memo** (single theme): 30 minutes
- **Standard memo** (2-3 themes): 45-60 minutes
- **Complex memo** (4-5 themes, multiple sources): 90 minutes

## Success Criteria

- Memo is delivered on time
- Key insights are clearly communicated
- Recommendations are actionable
- Henry can make decisions based on content
- Content is saved and accessible in memory
