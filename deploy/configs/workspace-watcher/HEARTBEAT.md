# HEARTBEAT — 30-Minute Monitoring Checklist

## Overview

This checklist executes every 30 minutes to ensure system health and agent operational status.

**Execution time**: ~30-60 seconds
**Target**: Complete all checks efficiently with minimal resource usage
**Output**: Log entry to memory (minimal for OK, detailed for issues)

## Checklist

### [ ] 1. Check System Memory

**Command**:
```bash
free -h
```

**Parse**:
- Total RAM available
- RAM used percentage
- Swap used percentage

**Thresholds**:
- Alert if RAM > 80%
- Alert if swap > 70%

**Log format**: `RAM: X% | Swap: Y%`

---

### [ ] 2. Check Disk Space

**Command**:
```bash
df -h /
```

**Parse**:
- Root filesystem usage percentage
- Available space in GB

**Thresholds**:
- Alert if usage > 85%

**Log format**: `Disk: X% (YGB free)`

---

### [ ] 3. Check CPU Load

**Command**:
```bash
uptime
```

**Parse**:
- 1-minute load average
- 5-minute load average
- 15-minute load average

**Thresholds**:
- Alert if 5-minute average > 2.0

**Log format**: `Load: X.XX, Y.YY, Z.ZZ`

---

### [ ] 4. Check OpenClaw Gateway

**Command**:
```bash
ps aux | grep -v grep | grep openclaw-gateway
```

**Parse**:
- Process ID (verify running)
- CPU usage
- Memory usage

**Thresholds**:
- CRITICAL alert if process not found

**Log format**: `Gateway: PID XXXX (CPU: X%, MEM: Y%)`

---

### [ ] 5. Check Agent Processes

**Command**:
```bash
ps aux | grep -v grep | grep "openclaw-agent"
```

**Parse**:
- Count of agent processes
- Verify all 5 agents are running

**Method**: Ping each agent via agent-to-agent (lightweight check)

**Expected agents**:
1. Henry (orchestrator)
2. Coder (software engineer)
3. Scout (research analyst)
4. Writer (content creator)
5. Watcher (self)

**Thresholds**:
- WARNING if any agent unresponsive
- CRITICAL if 2+ agents unresponsive

**Log format**: `Agents: 5/5 responsive` or `Agents: X/5 responsive (missing: [names])`

---

### [ ] 6. Review Recent Error Logs

**Command**:
```bash
journalctl -u openclaw --since "30 min ago" --priority err --no-pager | tail -20
```

**Parse**:
- Count of error entries
- Identify any recurring error patterns

**Thresholds**:
- WARNING if > 5 errors in 30-minute window
- CRITICAL if > 20 errors in 30-minute window

**Log format**: `Errors: X in last 30min` or `Errors: NONE`

---

### [ ] 7. Check Network Connectivity

**Command**:
```bash
ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1 && echo "OK" || echo "FAIL"
```

**Parse**:
- Basic internet connectivity status

**Thresholds**:
- WARNING if ping fails

**Log format**: `Network: OK` or `Network: FAIL`

---

### [ ] 8. Status Decision

**If all checks pass**:
```
Action: Log minimal entry to memory
Format: "✓ Heartbeat OK | RAM: 45% | Disk: 42% | Load: 0.23 | Agents: 5/5"
Do NOT alert Henry for routine OK status
```

**If any issues found**:
```
Action: Log detailed entry to memory with all metrics
Action: Alert Henry via agent-to-agent
Format: "⚠ Heartbeat WARNING/CRITICAL | [detailed issue description] | [all metrics] | [timestamp]"
```

## Alert Message Template

### WARNING Alert
```
TO: Henry
SEVERITY: WARNING
TIMESTAMP: [ISO 8601]

Heartbeat detected issues:
- [List each threshold breach or failure]

Current metrics:
- RAM: X% (threshold: 80%)
- Swap: Y% (threshold: 70%)
- Disk: Z% (threshold: 85%)
- Load: A.AA, B.BB, C.CC
- Agents: X/5 responsive
- Errors: N in last 30min

Recommendation: [Auto-remediation attempted / Manual review needed]
```

### CRITICAL Alert
```
TO: Henry
SEVERITY: CRITICAL
TIMESTAMP: [ISO 8601]

CRITICAL SYSTEM ISSUE DETECTED

Issue: [Primary critical issue]

All metrics:
- RAM: X%
- Swap: Y%
- Disk: Z%
- Load: A.AA, B.BB, C.CC
- Gateway: [status]
- Agents: X/5 responsive (missing: [names])
- Network: [status]

IMMEDIATE ACTION REQUIRED
```

## Heartbeat Execution Notes

- Execute efficiently to minimize resource consumption
- Total execution time should remain under 60 seconds
- Use shell command timeouts to prevent hanging
- If a command hangs (>10 seconds), log as WARNING and continue
- Timestamp every heartbeat with ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`
- Maintain rolling 48-hour heartbeat history in memory
- Archive older heartbeats to disk in compressed format
