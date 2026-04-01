# AGENTS — Operating Instructions

## Available Tools

- **shell**: Execute system commands for monitoring and maintenance
- **file operations**: Read logs, write reports, manage temporary files
- **memory**: Store health check results and monitoring history
- **agent-to-agent**: Communicate with Henry and other agents when needed

## Heartbeat System

**Frequency**: Every 30 minutes
**Execution**: Follow the checklist defined in HEARTBEAT.md
**Purpose**: Continuous monitoring of system health and agent status

## Essential Health Check Commands

### Memory Status
```bash
free -h
```
Parse output to track RAM and swap usage percentages.

### Disk Space
```bash
df -h
```
Monitor all mount points, with primary focus on root filesystem.

### CPU Load
```bash
top -bn1 | head -20
```
Identify top processes and current CPU utilization.

### Process Monitoring
```bash
ps aux | grep openclaw
```
Verify OpenClaw gateway and agent processes are running.

### System Uptime
```bash
uptime
```
Check load averages (1min, 5min, 15min).

### Error Log Review
```bash
journalctl -u openclaw --since "30 min ago" --priority err
```
Review recent critical errors.

## Scheduled Maintenance

### Weekly Session Cleanup
**Schedule**: Every Sunday at 4:00 AM
**Task**: Execute the session-cleanup skill
**Actions**:
- Archive sessions older than 7 days
- Clean temporary files from /tmp/openclaw/
- Compress and move old session data
- Report storage space recovered

### Daily Status Reports
**Schedule**: 6:00 AM daily
**Task**: Compile 24-hour summary from heartbeat logs
**Format**: Concise metrics overview saved to memory

## Alerting Protocol

### DO alert Henry for:
- WARNING level threshold breaches
- CRITICAL system issues
- Agent unresponsiveness
- Unusual error patterns
- Failed maintenance tasks

### DO NOT alert Henry for:
- Routine OK status from heartbeat checks
- Normal operational metrics
- Successful maintenance completions (log to memory instead)

## Logging Requirements

All health checks must be logged to memory with:
- Timestamp (ISO 8601 format)
- Check type (heartbeat, health-check, etc.)
- Status (OK, WARNING, CRITICAL)
- Key metrics
- Actions taken (if any)

## Memory Management

Keep memory organized:
- Latest heartbeat results (rolling 48-hour window)
- Health check summaries (last 7 days)
- Alert history (last 30 days)
- Maintenance task results (last 90 days)

Archive older entries to compressed logs on disk.

## Emergency Procedures

If CRITICAL issues detected:
1. Log detailed diagnostics immediately
2. Alert Henry via agent-to-agent with clear severity indicator
3. If possible, attempt automated remediation
4. Document all actions taken
5. Continue monitoring until issue resolved or human intervention occurs
