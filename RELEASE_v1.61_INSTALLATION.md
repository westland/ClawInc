# DermaArtIA v1.61 Patch Release & Installation Guide

This document outlines the upgrade and installation steps to deploy **DermaArtIA v1.61** on your cloud server.

DermaArtIA v1.61 is a maintenance patch that addresses false alert warnings and blocked maintenance tasks encountered by the system watcher agent.

## Key Updates in v1.61

1. **Resolved Watcher Permission Blocks**:
   - Instructed the Watcher agent (`SOUL.md`) regarding its non-sudo `clawuser` context.
   - Configured service status checks to run via standard user `systemctl is-active` queries instead of `sudo systemctl status`, avoiding authorization password prompts.

2. **Fixed Session Cleanup Path Constraints**:
   - Outlined correct server workspace folder layouts in the Watcher's identity.
   - Prevented incorrect checks to `/var/lib/openclaw/` (since OpenClaw runs strictly inside the user's home directory `/home/clawuser/.openclaw/`).

3. **Ensured Temporary Space Existence**:
   - Configured and pre-created `/tmp/openclaw` and `/tmp/openclaw-1000` directories with open permissions (`777` / owned by `clawuser`) on the remote server, preventing "No such file or directory" exceptions.

4. **Ignored Expected HTTP 401 Unauthorized Codes**:
   - Re-engineered the Python health check script in `SKILL.md` to check local web gateways (Nginx on port 80 and FastAPI on port 8000).
   - Configured it to treat HTTP 401 Unauthorized as a successful confirmation of service availability, resolving false error alerts on portal IPs.

---

## 1. Pull the Latest Repository Code

Connect to your server via SSH and navigate to your git clone directory (default: `/root/DermaArtIA`). Pull the v1.61 updates:
```bash
cd /root/DermaArtIA
git pull origin main
```

---

## 2. Run the Deployment Script

Deploy the new configs, templates, and agent skills:
```bash
# Make the deployment scripts executable
chmod +x /root/DermaArtIA/deploy/deploy-openclaw.sh

# Run the deployment using your existing API credentials
export NON_INTERACTIVE=1
export SERVER_IP="YOUR_DROPLET_IP"
export GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
export PORTAL_REPORTS_URL="http://127.0.0.1:8000/api/reports/submit"
export DISCORD_WEBHOOK_URL="http://127.0.0.1:8000/api/reports/submit"
/root/DermaArtIA/deploy/deploy-openclaw.sh
```

---

## 3. Restart and Verify Services

1. Restart the OpenClaw agent gateway and the portal API:
   ```bash
   systemctl restart openclaw
   systemctl restart dermaart-portal
   ```
2. Verify that the scheduled jobs run successfully without errors:
   ```bash
   su - clawuser -c 'openclaw cron run health-check-main'
   su - clawuser -c 'openclaw cron run session-cleanup-hourly'
   ```
3. Check the latest log reports in Watcher's workspace or reports database.

---
*Copyright © 2026 J. Christopher Westland, all rights reserved · v1.61*
