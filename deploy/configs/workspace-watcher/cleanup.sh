#!/bin/bash
# Pre-cleanup assessment
DISK_BEFORE=$(df -h / | awk 'NR==2 {print $3}')
echo "Pre-cleanup assessment done."

# Archive sessions older than 7 days
mkdir -p /home/clawuser/.openclaw/archives/sessions/
ARCHIVED_COUNT=0
find /home/clawuser/.openclaw/agents/*/sessions -type d -name "session-*" -mtime +7 2>/dev/null | while read session; do
  session_name=$(basename "$session")
  archive_date=$(date +%Y-%m-%d)
  tar -czf "/home/clawuser/.openclaw/archives/sessions/${session_name}_${archive_date}.tar.gz" -C "$(dirname "$session")" "$session_name" 2>/dev/null
  if [ $? -eq 0 ]; then
     # verify archive
     if tar -tzf "/home/clawuser/.openclaw/archives/sessions/${session_name}_${archive_date}.tar.gz" >/dev/null 2>&1; then
        rm -rf "$session"
        ((ARCHIVED_COUNT++))
     fi
  fi
done
echo "Sessions archived and deleted: $ARCHIVED_COUNT"

# Clean trajectory and main session files
find /home/clawuser/.openclaw/agents/*/sessions -name '*.trajectory.jsonl' -mmin +120 -delete 2>/dev/null
find /home/clawuser/.openclaw/agents/*/sessions -name '*.jsonl' ! -name '*.trajectory.jsonl' -mmin +480 2>/dev/null | while read f; do
    [ ! -f "${f}.lock" ] && rm -f "$f"
done

# Clean temp files
find /tmp/openclaw/ -type f -mtime +1 -delete 2>/dev/null
find /tmp/openclaw/ -type d -empty -delete 2>/dev/null
find /tmp/openclaw-1000/ -type f -mtime +1 -delete 2>/dev/null
find /tmp/openclaw-1000/ -type d -empty -delete 2>/dev/null
find /tmp/ -name "openclaw-*" -mtime +1 -delete 2>/dev/null
find /tmp/ -name "*.log" -mtime +7 -delete 2>/dev/null

# Clean archives older than 90 days
find /home/clawuser/.openclaw/archives/sessions/ -name "*.tar.gz" -mtime +90 -delete 2>/dev/null

# Post-cleanup metrics
DISK_AFTER=$(df -h / | awk 'NR==2 {print $3}')
echo "Storage metrics:"
echo "- Disk space before: $DISK_BEFORE used"
echo "- Disk space after: $DISK_AFTER used"
