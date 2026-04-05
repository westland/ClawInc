# SKILL: discord-report

## Identity
- **Sender name**: Writer — Content Bot
- **Embed color**: 10181046  *(purple #9B59B6)*
- **Footer**: ClawInc · Writer · Claude Sonnet 4.5

## Purpose

Post a signed, polished report or memo to the ClawInc Discord guild.
Use this after completing any written deliverable — memos, briefings,
summaries, or content pieces.

## When to Use

- After compiling the daily intelligence memo (9 AM cron)
- After completing an executive summary or report
- After writing any deliverable requested via Telegram
- After a content strategy session
- When a polished written output is ready for the team to read

## Execution Steps

### Step 1: Compose the Discord Version

For Discord, produce a clean, readable version of your document:

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

### Step 2: Post to Discord via Python

```python
import urllib.request, json, os, datetime

webhook = os.environ.get("DISCORD_WEBHOOK_URL", "")
if not webhook:
    print("DISCORD_WEBHOOK_URL not set — skipping Discord post")
else:
    body = """PASTE_REPORT_BODY_HERE"""
    payload = {
        "username": "Writer \u2014 Content Bot",
        "embeds": [{
            "title": "Writer's Report",
            "description": body[:4096],
            "color": 10181046,
            "footer": {
                "text": f"ClawInc \u00b7 Writer \u00b7 Claude Sonnet 4.5 \u00b7 {datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')}"
            }
        }]
    }
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        webhook, data=data,
        headers={"Content-Type": "application/json", "User-Agent": "ClawIncBot/1.0"},
        method="POST"
    )
    try:
        urllib.request.urlopen(req, timeout=10)
        print("Posted to Discord successfully")
    except Exception as e:
        print(f"Discord post failed: {e}")
```

### Step 3: Confirm and Log

- Confirm "Posted to Discord successfully"
- Log the post in memory: document title, date, word count

## Signature Line

Every Discord post from Writer ends with:

> *— Writer, Content Bot · ClawInc · [date]*
