# SKILL — Health Check

## Purpose

Check that the ClawInc server and openclaw-gateway are healthy. Run every 30 minutes via cron.

## Execution Time

Under 30 seconds.

## Instructions

Run the Python script below using exec. The script does everything: collects metrics,
appends a line to `health_check_log.txt`, and posts to the portal if any threshold is breached.
Do not break this into separate steps — run the whole script once.

```python
import subprocess, datetime, os, json, urllib.request

LOG = os.path.expanduser("~/.openclaw/workspace-watcher/health_check_log.txt")
WEBHOOK = os.environ.get("PORTAL_REPORTS_URL", "") or os.environ.get("DISCORD_WEBHOOK_URL", "")

def run(cmd):
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return r.stdout.strip()

# Gather metrics
free = run("free -m")
df   = run("df -h /")
load = run("cat /proc/loadavg")
gw   = run("systemctl --user is-active openclaw-gateway.service 2>/dev/null || echo inactive")

# Parse RAM
mem_line = [l for l in free.splitlines() if l.startswith("Mem:")][0].split()
ram_total, ram_used = int(mem_line[1]), int(mem_line[2])
ram_pct = round(ram_used / ram_total * 100)

# Parse swap
swap_line = [l for l in free.splitlines() if l.startswith("Swap:")][0].split()
swap_total, swap_used = int(swap_line[1]), int(swap_line[2])
swap_pct = round(swap_used / swap_total * 100) if swap_total > 0 else 0

# Parse disk
disk_line = df.splitlines()[-1].split()
disk_pct = int(disk_line[4].rstrip("%"))

# Parse load average
load_1m = float(load.split()[0])

# Evaluate thresholds
problems = []
if ram_pct > 95:    problems.append(f"CRITICAL: RAM {ram_pct}% (>95%)")
elif ram_pct > 80:  problems.append(f"WARNING: RAM {ram_pct}% (>80%)")

if swap_pct > 70:   problems.append(f"WARNING: Swap {swap_pct}% (>70%)")

if disk_pct > 95:   problems.append(f"CRITICAL: Disk {disk_pct}% (>95%)")
elif disk_pct > 85: problems.append(f"WARNING: Disk {disk_pct}% (>85%)")

gw_status = gw.strip()
if gw_status != "active": problems.append(f"CRITICAL: openclaw-gateway is {gw_status}")

status = "CRITICAL" if any(p.startswith("CRITICAL") for p in problems) else ("WARNING" if problems else "OK")

# Log to file (one line per run, append)
ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
summary = f"RAM:{ram_pct}% Swap:{swap_pct}% Disk:{disk_pct}% Load:{load_1m} GW:{gw_status}"
log_line = f"[{ts}] {status} | {summary}"
if problems:
    log_line += " | " + "; ".join(problems)

with open(LOG, "a") as f:
    print(log_line, file=f)

print(log_line)

# Alert Portal only if there are problems
if problems and WEBHOOK:
    body = f"**{status} — Health Check**\n\n" + "\n".join(f"• {p}" for p in problems)
    body += f"\n\n{summary}"
    payload = {"content": body}
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(WEBHOOK, data=data,
        headers={"Content-Type": "application/json"},
        method="POST")
    urllib.request.urlopen(req, timeout=10)
    print(f"Portal health alert posted ({status})")
elif not problems:
    print("All clear — no portal alert needed")
```

## Success Criteria

- Script runs without error
- One line appended to `health_check_log.txt`
- If status is OK: done, no further action
- If status is WARNING or CRITICAL: Portal health alert was posted
