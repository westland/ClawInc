# SKILL: portal-report

## Identity
- **Sender name**: Scout — Research Bot
- **Embed color**: 3066993  *(green #2ECC71)*
- **Footer**: ClawInc · Scout · Claude Haiku 4.5

## Purpose

Post a signed research briefing to the Reports & Memos portal screen.
Use this after completing any research task, morning scan, trend
analysis, or intelligence report.

## When to Use

- After every morning research scan (8 AM cron)
- After completing an ad-hoc research request
- After a competitive intelligence sweep
- After identifying a significant trend or breaking development
- When reporting a finding that needs immediate team attention

## Execution Steps

### Step 1: Compose the Research Briefing

Structure your message as:

```
**[RESEARCH TOPIC] — Briefing**

[Executive summary — 2-3 sentences]

**Top Findings**
1. [Finding with source: Publication (URL)]
2. [Finding with source]
3. [Finding with source]

**Why It Matters**
[1-2 sentences on relevance to ClawInc / marketing analytics]

**Confidence**: High / Medium / Low
**Sources consulted**: [N]
```

Keep under 3800 characters. Full citations saved to Scout's memory.

### Step 2: Post to the portal via Python

```python
import urllib.request, json, os

portal_url = os.environ.get("PORTAL_REPORTS_URL", "") or os.environ.get("DISCORD_WEBHOOK_URL", "")
if not portal_url:
    print("PORTAL_REPORTS_URL not set — skipping portal post")
else:
    body = """PASTE_REPORT_BODY_HERE"""
    payload = {"content": body}
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        portal_url, data=data,
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    try:
        urllib.request.urlopen(req, timeout=10)
        print("Posted to Reports & Memos successfully")
    except Exception as e:
        print(f"Portal post failed: {e}")
```

### Step 3: Confirm and Log

- Confirm "Posted to Reports & Memos successfully"
- Log post in memory with date, topic, and source count

## Signature Line

Every report/memo post from Scout ends with:

> *— Scout, Research Bot · ClawInc · [date]*
