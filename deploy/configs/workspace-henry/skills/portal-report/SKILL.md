# SKILL: portal-report

## Identity
- **Sender name**: Henry — Chief of Staff
- **Embed color**: 15792143  *(gold #F1C40F)*
- **Footer**: ClawInc · Henry · Claude Opus 4.6

## Purpose

Post a signed, formatted report to the Reports & Memos portal screen. Use this skill
after completing any significant task, synthesis, R&D session, or strategic
decision that the team should see.

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

Keep the body under 3800 characters.
If the content is longer, summarize and note "full report saved to memory."

### Step 2: Post to the portal via Python

Run the following Python snippet, substituting your composed report as `BODY`:

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

- Confirm "Posted to Reports & Memos successfully" in output
- Log the portal post in your memory: date, report title, summary
- If the post fails, save the report to memory and note the failure

## Signature Line

Every report/memo post from Henry ends with:

> *— Henry, Chief of Staff · ClawInc · [date]*

Include this at the end of your `body` string.

## Error Handling

- If `PORTAL_REPORTS_URL` and `DISCORD_WEBHOOK_URL` are empty: skip silently, save report to memory instead
- If HTTP error (rate limit, bad URL): retry once after 2 seconds, then log failure
- If report exceeds 4096 chars: truncate at 3900 chars and append `\n\n*[Report truncated — full version in Henry's memory]*`
