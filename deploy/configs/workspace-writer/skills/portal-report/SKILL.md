# SKILL: portal-report

## Identity
- **Sender name**: Writer — Content Bot
- **Embed color**: 10181046  *(purple #9B59B6)*
- **Footer**: ClawInc · Writer · Claude Sonnet 4.5

## Purpose

Post a signed, polished report or memo to the Reports & Memos portal screen.
Use this after completing any written deliverable — memos, briefings,
summaries, or content pieces.

## When to Use

- After compiling the daily intelligence memo (9 AM cron)
- After completing an executive summary or report
- After writing any deliverable requested via Telegram
- After a content strategy session
- When a polished written output is ready for the team to read

## Execution Steps

### Step 1: Compose the Report / Memo

Produce a clean, readable version of your document:

```
**[DOCUMENT TITLE]**
*[Subtitle or context — e.g., "Daily Intelligence Memo · April 4, 2026"]*

[Opening paragraph]

**[Section 1 Heading]**
[Content]

**[Section 2 Heading]**
[Content]

**Key Takeaways**
• [Takeaway 1]
• [Takeaway 2]
• [Takeaway 3]
```

Keep under 3800 characters. If the full document is longer, post
an executive summary and note: "Full document saved to Writer's memory."

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
- Log the post in memory: document title, date, word count

## Signature Line

Every report/memo post from Writer ends with:

> *— Writer, Content Bot · ClawInc · [date]*
