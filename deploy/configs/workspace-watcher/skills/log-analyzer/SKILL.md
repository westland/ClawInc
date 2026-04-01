# SKILL — Log Analyzer

## Purpose

Analyze system and application logs to identify errors, warnings, patterns, and anomalies. This skill provides deep insights into system behavior and helps identify issues before they become critical.

## Execution Time

Estimated: 3-7 minutes (depending on log volume)

## Steps

### Step 1: Collect System Logs

**Commands**:
```bash
# Last 24 hours of systemd logs
journalctl -u openclaw --since "24 hours ago" --no-pager > /tmp/openclaw-systemd-24h.log

# Last 24 hours of priority errors
journalctl --priority err --since "24 hours ago" --no-pager > /tmp/system-errors-24h.log

# Last 24 hours of priority warnings
journalctl --priority warning --since "24 hours ago" --no-pager > /tmp/system-warnings-24h.log
```

**Actions**:
- Collect comprehensive systemd journal logs
- Filter for OpenClaw-specific entries
- Capture system-wide errors and warnings
- Preserve timestamps and metadata

**Output**: Raw log files for analysis

---

### Step 2: Collect Application Logs

**Commands**:
```bash
# OpenClaw application logs
find /var/log/openclaw/ -type f -name "*.log" -mtime -1 -exec tail -1000 {} \;

# Agent-specific logs
cat /var/log/openclaw/henry.log
cat /var/log/openclaw/watcher.log
cat /var/log/openclaw/builder.log
cat /var/log/openclaw/analyst.log
cat /var/log/openclaw/researcher.log
```

**Actions**:
- Collect last 24 hours of application logs
- Gather agent-specific log files
- Include gateway logs
- Capture any crash dumps or stack traces

**Output**: Application log collection

---

### Step 3: Filter for Errors and Warnings

**Commands**:
```bash
# Extract ERROR level entries
grep -i "error\|exception\|failed\|failure\|fatal" /tmp/openclaw-systemd-24h.log > /tmp/errors.log

# Extract WARNING level entries
grep -i "warning\|warn\|deprecated" /tmp/openclaw-systemd-24h.log > /tmp/warnings.log

# Count by severity
echo "Errors: $(wc -l < /tmp/errors.log)"
echo "Warnings: $(wc -l < /tmp/warnings.log)"
```

**Actions**:
- Extract all error-level messages
- Extract all warning-level messages
- Count occurrences by severity
- Identify any critical/fatal errors
- Filter out known benign warnings

**Output**: Categorized error and warning lists

---

### Step 4: Identify Patterns and Recurring Issues

**Commands**:
```bash
# Find most common error messages
cut -d':' -f4- /tmp/errors.log | sort | uniq -c | sort -rn | head -20

# Find recurring error patterns
awk '{print $NF}' /tmp/errors.log | sort | uniq -c | sort -rn | head -10
```

**Actions**:
- Group similar error messages
- Identify most frequent errors
- Detect recurring error patterns
- Find repeated stack traces
- Identify error message templates

**Pattern categories to detect**:
- Connection failures
- Memory allocation errors
- Permission denied errors
- File not found errors
- Timeout errors
- API rate limiting
- Database errors

**Output**: Pattern analysis with frequency counts

---

### Step 5: Categorize by Severity

**Severity levels**:
1. **CRITICAL** - System stability at risk, immediate action required
2. **HIGH** - Functionality impaired, action needed soon
3. **MEDIUM** - Minor issues, should be addressed
4. **LOW** - Informational, monitor for trends
5. **INFO** - Normal operations, no action needed

**Categorization rules**:

**CRITICAL**:
- Gateway process crashes
- Out of memory errors
- Disk full errors
- Agent process failures
- Database corruption
- Security breaches

**HIGH**:
- API request failures
- Agent communication timeouts
- Service restart events
- Resource threshold breaches
- Authentication errors

**MEDIUM**:
- Deprecated API warnings
- Slow query warnings
- Temporary connection issues
- Retry attempts

**LOW**:
- Configuration warnings
- Info-level messages in error logs
- Successful retry operations

**Actions**:
- Assign severity to each unique error pattern
- Count occurrences per severity level
- Identify highest priority issues
- Create prioritized issue list

**Output**: Severity-categorized issue list

---

### Step 6: Check for Rate Anomalies

**Commands**:
```bash
# Errors per hour for last 24 hours
journalctl --priority err --since "24 hours ago" --output=short-iso --no-pager | \
  awk '{print substr($1, 1, 13)}' | uniq -c

# Warnings per hour
journalctl --priority warning --since "24 hours ago" --output=short-iso --no-pager | \
  awk '{print substr($1, 1, 13)}' | uniq -c
```

**Actions**:
- Calculate error rate per hour
- Identify sudden spikes in error frequency
- Detect anomalous error bursts
- Compare current rate to historical baseline
- Identify time-based patterns (e.g., errors during backup)

**Anomaly detection**:
- Baseline: Average errors per hour over last 7 days
- Spike threshold: 3x baseline rate
- Sustained increase: 2x baseline for > 2 hours

**Output**: Rate analysis with anomaly detection

---

### Step 7: Compile Analysis Report

**Actions**:
- Aggregate findings from all previous steps
- Create executive summary (3-5 bullet points)
- List top 10 most frequent issues
- Highlight any critical or high-severity items
- Provide trend analysis (improving/stable/degrading)
- Include statistics summary

**Report structure**:
```
LOG ANALYSIS REPORT
Generated: [timestamp]
Analysis period: Last 24 hours

EXECUTIVE SUMMARY:
- [Key finding 1]
- [Key finding 2]
- [Key finding 3]

STATISTICS:
- Total errors: N
- Total warnings: M
- Unique error patterns: X
- Critical issues: Y
- Anomalies detected: Z

TOP ISSUES (by frequency):
1. [Error pattern 1] - X occurrences - [severity]
2. [Error pattern 2] - Y occurrences - [severity]
...

CRITICAL FINDINGS:
[List any critical issues requiring immediate attention]

ANOMALIES:
[List any rate spikes or unusual patterns]

TREND ANALYSIS:
Current state vs 7-day baseline: [IMPROVING/STABLE/DEGRADING]
Error rate trend: [↑↓→]
Warning rate trend: [↑↓→]

RECOMMENDATIONS:
1. [Recommendation 1]
2. [Recommendation 2]
...
```

**Output**: Comprehensive log analysis report

---

### Step 8: Save to Memory

**Actions**:
- Save full analysis report to memory
- Tag with timestamp
- Link to raw log excerpts for reference
- Update historical trend data
- Archive previous reports (keep last 30 days)

**Memory structure**:
```
log_analysis/
  latest/
    timestamp: [ISO 8601]
    period: "24 hours"
    total_errors: N
    total_warnings: M
    critical_count: X
    report: [full report]
  history/
    [date-1]/
    [date-2]/
    ...
  trends/
    error_rate_7d: [array]
    warning_rate_7d: [array]
    critical_issues_30d: [array]
```

**Output**: Analysis saved to persistent memory

---

### Step 9: Report Critical Findings to Henry

**Alert Henry if**:
- Any CRITICAL severity issues found
- Error rate spike > 3x baseline
- New error patterns not seen before
- Multiple HIGH severity issues
- Trend is DEGRADING

**Do NOT alert if**:
- Only LOW/INFO level items
- No anomalies detected
- Trend is STABLE or IMPROVING
- All issues are known and tracked

**Alert format**:
```
TO: Henry
FROM: Watcher
SUBJECT: Log Analysis - [CRITICAL/WARNING] Findings

Analysis Period: Last 24 hours
Timestamp: [ISO 8601]

Critical Findings:
- [Critical issue 1]
- [Critical issue 2]

Statistics:
- Errors: N (baseline: M, [+X%/-Y%])
- Warnings: P (baseline: Q, [+X%/-Y%])
- New error patterns: R
- Anomaly count: S

Top 3 Issues:
1. [Issue 1] - X occurrences
2. [Issue 2] - Y occurrences
3. [Issue 3] - Z occurrences

Trend: [IMPROVING/STABLE/DEGRADING]

Immediate Actions Needed:
1. [Action 1]
2. [Action 2]

Full report available in Watcher memory at: log_analysis/latest/
```

**Output**: Alert sent if criteria met

---

### Step 10: Cleanup

**Commands**:
```bash
# Remove temporary log files
rm -f /tmp/openclaw-systemd-24h.log
rm -f /tmp/system-errors-24h.log
rm -f /tmp/system-warnings-24h.log
rm -f /tmp/errors.log
rm -f /tmp/warnings.log
```

**Actions**:
- Clean up temporary files
- Verify cleanup completed
- Free disk space used during analysis

**Output**: Cleanup confirmation

---

## Usage Scenarios

**Scheduled runs**:
- Daily at 6:30 AM (after daily health check)
- Weekly deep analysis Sunday 4:30 AM (after session cleanup)

**On-demand runs**:
- When investigating reported issues
- After system updates or deployments
- Following unusual events or alerts
- When requested by Henry or human operators

**Integration with other skills**:
- Run after health-check if issues detected
- Triggered automatically by heartbeat anomalies
- Part of incident response workflow

## Success Criteria

- All logs successfully collected and analyzed
- Patterns and anomalies accurately detected
- Severity levels correctly assigned
- Report generated and saved to memory
- Appropriate alerting based on findings
- Execution completes within time limit
- No excessive resource consumption during analysis
