# SKILL: portal-report

## Identity
- **Sender name**: Coder — Dev Agent
- **Embed color**: 3447003  *(blue #3498DB)*
- **Footer**: ClawInc · Coder · Claude Sonnet 4.5

## Purpose

Post a signed, formatted technical report to the Reports & Memos portal screen.
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
- Save a record of the portal post to memory

## Signature Line

Every report/memo post from Coder ends with:

> *— Coder, Dev Agent · ClawInc · [date]*
