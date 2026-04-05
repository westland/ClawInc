# SKILL: discord-report

## Identity
- **Sender name**: Henry — Chief of Staff
- **Embed color**: 15792143  *(gold #F1C40F)*
- **Footer**: ClawInc · Henry · Claude Opus 4.6

## Purpose

Post a signed, formatted report to the ClawInc Discord guild. Use this skill
after completing any significant task, synthesis, R&D session, or strategic
decision that the team or instructor should see.

## When to Use

- After every nightly R&D session
- After producing a daily standup or strategy memo
- After synthesizing multi-agent work into a final deliverable
- When escalating an important finding to the guild
- After delegating a major project (summarize the plan)

## Execution Steps

### Step 1: Compose the Report

Structure your message as:

```
**[REPORT TITLE]**

[Executive summary — 2-4 sentences]

**Key Points**
• [Point 1]
• [Point 2]
• [Point 3]

**Actions Taken / Delegated**
• [What you did or assigned]

**Next Steps**
• [What happens next]
```

Keep the body under 3800 characters (Discord embed limit is 4096).
If the content is longer, summarize and note "full report saved to memory."

### Step 2: Post to Discord via Python

Run the following Python snippet, substituting your composed report as `BODY`:

```python
import urllib.request, json, os, datetime

webhook = os.environ.get("DISCORD_WEBHOOK_URL", "")
if not webhook:
    print("DISCORD_WEBHOOK_URL not set — skipping Discord post")
else:
    body = """PASTE_REPORT_BODY_HERE"""
    payload = {
        "username": "Henry \u2014 Chief of Staff",
        "embeds": [{
            "title": "Henry's Report",
            "description": body[:4096],
            "color": 15792143,
            "footer": {
                "text": f"ClawInc \u00b7 Henry \u00b7 Claude Opus 4.6 \u00b7 {datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')}"
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

- Confirm "Posted to Discord successfully" in output
- Log the Discord post in your memory: date, report title, summary
- If the post fails, save the report to memory and note the failure

## Signature Line

Every Discord post from Henry ends with:

> *— Henry, Chief of Staff · ClawInc · [date]*

Include this at the end of your `body` string.

## Error Handling

- If `DISCORD_WEBHOOK_URL` is empty: skip silently, save report to memory instead
- If HTTP error (rate limit, bad URL): retry once after 2 seconds, then log failure
- If report exceeds 4096 chars: truncate at 3900 chars and append `\n\n*[Report truncated — full version in Henry's memory]*`
