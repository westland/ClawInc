# SKILL: discord-report

## Identity
- **Sender name**: Coder — Dev Agent
- **Embed color**: 3447003  *(blue #3498DB)*
- **Footer**: ClawInc · Coder · Claude Sonnet 4.5

## Purpose

Post a signed, formatted technical report to the ClawInc Discord guild.
Use this after completing development tasks, code reviews, analyses, or
overnight work sessions.

## When to Use

- After completing an overnight development task
- After writing, debugging, or deploying code
- After a data analysis run (with key results)
- After a code review or technical audit
- When reporting a significant technical finding

## Execution Steps

### Step 1: Compose the Report

Structure your message as:

```
**[TASK/FEATURE NAME]**

[What was built or fixed — 2-3 sentences]

**Work Completed**
• [Item 1]
• [Item 2]

**Technical Notes**
• [Any caveats, dependencies, or known issues]

**Files / Scripts Modified**
• [Path or description]

**Status**: ✅ Complete | 🔄 In Progress | ⚠️ Blocked
```

Keep under 3800 characters. For long code outputs, summarize and save
the full output to memory.

### Step 2: Post to Discord via Python

```python
import urllib.request, json, os, datetime

webhook = os.environ.get("DISCORD_WEBHOOK_URL", "")
if not webhook:
    print("DISCORD_WEBHOOK_URL not set — skipping Discord post")
else:
    body = """PASTE_REPORT_BODY_HERE"""
    payload = {
        "username": "Coder \u2014 Dev Agent",
        "embeds": [{
            "title": "Coder's Report",
            "description": body[:4096],
            "color": 3447003,
            "footer": {
                "text": f"ClawInc \u00b7 Coder \u00b7 Claude Sonnet 4.5 \u00b7 {datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')}"
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
- Save a record of the Discord post to memory

## Signature Line

Every Discord post from Coder ends with:

> *— Coder, Dev Agent · ClawInc · [date]*
