#!/bin/bash
# Prune old OpenClaw session files to prevent V8 heap OOM.
# Trajectory files: delete after 2 hours (execution traces, not needed for resume)
find /home/clawuser/.openclaw/agents/*/sessions   -name '*.trajectory.jsonl' -mmin +120   -print -delete

# Main session files: delete after 8 hours if not locked
find /home/clawuser/.openclaw/agents/*/sessions   -name '*.jsonl' ! -name '*.trajectory.jsonl'   -mmin +480 | while read f; do
    [ ! -f "${f}.lock" ] && rm -f "$f"
done
