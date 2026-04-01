# SKILL — Session Cleanup

## Purpose

Perform weekly maintenance to archive old sessions, clean temporary files, and recover disk space. This ensures the system maintains optimal performance and doesn't run out of storage due to accumulated session data.

## Schedule

**Primary**: Every Sunday at 4:00 AM
**Backup**: Can be triggered manually if needed

## Execution Time

Estimated: 5-15 minutes (depending on data volume)

## Steps

### Step 1: Pre-Cleanup Assessment

**Commands**:
```bash
# Check current disk usage
df -h / > /tmp/disk-before.txt

# Check session directory size
du -sh /var/lib/openclaw/sessions/

# Check temp directory size
du -sh /tmp/openclaw/

# Count sessions
find /var/lib/openclaw/sessions/ -type d -name "session-*" | wc -l
```

**Actions**:
- Record baseline disk usage
- Calculate total session data size
- Count total sessions
- Identify available disk space
- Verify sufficient space for compression operations

**Output**: Pre-cleanup metrics

---

### Step 2: Identify Sessions Older Than 7 Days

**Commands**:
```bash
# Find sessions older than 7 days
find /var/lib/openclaw/sessions/ -type d -name "session-*" -mtime +7

# Count old sessions
find /var/lib/openclaw/sessions/ -type d -name "session-*" -mtime +7 | wc -l

# Calculate total size of old sessions
find /var/lib/openclaw/sessions/ -type d -name "session-*" -mtime +7 -exec du -sh {} \; | \
  awk '{sum+=$1} END {print sum}'
```

**Actions**:
- List all sessions with modification time > 7 days
- Count sessions eligible for archival
- Calculate total size to be archived
- Verify sessions are inactive (no recent access)
- Create list of sessions to archive

**Safety check**:
- Do NOT archive sessions modified in last 7 days
- Do NOT archive sessions currently in use by agents
- Verify session lock files are not present

**Output**: List of sessions to archive with metadata

---

### Step 3: Archive Session Data

**Commands**:
```bash
# Create archive directory if it doesn't exist
mkdir -p /var/lib/openclaw/archives/sessions/

# Archive each old session
find /var/lib/openclaw/sessions/ -type d -name "session-*" -mtime +7 | while read session; do
  session_name=$(basename "$session")
  archive_date=$(date +%Y-%m-%d)
  tar -czf "/var/lib/openclaw/archives/sessions/${session_name}_${archive_date}.tar.gz" \
    -C "$(dirname "$session")" "$session_name"
done
```

**Actions**:
- Create archive directory structure
- Compress each old session using gzip
- Name archives with session ID and archival date
- Verify each archive created successfully
- Check archive integrity: `tar -tzf archive.tar.gz > /dev/null`

**Archive naming convention**:
```
session-[ID]_[YYYY-MM-DD].tar.gz
```

**Compression parameters**:
- Use gzip compression (good balance of speed and ratio)
- Compression level: default (-6)
- Preserve permissions and timestamps

**Safety measures**:
- Verify archive created before deleting original
- Check archive is not empty (size > 0)
- Verify archive is readable

**Output**: Compressed archives in archive directory

---

### Step 4: Verify Archives

**Commands**:
```bash
# List created archives
ls -lh /var/lib/openclaw/archives/sessions/

# Test each archive integrity
find /var/lib/openclaw/archives/sessions/ -name "*.tar.gz" -mtime -1 | while read archive; do
  echo "Testing: $archive"
  tar -tzf "$archive" > /dev/null && echo "OK" || echo "FAILED: $archive"
done
```

**Actions**:
- List all newly created archives
- Test archive integrity (can be extracted)
- Verify file count matches original session
- Check archive size is reasonable (not 0 bytes)
- Log any archive failures

**Verification criteria**:
- Archive file exists
- Archive size > 1KB
- Archive can be listed with tar -tzf
- No errors during integrity check

**Failure handling**:
- If archive verification fails, do NOT delete original session
- Log failure details
- Alert Henry about failed archival
- Skip deletion for that session

**Output**: Verification results for each archive

---

### Step 5: Delete Archived Sessions

**Commands**:
```bash
# Only delete sessions that were successfully archived
find /var/lib/openclaw/archives/sessions/ -name "*.tar.gz" -mtime -1 | while read archive; do
  session_name=$(basename "$archive" | sed 's/_[0-9-]*\.tar\.gz$//')
  session_path="/var/lib/openclaw/sessions/$session_name"

  if [ -d "$session_path" ]; then
    echo "Deleting: $session_path"
    rm -rf "$session_path"
  fi
done
```

**Actions**:
- For each verified archive, delete the original session directory
- Use rm -rf to remove directory and all contents
- Log each deletion
- Count successful deletions

**Safety measures**:
- Double-check archive exists before deleting original
- Only delete if archive verification passed in Step 4
- Never delete sessions modified in last 7 days (extra safety check)

**Output**: List of deleted session directories

---

### Step 6: Clean Temporary Files

**Commands**:
```bash
# Clean OpenClaw temp directory
find /tmp/openclaw/ -type f -mtime +1 -delete
find /tmp/openclaw/ -type d -empty -delete

# Clean system temp files related to OpenClaw
find /tmp/ -name "openclaw-*" -mtime +1 -delete

# Clean log temp files
find /tmp/ -name "*.log" -mtime +7 -delete
```

**Actions**:
- Delete temporary files older than 1 day from /tmp/openclaw/
- Delete temporary log files older than 7 days
- Remove empty directories
- Clean any orphaned temp files

**Safety measures**:
- Only delete files in /tmp/openclaw/ or with openclaw prefix
- Preserve files modified in last 24 hours
- Do not delete system temp directories

**Output**: Count of temporary files deleted

---

### Step 7: Clean Old Archives

**Commands**:
```bash
# Delete archives older than 90 days
find /var/lib/openclaw/archives/sessions/ -name "*.tar.gz" -mtime +90 -delete

# Count remaining archives
find /var/lib/openclaw/archives/sessions/ -name "*.tar.gz" | wc -l
```

**Actions**:
- Delete session archives older than 90 days
- These are beyond retention period
- Log deleted archive count
- Free up additional disk space

**Retention policy**:
- Active sessions: 7 days
- Archived sessions: 90 days
- Total retention: 97 days

**Output**: Count of old archives deleted

---

### Step 8: Post-Cleanup Assessment

**Commands**:
```bash
# Check disk usage after cleanup
df -h / > /tmp/disk-after.txt

# Compare before and after
diff /tmp/disk-before.txt /tmp/disk-after.txt

# Calculate space recovered
# (Parse before/after disk usage and compute difference)

# Count remaining sessions
find /var/lib/openclaw/sessions/ -type d -name "session-*" | wc -l
```

**Actions**:
- Record post-cleanup disk usage
- Calculate space recovered
- Count remaining active sessions
- Verify disk usage decreased
- Calculate cleanup effectiveness percentage

**Output**: Storage metrics comparison

---

### Step 9: Calculate Space Recovered

**Actions**:
- Parse "disk-before.txt" for used space
- Parse "disk-after.txt" for used space
- Calculate difference in GB or MB
- Calculate percentage of disk space recovered
- Verify space was actually freed

**Calculation**:
```
space_recovered = disk_used_before - disk_used_after
recovery_percent = (space_recovered / disk_used_before) * 100
```

**Expected results**:
- Should recover at least 100MB per week
- Recovery percentage varies based on activity

**Output**: Space recovery metrics

---

### Step 10: Log Cleanup Results

**Actions**:
- Compile comprehensive cleanup report
- Include all metrics from previous steps
- Log success/failure status
- Record any errors or warnings
- Save to memory with timestamp

**Report structure**:
```
SESSION CLEANUP REPORT
Executed: [timestamp]
Duration: [execution time]
Status: [SUCCESS/PARTIAL/FAILED]

SESSIONS:
- Sessions archived: N
- Sessions deleted: M
- Archives created: X
- Archive verification: Y passed, Z failed

TEMPORARY FILES:
- Temp files deleted: P
- Old archives removed: Q

STORAGE RECOVERED:
- Disk space before: X.XX GB used
- Disk space after: Y.YY GB used
- Space recovered: Z.ZZ GB (W.W%)
- Remaining sessions: R active

ERRORS:
[List any errors or warnings]

NEXT CLEANUP: [Next Sunday at 4:00 AM]
```

**Output**: Cleanup report saved to memory

---

### Step 11: Notify Henry

**Alert format**:
```
TO: Henry
FROM: Watcher
SUBJECT: Weekly Session Cleanup - [SUCCESS/ISSUES]

Cleanup completed: [timestamp]
Execution time: X minutes

Summary:
- Sessions archived: N
- Space recovered: X.XX GB (Y.Y%)
- Status: [SUCCESS/PARTIAL/FAILED]

Before: Z.ZZ GB used (AA%)
After: W.WW GB used (BB%)
Recovered: X.XX GB

[If issues] Issues encountered:
- [Issue 1]
- [Issue 2]

Active sessions remaining: R
Next cleanup: [Next Sunday 4:00 AM]
```

**Alert conditions**:
- ALWAYS notify Henry after cleanup (even if successful)
- This is a scheduled maintenance notification
- Use SUBJECT line to indicate success or issues

**Output**: Notification sent to Henry

---

### Step 12: Cleanup Temporary Files

**Commands**:
```bash
# Remove assessment temp files
rm -f /tmp/disk-before.txt /tmp/disk-after.txt

# Verify cleanup
ls /tmp/disk-*.txt 2>/dev/null || echo "Cleanup complete"
```

**Actions**:
- Remove temporary files created during cleanup process
- Verify all temp files are deleted
- Leave no trace of cleanup artifacts

**Output**: Cleanup artifacts removed

---

## Safety Protocols

**Pre-execution checks**:
- Verify sufficient disk space for compression (at least 500MB free)
- Check no critical processes are using sessions to be archived
- Verify archive directory is writable

**During execution**:
- Never delete without successful archive verification
- Log all operations
- Maintain transaction log in case of rollback needed

**Error handling**:
- If compression fails, skip that session and continue
- If verification fails, do NOT delete original
- If disk space runs out, abort and alert
- Log all failures for investigation

**Rollback procedure** (if needed):
- Archives can be extracted to restore sessions
- Command: `tar -xzf archive.tar.gz -C /var/lib/openclaw/sessions/`

## Success Criteria

- All old sessions successfully archived and verified
- Original sessions deleted only after archive verification
- Temporary files cleaned up
- Disk space recovered (measurable improvement)
- No data loss
- Complete report generated and logged
- Henry notified of results
- Execution completed within time limit (< 15 minutes)

## Failure Scenarios

**Partial failure** (some sessions failed to archive):
- Continue with successful archives
- Log failures
- Alert Henry with details
- Retry failed sessions next week

**Complete failure** (cannot create archives):
- Abort cleanup
- Do NOT delete any sessions
- Alert Henry immediately with CRITICAL severity
- Investigate disk space or permission issues

**Recovery procedure**:
- If sessions accidentally deleted, restore from archives
- Human intervention may be required for complex failures
