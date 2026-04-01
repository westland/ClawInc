# SKILL — Comprehensive Health Check

## Purpose

Perform a thorough, in-depth health assessment of the entire ClawInc system. This is more comprehensive than the standard heartbeat check and should be used for:

- Daily detailed status reports
- Pre/post maintenance verification
- Investigating reported issues
- Monthly system audits

## Execution Time

Estimated: 2-5 minutes

## Steps

### Step 1: Analyze Memory Usage

**Command**:
```bash
free -h && free -m
```

**Actions**:
- Parse total, used, free, available RAM
- Calculate RAM usage percentage
- Parse swap total, used, free
- Calculate swap usage percentage
- Identify trend (compare to last health check)

**Output**: Detailed memory report with trend analysis

---

### Step 2: Analyze Disk Space

**Command**:
```bash
df -h && du -sh /var/lib/openclaw/* /var/log/openclaw/* /tmp/openclaw/*
```

**Actions**:
- Check all mount points (not just root)
- Identify largest directories
- Calculate growth rate since last check
- Identify candidates for cleanup
- Check inode usage: `df -i`

**Output**: Disk usage report with growth trends

---

### Step 3: Analyze CPU and Processes

**Command**:
```bash
top -bn1 | head -30 && ps aux --sort=-%cpu | head -20 && ps aux --sort=-%mem | head -20
```

**Actions**:
- Identify top CPU-consuming processes
- Identify top memory-consuming processes
- Check for zombie processes
- Verify process counts are normal
- Analyze CPU load trends

**Output**: Process analysis with resource hogs identified

---

### Step 4: Check Gateway Status

**Command**:
```bash
ps aux | grep openclaw-gateway
systemctl status openclaw-gateway --no-pager
```

**Actions**:
- Verify gateway process is running
- Check process uptime
- Review gateway resource usage
- Check for recent restarts
- Verify port bindings: `netstat -tlnp | grep openclaw`

**Output**: Gateway health report

---

### Step 5: Ping All Agents

**Actions**:
- Send lightweight ping to each agent:
  - Henry (orchestrator)
  - Watcher (self-check)
  - Builder
  - Analyst
  - Researcher
- Measure response time for each
- Check agent memory state accessibility
- Verify agent workspace integrity

**Output**: Agent responsiveness matrix with response times

---

### Step 6: Review Last Hour of Error Logs

**Command**:
```bash
journalctl -u openclaw --since "1 hour ago" --priority warning --no-pager
journalctl -u openclaw --since "1 hour ago" --priority err --no-pager
```

**Actions**:
- Count warnings and errors
- Categorize errors by type
- Identify any error patterns or spikes
- Check for stack traces or critical failures
- Review application-specific logs in `/var/log/openclaw/`

**Output**: Error summary with categorization

---

### Step 7: Check Systemd Service Status

**Command**:
```bash
systemctl status openclaw --no-pager
systemctl is-failed openclaw-*
journalctl -u openclaw --since "24 hours ago" --grep "Failed\|Error\|Critical"
```

**Actions**:
- Verify all OpenClaw services are active
- Check for any failed units
- Review service restart counts
- Verify service configurations are intact

**Output**: Service health matrix

---

### Step 8: Check Network and Connectivity

**Command**:
```bash
ping -c 5 8.8.8.8
curl -I -s --connect-timeout 5 https://api.anthropic.com | head -1
netstat -an | grep ESTABLISHED | wc -l
```

**Actions**:
- Verify external network connectivity
- Check API endpoint accessibility
- Count active connections
- Check for unusual network activity

**Output**: Network health report

---

### Step 9: Compile Health Report

**Actions**:
- Aggregate all findings from steps 1-8
- Calculate overall health score (0-100)
  - Each subsystem contributes to score
  - Deduct points for warnings and errors
  - Major issues can drop score significantly
- Assign overall status: HEALTHY / DEGRADED / CRITICAL
- Generate executive summary
- Create detailed technical report

**Health Score Calculation**:
- RAM within limits: 15 points
- Disk within limits: 15 points
- CPU within limits: 10 points
- Gateway healthy: 20 points
- All agents responsive: 20 points
- No critical errors: 10 points
- Services running: 10 points

**Score interpretation**:
- 90-100: HEALTHY
- 70-89: DEGRADED
- 0-69: CRITICAL

---

### Step 10: Save to Memory

**Actions**:
- Save complete health report to memory
- Tag with timestamp (ISO 8601)
- Link to any relevant log excerpts
- Update health trend data
- Archive previous health checks (keep last 7 days in active memory)

**Memory structure**:
```
health_checks/
  latest/
    timestamp: [ISO 8601]
    status: [HEALTHY/DEGRADED/CRITICAL]
    score: [0-100]
    executive_summary: [text]
    detailed_report: [full report]
  history/
    [date-1]/
    [date-2]/
    ...
```

---

### Step 11: Alert Henry (Conditional)

**Alert if**:
- Overall status is DEGRADED or CRITICAL
- Health score < 85
- Any critical errors found
- Any agent unresponsive
- Resource usage exceeds thresholds

**Do NOT alert if**:
- Status is HEALTHY
- Score >= 90
- This is a routine scheduled check with no issues

**Alert format**:
```
TO: Henry
FROM: Watcher
SUBJECT: Health Check Report - [STATUS]

Overall Status: [HEALTHY/DEGRADED/CRITICAL]
Health Score: XX/100
Timestamp: [ISO 8601]

Executive Summary:
[2-3 sentence summary of findings]

Key Metrics:
- RAM: X% | Swap: Y%
- Disk: Z%
- CPU Load: A.AA
- Gateway: [UP/DOWN]
- Agents: X/5 responsive
- Errors (1h): N warnings, M errors

[If issues] Recommended Actions:
1. [Action 1]
2. [Action 2]
...

Full report available in Watcher memory at: health_checks/latest/
```

## Usage

Invoke this skill:
- Daily at 6:00 AM for routine comprehensive check
- Before major maintenance operations
- After system updates or changes
- When investigating reported issues
- On-demand via manual request

## Success Criteria

- All 11 steps complete successfully
- Report generated and saved to memory
- Appropriate alerting based on findings
- Execution time < 5 minutes
- No false positives in alerting
