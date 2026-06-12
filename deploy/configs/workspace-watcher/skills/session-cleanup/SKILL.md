# SKILL — Session Cleanup

## Purpose

Perform weekly maintenance to archive old sessions, clean temporary files, and recover disk space. This ensures the system maintains optimal performance and doesn't run out of storage due to accumulated session data.

> [!IMPORTANT]
> The target directories for cleanup are located under the user home directory (`/home/clawuser/.openclaw/agents/`) and temporary directories (`/tmp/openclaw` and `/tmp/openclaw-1000`).
> The directory `/var/lib/openclaw/` does **not** exist in this system and is **not** used. Do not attempt to check or clean `/var/lib/openclaw/`.
> You run as `clawuser` and do **not** have `sudo` privileges. Do not run any commands using `sudo`.


## Schedule

**Primary**: Every Sunday at 4:00 AM
**Backup**: Can be triggered manually if needed

## Execution Time

Estimated: 1-2 minutes

## Steps

### Step 1: Run the Cleanup Script

Run the pre-configured local cleanup script in your workspace:
```bash
bash cleanup.sh
```

### Step 2: Parse and Log Results

- Read and parse the stdout output of `bash cleanup.sh`.
- Compile a comprehensive cleanup report in Markdown structure.
- Save the report to a log file or your memory.
- Pipe the report to `/usr/local/bin/portal-post` to submit it to the portal.

## Success Criteria

- `bash cleanup.sh` runs successfully.
- Report successfully compiled and posted to `/usr/local/bin/portal-post`.
