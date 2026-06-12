# SKILL: portal-report

## Identity
- **Sender name**: Watcher — Monitor Bot
- **Embed color**: 15105570  *(orange #E67E22)*
- **Footer**: ClawInc · Watcher · Claude Haiku 4.5

## Purpose

Post a signed system health report to the Reports & Memos portal screen.
Watcher posts are concise status updates — green when healthy,
detailed when there is a problem.

## When to Use

- After every 30-minute health check **only if an issue is found**
  (do NOT spam the portal with "all clear" every 30 min)
- After weekly session cleanup (Sunday 4 AM)
- After detecting a resource warning (CPU > 85%, RAM > 90%, disk > 80%)
- After any incident or anomaly
- When explicitly asked to post a status update

## Health Check Posting Rule

**Post to the portal only if:**
- A metric exceeds warning threshold (CPU > 85%, RAM > 90%, disk > 80%)
- The openclaw service is inactive or crashed
- An error appears in the logs that needs attention
- The weekly cleanup is complete (always post this one)

**Do NOT post for routine "all systems normal" checks** — the portal should
only light up when something needs attention or as a weekly summary.

## Execution Steps

### Step 1: Compose the Status Report

For alerts:
```
**⚠️ [ALERT TYPE] — [SEVERITY: Warning/Critical]**

**Affected**: [Service or resource]
**Value**: [Current reading]
**Threshold**: [What triggered this alert]

**Details**
[What was found in logs or metrics]

**Recommended Action**
[What should be done]

**Auto-remediated**: Yes / No
```

For weekly cleanup:
```
**✅ Weekly Cleanup Complete**

**Sessions archived**: [N]
**Disk space freed**: [X MB]
**Log files rotated**: [N]
**System health**: All clear / [Issues noted]
```

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
- Log in memory: date, alert type, severity, whether resolved

## Signature Line

Every report/memo post from Watcher ends with:

> *— Watcher, Monitor Bot · ClawInc · [date]*
