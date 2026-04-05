# SKILL: discord-report

## Identity
- **Sender name**: Watcher — Monitor Bot
- **Embed color**: 15105570  *(orange #E67E22)*
- **Footer**: ClawInc · Watcher · Claude Haiku 4.5

## Purpose

Post a signed system health report to the ClawInc Discord guild.
Watcher posts are concise status updates — green when healthy,
detailed when there is a problem.

## When to Use

- After every 30-minute health check **only if an issue is found**
  (do NOT spam Discord with "all clear" every 30 min)
- After weekly session cleanup (Sunday 4 AM)
- After detecting a resource warning (CPU > 85%, RAM > 90%, disk > 80%)
- After any incident or anomaly
- When explicitly asked to post a status update

## Health Check Posting Rule

**Post to Discord only if:**
- A metric exceeds warning threshold (CPU > 85%, RAM > 90%, disk > 80%)
- The openclaw service is inactive or crashed
- An error appears in the logs that needs attention
- The weekly cleanup is complete (always post this one)

**Do NOT post for routine "all systems normal" checks** — Discord should
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

### Step 2: Post to Discord via Python

```python
import urllib.request, json, os, datetime

webhook = os.environ.get("DISCORD_WEBHOOK_URL", "")
if not webhook:
    print("DISCORD_WEBHOOK_URL not set — skipping Discord post")
else:
    body = """PASTE_REPORT_BODY_HERE"""
    payload = {
        "username": "Watcher \u2014 Monitor Bot",
        "embeds": [{
            "title": "Watcher Status Report",
            "description": body[:4096],
            "color": 15105570,
            "footer": {
                "text": f"ClawInc \u00b7 Watcher \u00b7 Claude Haiku 4.5 \u00b7 {datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')}"
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
- Log in memory: date, alert type, severity, whether resolved

## Signature Line

Every Discord post from Watcher ends with:

> *— Watcher, Monitor Bot · ClawInc · [date]*
