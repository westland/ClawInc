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
import subprocess, datetime, os, json

LOG = os.path.expanduser("~/.openclaw/workspace-watcher/health_check_log.txt")
problems = []

def run(cmd):
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return r.stdout.strip()

# Gather metrics
free = run("free -m")
df   = run("df -h /")
load = run("cat /proc/loadavg")
gw   = run("systemctl is-active openclaw.service 2>/dev/null || echo inactive")

# Check Nginx and Portal health
portal_status = "inactive"
try:
    curl_output = run("curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8000/")
    if curl_output in ["200", "301", "302", "307", "401", "403", "404"]:
        portal_status = f"active (status {curl_output} expected)"
    elif curl_output in ["000", ""]:
        problems.append("CRITICAL: Portal on port 8000 is unreachable")
    else:
        problems.append(f"WARNING: Portal returned status {curl_output}")
except Exception as e:
    problems.append(f"CRITICAL: Portal check failed: {e}")

nginx_status = "inactive"
try:
    curl_output = run("curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/")
    if curl_output in ["200", "301", "302", "307", "401", "403", "404"]:
        nginx_status = f"active (status {curl_output} expected)"
    elif curl_output in ["000", ""]:
        problems.append("CRITICAL: Nginx on port 80 is unreachable")
    else:
        problems.append(f"WARNING: Nginx returned status {curl_output}")
except Exception as e:
    problems.append(f"CRITICAL: Nginx check failed: {e}")

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
# problems list is initialized above
if ram_pct > 95:    problems.append(f"CRITICAL: RAM {ram_pct}% (>95%)")
elif ram_pct > 80:  problems.append(f"WARNING: RAM {ram_pct}% (>80%)")

if swap_pct > 70:   problems.append(f"WARNING: Swap {swap_pct}% (>70%)")

if disk_pct > 95:   problems.append(f"CRITICAL: Disk {disk_pct}% (>95%)")
elif disk_pct > 85: problems.append(f"WARNING: Disk {disk_pct}% (>85%)")

gw_status = gw.strip()
if gw_status != "active": problems.append(f"CRITICAL: openclaw-gateway is {gw_status}")
if "CRITICAL" in portal_status or portal_status == "inactive": problems.append("CRITICAL: dermaart-portal is inactive")
if "CRITICAL" in nginx_status or nginx_status == "inactive": problems.append("CRITICAL: Nginx is inactive")

status = "CRITICAL" if any(p.startswith("CRITICAL") for p in problems) else ("WARNING" if problems else "OK")


# Log to file (one line per run, append)
ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
summary = f"RAM:{ram_pct}% Swap:{swap_pct}% Disk:{disk_pct}% Load:{load_1m} GW:{gw_status} Portal:{portal_status} Nginx:{nginx_status}"
log_line = f"[{ts}] {status} | {summary}"
if problems:
    log_line += " | " + "; ".join(problems)

with open(LOG, "a") as f:
    print(log_line, file=f)

print(log_line)

# Alert Portal only if there are problems
if problems:
    report_content = f"# Watcher — System Health Check\n## {status} Alert\n\n"
    report_content += "\n".join(f"*   **{p}**" for p in problems)
    report_content += f"\n*   **Summary**: {summary}"
    subprocess.run(["/usr/local/bin/portal-post"], input=report_content.encode("utf-8"))
    print(f"Portal health alert posted ({status})")
else:
    print("All clear — no portal alert needed")
```

## Success Criteria

- Script runs without error
- One line appended to `health_check_log.txt`
- If status is OK: done, no further action
- If status is WARNING or CRITICAL: Portal health alert was posted
